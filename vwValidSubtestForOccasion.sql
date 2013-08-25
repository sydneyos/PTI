USE [PTI]
GO

/****** Object:  View [dbo].[vwValidSubtestsForOccasion]    Script Date: 8/24/2013 2:34:31 PM ******/
DROP VIEW [dbo].[vwValidSubtestsForOccasion]
GO

/****** Object:  View [dbo].[vwValidSubtestsForOccasion]    Script Date: 8/24/2013 2:34:31 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[vwValidSubtestsForOccasion]
AS
	SELECT ifi.OcassionTypeID, ifi.InterventionID, ifi.AssessedPersonID, ifi.RespondentPersonID, fim.MeasureSubscaleTypeID, ifi.MeasureTypeID, ScoreTypeID
	FROM [dbo].[FormInstance_MeasureSubscaleValue_ScoreTypeID_Score] fis --include to ensure valid score
	INNER JOIN [dbo].[FormInstance_MeasureSubscaleValue] fim
		ON fis.FormInstanceMeasureSubscaleValueID = fim.FormInstanceMeasureSubscaleValueID
	INNER JOIN [dbo].[FormInstance] ifi
		ON fim.FormInstanceID = ifi.FormInstanceID
	WHERE (fim.Invalid = 0 OR fim.Invalid IS NULL)
	AND NumericScore IS NOT NULL
	AND ScoreTypeID IS NOT NULL
GO


