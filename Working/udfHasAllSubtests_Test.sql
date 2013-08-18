DECLARE @AssessedPersonID INT,
	@MeasureTypeID INT,
	@MeasureSubscaleTypeID INT,
	@PreTest bit,
	@PostTest bit,
	@ThreeMo bit,
	@SixMo bit,
	@NineMo bit,
	@TwelveMo bit

--SELECT @PreTest = 1, @PostTest = 1, @PersonID = 6475, @MeasureTypeID = 3, @MeasureSubscaleTypeID = 14 -- both
SELECT @PreTest = 1, @PostTest = 1, @AssessedPersonID = 6486, @MeasureTypeID = 4, @MeasureSubscaleTypeID = 18 -- one

SELECT COUNT(*) as MissingCount
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
				AND fim.MeasureSubscaleTypeID = @MeasureSubscaleTypeID
				AND ifi.MeasureTypeID = @MeasureTypeID
				AND (fim.Invalid = 0 OR fim.Invalid IS NULL)
		) AS fi 
			ON ot.OcassionTypeID = fi.OcassionTypeID
	WHERE fi.OcassionTypeID IS NULL