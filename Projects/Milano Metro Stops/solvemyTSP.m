function TSPsolution = solvemyTSP(tsp)
    % Risolve il TSP convertendolo in QUBO e usando Tabu Search
    n = numel(tsp.Customers);
    
    if n < 3
        TSPsolution.Route = 1:n;
        TSPsolution.Customers = tsp.Customers;
        TSPsolution.QuboFval = tsp.CostMatrix(1, 2) + tsp.CostMatrix(2, 1);
        return
    end
    
    % Risolvi con Tabu Search
    TSPsol = solveTSPwithTabu(tsp.CostMatrix);
    
    % Converti la soluzione in un percorso
    TSPsolution.Route = convertSolutionToRoute(TSPsol);
    TSPsolution.QuboFval = TSPsol.BestFunctionValue;
    TSPsolution.Customers = tsp.Customers;
end
