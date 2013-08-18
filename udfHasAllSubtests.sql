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
	@InterventionID INT,
	@AssessedPersonID INT,
	@MeasureTypeID INT,
	@MeasureSubscaleTypeID INT,
	@IncludePreTest bit = 1,
	@IncludePostTest bit = 1,
	@IncludeThreeMo bit = 0,
	@IncludeSixMo bit = 0,
	@IncludeNineMo bit = 0,
	@IncludeTwelveMo bit = 0
)
RETURNS @table TABLE (MissingCount INT)
AS
BEGIN
	DECLARE @PreTest INT, @PostTest INT, @ThreeMonth INT, @SixMonth INT, @NineMonth INT, @TwelveMonth INT
	SELECT @PreTest = 1, @PostTest = 2, @ThreeMonth = 5, @SixMonth = 3, @NineMonth = 6, @TwelveMonth = 4

	INSERT @table 
	SELECT COUNT(*) as MissingCount
	FROM
		(
			SELECT OcassionTypeID
			FROM OcassionType
			--PreTest = 1, PostTest = 2, 3 Mo = 5, 6mo = 3, 9mo = 6, 12mo = 4
			WHERE (
					(@IncludePreTest = 1 AND OcassionTypeID = @PreTest) OR
					(@IncludePostTest = 1 AND OcassionTypeID = @PostTest) OR
					(@IncludeThreeMo = 1 AND OcassionTypeID = @ThreeMonth) OR
					(@IncludeSixMo = 1 AND OcassionTypeID = @SixMonth) OR
					(@IncludeNineMo = 1 AND OcassionTypeID = @NineMonth) OR
					(@IncludeTwelveMo = 1 AND OcassionTypeID = @TwelveMonth)
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
				ifi.InterventionID = @InterventionID
				AND ifi.AssessedPersonID = @AssessedPersonID
				AND fim.MeasureSubscaleTypeID = @MeasureSubscaleTypeID
				AND ifi.MeasureTypeID = @MeasureTypeID
		) AS fi 
			ON ot.OcassionTypeID = fi.OcassionTypeID
	WHERE fi.OcassionTypeID IS NULL

	RETURN
END
GO

