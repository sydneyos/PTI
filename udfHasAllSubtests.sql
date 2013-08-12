USE [PTI]
GO

/****** Object:  UserDefinedFunction [dbo].[udfHasAllSubtests]    Script Date: 8/11/2013 3:54:04 PM ******/
DROP FUNCTION [dbo].[udfHasAllSubtests]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- ==============================================================================================
-- Author:		Sydney Osborne
-- Create date: 11 Aug 2013
-- Description:	Determine whether a respondent has all specified occasions for a given subtest
-- ==============================================================================================
CREATE FUNCTION udfHasAllSubtests 
(
	@PersonID INT,
	@MeasureTypeID INT,
	@MeasureSubscaleTypeID INT,
	@PreTest bit = 1,
	@PostTest bit = 1,
	@ThreeMo bit = 0,
	@SixMo bit = 0,
	@NineMo bit = 0,
	@TwelveMo bit = 0
)
RETURNS TABLE
AS

	RETURN SELECT COUNT(*) as MissingCount
	FROM
		(
			SELECT OcassionTypeID
			FROM OcassionType
			--PreTest = 1, PostTest = 2, 3 Mo = 5, 6mo = 3, 9mo = 6, 12mo = 4
			WHERE (
					(@PreTest = 1 AND OcassionTypeID = 1) OR
					(@PostTest = 1 AND OcassionTypeID = 2) OR
					(@ThreeMo = 1 AND OcassionTypeID = 5) OR
					(@SixMo = 1 AND OcassionTypeID = 3) OR
					(@NineMo = 1 AND OcassionTypeID = 6) OR
					(@TwelveMo = 1 AND OcassionTypeID = 4)
				)
		) as ot
		LEFT JOIN (
			SELECT ifi.OcassionTypeID
			FROM [dbo].[FormInstance_MeasureSubscaleValue_ScoreTypeID_Score] fis --include to ensure valid score
			INNER JOIN [dbo].[FormInstance_MeasureSubscaleValue] fim
				ON fis.FormInstanceMeasureSubscaleValueID = fim.FormInstanceMeasureSubscaleValueID
			INNER JOIN [dbo].[FormInstance] ifi
				ON fim.FormInstanceID = ifi.FormInstanceID
			WHERE 
				ifi.AssessedPersonID = @PersonID
				AND fim.MeasureSubscaleTypeID = @MeasureSubscaleTypeID
				AND ifi.MeasureTypeID = MeasureTypeID
		) AS fi 
			ON ot.OcassionTypeID = fi.OcassionTypeID
	WHERE fi.OcassionTypeID IS NULL

END
GO

