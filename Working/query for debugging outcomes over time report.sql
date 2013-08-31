use pti

DECLARE @MeasureTypeID int
DECLARE @ScoreTypeID int
DECLARE @MeasureSubscaleTypeID int

/*
SET @MeasureTypeID = 1 --ECBF
SET @MeasureSubscaleTypeID = 1 --Intensity
SET @ScoreTypeID = 5 --Raw Score

SET @MeasureTypeID = 1 --ECBF
SET @MeasureSubscaleTypeID = 2 --Problem
SET @ScoreTypeID = 5 --Raw Score

SET @MeasureTypeID = 3 --Parenting Scale
SET @MeasureSubscaleTypeID = 11	--Laxness (LX) 3F
SET @ScoreTypeID = 5 --Raw Score
*/

SET @MeasureTypeID = 3 --Parenting Scale
SET @MeasureSubscaleTypeID = 25	--PS Total Score 2F
SET @ScoreTypeID = 5 --Raw Score

/*
SET @MeasureTypeID = 3 --Parenting Scale
SET @MeasureSubscaleTypeID = 24	--Over Reactivity (OR) 2F
SET @ScoreTypeID = 5 --Raw Score
*/
SELECT 
	COUNT(DISTINCT pre.FormInstanceID)		as pre,
	COUNT(DISTINCT post.FormInstanceID)		as post,
	COUNT(DISTINCT three.FormInstanceID)	as three,
	COUNT(DISTINCT six.FormInstanceID)		as six,
	COUNT(DISTINCT yr.FormInstanceID)		as yr
