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
	@operatorDescription		NVARCHAR(109)		-- incident.ref_operatorgroup
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @RC					INT,			-- SPROC return value.  1 successful update.  0 unsuccessful update or error.
	@errorMessage				NVARCHAR(4000), -- For logging any error. 
	@errorMessageEmailText		NVARCHAR(MAX),	-- Email text for for sp_send_dbmail.
	@errorMessageEmailSubject	NVARCHAR(MAX),	-- Email subject for sp_send_dbmail.
	
	@incidentTypeName			NVARCHAR(100) = (	SELECT [naam] 
													FROM [soortmelding] 
													WHERE [unid] = @incidentTypeUNID)
	
	SET XACT_ABORT OFF	-- This prevents the calling program (the Trigger in this case) from rolling back it's Transaction.
	BEGIN TRY
		UPDATE [incident]
		SET
			[impactid]				= @impactUNID,
			[ref_soortmelding]		= @incidentTypeName,			-- Incident Type description.
			[soortmeldingid]		= @incidentTypeUNID,			-- The Incident Type is Incident.
			[vrijelogisch5]			= @kaseyaAutomation,			-- 1 indicates Kaseya automation.  Event and Action will set Status to Responded.
			[soortbinnenkomstid]	= @entryUNID,					-- Entry i.e. Alert.
			[operatorgroupid]		= @operatorGroupUNID,			-- Operator Group uniqueidentifier.
			[operatorid]			= @operatorUNID,				-- Operator ID.  For Kaseay Automation, this will be the same as the Operator Group ID.  i.e. ~RS-2nd.
			[ref_operatordynanaam]	= @operatorGroupDescription,	-- Operator Group description.
			[ref_operatorgroup]		= @operatorDescription			-- Operator description.
		WHERE 
			[naam] = @strIncidentNumber	

		SET @RC = 1
	END TRY

	BEGIN CATCH
		SET @RC = 0
		SET @errorMessage = ERROR_MESSAGE()
		SET @errorMessageEmailText = 'Please see Incident: ' + @strIncidentNumber + '.  The Stored Procedure, ' + OBJECT_NAME(@@PROCID) + ' has failed with below error: ' + 
		CHAR(10) + CHAR(13) + @errormessage + '.'

		SET @errorMessageEmailSubject = OBJECT_NAME(@@PROCID) + '.' + 'Incident number: ' + @strIncidentNumber

	END CATCH
END

SELECT OBJECT_NAME(@@PROCID)

