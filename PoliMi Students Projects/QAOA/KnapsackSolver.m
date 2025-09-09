% KnapsackSolver Class
% ====================
% A MATLAB class for solving the 0/1 Multi-Knapsack Problem using QUBO (Quadratic Unconstrained Binary Optimization) 
% and other optimization techniques such as MILP (Mixed Integer Linear Programming) and QAOA (Quantum Approximate Optimization Algorithm).
%
% Methods:
% --------
% - KnapsackSolver: Constructor to initialize the KnapsackSolver object with problem parameters.
% - create_ising_model: Creates the Ising model representation of the problem.
% - solve_milp: Solves the multi-knapsack problem using MILP (Mixed Integer Linear Programming).
% - solve_tabu: Solves the QUBO problem using MATLAB's Tabu search algorithm.
% - solve_native_qaoa: Solves the QUBO problem using MATLAB's native QAOA implementation.
% - solveQAOA: Solves the QUBO problem using a custom QAOA solver.
% - qubo_multi_knapsack_linear_formulation: Generates the QUBO formulation for the multi-knapsack problem using linear slack bits.
% - qubo_single_knapsack_linear_formulation: Generates the QUBO formulation for a single knapsack problem using linear slack bits.
% - display_solution: Displays the solution in a readable format.
% - interpret_solution: Interprets the binary solution vector into knapsack assignments and slack values.
% - verify_solution: Verifies the feasibility and optimality of a solution.
%
% Usage:
% ------
% 1. Create an instance of the KnapsackSolver class by providing the required parameters.
% 2. Use one of the solver methods (e.g., solve_milp, solve_tabu, solve_native_qaoa) to solve the problem.
% 3. Display or verify the solution using the display_solution or verify_solution methods.

