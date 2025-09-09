% Matrice con coordinate e nomi delle fermate 

stazioni = [
   -0.00100412529410221000, 0.0029106531254612400000; % cordusio
   -0.00378174676700382000, 0.0070191622163804400000; % cairoli
   -0.00377627678319925000, 0.0134305292179615000000; % cadorna
   -0.00307064518040079000, 0.0229929816359213000000; % conciliazione
   -0.00384738645259830000, 0.0284761823517208000000; % pagano
   -0.00611737881219909000, 0.0340373801874403000000; % bonarotti
   -0.00913113102230056000, 0.0379840367426105000000; % amendola
   -0.01463313766529950000, 0.0447541907021201000000; % lotto
   -0.00252602090009901000, -0.0081939792271192900000; % san babila
   -0.01029082874950400000, -0.0164326386427192000000; % porta venezia
   -0.01575044301590370000, -0.0216498855407696000000; % lima
   -0.00853165845069981000, -0.0134594389526299000000; % palestro
   -0.00357100437999947000, 0.0339266898190402000000; % wagner
   -0.01378732725589770000, 0.0325524321035413000000; % tre torri
   -0.02061290131999980000, 0.0223642781730611000000; % geru
   -0.02142691536810300000, -0.0271680104542700000000; % loreto
   -0.02084502764670050000, -0.0198326397780999000000; % caiazzo
   -0.02022391485250100000, -0.0134710576509196000000; % centrale
   -0.02022391484550210000, -0.0059833102913593500000; % gioia
   -0.01306653883390400000, 0.0045730008837612200000; % moscova
   -0.00753166412500406000, 0.0065150102399105200000; % lanza
    0.00257912735689558000, 0.0160277484557305000000; % sant'ambrogio
    0.00608260083689771000, 0.0194726838083614000000; % sant'agostino
   -0.00215549650530278000, 0.0393475624661406000000; % de angeli
    0.01169175374690210000, 0.0195488397260206000000; % pta genova
    0.00383747882409580000, 0.0011054791463607200000; % missori
    0.00842003691679594000, -0.0064354380179398900000; % crocetta
    0.01291909346790020000, -0.0137457722096990000000; % porta romana
    0.01740053453099930000, -0.0204753789046794000000; % lodi
   -0.00578515490349929000, -0.0032295558218784500000; % montenapoleone
   -0.01008821236749920000, -0.0055212233723800400000; % turati
   -0.01412622704800270000, -0.0078028874706390600000; % republica
   -0.02519112925430280000, -0.0118537469419895000000; % sondrio
   -0.02783807256900420000, -0.0032261645612994300000; % zara
   -0.02313089964999900000, -0.0021415769681585300000; % isola
   -0.01902919247790180000, 0.0025097335274111300000; % garibaldi
   -0.02094626671129870000, 0.0082515307668806800000; % monumentale
   -0.02385393492020430000, 0.0171420845569106000000; % cenisio
   -0.01697117953629860000, 0.0270915627840616000000; % domodossola
   -0.01700211515250060000, 0.0387176715228499000000; % portello
    0.00900624078359868000, 0.0360846991773816000000; % bolivar
    0.00675284140069721000, 0.0292528630165911000000; % california
    0.00537944161879977000, 0.0244044632148110000000; % coni zugna
    0.00503202651550083000, 0.0121802306314009000000; % de amicis
    0.00737722561199661000, 0.0066044614681999300000; % vetra
    0.00810748716839527000, 0.0006382883199513860000; % santa sofia
    0.00571310721490192000, -0.0049675119601992900000; % sforza policlinico
   -0.00349833912780184000, -0.0193824269018492000000; % tricolore
];
%ora li convertiamo con i fattori di latitudine e longitudine,sapendo che
%un grado di latitudine corrisponde a 2pigreco*raggio dellaterra/360 mentre
%1 grado di longitudine è 2pigreco*raggiodellaterra*cos(56)/360. quindi
%otteniamo cosi la nostra matrice

stazioni=[stazioni(:,1)*111.2 stazioni(:,2)*111.2*cosd(56)]; 

%ora che abbiamo inizializato le stazioni generiamo un numero di user
%randomico per ciascuna di esse.
rng(1) % For reproducibility
numStazioni(1,:) = size(stazioni,1); 
deposito = [0 0]; % Deposito impostato a duomo
domanda = 100*randi([50,150],numStazioni,1);
sistema = [deposito;stazioni];

%disegnamo un grafico con le stazioni della metro, il numero di utenti e il
%deposito.

plot(deposito(:,1),deposito(:,2),"+",Color="r")
hold on;
plot(stazioni(:,1),stazioni(:,2),"*",Color="b")
text(sistema(:,1),sistema(:,2),["Depot"; num2str(domanda)]);
title("metro circonvallazione");
xlabel("km");
ylabel("km");

