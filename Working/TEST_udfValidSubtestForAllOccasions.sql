DECLARE @IncludePostTest bit = 1,
	@IncludeThreeMo bit = 1,
	@IncludeSixMo bit = 0,
	@IncludeNineMo bit = 0,
	@IncludeTwelveMo bit = 0,
	@MeasureTypeID INT,
	@MeasureSubscaleTypeID INT

DECLARE @PreTest INT, @PostTest INT, @ThreeMonth INT, @SixMonth INT, @NineMonth INT, @TwelveMonth INT
SELECT @PreTest = 1, @PostTest = 2, @ThreeMonth = 5, @SixMonth = 3, @NineMonth = 6, @TwelveMonth = 4

SET @MeasureTypeID = 3
SET @MeasureSubscaleTypeID = 25	--PS Total Score 2F

SELECT * FROM udfValidSubtestForAllOccasions(@MeasureTypeID, @IncludePostTest, @IncludeThreeMo, @IncludeSixMo, @IncludeNineMo, @IncludeTwelveMo)
WHERE MeasureSubscaleTypeID = @MeasureSubscaleTypeID

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
	AND @MeasureSubscaleTypeID = MeasureSubscaleTypeID