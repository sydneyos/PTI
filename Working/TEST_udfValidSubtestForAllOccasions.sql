DECLARE @IncludePostTest bit = 1,
	@IncludeThreeMo bit = 1,
	@IncludeSixMo bit = 1,
	@IncludeNineMo bit = 0,
	@IncludeTwelveMo bit = 1

DECLARE @PreTest INT, @PostTest INT, @ThreeMonth INT, @SixMonth INT, @NineMonth INT, @TwelveMonth INT
SELECT @PreTest = 1, @PostTest = 2, @ThreeMonth = 5, @SixMonth = 3, @NineMonth = 6, @TwelveMonth = 4

SELECT 
	InterventionID, 
	AssessedPersonID, 
	RespondentPersonID, 
	MeasureTypeID, 
	MeasureSubscaleTypeID
FROM 
	(
		SELECT DISTINCT 
			InterventionID, 
			AssessedPersonID, 
			RespondentPersonID, 
			MeasureTypeID, 
			MeasureSubscaleTypeID,
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
			v.OcassionTypeID, 
			1 as Placeholder
			FROM vwValidSubtestsForOccasion v
			INNER JOIN OcassionType o
			ON v.OcassionTypeID = o.OcassionTypeID
			) T
		PIVOT (
			AVG(Placeholder)
			FOR OcassionTypeID
			IN ([1], [2], [5], [3], [6], [4]) 
		) AS P
	) O
WHERE (@IncludePostTest = 0 OR (@IncludePostTest = 1 AND [2] IS NOT NULL))
AND (@IncludeThreeMo = 0 OR (@IncludeThreeMo = 1 AND [5] IS NOT NULL))
AND (@IncludeSixMo = 0 OR (@IncludeSixMo = 1 AND [3] IS NOT NULL))
AND (@IncludeNineMo = 0 OR (@IncludeNineMo = 1 AND [6] IS NOT NULL))
AND (@IncludeTwelveMo = 0 OR (@IncludeTwelveMo = 1 AND [4] IS NOT NULL))