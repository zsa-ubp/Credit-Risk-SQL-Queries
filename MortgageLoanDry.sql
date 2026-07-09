---Mortgage Loan en dry
WITH Base AS (
  SELECT
      D.DayCode,
      CASE 
        WHEN PG.PledgeGroupCode <> '-9999' THEN PG.PledgeGroupCode
        ELSE C.ClientCode
      END AS PledgeGroup,
      CR.CreditClassificationCode,
      CR.CreditClassificationName,
      PC.PositionClassCode,
      PC.PositionClassName,
      SUM(P.AmountEntityCcy) AS Amount,
      SUM(P.MarketValue)     AS MarketValue
  FROM dm.FactPositions P
  JOIN dm.date D                  ON D.Day = P.DateKey
  JOIN dm.PledgeGroup PG          ON PG.PledgeGroupKey = P.PledgeGroupKey
  JOIN dm.PositionClass PC        ON PC.PositionClassKey = P.PositionClassKey
  JOIN dm.Entity E                ON E.EntityKey       = P.EntityKey
  JOIN dm.Client C                ON C.ClientKey       = P.ClientKey
  JOIN dm.Currency CU             ON CU.CurrencyKey    = P.CurrencyKey
  JOIN dm.CreditClassification CR ON CR.CreditClassificationKey = P.CreditClassificationKey
  WHERE
      C.ClientNature <> 'BANK'
      AND P.DateKey = 20260629 AND PG.PledgeGroupCode='G0012761300'
  GROUP BY
      D.DayCode,
      P.DateKey,
      CASE WHEN PG.PledgeGroupCode <> '-9999' THEN PG.PledgeGroupCode ELSE C.ClientCode END,
      CR.CreditClassificationCode,
      CR.CreditClassificationName,
      PC.PositionClassCode,
      PC.PositionClassName
),
-- Totaux par PledgeGroup
AggGroup AS (
  SELECT
      PledgeGroup,
      SUM(MarketValue) AS SumMarketValue
  FROM Base
  GROUP BY PledgeGroup
),
-- Montant MTG par PledgeGroup
AggMTG AS (
  SELECT
      PledgeGroup,
      SUM(Amount) AS SumAmountMTG
  FROM Base
  WHERE CreditClassificationCode = 'MTG'
  GROUP BY PledgeGroup
),
-- Montant MORLO par PledgeGroup
AggMORLO AS (
  SELECT
      PledgeGroup,
      SUM(Amount) AS SumAmountMORLO
  FROM Base
  WHERE CreditClassificationCode = 'MORLO'
  GROUP BY PledgeGroup
),
-- Montant MOR par PledgeGroup
AggMOR AS (
  SELECT
      PledgeGroup,
      SUM(Amount) AS SumAmountMOR
  FROM Base
  WHERE CreditClassificationCode = 'MOR'
  GROUP BY PledgeGroup
),
-- Consolidation et calcul du flag
FlagPerGroup AS (
  SELECT
      g.PledgeGroup,
      g.SumMarketValue,
      COALESCE(mtg.SumAmountMTG, 0)   AS SumAmountMTG,
      COALESCE(morlo.SumAmountMORLO, 0) AS SumAmountMORLO,
	  COALESCE(mor.SumAmountMOR, 0) AS SumAmountMORFACILITY,
      (g.SumMarketValue - COALESCE(mtg.SumAmountMTG,0) - COALESCE(morlo.SumAmountMORLO,0)-  COALESCE(mor.SumAmountMOR,0) ) AS DiffValue,
      CASE
        WHEN (g.SumMarketValue - COALESCE(mtg.SumAmountMTG,0) - COALESCE(morlo.SumAmountMORLO,0)-  COALESCE(mor.SumAmountMOR,0) )  < 0
          THEN 'loan_dry'
        ELSE 'loan_not_dry'
      END AS LoanDryFlag
  FROM AggGroup g
  LEFT JOIN AggMTG  mtg   ON mtg.PledgeGroup  = g.PledgeGroup
  LEFT JOIN AggMORLO morlo ON morlo.PledgeGroup = g.PledgeGroup
  LEFT JOIN AggMOR mor ON mor.PledgeGroup = g.PledgeGroup
)
SELECT
    b.DayCode,
    b.PledgeGroup,
    b.CreditClassificationCode,
    b.CreditClassificationName,
    b.PositionClassCode,
    b.PositionClassName,
    b.Amount,
    b.MarketValue,
    f.DiffValue,
    f.LoanDryFlag
FROM Base b
JOIN FlagPerGroup f
  ON f.PledgeGroup = b.PledgeGroup
WHERE
  b.CreditClassificationCode='MORLO' 

/*ORDER BY b.PledgeGroup, b.CreditClassificationCode 
 b.PledgeGroup IN ('G0143062235','0016260068');*/

