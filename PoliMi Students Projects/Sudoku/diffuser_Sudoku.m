function cg = diffuser(n)
gates = [hGate(1:n);
         xGate(1:n);
         hGate(n);
         mcxGate(1:n-1, n, []);
         hGate(n);
         xGate(1:n);
         hGate(1:n)];
cg = quantumCircuit(gates,Name="Diffuser");
end