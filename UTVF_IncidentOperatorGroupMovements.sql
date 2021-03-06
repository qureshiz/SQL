USE [TopDesk577]
GO
/****** Object:  UserDefinedFunction [dbo].[UTVF_IncidentOperatorGroupMovements]    Script Date: 24/07/2018 17:20:34 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		zqureshi
-- Create date: 23/Jul/2018
-- Description:	Incident Operator Group Movements.  Given the Incident number, get all of the audit records for Operator Group movements.
/*
Useful:
mutatie_incident.mut_operatorgroupid_act	boolean	Amended (Operator Group)
mutatie_incident.mut_operatorgroupid		unid	Operator Group

mutatie_incident.mut_operatorgroupid = actiedoor.unid
*/
-- =============================================
ALTER FUNCTION [dbo].[UTVF_IncidentOperatorGroupMovements]
(	
	-- Add the parameters for the function here
@incident  nvarchar(30)
)
RETURNS TABLE 
AS
RETURN 
(
	-- Add the SELECT statement with parameter references here
		select /*identity(int, 1,1) as RowNumber,*/ -- Create the RowNumber in the calling programme.
		convert(bit, 0) as Processed, i.naam as Incident, i.ref_soortmelding as [Type], i.dataanmk as Log_Date, i.ref_impact as [Impact],
		case when i.ismajorincident=1 then 'Yes' else 'No' end as Major_Incident, ref_domein as [Category], ref_specificatie as SubCategory, mi.datwijzig as Move_Date,
		op1.ref_dynanaam as ChangedFrom, convert(nvarchar(109), '') as ChangedTo, g.naam as ChangedBy, op2.ref_dynanaam as CurrentOperator, 
		mi.mut_operatorgroupid as ChangedFromOperatorGroupID, 
		convert(uniqueidentifier, null) as ChangeToOperatorGroupID, i.OperatorGroupID as CurrentOperatorGroupID
		--into #c1
		 from incident i left join mutatie_incident mi
		 on i.unid=mi.parentid
		 left join actiedoor op1
		 on mi.mut_operatorgroupid = op1.unid
		 left join actiedoor op2 on i.operatorgroupid = op2.unid
		 left join gebruiker g on mi.uidwijzig = g.unid -- gebruiker, this is the list of TopDesk users.
		 where i.naam = @incident
		 and mi.mut_operatorgroupid_act = 1	--Amended (Operator).
		 -- Order the data by Move_Date in the calling programme.	This is essential as determining the operator movements is dependent on Move_Date.
)
