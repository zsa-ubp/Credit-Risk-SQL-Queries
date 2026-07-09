---Mortgage Loan avec LTV>60% 
 SELECT 
 D.DayCode,
 P.DateKey,
 C.ClientCode,
 C.ClientName, 
 E.EntityCode,
 E.EntityDescription,
 P.ContractualLTV1,
 P.ValuationRiskAmount,
 CU.CurrencyCode
 FROM dm.FactMortgages P
  JOIN dm.date D                  ON D.Day = P.DateKey
  JOIN dm.Entity E                ON E.EntityKey       = P.EntityKey
  JOIN dm.Client C                ON C.ClientKey       = P.ClientKey
  JOIN dm.Currency CU             ON CU.CurrencyKey    = P.CurrencyKey
  WHERE P.DateKey='20260701'