USE [PTI]
GO

--SELECT * FROM dbo.udfValidSubtestForAllOccasions(1, 0, 0, 0, 0)

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
	@IncludePostTest bit = 1,
	@IncludeThreeMo bit = 0,
	@IncludeSixMo bit = 0,
	@IncludeNineMo bit = 0,
	@IncludeTwelveMo bit = 0
)
RETURNS @table TABLE (InterventionID INT, AssessedPersonID INT, RespondentPersonID INT, MeasureTypeID INT, MeasureSubscaleTypeID INT)
AS
BEGIN
	DECLARE @PreTest INT, @PostTest INT, @ThreeMonth INT, @SixMonth INT, @NineMonth INT, @TwelveMonth INT
	SELECT @PreTest = 1, @PostTest = 2, @ThreeMonth = 5, @SixMonth = 3, @NineMonth = 6, @TwelveMonth = 4

	INSERT @table 
	
	SELECT DISTINCT one.InterventionID, one.AssessedPersonID, one.RespondentPersonID, one.MeasureTypeID, one.MeasureSubscaleTypeID
	FROM vwValidSubtestsForOccasion one
	LEFT JOIN vwValidSubtestsForOccasion two
		ON one.InterventionID = two.InterventionID
		AND one.AssessedPersonID = two.AssessedPersonID
		AND one.RespondentPersonID = two.RespondentPersonID
		AND one.MeasureTypeID = two.MeasureTypeID
		AND one.MeasureSubscaleTypeID = two.MeasureSubscaleTypeID
		AND one.OcassionTypeID = @PreTest
		AND two.OcassionTypeID = @PostTest
	LEFT JOIN vwValidSubtestsForOccasion three
		ON one.InterventionID = three.InterventionID
		AND one.AssessedPersonID = three.AssessedPersonID
		AND one.RespondentPersonID = three.RespondentPersonID
		AND one.MeasureTypeID = three.MeasureTypeID
		AND one.MeasureSubscaleTypeID = three.MeasureSubscaleTypeID
		AND one.OcassionTypeID = @PreTest
		AND three.OcassionTypeID  = @ThreeMonth
	LEFT JOIN vwValidSubtestsForOccasion four
		ON one.InterventionID = four.InterventionID
		AND one.AssessedPersonID = four.AssessedPersonID
		AND one.RespondentPersonID = four.RespondentPersonID
		AND one.MeasureTypeID = four.MeasureTypeID
		AND one.MeasureSubscaleTypeID = four.MeasureSubscaleTypeID
		AND one.OcassionTypeID = @PreTest
		AND four.OcassionTypeID = @SixMonth
	LEFT JOIN vwValidSubtestsForOccasion five
		ON one.InterventionID = five.InterventionID
		AND one.AssessedPersonID = five.AssessedPersonID
		AND one.RespondentPersonID = five.RespondentPersonID
		AND one.MeasureTypeID = five.MeasureTypeID
		AND one.MeasureSubscaleTypeID = five.MeasureSubscaleTypeID
		AND one.OcassionTypeID = @PreTest
		AND five.OcassionTypeID = @TwelveMonth
	WHERE (one.OcassionTypeID = @PreTest)
	AND (@IncludePostTest = 0 OR (@IncludePostTest = 1 AND two.OcassionTypeID IS NOT NULL))
	AND (@IncludeThreeMo = 0 OR (@IncludeThreeMo = 1 AND three.OcassionTypeID IS NOT NULL))
	AND (@IncludeSixMo = 0 OR (@IncludeSixMo = 1 AND four.OcassionTypeID IS NOT NULL))
	AND (@IncludeTwelveMo = 0 OR (@IncludeTwelveMo = 1 AND five.OcassionTypeID IS NOT NULL))

	RETURN
END
GO

