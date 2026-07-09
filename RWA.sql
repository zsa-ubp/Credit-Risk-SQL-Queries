SELECT
  T_TIERS_M.Tiers,
  V_PERIOD_M.Period,
  V_PLANCPT_M_T_MGR_PROFIT.Lien6,
  V_PLANCPT_M_T_MGR_PROFIT.Lien5,
  V_PLANCPT_M_T_MGR_PROFIT.LbLien5,
  V_PLANCPT_M_T_MGR_PROFIT.Lien4,
  V_PLANCPT_M_T_MGR_PROFIT.LbLien4,
  V_PLANCPT_M_T_MGR_PROFIT.Lien3,
  V_PLANCPT_M_T_MGR_PROFIT.LbLien3,
  V_PLANCPT_M_T_MGR_PROFIT.FlagComm,
  T_TIERS.TiersName,
  T_TIERS.ManagerCode,
  T_TIERS.FinderCode,
  case when T_TIERS.ManagementType = 3  then 'Advisory' Else case when T_TIERS.ManagementType = 1  or  T_TIERS.SuiviGere = 'Y'  Then 'Managed' Else 'Execution Only' end end,
  T_TIERS.ManagementType,
  sum(T_TIERS_PROFIT.NetProfitChfNh),
  sum(T_TIERS_PROFIT.GrossProfitChfNh),
  sum(T_TIERS_PROFIT.RetroChfNh),
  T_TIERS_M.Soc,
  T_TIERS_M.Soc + substring(T_TIERS_M.Tiers,6,7),
  V_PLANCPT_M_T_MGR_PROFIT.Lien1,
  V_PLANCPT_M_T_MGR_PROFIT.LbLien1,
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
  sum(T_TIERS_PROFIT.NetProfitChfNhEco)
FROM
  V_PLANCPT_M  V_PLANCPT_M_T_MGR_PROFIT INNER JOIN T_TIERS_PROFIT ON (round(T_TIERS_PROFIT.Period/100,0)*100=V_PLANCPT_M_T_MGR_PROFIT.Period  AND  V_PLANCPT_M_T_MGR_PROFIT.Lien6=T_TIERS_PROFIT.Lien6)
   INNER JOIN V_PERIOD_M ON (T_TIERS_PROFIT.Period=V_PERIOD_M.Period)
   INNER JOIN V_HIERARCHY_M ON (T_TIERS_PROFIT.ManagerCode=V_HIERARCHY_M.ManagerCode  AND  round(T_TIERS_PROFIT.Period/100,0)*100=V_HIERARCHY_M.Period)
   INNER JOIN T_TIERS_M ON (T_TIERS_PROFIT.Soc=T_TIERS_M.Soc
and cast(round(T_TIERS_PROFIT.Period/100,0)*100 as decimal(8,0))=T_TIERS_M.Period 
and T_TIERS_PROFIT.Tiers=T_TIERS_M.Tiers)
   INNER JOIN T_TIERS ON (T_TIERS_M.Tiers=T_TIERS.Tiers 
and T_TIERS.Soc=T_TIERS_M.Soc 
and T_TIERS.DateFinHist=99991231)
   INNER JOIN ( 
  select * from MIS.MISCurrentSecurity
  )  Der_MISCurrentSecurity ON (T_TIERS_PROFIT.ManagerCode=Der_MISCurrentSecurity.chPrftyMgrCode)
   INNER JOIN ( 
  select * from MIS.MISREFUser where chLoginName <> ''
  )  Der_MISREFUser ON (Der_MISREFUser.idREFUser=Der_MISCurrentSecurity.idREFUser)
   INNER JOIN MIS.BO_ACCESS_NOM ON (MIS.BO_ACCESS_NOM.Nom=Der_MISREFUser.chLongName)
WHERE
  (
   V_PERIOD_M.Period  >=  20250600
   AND
   V_PERIOD_M.Period  <=  20260400
   AND
   ( MIS.BO_ACCESS_NOM.Trigramme=lower('kki')  )
   AND
   ( T_TIERS.DateFinHist=99991231  )
   AND
   ( MIS.BO_ACCESS_NOM.Trigramme=lower('kki')  )
  )
GROUP BY
  T_TIERS_M.Tiers, 
  V_PERIOD_M.Period, 
  V_PLANCPT_M_T_MGR_PROFIT.Lien6, 
  V_PLANCPT_M_T_MGR_PROFIT.Lien5, 
  V_PLANCPT_M_T_MGR_PROFIT.LbLien5, 
  V_PLANCPT_M_T_MGR_PROFIT.Lien4, 
  V_PLANCPT_M_T_MGR_PROFIT.LbLien4, 
  V_PLANCPT_M_T_MGR_PROFIT.Lien3, 
  V_PLANCPT_M_T_MGR_PROFIT.LbLien3, 
  V_PLANCPT_M_T_MGR_PROFIT.FlagComm, 
  T_TIERS.TiersName, 
  T_TIERS.ManagerCode, 
  T_TIERS.FinderCode, 
  case when T_TIERS.ManagementType = 3  then 'Advisory' Else case when T_TIERS.ManagementType = 1  or  T_TIERS.SuiviGere = 'Y'  Then 'Managed' Else 'Execution Only' end end, 
  T_TIERS.ManagementType, 
  T_TIERS_M.Soc, 
  T_TIERS_M.Soc + substring(T_TIERS_M.Tiers,6,7), 
  V_PLANCPT_M_T_MGR_PROFIT.Lien1, 
  V_PLANCPT_M_T_MGR_PROFIT.LbLien1, 
  V_HIERARCHY_M.SectGrpCode, 
  V_HIERARCHY_M.SectGrpName, 
  V_HIERARCHY_M.SectCode, 
  V_HIERARCHY_M.SectName, 
  V_HIERARCHY_M.EntityCode, 
  V_HIERARCHY_M.EntityName, 
  V_HIERARCHY_M.ZoneCode, 
  V_HIERARCHY_M.ZoneName, 
  V_HIERARCHY_M.PMECode, 
  V_HIERARCHY_M.PMEName