classdef KnapsackSolver < handle

    properties
        article_value       % Value matrix (m × n)
        article_weight      % Weight array (1 × n)
        knapsack_capacity   % Capacity array (1 × m)
        single_penalty      % Penalty for having an item in multiple knapsacks
        capacity_penalty    % Penalty for exceeding any knapsack capacity
        objective_weight    % Weight for objective function (explore for an optimal solution)
        formulation         % 'Binary' or 'Linear'

        n_layers            % Number of QAOA layers
        init_type           % Pparameters initialization strategy: 'rand', 'ramp', 'custom'
        mixer_hamiltonian   % Mixer Type: 'x', 'xy'
        custom_params       % Custom parameters [gamma1, ... gamman; beta1, ... betan]
        
        H_capacity          % Capacity constraint portion of Hamiltonian
        H_single            % Single assignment portion of Hamiltonian
        H_obj               % Objective function portion of Hamiltonian
        
        number_of_knapsacks % Number of knapsacks (m)
        number_of_articles  % Number of items (n)
        
        H                   % Full Hamiltonian matrix
        offset              % Constant offset
        
        variables           % Variable names
        num_qubits          % Total number of qubits/variables
    end
    
    methods
        function obj = KnapsackSolver(article_value, article_weight, knapsack_capacity, formulation, ...
                                 single_penalty, capacity_penalty, objective_weight, n_layers, init_type, mixer_hamiltonian, custom_params)

            obj.article_value = article_value;
            obj.article_weight = article_weight;
            obj.knapsack_capacity = knapsack_capacity;

            obj.number_of_knapsacks = length(obj.knapsack_capacity);
            obj.number_of_articles = length(obj.article_weight);

            obj.single_penalty = single_penalty;
            obj.capacity_penalty = ones(1, obj.number_of_knapsacks) * capacity_penalty;
            obj.objective_weight = ones(1, obj.number_of_knapsacks) * objective_weight;
            obj.formulation = formulation;
            obj.n_layers = n_layers;
            obj.init_type = init_type;
            obj.mixer_hamiltonian = mixer_hamiltonian;

            if nargin >= 11 && ~isempty(custom_params)
                obj.custom_params = custom_params;
            else
                obj.custom_params = [];
            end
            
            obj.H_capacity = 0;
            obj.H_single = 0;
            obj.H_obj = 0;
      
            [obj.H, obj.offset] = obj.create_ising_model();
        end
        
        function [H, offset] = create_ising_model(obj)
            % Create binary variables for item-knapsack assignments and slack bits
            x_vars = {};
            var_count = 1;
            
            % Item variables: x_i_j (item j in knapsack i)
            for i = 1:obj.number_of_knapsacks
                for j = 1:obj.number_of_articles
                    x_vars{end+1} = sprintf('x_%d_%d', i-1, j-1);
                    var_count = var_count + 1;
                end
            end
            
            % Slack variables: y_i_b (slack bit b for knapsack i)
            y_vars = {};
            for i = 1:obj.number_of_knapsacks
                if strcmp(obj.formulation, 'Binary')
                    num_slack_bits = length(dec2bin(obj.knapsack_capacity(i))) - 1;
                elseif strcmp(obj.formulation, 'Linear')
                    num_slack_bits = obj.knapsack_capacity(i);
                else
                    error('Unknown formulation: %s', obj.formulation);
                end
                
                for b = 1:num_slack_bits
                    y_vars{end+1} = sprintf('y_%d_%d', i-1, b-1);
                    var_count = var_count + 1;
                end
            end
            
            % Total number of variables
            obj.variables = [x_vars, y_vars];
            obj.num_qubits = length(obj.variables);
            
            [H, offset] = obj.qubo_multi_knapsack_linear_formulation();                               
        end

        function sol = solve_milp(obj)
            % Solve the multi-knapsack problem using MILP
            
            % Extract parameters from object
            m = obj.number_of_knapsacks;
            n = obj.number_of_articles;
            values = obj.article_value;
            weights = obj.article_weight;
            capacities = obj.knapsack_capacity;
            
            % MILP Formulation ===============================================
            % Decision variables: x(i,j) = 1 if item j assigned to knapsack i
            % Create linear indices for mapping (i,j) to flat index
            idx = @(i,j) (i-1)*n + j;
            
            % Objective: Maximize total value (convert to minimization for intlinprog)
            f = zeros(m*n, 1);
            for i = 1:m
                for j = 1:n
                    f(idx(i,j)) = -values(i,j); % Negative because intlinprog minimizes
                end
            end
            
            % Constraint matrices
            A_ineq = []; b_ineq = [];
            
            % 1. Capacity constraints for each knapsack
            A_cap = zeros(m, m*n);
            for i = 1:m
                for j = 1:n
                    A_cap(i, idx(i,j)) = weights(j);
                end
                b_cap(i) = capacities(i);
            end
            
            % 2. Each item assigned to at most one knapsack
            A_assign = zeros(n, m*n);
            for j = 1:n
                for i = 1:m
                    A_assign(j, idx(i,j)) = 1;
                end
                b_assign(j) = 1;
            end
            
            % Combine all inequality constraints
            A_ineq = [A_cap; A_assign];
            b_ineq = [b_cap, b_assign]';
            
            % All variables are binary
            intcon = 1:(m*n);
            lb = zeros(m*n, 1);
            ub = ones(m*n, 1);
            
            % Solve MILP
            options = optimoptions('intlinprog', 'Display', 'iter');
            [x_sol, fval, exitflag, output] = intlinprog(f, intcon, A_ineq, b_ineq, [], [], lb, ub, options);
            
            % Check if a solution was found
            if isempty(x_sol) || exitflag <= 0
                error('MILP solver failed to find a solution. Exitflag: %d', exitflag);
            end
            
            % Reshape solution to match QUBO format
            x_binary = reshape(x_sol, [], 1);
            
            % Calculate slack variables for each knapsack
            y_binary = [];
            
            for i = 1:m
                % Calculate used capacity for this knapsack
                used_capacity = 0;
                for j = 1:n
                    if x_sol(idx(i,j)) > 0.5  % Threshold to handle numerical precision
                        used_capacity = used_capacity + weights(j);
                    end
                end
                
                % Calculate slack (unused capacity)
                slack = capacities(i) - used_capacity;
                
                % Encode slack variables based on formulation
                if strcmp(obj.formulation, 'Linear')
                    % Linear slack encoding
                    num_slack_bits = capacities(i);
                    yi = zeros(num_slack_bits, 1);
                    valid_slack = max(0, min(round(slack), num_slack_bits));
                    yi(1:valid_slack) = 1;
                    y_binary = [y_binary; yi];
                    
                elseif strcmp(obj.formulation, 'Binary')
                    % Binary slack encoding
                    num_slack_bits = length(dec2bin(capacities(i))) - 1;
                    % Convert slack to binary representation
                    binary_str = dec2bin(round(slack), num_slack_bits);
                    yi = zeros(num_slack_bits, 1);
                    for b = 1:num_slack_bits
                        if binary_str(b) == '1'
                            yi(b) = 1;
                        end
                    end
                    y_binary = [y_binary; yi];
                end
            end
            
            % Combine main variables and slack variables
            solution_vector = [x_binary; y_binary];
            
            % Create result structure compatible with QUBO solver output
            sol = struct();
            sol.BestX = solution_vector;
            sol.BestValue = -fval;  % Convert back from minimization to maximization
            sol.ExitFlag = exitflag;
            sol.Gap = output.relativegap;
            sol.ObjectiveValue = -fval;  % Same as BestValue
            sol.OptimalityInfo = sprintf('MILP solved with gap: %g', output.relativegap);
            
            % Add information about which items are assigned to which knapsacks
            sol.Assignments = cell(m, 1);
            for i = 1:m
                assigned_items = [];
                for j = 1:n
                    if x_sol(idx(i,j)) > 0.5
                        assigned_items = [assigned_items, j];
                    end
                end
                sol.Assignments{i} = assigned_items;
            end
            
            % Calculate total value and used capacity per knapsack
            sol.KnapsackValues = zeros(m, 1);
            sol.UsedCapacities = zeros(m, 1);
            
            for i = 1:m
                for j = 1:n
                    if x_sol(idx(i,j)) > 0.5
                        sol.KnapsackValues(i) = sol.KnapsackValues(i) + values(i,j);
                        sol.UsedCapacities(i) = sol.UsedCapacities(i) + weights(j);
                    end
                end
            end
            
            % Display summary if verbose
            fprintf('MILP Solution:\n');
            fprintf('Objective value: %.4f\n', -fval);
            fprintf('Relative gap: %.2e\n', output.relativegap);
            
            for i = 1:m
                fprintf('Knapsack %d: %d/%d capacity used, value = %.2f\n', ...
                    i, sol.UsedCapacities(i), capacities(i), sol.KnapsackValues(i));
                fprintf('  Items: %s\n', mat2str(sol.Assignments{i}));
            end
        end

        function [sol] = solve_tabu(obj)
            % Solve the QUBO problem using Tabu search algorithm
    
            % Create a QUBO problem object
            qprob = qubo(obj.H);
            
            % Solve the QUBO problem
            sol = solve(qprob);
        end

        function [sol] = solve_native_qaoa(obj, numShots, maxIter)
            % Solve the QUBO problem using MATLAB's QAOA

            if nargin < 3 || isempty(maxIter)
                maxIter = 1e3;
            end

            opts = optimset(MaxIter = maxIter);

            qa = qaoa(NumLayer=obj.n_layers, NumShots=numShots, OptimizationSolverOption=opts);
           
            qprob = qubo(obj.H);

            sol = solve(qprob,Algorithm=qa);
        
        end

        function [sol] = solveQAOA(obj, numShots, numIterations, optimizer)

            solver = QAOA(...
                    obj.H, ...
                    obj.n_layers, ...
                    obj.init_type, ...
                    obj.mixer_hamiltonian, ...
                    numShots, ...
                    numIterations, ...
                    optimizer, ...
                    'max' ...
                );

            sol = solver.solve();

        end
            
        function [q, offset] = qubo_multi_knapsack_linear_formulation(obj, c_min)
            % QUBO for multiple knapsack problem using linear slack bits

            m = obj.number_of_knapsacks; % Number of knapsacks (m)
            n = obj.number_of_articles;  % Number of items (n)
            c_max = obj.knapsack_capacity; %Array with capacities for each knapsack. dim=m
            w = obj.article_weight;
            v = obj.article_value;
            A = obj.capacity_penalty; % A: array with penalties for overstepping capacity for each knapsack. dim=m
            B = obj.objective_weight; % B: array with penalties for not maximizing the total value. A > max(values)*B > 0 for each knapsack. dim=m
            P = obj.single_penalty;  % P: penalty for having one item in several knapsacks. Assumed to be the same for each item
        
            % number auxiliary variables y_ij per knapsack j
            if nargin < 2
                c_min = (c_max - max(w) + 1);
            end
        
            n_aux = zeros(1, m);
            for j = 1:m
                n_aux(j) = max(0, c_max(j) - c_min(j) + 1);
            end
        
            % total size of QUBO
            n_qubo = m * n + sum(n_aux);
        
            % initialize QUBO with 0
            q = zeros(n_qubo);
        
            % sizes of the single QUBOs
            q_size = n + n_aux;
        
            o = 0;
            % add single QUBOs for knapsacks j=1,m
            for j = 1:m
                [qs, ~] = obj.qubo_single_knapsack_linear_formulation(n, c_max(j), w, v(j,:), A(j), B(j), c_min(j));
                s = size(qs, 1);
                q(o+1:o+s, o+1:o+s) = qs;
                o = o + s;
            end
            
            % add cross-QUBO penalty elements (x_i_j, x_i_jp) -> q_l_lp
            % cumsum for index calculation (equivalent to sum(q_size[0:j]))
            q_size_cum = [0, cumsum(q_size)];
            
            for i = 1:n
                for j = 1:m
                    l = q_size_cum(j) + i;
                    for jp = (j+1):m
                        lp = q_size_cum(jp) + i;
                        q(l, lp) = P;
                    end
                end
            end
           
            % Calculate constant offset
            if n_aux(1) == 0
                offset = dot(A, c_max.^2);
            else
                offset = sum(A);
            end
        end

        function [q, offset] = qubo_single_knapsack_linear_formulation(obj, n, c_max, w, v, A, B, c_min)
            % QUBO for single knapsack problem using linear slack bits
      
            % Compute single qubo size
            if nargin < 7 || isempty(c_min)
                c_min = c_max - max(w) + 1;
            end
            
            n_aux = max(0, c_max - c_min + 1);
            n_qubo = n + n_aux;
           
            q = zeros(n_qubo);
            for i = 1:n
                % add cost elements (x_i, x_i)
                q(i, i) = q(i, i) - B * v(i);
                % add capacity penalty elements (x_i, x_i)
                q(i, i) = q(i, i) + A * w(i)^2;
                if n_aux == 0
                    q(i, i) = q(i, i) - 2 * A * c_max * w(i); % factor of 2 due to mixed quadratic term
                end
            end
        
            % add capacity penalty elements (x_i, x_ip)
            for i = 1:n
                for ip = (i+1):n
                    q(i, ip) = q(i, ip) + 2 * A * w(i) * w(ip); % factor of 2 due to summation over (i, ip): i < ip
                end
            end
        
            % add capacity penalty elements (y_k, y_k) -> q_i_i
            % transformation: i = n + k - c_min + 1 (adding 1 for MATLAB 1-based indexing)
            if n_aux > 0
                for k = c_min:c_max
                    i = n + k - c_min + 1;
                    q(i, i) = q(i, i) + A * (k^2 - 1);
                end
            end
        
            % add capacity penalty elements (y_k, y_kp) -> q_i_ip
            % transformation: i = n + k - c_min + 1
            %                 ip = n + kp - c_min + 1
            if n_aux > 0
                for k = c_min:c_max
                    i = n + k - c_min + 1;
                    for kp = (k+1):c_max
                        ip = n + kp - c_min + 1;
                        q(i, ip) = q(i, ip) + 2 * A * (k * kp + 1); % factor of 2 due to summation over (k, kp): k < kp
                    end
                end
            end
            
            % add capacity penalty elements (x_i, y_k) -> q_i_ip
            % transformation: ip = k + n - c_min + 1
            if n_aux > 0
                for i = 1:n
                    for k = c_min:c_max
                        ip = n + k - c_min + 1;
                        q(i, ip) = q(i, ip) - 2 * A * k * w(i); % factor of 2 due to mixed quadratic term
                    end
                end
            end
        
            % Calculate offset
            if n_aux == 0
                offset = A * c_max^2;
            else
                offset = A;
            end
        end

        function display_solution(obj, sol)
            % Display the solution in a readable format
            
            [knapsack_assignments, slack_values] = obj.interpret_solution(sol);
            
            fprintf('Solution for Multi-Knapsack Problem:\n');
            fprintf('----------------------------------\n');
            
            % Calculate total value and weight for each knapsack
            total_value = zeros(1, obj.number_of_knapsacks);
            total_weight = zeros(1, obj.number_of_knapsacks);
            
            for i = 1:obj.number_of_knapsacks
                fprintf('Knapsack %d (Capacity: %d):\n', i, obj.knapsack_capacity(i));
                fprintf('  Items: ');
                item_count = 0;
                
                for j = 1:obj.number_of_articles
                    if knapsack_assignments(i, j) == 1
                        fprintf('%d ', j);
                        total_value(i) = total_value(i) + obj.article_value(i, j);
                        total_weight(i) = total_weight(i) + obj.article_weight(j);
                        item_count = item_count + 1;
                    end
                end
                
                if item_count == 0
                    fprintf('None');
                end
                
                fprintf('\n  Total Weight: %d / %d\n', total_weight(i), obj.knapsack_capacity(i));
                fprintf('  Total Value: %d\n', total_value(i));
                fprintf('  Slack: %d\n\n', slack_values(i));
            end
            
            % Check if any items are unassigned
            all_assigned = sum(knapsack_assignments, 1);
            unassigned = find(all_assigned == 0);
            
            fprintf('Unassigned Items: ');
            if isempty(unassigned)
                fprintf('None\n');
            else
                fprintf('%s\n', num2str(unassigned));
            end
            
            fprintf('\nTotal Solution Value: %d\n', sum(total_value));
        end

        function [knapsack_assignments, slack_values] = interpret_solution(obj, sol)
            % Interpret the binary solution vector

            knapsack_assignments = zeros(obj.number_of_knapsacks, obj.number_of_articles);

            sol = sol.BestX;
            
            % Extract item assignments
            idx = 1;
            for i = 1:obj.number_of_knapsacks
                for j = 1:obj.number_of_articles
                    knapsack_assignments(i, j) = sol(idx);
                    idx = idx + 1;
                end
            end
            
            % Extract and interpret slack variables
            slack_values = zeros(1, obj.number_of_knapsacks);

            idx = 1;
           
            for i = 1:obj.number_of_knapsacks
                if strcmp(obj.formulation, 'Binary')
                    num_slack_bits = length(dec2bin(obj.knapsack_capacity(i))) - 1;
                    slack = 0;
                    for b = 1:num_slack_bits
                        slack = slack + 2^(b-1) * sol(idx);
                        idx = idx + 1;
                    end
                elseif strcmp(obj.formulation, 'Linear')
                    num_slack_bits = obj.knapsack_capacity(i);
                    slack = 0;
                    for b = 1:num_slack_bits
                        slack = slack + sol(idx);
                        idx = idx + 1;
                    end
                end
                slack_values(i) = slack;
            end
        end

        function [isFeasible, isOptimal, totalValue] = verify_solution(obj, sol, optimalValue)
            % Verify solution feasibility and optimality

            % Parse solution into assignments and slack values
            [knapsack_assignments, slack_values] = obj.interpret_solution(sol);

            %Structure of knapsack_assignments: n_knapsacks x n_items matrix
            
            % 1. Check single assignment constraint
            single_assignment = true;
            
            % Check if any item is assigned to multiple knapsacks
            for item = 1:obj.number_of_articles
                % Sum across all knapsacks for i-th item
                if sum(knapsack_assignments(:, item)) > 1
                    single_assignment = false;
                    break;
                end
            end
            
            % 2. Check capacity constraints
            capacity_constraints = true;
            for i = 1:obj.number_of_knapsacks
                total_weight = sum(obj.article_weight .* knapsack_assignments(i,:));
                         
                if total_weight > obj.knapsack_capacity(i)
                    capacity_constraints = false;
                    break;
                end
            end
            
            % 3. Value of the solution
            totalValue = sum(sum(obj.article_value .* knapsack_assignments));
            
            isFeasible = single_assignment && capacity_constraints;
            isOptimal = isFeasible && (abs(totalValue - optimalValue) < 1e-6);
        end
    end
end


