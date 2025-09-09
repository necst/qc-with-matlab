function validSolutions = checkTSPConstraints(x)
    % Verifica che la soluzione del TSP rispetti i vincoli
    N = size(x.BestX, 1);
    n = sqrt(N);
    y = reshape(x.BestX, n, n);

    r = all(sum(y, 1) == 1);
    s = all(sum(y, 2) == 1);
    
    validSolutions = r && s;
end