FROM	
	FormInstance																			pre

	JOIN FormInstance_MeasureSubscaleValue													sv1
		ON pre.FormInstanceID=sv1.FormInstanceID
		AND sv1.MeasureSubscaleTypeID=@MeasureSubscaleTypeID
		--AND sv1.Invalid=0

	JOIN FormInstance_MeasureSubscaleValue_ScoreTypeID_Score								sc1
		ON sv1.FormInstanceMeasureSubscaleValueID=sc1.FormInstanceMeasureSubscaleValueID
		AND sc1.ScoreTypeID=@ScoreTypeID
		AND sc1.NumericScore IS NOT NULL
	-----------------------------------------------------------------------------------------------------------
	LEFT JOIN
		(
			SELECT
				x.FormInstanceID,
				RespondentPersonID,
				AssessedPersonID,
				InterventionID,
				MeasureTypeID
			FROM 
				FormInstance																			x

				JOIN FormInstance_MeasureSubscaleValue													sv2
					ON x.FormInstanceID=sv2.FormInstanceID
					AND sv2.MeasureSubscaleTypeID=@MeasureSubscaleTypeID
					--AND sv2.Invalid=0

				JOIN FormInstance_MeasureSubscaleValue_ScoreTypeID_Score								sc2
					ON sv2.FormInstanceMeasureSubscaleValueID=sc2.FormInstanceMeasureSubscaleValueID
					AND sc2.ScoreTypeID=@ScoreTypeID
					AND sc2.NumericScore IS NOT NULL
			WHERE
				x.OcassionTypeID=2
		) post
				ON pre.RespondentPersonID	= post.RespondentPersonID
				AND pre.AssessedPersonID	= post.AssessedPersonID
				AND pre.InterventionID		= post.InterventionID
				AND pre.MeasureTypeID		= post.MeasureTypeID
	-----------------------------------------------------------------------------------------------------------
	LEFT JOIN
			(
				SELECT
					x.FormInstanceID,
					RespondentPersonID,
					AssessedPersonID,
					InterventionID,
					MeasureTypeID
				FROM 
					FormInstance																			x

					JOIN FormInstance_MeasureSubscaleValue													sv3
						ON x.FormInstanceID=sv3.FormInstanceID
						AND sv3.MeasureSubscaleTypeID=@MeasureSubscaleTypeID
						--AND sv2.Invalid=0

					JOIN FormInstance_MeasureSubscaleValue_ScoreTypeID_Score								sc3
						ON sv3.FormInstanceMeasureSubscaleValueID=sc3.FormInstanceMeasureSubscaleValueID
						AND sc3.ScoreTypeID=@ScoreTypeID
						AND sc3.NumericScore IS NOT NULL
				WHERE
					x.OcassionTypeID=5
			) three
					ON post.RespondentPersonID	= three.RespondentPersonID
					AND post.AssessedPersonID	= three.AssessedPersonID
					AND post.InterventionID		= three.InterventionID
					AND post.MeasureTypeID		= three.MeasureTypeID
	-----------------------------------------------------------------------------------------------------------
	LEFT JOIN
			(
				SELECT
					x.FormInstanceID,
					RespondentPersonID,
					AssessedPersonID,
					InterventionID,
					MeasureTypeID
				FROM 
					FormInstance																			x

					JOIN FormInstance_MeasureSubscaleValue													sv4
						ON x.FormInstanceID=sv4.FormInstanceID
						AND sv4.MeasureSubscaleTypeID=@MeasureSubscaleTypeID
						--AND sv4.Invalid=0

					JOIN FormInstance_MeasureSubscaleValue_ScoreTypeID_Score								sc4
						ON sv4.FormInstanceMeasureSubscaleValueID=sc4.FormInstanceMeasureSubscaleValueID
						AND sc4.ScoreTypeID=@ScoreTypeID
						AND sc4.NumericScore IS NOT NULL
				WHERE
					x.OcassionTypeID=3
			) six
					ON post.RespondentPersonID	= six.RespondentPersonID
					AND post.AssessedPersonID	= six.AssessedPersonID
					AND post.InterventionID		= six.InterventionID
					AND post.MeasureTypeID		= six.MeasureTypeID
	-----------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------------
	LEFT JOIN
			(
				SELECT
					x.FormInstanceID,
					RespondentPersonID,
					AssessedPersonID,
					InterventionID,
					MeasureTypeID
				FROM 
					FormInstance																			x

					JOIN FormInstance_MeasureSubscaleValue													sv5
						ON x.FormInstanceID=sv5.FormInstanceID
						AND sv5.MeasureSubscaleTypeID=@MeasureSubscaleTypeID
						--AND sv5.Invalid=0

					JOIN FormInstance_MeasureSubscaleValue_ScoreTypeID_Score								sc5
						ON sv5.FormInstanceMeasureSubscaleValueID=sc5.FormInstanceMeasureSubscaleValueID
						AND sc5.ScoreTypeID=@ScoreTypeID
						AND sc5.NumericScore IS NOT NULL
				WHERE
					x.OcassionTypeID=4
			) yr
					ON post.RespondentPersonID	= yr.RespondentPersonID
					AND post.AssessedPersonID	= yr.AssessedPersonID
					AND post.InterventionID		= yr.InterventionID
					AND post.MeasureTypeID		= yr.MeasureTypeID
	-----------------------------------------------------------------------------------------------------------
WHERE
	pre.MeasureTypeID = @MeasureTypeID
	AND pre.OcassionTypeID=1


/*
select * from ocassiontype

select * from measuretype
select * from MeasureSubscaleType
select * from ScoreType

select * from FormInstance_MeasureSubscaleValue
select * from FormInstance_MeasureSubscaleValue_ScoreTypeID_Score
	*/

/*
SELECT * FROM vwFormInstance_MeasureSubscaleValue_Score v
WHERE v.MeasureTypeAbbrev='PS'
AND v.MeasureSubscaleType='Over Reactivity (OR) 2F'
AND v.ScoreType='RAW Score'
AND Score='0.00'
ANd v.OcassionTypeName='Posttest'

SELECT * FROM FormInstance_MeasureSubscaleValue
WHERE FormInstanceID IN
(
2379,
4779,
2345,
3395,
2422,
1126,
2410
)
*/