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
-- Create date: 31/Jan/2019
-- Description:	533 - I1901-16577 - Matt Dodd - Kaseya Automation Amendment
-- =============================================
CREATE PROCEDURE USP_Update_Kaseya_Incident
	-- Add the parameters for the stored procedure here
	@strIncidentNumber			NVARCHAR(30),
	@impactUNID					UNIQUEIDENTIFIER,
	@incidentTypeUNID			UNIQUEIDENTIFIER,
	@kaseyaAutomation			BIT,
	@entryUNID					UNIQUEIDENTIFIER,
	@operatorGroupUNID			UNIQUEIDENTIFIER,	-- incident.operatorgroupid
	@operatorUNID				UNIQUEIDENTIFIER,	-- incident.operatorid.  This will be the same value as the Operator Group UNID.
	@operatorGroupDescription	NVARCHAR(109),		-- incident.ref_operatordynanaam
	@operatorDescription		NVARCHAR(109),		-- incident.ref_operatorgroup
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
END
GO
