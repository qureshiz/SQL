USE [TopDesk577]
GO
/****** Object:  StoredProcedure [dbo].[USP_GetIncidentsOperatorOperatorGroupMovements]    Script Date: 23/07/2018 12:21:14 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		zqureshi	
-- Create date: 18/Jul/2018
-- Description:	316 - C1807-0008 - Matt Dodd - Reporting on To Value
-- =============================================
ALTER PROCEDURE [dbo].[USP_GetIncidentsOperatorOperatorGroupMovements]
	-- Add the parameters for the stored procedure here
	@operatorOrOperatorGroup	int,	-- 1 Operator, 2 Operator Group.
	@operatorID	uniqueidentifier,
	@operatorGroupID	uniqueidentifier,
	@startDate 	datetime,
	@endDate	datetime

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

/*
Temp tables. 
*/
	if object_id('tempdb..#c1') is not null
		begin
			drop table #c1
		end

	if object_id('tempdb..#OperatorIncidents') is not null
		begin
			drop table #OperatorIncidents
		end

	if object_id('tempdb..#OperatorIncidents2') is not null
		begin
			drop table #OperatorIncidents2
		end

	if object_id('tempdb..#Holding') is not null
		begin
			drop table #Holding
		end

	if object_id('tempdb..#IncidentOperatorMovements') is not null
		begin
			drop table #IncidentOperatorMovements
		end

	/*
	Variables
	*/
	declare @rowNumber_OperatorIncidents2 int
	declare @incidentNumber nvarchar(30)
	declare @rowCount_IncidentOperatorMovements int
	declare @rowNumber_IncidentOperatorMovements int
	declare @changedTo nvarchar(109)
	declare @ChangedToOperatorID uniqueidentifier

	-- Create holding table.  This will be the Data Source for the Report(s).
	create table #Holding
	(Incident nvarchar(30), [Type] nvarchar(109) /* from incident.ref_soortmelding */, Log_Date datetime, Impact nvarchar(100),
	Major_Incident nvarchar(3), Category nvarchar(30), SubCategory nvarchar(30), 
	Move_Date datetime, ChangedFrom nvarchar(109), ChangedTo nvarchar(109), ChangedBy nvarchar(109), CurrentOperator nvarchar(109),
	ChangedFromOperatorID uniqueidentifier, ChangeToOperatorID uniqueidentifier, CurrentOperatorID uniqueidentifier)

	-- Get a unqiue list of Incident numbers that have had the Operator moved from the specified Operator (parameer @operatorID) - implying 
	-- that the operator had the Incident assigned to him/her.  Within the given date parameters.
	SELECT Incident
	into #OperatorIncidents
	FROM [dbo].[UTVF_IncidentsMovedToOperator] (
	   @operatorOrOperatorGroup,
	   @operatorID,
	   @operatorGroupID,
	  @startDate,
	  @endDate)
	  order by Incident

	  -- Add columns to #OperatorIncidents to use for iteration purposes - RowNumber and Processed.
	select Incident, identity(int, 1,1) as RowNumber, convert(bit, 0) as Processed 
	into #OperatorIncidents2
	from #OperatorIncidents

	/* Iterate #OperatorIncidents2 for each of the Incident numbers.
	There are two iterations using While loops.
	The outer loop is on table #OperatorIncidents2 that contains unique Incident numbers.
	The inner loop is on table #IncidentOperatorMovements that is being called for each of the Incident numbers.
	*/

	while (select count(*) from #OperatorIncidents2 where Processed = 0) > 0
	begin
		-- Get the first row number of the an un-processed Incident number.
		select top 1 @rowNumber_OperatorIncidents2 = RowNumber, @incidentNumber = Incident from #OperatorIncidents2 where Processed = 0 order by RowNumber

		if object_id('tempdb..#IncidentOperatorMovements') is not null drop table #IncidentOperatorMovements
		
		SELECT identity(int, 1,1) as RowNumber,*
		into #IncidentOperatorMovements
		FROM UTVF_IncidentOperatorMovements (
		@incidentNumber)
		Order by Move_Date

		select @rowCount_IncidentOperatorMovements = @@rowcount
		while (select count(*) from  #IncidentOperatorMovements where Processed = 0) > 0
			begin
				select top 1 @rowNumber_IncidentOperatorMovements = RowNumber from #IncidentOperatorMovements where Processed = 0 order by RowNumber
				if @rowNumber_IncidentOperatorMovements = @rowCount_IncidentOperatorMovements
					begin
						update #IncidentOperatorMovements set ChangedTo = CurrentOperator, ChangeToOperatorID = CurrentOperatorID 
						where RowNumber = @rowNumber_IncidentOperatorMovements -- Update the current row.
					end
				else
					begin
						select @changedTo = ChangedFrom, @changedToOperatorID = ChangedFromOperatorID 
						from #IncidentOperatorMovements where RowNumber = (@rowNumber_IncidentOperatorMovements + 1) --Get the ChangedTo from the ChangedFrom of the next row.
						update #IncidentOperatorMovements set ChangedTo = @changedTo, ChangeToOperatorID = @changedToOperatorID where RowNumber = @rowNumber_IncidentOperatorMovements -- Update the current row.
					end
					
					update #IncidentOperatorMovements set Processed = 1 where RowNumber = @rowNumber_IncidentOperatorMovements	-- Mark the row as processed so the While loop goes to the next row.
			end

			-- Update the holding table with the audit data for one Incident 
			insert into #Holding
			(
			Incident, [Type], Log_Date, Impact, Major_Incident, Category, SubCategory, Move_Date, ChangedFrom, ChangedTo, ChangedBy, CurrentOperator, ChangedFromOperatorID, ChangeToOperatorID, CurrentOperatorID)
			select 
			Incident, [Type], Log_Date, Impact, Major_Incident, Category, SubCategory, Move_Date, ChangedFrom, ChangedTo, ChangedBy, CurrentOperator, ChangedFromOperatorID, ChangeToOperatorID, CurrentOperatorID
			from #IncidentOperatorMovements

		--Mark the row as processed.
		update #OperatorIncidents2 set Processed = 1 where RowNumber = @rowNumber_OperatorIncidents2
	end

	select Incident, [Type], Log_Date, Impact, Major_Incident, Category, SubCategory, Move_Date, ChangedFrom, ChangedTo, ChangedBy, CurrentOperator, ChangedFromOperatorID, ChangeToOperatorID, CurrentOperatorID
	from #Holding

END
