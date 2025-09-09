function Route = convertSolutionToRoute(sol)
    % Converte la soluzione QUBO in un percorso ordinato
    solution = sol.BestX;
    n = sqrt(numel(solution));
    selected_indices = find(solution);
    order = mod(selected_indices - 1, n) + 1;
    [~, node_order] = sort(order);
    nodes = 1:n;
    Route = nodes(node_order);
end