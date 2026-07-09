 ----Positions avec ETP en liquidation 
WITH S AS (
  SELECT
      D.DayCode,
      E.EntityCode,
      E.EntityDescription,
      C.ClientCode,
      C.ClientName,
      PC.PositionClassName,
	  P.PledgeReceived,
	  CL.CleanLimit,
	  SUM(P.MarketValue)            AS MarketValue,
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
  JOIN dm.FactClientOverview CL ON P.ClientKey=CL.ClientKey AND P.DateKey=CL.DateKey
  JOIN dm.date D           ON D.Day = P.DateKey
  JOIN dm.PositionClass PC ON PC.PositionClassKey = P.PositionClassKey
  JOIN dm.Entity E         ON E.EntityKey = P.EntityKey
  JOIN dm.Client C         ON C.ClientKey = P.ClientKey
  JOIN dm.FactClientLimits L on L.ClientKey =P.ClientKey AND L.DateKey=P.DateKey
  JOIN dm.CreditClassification CR ON CR.CreditClassificationKey = P.CreditClassificationKey
  JOIN dm.Currency CU ON CU.CurrencyKey=P.CurrencyKey
  WHERE
      C.ClientNature <> 'BANK'
      AND P.DateKey = 20260701 AND C.ClientCode='0012402427'
  GROUP BY
      D.DayCode,
      E.EntityCode,
      E.EntityDescription,
      C.ClientCode,
      C.ClientName,
      PC.PositionClassName,
	  CR.CreditClassificationCode,
	  P.PledgeReceived,CL.CleanLimit
)

SELECT
S.DayCode,
    S.ClientCode,
    S.ClientName,
	S.EntityCode,
	S.CleanLimit,
	SUM(CASE WHEN S.PledgeReceived =1  THEN S.MarketValue    ELSE 0 END) AS MarketValue,
    SUM(CASE WHEN S.PositionClassName = 'Asset'    THEN S.LendingValue3   ELSE 0 END) AS LendingValue3,
    SUM(CASE WHEN S.PositionClassName = 'Liability' THEN S.TotalExposure3   ELSE 0 END) AS TotalExposure3,
    IIF(
      (SUM(CASE WHEN S.PositionClassName = 'Asset'     THEN S.LendingValue3  ELSE 0 END)+SUM(CASE WHEN S.PledgeReceived =1  THEN S.MarketValue    ELSE 0 END)+S.CleanLimit
      - SUM(CASE WHEN S.PositionClassName = 'Liability' THEN S.TotalExposure3 ELSE 0 END)) < 0,
      'liquidation',
      'not_liquidation'
    ) AS Flag_liquidation
FROM S
GROUP BY
S.DayCode,
    S.ClientCode,
    S.ClientName,
	S.EntityCode,
	S.CleanLimit
