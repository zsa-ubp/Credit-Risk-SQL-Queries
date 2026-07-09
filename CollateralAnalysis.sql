  SELECT
      D.DayCode as Closing,
	  C.clientcode as Tier,
	  PG.PledgeGroupCode as Pledge_group,
	  CONCAT(P.AccountKey,'-',P.ContractKey) as PositionIdentifier,
	  CU.CurrencyCode,
	  P.Quantity,
	  P.AmountEntityCcy AS MV_CHF  ,
	  P.LendingValue *P.ExchangeRate  AS LV_CHF,
	  P.PositionDescription as Instrument_description,
	  I.InstrumentCode as Valoren, 
	  I.Isin,
	  '' as AccountKind,
	  P.AccountKey,
	  P.ContractKey,
	  CR.CreditClassificationCode,
	  PC.PositionClassName,
	  IIF(PC.PositionClassCode=1,'YES', 'NO') as AssetFlag,
      P.PledgeGiven  ,
	  P.PledgeReceived
  FROM dm.FactPositions P

  JOIN dm.Instrument I on I.InstrumentKey=P.InstrumentKey
  JOIN dm.date D                  ON D.Day = P.DateKey
  JOIN dm.PledgeGroup PG          ON PG.PledgeGroupKey = P.PledgeGroupKey
  JOIN dm.PositionClass PC        ON PC.PositionClassKey = P.PositionClassKey
  JOIN dm.Entity E                ON E.EntityKey       = P.EntityKey
  JOIN dm.Client C                ON C.ClientKey       = P.ClientKey
  JOIN dm.Currency CU             ON CU.CurrencyKey    = P.CurrencyKey
  JOIN dm.CreditClassification CR ON CR.CreditClassificationKey = P.CreditClassificationKey
  WHERE
      C.ClientNature <> 'BANK'
      AND P.DateKey = 20260630  AND C.ClientCode='3055511501'



