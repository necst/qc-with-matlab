function solution = solveOpenTSP(tsp)
    numNodes = size(tsp.CostMatrix, 1);
    
    % Imposta il nodo iniziale (deposito)
    startNode = 1;
    
    % Usa l'algoritmo nearest neighbor per trovare un percorso aperto
    visited = false(numNodes, 1);
    visited(startNode) = true;
    route = startNode;
    
    currentNode = startNode;
    
    while sum(visited) < numNodes
        % Trova il nodo più vicino non ancora visitato
        distances = tsp.CostMatrix(currentNode, :);
        distances(visited) = inf; % Esclude i nodi già visitati
        [~, nextNode] = min(distances);
        
        % Aggiorna il percorso
        route = [route, nextNode];
        visited(nextNode) = true;
        currentNode = nextNode;
    end
    
    % Salva la soluzione
    solution.Route = route;
    solution.Cost = sum(tsp.CostMatrix(sub2ind(size(tsp.CostMatrix), route(1:end-1), route(2:end))));
end
