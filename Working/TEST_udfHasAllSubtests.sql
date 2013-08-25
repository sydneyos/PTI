DECLARE 
	@InterventionID INT,
	@AssessedPersonID INT,
	@RespondentPersonID INT,
	@MeasureTypeID INT,
	@MeasureSubscaleTypeID INT,
	@IncludePreTest bit,
	@IncludePostTest bit,
	@IncludeThreeMo bit,
	@IncludeSixMo bit,
	@IncludeNineMo bit,
	@IncludeTwelveMo bit

	
DECLARE @PreTest INT, @PostTest INT, @ThreeMonth INT, @SixMonth INT, @NineMonth INT, @TwelveMonth INT
SELECT @PreTest = 1, @PostTest = 2, @ThreeMonth = 5, @SixMonth = 3, @NineMonth = 6, @TwelveMonth = 4

SELECT 
@IncludePreTest = 1
, @IncludePostTest = 1
, @IncludeThreeMo = 0
, @IncludeSixMo = 0
, @IncludeTwelveMo = 0
, @InterventionID = 81
, @AssessedPersonID = 1460
, @RespondentPersonID = 1460
, @MeasureTypeID = 4
, @MeasureSubscaleTypeID = 10 -- has all

--SELECT 
--@IncludePreTest = 1
--, @IncludePostTest = 1
--, @IncludeThreeMo = 1
--, @IncludeSixMo = 1
--, @IncludeTwelveMo = 1
--, @InterventionID = 82
--, @AssessedPersonID = 1492
--, @RespondentPersonID = 1492
--, @MeasureTypeID = 4
--, @MeasureSubscaleTypeID = 10 -- does not have all

--/****** Script for SelectTopNRows command from SSMS  ******/
--SELECT DISTINCT TOP 1000 [OcassionTypeID]
--      ,[InterventionID]
--      ,[AssessedPersonID]
--      ,[RespondentPersonID]
--      ,[MeasureSubscaleTypeID]
--      ,[MeasureTypeID]
--  FROM [PTI].[dbo].[vwValidSubtestsForOccasion]
--  WHERE AssessedPersonID = @AssessedPersonID
--  AND RespondentPersonID = @RespondentPersonID
--  AND MeasureTypeID = @MeasureTypeID
--  AND MeasureSubscaleTypeID = @MeasureSubscaleTypeID
--  ORDER BY InterventionID, AssessedPersonID, RespondentPersonID, MeasureTypeID, MeasureSubscaleTypeID, OcassionTypeID

--SELECT OcassionTypeID
--FROM OcassionType
----PreTest = 1, PostTest = 2, 3 Mo = 5, 6mo = 3, 9mo = 6, 12mo = 4
--WHERE (
--		(@IncludePreTest = 1 AND OcassionTypeID = 1) OR
--		(@IncludePostTest = 1 AND OcassionTypeID = 2) OR
--		(@IncludeThreeMo = 1 AND OcassionTypeID = 5) OR
--		(@IncludeSixMo = 1 AND OcassionTypeID = 3) OR
--		(@IncludeNineMo = 1 AND OcassionTypeID = 6) OR
--		(@IncludeTwelveMo = 1 AND OcassionTypeID = 4)
--	)

--SELECT ifi.OcassionTypeID
----SELECT ifi.AssessedPersonID, ifi.MeasureTypeID, fim.MeasureSubscaleTypeID,  ifi.OcassionTypeID
--FROM [dbo].[FormInstance_MeasureSubscaleValue_ScoreTypeID_Score] fis --include to ensure valid score
--INNER JOIN [dbo].[FormInstance_MeasureSubscaleValue] fim
--	ON fis.FormInstanceMeasureSubscaleValueID = fim.FormInstanceMeasureSubscaleValueID
--INNER JOIN [dbo].[FormInstance] ifi
--	ON fim.FormInstanceID = ifi.FormInstanceID
----WHERE ifi.MeasureTypeID IN (4, 1, 3)
----ORDER BY ifi.AssessedPersonID, ifi.MeasureTypeID, fim.MeasureSubscaleTypeID, ifi.OcassionTypeID
--WHERE 
--	ifi.AssessedPersonID = @AssessedPersonID
--	AND ifi.RespondentPersonID = @RespondentPersonID
--	AND ifi.InterventionID = @InterventionID
--	AND fim.MeasureSubscaleTypeID = @MeasureSubscaleTypeID
--	AND ifi.MeasureTypeID = @MeasureTypeID
--	AND (fim.Invalid = 0 OR fim.Invalid IS NULL)

SELECT COUNT(*) as MissingCount
	FROM
		(
			SELECT OcassionTypeID
			FROM OcassionType
			--PreTest = 1, PostTest = 2, 3 Mo = 5, 6mo = 3, 9mo = 6, 12mo = 4
			WHERE (
					(@IncludePreTest = 1 AND OcassionTypeID = 1) OR
					(@IncludePostTest = 1 AND OcassionTypeID = 2) OR
					(@IncludeThreeMo = 1 AND OcassionTypeID = 5) OR
					(@IncludeSixMo = 1 AND OcassionTypeID = 3) OR
					(@IncludeNineMo = 1 AND OcassionTypeID = 6) OR
					(@IncludeTwelveMo = 1 AND OcassionTypeID = 4)
				)
		) as ot
		LEFT JOIN (
			SELECT ifi.OcassionTypeID
			--SELECT ifi.AssessedPersonID, ifi.MeasureTypeID, fim.MeasureSubscaleTypeID,  ifi.OcassionTypeID
			FROM [dbo].[FormInstance_MeasureSubscaleValue_ScoreTypeID_Score] fis --include to ensure valid score
			INNER JOIN [dbo].[FormInstance_MeasureSubscaleValue] fim
				ON fis.FormInstanceMeasureSubscaleValueID = fim.FormInstanceMeasureSubscaleValueID
			INNER JOIN [dbo].[FormInstance] ifi
				ON fim.FormInstanceID = ifi.FormInstanceID
			--WHERE ifi.MeasureTypeID IN (4, 1, 3)
			--ORDER BY ifi.AssessedPersonID, ifi.MeasureTypeID, fim.MeasureSubscaleTypeID, ifi.OcassionTypeID
			WHERE 
				ifi.AssessedPersonID = @AssessedPersonID
				AND ifi.RespondentPersonID = @RespondentPersonID
				AND ifi.InterventionID = @InterventionID
				AND fim.MeasureSubscaleTypeID = @MeasureSubscaleTypeID
				AND ifi.MeasureTypeID = @MeasureTypeID
				AND (fim.Invalid = 0 OR fim.Invalid IS NULL)
		) AS fi 
			ON ot.OcassionTypeID = fi.OcassionTypeID
	WHERE fi.OcassionTypeID IS NULL


SELECT DISTINCT TOP 50  one.*--, two.OcassionTypeID, three.OcassionTypeID, four.OcassionTypeID, five.OcassionTypeID
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
--AND two.OcassionTypeID IS NOT NULL
--AND three.OcassionTypeID IS NOT NULL
--AND four.OcassionTypeID IS NULL
--AND five.OcassionTypeID IS NULL
AND one.AssessedPersonID = @AssessedPersonID
AND one.RespondentPersonID = @RespondentPersonID
AND one.InterventionID = @InterventionID
AND one.MeasureTypeID = @MeasureTypeID
AND one.MeasureSubscaleTypeID = @MeasureSubscaleTypeID

