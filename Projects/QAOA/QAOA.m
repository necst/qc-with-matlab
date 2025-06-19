classdef QAOA < handle
    % QAOASolver   Generic QAOA solver for QUBO optimization problems
    %   This class implements QAOA with classical parameter optimization and final
    %   circuit sampling. Use solve() to run the full workflow.

    properties
        H                   % QUBO matrix (Hamiltonian)
        n_layers            % Number of QAOA layers
        init_type           % 'rand', 'ramp', or 'custom'
        custom_params       % 2xN matrix of [gamma; beta] if init_type='custom'
        mixer_hamiltonian   % 'x' or 'xy'
        numShots            % Number of measurement shots per circuit
        numIterations       % Max function evaluations for optimizer
        N                   % Number of qubits
        optimizer           % Classical Global/Local Optimization Method for finding final Ansatz Params
        direction           % 'max' OR 'min' based on the problem instance
    end

    methods
        function obj = QAOA(H, n_layers, init_type, mixer_hamiltonian, numShots, numIterations, optimizer, direction, custom_params)
            % Constructor sets up the problem and algorithm parameters
            obj.H = H;
            obj.n_layers = n_layers;
            obj.init_type = lower(init_type);
            obj.mixer_hamiltonian = lower(mixer_hamiltonian);
            obj.numShots = numShots;
            obj.numIterations = numIterations;
            obj.N = size(H,1);
            obj.optimizer = lower(optimizer);
            obj.direction = lower(direction);

            if strcmp(obj.init_type, 'custom')
                if nargin < 9 || size(custom_params,1)~=2 || size(custom_params,2)~=n_layers
                    error('Provide custom_params as 2x%d matrix', n_layers);
                end
                obj.custom_params = custom_params;
            else
                obj.custom_params = [];
            end
        end

        function sol = solve(obj)
            % solve   Execute the full QAOA workflow
            %   Optimizes parameters and runs the final circuit to find the solution
            %   to the QUBO problem defined by obj.H
            
            % Extract QUBO terms
            [h, J] = obj.extract_qubo_terms();
            
            % Set up Optimization
            n_params = 2 * obj.n_layers;
            initial_params = obj.initialize_parameters();
            initial_params_vector = initial_params(:);
            
            % Set bounds for optimization
            lb = zeros(n_params, 1);
            ub = pi * ones(n_params, 1);
            
            % Define the objective function that calls the class method
            objfun = @(p) obj.optimizer_objective(p, h, J);

            % Negate energy for maximization problems
            if strcmp(obj.direction, 'max')
                objfun = @(p) -objfun(p); % Minimize -energy = Maximize energy
            end
            
            % Run appropriate optimization based on the selected method
            switch obj.optimizer
                case 'fminsearch'
                    options = optimset('MaxFunEvals', obj.numIterations, 'Display', 'iter');
                    [opt_params, best_energy] = fminsearch(objfun, initial_params_vector, options);
                    
                case 'fmincon'
                    options = optimoptions('fmincon', 'MaxFunctionEvaluations', obj.numIterations, 'Display', 'iter');
                    [opt_params, best_energy] = fmincon(objfun, initial_params_vector, [], [], [], [], lb, ub, [], options);
                    
                case 'surrogateopt'
                    options = optimoptions('surrogateopt', 'MaxFunctionEvaluations', obj.numIterations, 'Display', 'iter');
                    [opt_params, best_energy] = surrogateopt(objfun, lb, ub, options);
            end
            
            % Revert negation for maximization
            if strcmp(obj.direction, 'max')
                best_energy = -best_energy; % Original energy (maximization)
            end
            
            % Run with optimal parameters
            opt_params = reshape(opt_params, 2, obj.n_layers);
            circuit = obj.build_qaoa_circuit(h, J, opt_params);
            qc = quantumCircuit(circuit, obj.N, 'Name', 'QAOA_Optimal');
            
            % Plot final circuit
            qc.plot;
          
            % Final simulation with optimal parameters
            sim = simulate(qc);
            meas = randsample(sim, obj.numShots);
            
            % Convert all measured states to binary arrays
            states = char(meas.MeasuredStates) - '0';
            
            % Calculate energy for each measured state
            energies = zeros(size(states, 1), 1);
            for i = 1:size(states, 1)
                x = states(i, :)';
                energies(i) = x' * obj.H * x;
            end
            

          % Find the best state based on direction
            if strcmp(obj.direction, 'min')
                [best_energy, best_idx] = min(energies);
            else  % 'max'
                [best_energy, best_idx] = max(energies);
            end
            
            sol = struct();
            sol.BestX = states(best_idx, :)';
            sol.Energy = best_energy;
            sol.OptimalParameters = opt_params;
            sol.AllStates = states;
            sol.StateDistribution = [meas.MeasuredStates, meas.Counts];
            sol.circuit = qc;
        end
    end

    methods (Access = private)
        function energy = optimizer_objective(obj, p, h, J)
            % Reshape and build circuit
            params = reshape(p, 2, obj.n_layers);
            circuit = obj.build_qaoa_circuit(h, J, params);
            qc = quantumCircuit(circuit, obj.N, 'Name', 'QAOA_Iter');

            % Simulate and sample
            sim = simulate(qc);
            meas = randsample(sim, obj.numShots);
            states = char(meas.MeasuredStates) - '0';
            counts = meas.Counts;

            % Compute expected energy
            energies = sum((states * obj.H) .* states, 2);
            energy = sum(energies .* counts) / obj.numShots;
        end

        function [h, J] = extract_qubo_terms(obj)
            % Extract linear (h) and quadratic (J) terms from QUBO
            H_sym = (obj.H + obj.H') / 2; % Symmetrize first
            h = diag(H_sym);
            J = triu(H_sym, 1);
        end

        function params = initialize_parameters(obj)
            % Initialize parameters based on init_type
            switch obj.init_type
                case 'rand'
                    params = obj.random_initialization();
                case 'ramp'
                    params = obj.ramp_initialization();
                case 'custom'
                    params = obj.custom_params;
                otherwise
                    error('Unknown init_type: %s', obj.init_type);
            end
        end

        function params = random_initialization(obj)
            % Random gamma in [0,pi], beta in [0,pi/2]
            params = [pi * rand(1,obj.n_layers);
                      0.5*pi * rand(1,obj.n_layers)];
        end

        function params = ramp_initialization(obj)
            % Linear ramp inspired by QA
            gamma = linspace(0.8*pi,0.2*pi,obj.n_layers);
            beta  = linspace(0.2*pi,0.8*pi,obj.n_layers);
            params = [gamma; beta];
        end

        function circuit = build_qaoa_circuit(obj, h, J, params)
            % Construct QAOA circuit
            circuit = hGate(1:obj.N);
            for layer = 1:obj.n_layers
                circuit = obj.apply_cost_layer(circuit, h, J, params(1,layer));
                circuit = obj.apply_mixer_layer(circuit, params(2,layer));
            end
        end

        function circuit = apply_cost_layer(obj, circuit, h, J, gamma)
            % Apply RZ for linear and RZZ for quadratic terms
            for q = 1:obj.N
                circuit = [circuit; rzGate(q, 2*gamma*h(q))];
            end
            [I,Jc] = find(triu(J));
            for k = 1:length(I)
                i = I(k); j = Jc(k);
                circuit = [circuit; rzzGate(i,j, 2*gamma*J(i,j))];
            end
        end

        function circuit = apply_mixer_layer(obj, circuit, beta)
            % Apply chosen mixer
            switch obj.mixer_hamiltonian
                case 'x'
                    circuit = [circuit; rxGate(1:obj.N, 2*beta)];
                case 'xy'
                    for q = 1:obj.N
                        circuit = [circuit; rxGate(q, beta); ryGate(q, beta)];
                    end
                otherwise
                    error('Unknown mixer: %s', obj.mixer_hamiltonian);
            end
        end
    end
end