---Mortgage Loan avec LTV>60%  b.CreditClassificationCode='MORLO' AND 

 SELECT 
 D.DayCode,
 P.DateKey,
 C.ClientCode,
 C.ClientName, 
 E.EntityCode,
 E.EntityDescription,
 P.PropertiesContractualLTV,
 P.ValuationRiskAmount,
 CU.CurrencyCode
 FROM dm.FactMortgages P
  JOIN dm.date D                  ON D.Day = P.DateKey
  JOIN dm.Entity E                ON E.EntityKey       = P.EntityKey
  JOIN dm.Client C                ON C.ClientKey       = P.ClientKey
  JOIN dm.Currency CU             ON CU.CurrencyKey    = P.CurrencyKey
  WHERE P.DateKey='20260701' AND C.ClientCode IN ('2010409835','2010409835')
  --AND  P.PropertiesContractualLTV>0.6 
  
----Positions avec ETP en liquidation 
WITH S AS (
  SELECT
      D.DayCode,
      E.EntityCode,
      E.EntityDescription,
      C.ClientCode,
      C.ClientName,
      PC.PositionClassName,
      SUM(P.LendingValue)           AS LendingValue,
      SUM(P.LendingValueAdjusted)   AS LendingValueAdjusted,
      SUM(P.LendingValue2)          AS LendingValue2,
      SUM(P.LendingValue2Adjusted)  AS LendingValue2Adjusted,
      SUM(P.LendingValue3)          AS LendingValue3,
      SUM(P.LendingValue3Adjusted)  AS LendingValue3Adjusted,
      SUM(P.Liability)              AS Liability,
      SUM(P.TotalExposure)          AS TotalExposure,
      SUM(P.TotalExposure2)         AS TotalExposure2,
      SUM(P.TotalExposure3)         AS TotalExposure3,
      SUM(P.AmountEntityCcy)        AS Amount,
      SUM(P.MarginRate)             AS MarginRate,
      SUM(P.MarginRate2)            AS MarginRate2,
      SUM(P.MarginRate3)            AS MarginRate3
  FROM dm.FactPositions P
  JOIN dm.date D           ON D.Day = P.DateKey
  JOIN dm.PositionClass PC ON PC.PositionClassKey = P.PositionClassKey
  JOIN dm.Entity E         ON E.EntityKey = P.EntityKey
  JOIN dm.Client C         ON C.ClientKey = P.ClientKey
  JOIN dm.FactClientLimits L on L.ClientKey =P.ClientKey AND L.DateKey=P.DateKey
  JOIN dm.CreditClassification CR ON CR.CreditClassificationKey = P.CreditClassificationKey
  JOIN dm.Currency CU ON CU.CurrencyKey=P.CurrencyKey
  WHERE
      C.ClientNature <> 'BANK'
      AND P.DateKey = 20260701 
  GROUP BY
      D.DayCode,
      E.EntityCode,
      E.EntityDescription,
      C.ClientCode,
      C.ClientName,
      PC.PositionClassName
)

SELECT
S.DayCode,
    S.ClientCode,
    S.ClientName,
	S.EntityCode,
    SUM(CASE WHEN S.PositionClassName = 'Asset'    THEN S.LendingValue3    ELSE 0 END) AS LendingValue3,
    SUM(CASE WHEN S.PositionClassName = 'Liability' THEN S.TotalExposure3   ELSE 0 END) AS TotalExposure3,
    IIF(
      SUM(CASE WHEN S.PositionClassName = 'Asset'     THEN S.LendingValue3  ELSE 0 END) 
      - SUM(CASE WHEN S.PositionClassName = 'Liability' THEN S.TotalExposure3 ELSE 0 END) < 0,
      'liquidation',
      'not_liquidation'
    ) AS Flag_liquidation
FROM S
GROUP BY
S.DayCode,
    S.ClientCode,
    S.ClientName,
	S.EntityCode




	  SELECT
      D.DayCode,
      E.EntityCode,
      E.EntityDescription,
      C.ClientCode,
      C.ClientName,
      PC.PositionClassName,
	  CR.CreditClassificationDescription,
	  P.*
  FROM dm.FactPositions P
  JOIN dm.date D           ON D.Day = P.DateKey
  JOIN dm.PositionClass PC ON PC.PositionClassKey = P.PositionClassKey
  JOIN dm.Entity E         ON E.EntityKey = P.EntityKey
  JOIN dm.Client C         ON C.ClientKey = P.ClientKey
  JOIN dm.FactClientLimits L on L.ClientKey =P.ClientKey AND L.DateKey=P.DateKey
  JOIN dm.CreditClassification CR ON CR.CreditClassificationKey = P.CreditClassificationKey
  JOIN dm.Currency CU ON CU.CurrencyKey=P.CurrencyKey
  WHERE
      C.ClientNature <> 'BANK'
      AND P.DateKey = 20260701 AND C.ClientCode='0010730762' AND  CR.CreditClassificationDescription='Cash'