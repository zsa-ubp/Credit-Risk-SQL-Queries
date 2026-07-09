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
      AND P.DateKey = 20260629 
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