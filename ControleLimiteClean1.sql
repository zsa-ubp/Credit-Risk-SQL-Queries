;WITH Base AS (
    SELECT
        LEFT(P.PositionDescription, 11) AS Val,
        I.InstrumentCode,
        I.InstrumentDescription,
        E.EntityCode AS SOC,
        SUBSTRING(P.AccountKey, 4, 7) AS SousLeader,
        P.AccountKey,
        SUBSTRING(CL.ClientCode, 4, LEN(CL.ClientCode)) AS Client,
        CL.ClientName,
        '' AS Mactnumber,
        P.PositionDescription,
        C.CurrencyCode,
        -1 * P.Amount AS Solde,
        FC.CleanLimitOrigin AS Limite,
        IIF(FC.CleanLimitOrigin IS NULL, 0, 100.0 * FC.CleanLimitOrigin / NULLIF(P.Amount,0)) AS PctClean,
        RIGHT(LEFT(P.PositionDescription, 11), 2) AS ValLast2,
        RIGHT(I.InstrumentCode, 2) AS InstLast2,

        CASE 
            WHEN RIGHT(I.InstrumentCode, 2) = RIGHT(LEFT(P.PositionDescription, 11), 2) THEN 2
            WHEN RIGHT(I.InstrumentCode, 2) = '00' THEN 1
            ELSE 0
        END AS MatchScore
    FROM dm.FactPositions P
    LEFT JOIN dm.FactClientOverview FC 
        ON FC.ClientKey = P.ClientKey AND FC.DateKey = P.DateKey
    LEFT JOIN dm.Instrument I 
        ON LEFT(P.PositionDescription, 9) = LEFT(I.InstrumentCode, 9)
    LEFT JOIN dm.Currency AS C 
        ON C.CurrencyKey = P.CurrencyKey
    LEFT JOIN dm.Entity AS E 
        ON P.EntityKey = E.EntityKey
    LEFT JOIN dm.Client AS CL 
        ON CL.ClientKey = P.ClientKey
    LEFT JOIN dm.ClientGroup AS CG 
        ON CG.ClientGroupKey = P.ClientGroupKey
    LEFT JOIN dm.CreditClassification AS CC 
        ON CC.CreditClassificationKey = P.CreditClassificationKey
    WHERE 
        CC.CreditClassificationCode = 'PRIEQU'
        AND P.DateKey = 20260630 AND SUBSTRING(CL.ClientCode, 4, LEN(CL.ClientCode))='6334465'
),
Ranked AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY Val
            ORDER BY 
                MatchScore DESC,         
                InstrumentCode ASC       
        ) AS rn
    FROM Base
)
SELECT
    Val,
    InstrumentCode,
    InstrumentDescription,
    SOC,
    SousLeader,
    AccountKey,
    Client,
    ClientName,
    Mactnumber,
    PositionDescription,
    CurrencyCode,
    Solde,
    Limite,
    PctClean
FROM Ranked
WHERE rn = 1 


