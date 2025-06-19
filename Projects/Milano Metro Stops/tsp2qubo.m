function QP = tsp2qubo(costMatrix)
    % Converti il problema del TSP in una matrice QUBO
    N = size(costMatrix, 1);
    
    % Vincoli per garantire che ogni città sia visitata una sola volta
    A = eye(N);
    B = ones(N);
    Q0 = kron(A, B);
    Q1 = kron(B, A);
    
    % Vincoli per la distanza tra città
    v = ones(N-1, 1);
    A2 = diag(v, 1);
    Q2 = kron(B, A2);
    C = kron(costMatrix, B);
    Q2 = Q2 .* C;
    
    % Matrice di costo simmetrica
    E = zeros(N);
    E(1, N) = 1;
    Q3 = kron(B, E);
    CP = kron(costMatrix', B);
    Q3 = Q3 .* CP;
    
    % Penalità per vincoli
    M = max(costMatrix(:));
    QN = sparse(M * (Q0 + Q1) * N^2 + Q2 + Q3);
    QN = (QN + QN.') / 2; % Simmetrizzazione
    
    % Termini costanti e lineari
    c = -4 * ones(N^2, 1) * M * N^2;
    d = 2 * N * M * N^2;

    QP = qubo(QN, c, d);
end