%ora definiamo il numero di corse giornaliere e il numero di persone che
%può contenere la metropolitana.

capienzaMetro = 1200;
numCorseGiornaliere = 25;
%ora non ci rimane che scrivere una matrice diagonale contenente le
%distanze reciproche tra le fermate
numSistema = size(sistema,1);
[X, Y] = meshgrid(1:numSistema); % Creiamo indici per combinare tutte le fermate
dist = hypot(sistema(X(:),1) - sistema(Y(:),1), sistema(X(:),2) - sistema(Y(:),2));
dist = reshape(dist, numSistema, numSistema);

% Definizione della portata di persone
capienzaLinea = capienzaMetro * numCorseGiornaliere; % Imposta il limite massimo di tratta

customerCoords = sistema(2:end,:);
costMatrix = dist;
vehicleCapacity = capienzaLinea;

clusters = [];
remainingCustomers = 1:size(stazioni,1); % Tutte le stazioni disponibili
while ~isempty(remainingCustomers)
    % Trova la stazione più lontana dal deposito (Duomo)
    distsToDepot = hypot(stazioni(remainingCustomers,1), stazioni(remainingCustomers,2));
    [~, idx] = max(distsToDepot);
    startCustomer = remainingCustomers(idx);

    % Inizializza il cluster
    cluster = struct("Customers", startCustomer, "Center", stazioni(startCustomer,:), "Demand", domanda(startCustomer));

    % Rimuovi dalla lista dei clienti rimanenti
    remainingCustomers(idx) = [];

    % Aggiungi altre fermate finché non si supera la capacità della metro
    while ~isempty(remainingCustomers)
        distsToCluster = vecnorm(stazioni(remainingCustomers,:) - cluster.Center, 2, 2);
        [~, idx] = min(distsToCluster);
        nextCustomer = remainingCustomers(idx);

        % Controlla se possiamo aggiungere questa fermata senza superare la capacità
        if cluster.Demand + domanda(nextCustomer) > capienzaLinea
            break;
        end

        % Aggiungi la fermata al cluster
        cluster = addToCluster(cluster, nextCustomer, stazioni, domanda);
        remainingCustomers(idx) = []; % Rimuovila dalla lista
    end

    % Salva il cluster creato
    clusters = [clusters, cluster];
end

% Disegna i cluster trovati
plotClusters(clusters, stazioni);

% CLUSTER IMPROVEMENT
iterations = 0;

while iterations < 10
    for i = 1:numel(clusters)
        % Per ogni stazione all'interno del cluster
        for customer = clusters(i).Customers
            % Calcolo della distanza della stazione dal centro del cluster
            d_i = sqrt(sum((clusters(i).Center - sistema(customer+1,:)).^2));

            % Per ogni cluster alternativo
            for j = [1:i-1, i+1:numel(clusters)]
                % Calcolo della distanza della stazione dal centro del cluster alternativo
                d_j = sqrt(sum((clusters(j).Center - sistema(customer+1,:)).^2));

                % Spostiamo la stazione nel cluster più vicino se i vincoli di capacità sono rispettati
                if d_j < d_i && clusters(j).Demand + domanda(customer) < capienzaLinea
                    % Rimuovi la stazione dal cluster originale
                    clusters(i) = removeFromCluster(clusters(i), ...
                        customer, sistema(2:end,:), domanda);

                    % Aggiungi la stazione al nuovo cluster
                    clusters(j) = addToCluster(clusters(j), ...
                        customer, sistema(2:end,:), domanda);
                    
                    break
                end
            end
        end
    end
    iterations = iterations + 1;
end

nRoutes = numel(clusters);
for i = 1:nRoutes
    clusters(i).Customers = clusters(i).Customers + 1;
end

%con le funzioni in classe (non ottimizate al nostro problema),risolvo
TSPsolutions = cell(numel(clusters),1);
Routes = cell(numel(clusters),1);
customerCoords = sistema; 

for rt = 1:nRoutes
    % Compute pairwise distance
    cluster = clusters(rt);
    coords = [deposito; customerCoords(cluster.Customers,:)];
    M = height(coords);
    [X,Y] = meshgrid(1:M);
    dist = hypot(coords(X(:),1)- coords(Y(:),1),coords(X(:),2) - coords(Y(:),2));
    
    % Collect TSP data
    tsp.CostMatrix = reshape(dist,M,M);
    tsp.Customers = cluster.Customers;
    % Solve this TSP
    TSPsolutions{rt} = solvemyTSP(tsp);
    Routes{rt} = TSPsolutions{rt}.Route;
end
plotClusters(clusters,sistema,Routes)
