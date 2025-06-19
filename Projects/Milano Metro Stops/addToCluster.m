function cluster = addToCluster(cluster, next, stazioni, domanda)
    cluster.Customers = [cluster.Customers, next]; 
    cluster = updateCluster(cluster, next, stazioni, domanda, 1);
end