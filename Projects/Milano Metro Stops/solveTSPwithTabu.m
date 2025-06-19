function solution = solveTSPwithTabu(costMatrix)
    % Risoluzione del TSP con Tabu Search
    Q = tsp2qubo(costMatrix);
    x = solve(Q);

    validSolutions = checkTSPConstraints(x);
    it = 1;

    while (~validSolutions && it < 10)
        x = solve(Q);
        validSolutions = checkTSPConstraints(x);
        it = it + 1;
    end

    if ~validSolutions
        solution = [];
    else
        solution = x;
    end
end
