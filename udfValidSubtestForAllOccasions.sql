USE [PTI]
GO

--SELECT * FROM dbo.udfValidSubtestForAllOccasions(1, 1, 1, 0, 1)

/****** Object:  UserDefinedFunction [dbo].[udfValidSubtestForAllOccasions]    Script Date: 8/11/2013 3:54:04 PM ******/
DROP FUNCTION [dbo].[udfValidSubtestForAllOccasions]
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
CREATE FUNCTION udfValidSubtestForAllOccasions 
(
	@MeasureTypeID INT,
	@IncludePostTest bit = 1,
	@IncludeThreeMo bit = 0,
	@IncludeSixMo bit = 0,
	@IncludeNineMo bit = 0,
	@IncludeTwelveMo bit = 0
)
RETURNS @table TABLE (InterventionID INT, AssessedPersonID INT, RespondentPersonID INT, MeasureTypeID INT, MeasureSubscaleTypeID INT, ScoreTypeID INT)
AS
BEGIN
	DECLARE @PreTest INT, @PostTest INT, @ThreeMonth INT, @SixMonth INT, @NineMonth INT, @TwelveMonth INT
	SELECT @PreTest = 1, @PostTest = 2, @ThreeMonth = 5, @SixMonth = 3, @NineMonth = 6, @TwelveMonth = 4

	INSERT @table
	SELECT 
		InterventionID, 
		AssessedPersonID, 
		RespondentPersonID, 
		MeasureTypeID, 
		MeasureSubscaleTypeID,
		ScoreTypeID
	FROM 
		(
			SELECT DISTINCT 
				InterventionID, 
				AssessedPersonID, 
				RespondentPersonID, 
				MeasureTypeID, 
				MeasureSubscaleTypeID,
				ScoreTypeID,
				[1],
				[2],
				[5],
				[3],
				[6],
				[4]
			FROM 
			(
				SELECT DISTINCT InterventionID, 
				AssessedPersonID, 
				RespondentPersonID, 
				MeasureTypeID, 
				MeasureSubscaleTypeID,
				ScoreTypeID, 
				v.OcassionTypeID, 
				1 as Placeholder
				FROM vwValidSubtestsForOccasion v
				INNER JOIN OcassionType o
				ON v.OcassionTypeID = o.OcassionTypeID
				WHERE (@MeasureTypeID IS NULL OR (v.MeasureTypeID = @MeasureTypeID))
				) T
			PIVOT (
				AVG(Placeholder)
				FOR OcassionTypeID
				IN ([1], [2], [5], [3], [6], [4]) 
			) AS P
		) O
	WHERE [1] IS NOT NULL
	AND (@IncludePostTest = 0 OR (@IncludePostTest = 1 AND [2] IS NOT NULL))
	AND (@IncludeThreeMo = 0 OR (@IncludeThreeMo = 1 AND [5] IS NOT NULL))
	AND (@IncludeSixMo = 0 OR (@IncludeSixMo = 1 AND [3] IS NOT NULL))
	AND (@IncludeNineMo = 0 OR (@IncludeNineMo = 1 AND [6] IS NOT NULL))
	AND (@IncludeTwelveMo = 0 OR (@IncludeTwelveMo = 1 AND [4] IS NOT NULL))
	RETURN
END
GO

