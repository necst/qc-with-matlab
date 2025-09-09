
function plotClusters(clusters, stazioni, Routes)
    figure;
    hold on;
    
    % Disegna il deposito (Duomo)
    scatter(0, 0, 100, "r", "filled");
    text(0, 0, "Depot", 'FontSize', 12, 'FontWeight', 'bold');
    
    % Disegna le fermate della metro con i relativi cluster
    for i = 1:numel(clusters)
        customers = clusters(i).Customers;
        scatter(stazioni(customers,1), stazioni(customers,2), 50, 'filled');
        text(stazioni(customers,1), stazioni(customers,2), num2str(customers'), 'FontSize', 10);
    end

    % Disegna i percorsi se forniti
    if nargin > 2
        for k = 1:numel(Routes)
            route = Routes{k};
            cu = [1, clusters(k).Customers]; % Aggiungi il deposito
            tr = cu(route); % Ordine delle fermate

            % Disegna le linee del percorso
            for j = 1:numel(tr) - 1
                plot(stazioni(tr(j:j+1),1), stazioni(tr(j:j+1),2), 'k');
            end
            plot(stazioni([tr(end), tr(1)],1), stazioni([tr(end), tr(1)],2), 'k');
        end
    end

    title("Cluster delle fermate metro");
    xlabel("Distanza (km)");
    ylabel("Distanza (km)");
    grid on;
    hold off;
end
