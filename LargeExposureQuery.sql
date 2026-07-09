SELECT E.EntityCode, E.EntityDescription,
CL.ClientCode, CL.ClientName, CG.ClientGroupCode,
PC.PositionClassName AS AvEng,
CC.CreditClassificationDescription as CAT,
CASE WHEN I.EligibilityFlag =1 THEN 'Eligible'
     WHEN I.EligibilityFlag =1 THEN 'Non-Eligible'
	 ELSE 'Non défini'
END as Eligible_ID,
P.Amount* (EX1.EndOfDayRate / EX2.EndOfDayRate)  as  Amount,
'NET',
'Leader',
'Netting_group'
FROM dm.FactClientOverview O 
JOIN dm.FactPositions P ON P.ClientKey=O.ClientKey AND P.DateKey=O.DataStatus
JOIN dm.FactInstrumentMarketData I ON I.InstrumentKey = P.InstrumentKey AND I.DateKey= P.DateKey
JOIN dm.FactExchangeRate EX1 ON EX1.CurrencyKey= P.CurrencyKey AND EX1.DateKey= P.DateKey 
JOIN dm.FactExchangeRate EX2 ON EX2.CurrencyKey= 1459 AND EX2.DateKey= P.DateKey
JOIN dm.Currency C ON C.CurrencyKey=P.CurrencyKey
JOIN dm.Entity E ON O.EntityKey= E.EntityKey
JOIN dm.Client CL ON Cl.ClientKey= O.ClientKey
JOIN dm.ClientGroup CG On CG.ClientGroupKey=O.ClientGroupKey
JOIN dm.PositionClass PC ON PC.PositionClassKey= P.PositionClassKey
JOIN dm.CreditClassification CC ON CC.CreditClassificationKey= P.CreditClassificationKey




SELECT 
    A.CurrencyKey AS CurrencyA,
    B.CurrencyKey AS CurrencyB,
    A.EndOfDayRate / B.EndOfDayRate AS ExchangeRate,
    A.DateKey
FROM 
    dm.FactExchangeRate A
JOIN 
    dm.FactExchangeRate B
ON 
    A.DateKey = B.DateKey
WHERE 
    A.CurrencyKey = 'KeyDeviseA' AND 
    B.CurrencyKey = 'KeyDeviseB';


	SELECT * FROM dm.Currency