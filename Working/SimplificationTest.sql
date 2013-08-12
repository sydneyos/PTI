SELECT COUNT(*)
FROM
	vwAgencyInterventionPersonMeasureSubscaleValue vw1

	LEFT JOIN

	 vwAgencyInterventionPersonMeasureSubscaleValue vw2

		ON vw1.InterventionID						= vw2.InterventionID
		AND vw1.AssessedPersonID						= vw2.AssessedPersonID
		AND vw1.RespondentPersonID					= vw2.RespondentPersonID
		AND vw1.MeasureTypeID						= vw2.MeasureTypeID
		AND vw1.MeasureSubscaleTypeID				= vw2.MeasureSubscaleTypeID
		AND vw1.ScoreTypeID							= vw2.ScoreTypeID
		AND vw2.OcassionTypeID = 2

WHERE vw1.OcassionTypeID=1