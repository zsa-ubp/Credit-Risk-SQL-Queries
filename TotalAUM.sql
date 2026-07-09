SELECT

  V_PERIOD_M.Period,

  T_TIERS.Soc,

  T_TIERS.Soc + substring(T_TIERS.Tiers,6,7),

  T_TIERS_M.ScopeMIS,

  V_HIERARCHY_M.SectGrpCode,

  V_HIERARCHY_M.SectGrpName,

  V_HIERARCHY_M.SectCode,

  V_HIERARCHY_M.SectName,

  V_HIERARCHY_M.EntityCode,

  V_HIERARCHY_M.EntityName,

  V_HIERARCHY_M.ZoneCode,

  V_HIERARCHY_M.ZoneName,

  V_HIERARCHY_M.PMECode,

  V_HIERARCHY_M.PMEName,

  V_HIERARCHY_M.GroupCode,

  V_HIERARCHY_M.GroupName,

  V_HIERARCHY_M.ManagerCode,

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassCodeLevel5,

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassNameLevel5,

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassCodeLevel4,

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassNameLevel4,

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassCodeLevel3,

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassNameLevel3,

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassCodeLevel2,

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassNameLevel2,

  CASE WHEN Right(T_TIERS_M.Tiers,1) = 'M' THEN 'ME' WHEN Right(T_TIERS_M.Tiers,1) = 'X' THEN 'VE' ELSE 'UBP' END,

  T_TIERS_M.KeyOrigine,

  sum(T_TIERS_ASSETS.EvalChfEco),

  sum(T_TIERS_ASSETS.EvalChf)

FROM

  V_ASSETCLASS_M  V_ASSETCLASS_M_T_TIERS_ASSETS INNER JOIN T_TIERS_ASSETS ON (T_TIERS_ASSETS.InstrTypePos=V_ASSETCLASS_M_T_TIERS_ASSETS.InstrType  AND  T_TIERS_ASSETS.Period=V_ASSETCLASS_M_T_TIERS_ASSETS.Period)

   INNER JOIN V_PERIOD_M ON (T_TIERS_ASSETS.Period=V_PERIOD_M.Period)

   INNER JOIN V_HIERARCHY_M ON (T_TIERS_ASSETS.ManagerCode=V_HIERARCHY_M.ManagerCode  AND  T_TIERS_ASSETS.Period=V_HIERARCHY_M.Period)

   INNER JOIN T_TIERS_M ON (T_TIERS_ASSETS.Period=T_TIERS_M.Period  AND  T_TIERS_ASSETS.Soc=T_TIERS_M.Soc  AND  T_TIERS_ASSETS.Tiers=T_TIERS_M.Tiers)

   INNER JOIN T_TIERS ON (T_TIERS_M.Tiers=T_TIERS.Tiers 

and T_TIERS.Soc=T_TIERS_M.Soc 

and T_TIERS.DateFinHist=99991231)

   INNER JOIN ( 

  select * from MIS.MISCurrentSecurity

  )  Der_MISCurrentSecurity ON (T_TIERS_ASSETS.ManagerCode=Der_MISCurrentSecurity.chPrftyMgrCode)

   INNER JOIN ( 

  select * from MIS.MISREFUser where chLoginName <> ''

  )  Der_MISREFUser ON (Der_MISREFUser.idREFUser=Der_MISCurrentSecurity.idREFUser)

   INNER JOIN MIS.BO_ACCESS_NOM ON (MIS.BO_ACCESS_NOM.Nom=Der_MISREFUser.chLongName)

WHERE

  (

   V_PERIOD_M.Period  =  20260500

   AND

   ( T_TIERS.DateFinHist=99991231  )

   AND

   ( MIS.BO_ACCESS_NOM.Trigramme=lower(@variable('BOUSER'))  )

   AND

   ( MIS.BO_ACCESS_NOM.Trigramme=lower(@variable('BOUSER'))  )

  )

GROUP BY

  V_PERIOD_M.Period, 

  T_TIERS.Soc, 

  T_TIERS.Soc + substring(T_TIERS.Tiers,6,7), 

  T_TIERS_M.ScopeMIS, 

  V_HIERARCHY_M.SectGrpCode, 

  V_HIERARCHY_M.SectGrpName, 

  V_HIERARCHY_M.SectCode, 

  V_HIERARCHY_M.SectName, 

  V_HIERARCHY_M.EntityCode, 

  V_HIERARCHY_M.EntityName, 

  V_HIERARCHY_M.ZoneCode, 

  V_HIERARCHY_M.ZoneName, 

  V_HIERARCHY_M.PMECode, 

  V_HIERARCHY_M.PMEName, 

  V_HIERARCHY_M.GroupCode, 

  V_HIERARCHY_M.GroupName, 

  V_HIERARCHY_M.ManagerCode, 

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassCodeLevel5, 

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassNameLevel5, 

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassCodeLevel4, 

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassNameLevel4, 

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassCodeLevel3, 

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassNameLevel3, 

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassCodeLevel2, 

  V_ASSETCLASS_M_T_TIERS_ASSETS.ClassNameLevel2, 

  CASE WHEN Right(T_TIERS_M.Tiers,1) = 'M' THEN 'ME' WHEN Right(T_TIERS_M.Tiers,1) = 'X' THEN 'VE' ELSE 'UBP' END, 

  T_TIERS_M.KeyOrigine

 