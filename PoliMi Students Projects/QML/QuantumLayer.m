classdef QuantumLayer < nnet.layer.Layer

    properties (Learnable)
        A1, B1, C1, D1      % firt gate
        A2, B2, C2, D2      % second gate
        A3, B3, C3, D3      % third gate

    end

    methods 
        function layer = QuantumLayer

            layer.Name = "Quantum Classification Layer";

            p = single( pi*(2*rand-1) * 0.1 );
            
            % twelve learnable rotation parameters for three gates per qubit
            layer.A1 = p; layer.B1 = p; layer.C1 = p; layer.D1 = p;     % parameters for first variational block
            layer.A2 = p; layer.B2 = p; layer.C2 = p; layer.D2 = p;     % parameters for second variational block
            layer.A3 = p; layer.B3 = p; layer.C3 = p; layer.D3 = p;     % parameters for third variational block
     
        end

        function Z = predict(layer,X)

            N  = size(double(X),2);
            Z = zeros(3, N, 'single');

            for k = 1:N
                x = X(:,k);
                qc = quantumCircuit(3);

                qc.Gates = [
                    rxGate(1, x(1)*layer.A1); rxGate(2, x(3)*layer.A2); rxGate(3, x(1)*layer.A3);
                    cxGate(1,2); cxGate(2,3); cxGate(3,1);

                    ryGate(1, x(2)*layer.B1); ryGate(2, x(4)*layer.B2); ryGate(3, x(4)*layer.B3);
                    cxGate(1,2); cxGate(2,3); cxGate(3,1);

                    rxGate(1, x(1)*layer.C1); rxGate(2, x(3)*layer.C2); rxGate(3, x(1)*layer.C3);
                    cxGate(1,2); cxGate(2,3); cxGate(3,1);

                    ryGate(1, x(2)*layer.D1); ryGate(2, x(4)*layer.D2); ryGate(3, x(4)*layer.D3);
                    cxGate(1,2); cxGate(2,3); cxGate(3,1);
                ];

                %plot(qc);

                st = simulate(qc);

                Z(:,k) = [
                    probability(st,1,"0") - probability(st,1,"1");
                    probability(st,2,"0") - probability(st,2,"1");
                    probability(st,3,"0") - probability(st,3,"1")];
            end
        end

        function [dLdX,dLdA1,dLdB1,dLdC1,dLdD1, ...
                    dLdA2,dLdB2,dLdC2,dLdD2, ...
                    dLdA3,dLdB3,dLdC3,dLdD3] ...
                    = backward(layer,X,~,dLdZ,~)
           
            Xin = double(X);

            s      = pi/4;
            parms  = ["A1","B1","C1","D1","A2","B2","C2","D2","A3","B3","C3","D3"];
            grads  = cast( zeros(1,12), 'like', layer.A1 );

            for p = 1:12
                name          = parms(p);

                layerPlus     = layer;  layerPlus.(name)  = layer.(name) + s;
                layerMinus    = layer;  layerMinus.(name) = layer.(name) - s;

                Zp = single(layerPlus.predict (Xin));
                Zm = single(layerMinus.predict(Xin));

                dZdP     = (Zp - Zm)/2;
                grads(p) = mean(dLdZ .* dZdP , "all");
            end

            dLdX = zeros(size(X),"like",X);

            dLdA1 = grads(1); dLdB1 = grads(2); dLdC1 = grads(3); dLdD1 = grads(4);

            dLdA2 = grads(5); dLdB2 = grads(6); dLdC2 = grads(7); dLdD2 = grads(8);

            dLdA3 = grads(9); dLdB3 = grads(10); dLdC3 = grads(11); dLdD3 = grads(12);
        end
    end
end

