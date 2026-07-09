SELECT C.ClientCode, 
c.ClientName, 
A.AddressLine1,
A.ZipCode, 
A.City,A.state,  A.Country, E.EntityCode, E.EntityDescription, M.MortgageContractCode, M.MortgageContractName,
G.ClientGroupCode, G.ClientGroupDescription,  L.PledgeGroupCode, L.PledgeGroupName, LivingSpace, LandArea, AssetPurchasePrice, AssetPruchaseDateKey
FROm dm.FactProperty P
JOIN dm.Entity E ON E.EntityKey     = P.EntityKey
JOIN dm.Client C ON C.ClientKey     = P.ClientKey
JOIN dm.Address A ON A.AddressKey = P.AddressKey
JOIN dm.MortgageContract M ON M.MortgageContractKey= P.MortgageContractKey
Join dm.ClientGroup G on G.ClientGroupKey=P.ClientGroupKey
JOIN dm.PledgeGroup L ON L.PledgeGroupKey =P.PledgeGroupKey 
WHERE  A.Country ='SWITZERLAND' AND DateKey=20260630

