-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		zqureshi
-- Create date: 05/Aug/2018
-- Description:	Given an Incident number, check if the Incident is breached.
/* This is based on three fields.  At least one of the fields should be true for the Incident
to be breached.
*/
/*
--vrijelogisch1	SLA Respond Breached.
--vrijelogisch2	SLA Resolve Breached.
-- vrijegetal2	Escalation.
*/
-- =============================================
alter PROCEDURE USP_Get_Incident_Is_Breached
@strIncident nvarchar(30),
@breachedIncident bit output -- 1 is Breached and two is 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	if (select count(*) from incident
		where (vrijelogisch1 = 1 or vrijelogisch2 = 1 or vrijegetal2 = 1)
		and incident.naam = @strIncident) = 1

		begin
			set @breachedIncident = 1
		end
	else
		begin
			set @breachedIncident = 0
		end

	return @breachedIncident
END
GO