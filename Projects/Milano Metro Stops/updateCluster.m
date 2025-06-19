function cluster = updateCluster(cluster, next, stazioni, domanda, s)
    currentN = numel(cluster.Customers);
    previousN = currentN - s;

    % Aggiorna il centro del cluster (coordinate medie delle stazioni)
    newX = (cluster.Center(1) * previousN + s * stazioni(next,1)) / (currentN);
    newY = (cluster.Center(2) * previousN + s * stazioni(next,2)) / (currentN);
    cluster.Center = [newX, newY];

    % Aggiorna la domanda totale (numero di passeggeri)
    cluster.Demand = cluster.Demand + s * domanda(next);
end
