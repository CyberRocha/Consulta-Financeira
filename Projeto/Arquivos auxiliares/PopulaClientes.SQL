INSERT INTO Clientes ("ID_Cliente","Nome_Cliente") SELECT 1, "Alterdata"
WHERE NOT EXISTS(SELECT * FROM Clientes WHERE ID_Cliente = 1);
