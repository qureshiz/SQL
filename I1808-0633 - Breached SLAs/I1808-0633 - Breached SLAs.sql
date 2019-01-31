-- 05/Aug/2018.
-- I1808-0633 - Breached SLAs.sql
USE [TopDesk577]
GO

DECLARE @RC_IsBreached int
DECLARE @strIncident nvarchar(30)
Declare @RC_Incident_Unbreached int
-- TODO: Set parameter values here.

EXECUTE @RC_IsBreached = [dbo].[USP_Get_Incident_Is_Breached] 
   @strIncident

select @strIncident as Incident, @RC_IsBreached as IsBreached

if @RC_IsBreached = 1
	begin
		/* Update the Incident.
		*/

	EXECUTE @RC_Incident_Unbreached = [dbo].[USP_UnbreachIncident] 
	   @strIncident

	   select @strIncident as Incident, @RC_IsBreached as RC_IsBreached, @RC_Incident_Unbreached as Incident_Unbreached

	end





