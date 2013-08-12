USE [PTI]
GO

/****** Object:  View [dbo].[vwAgencyInterventionPersonMeasureSubscaleValue]    Script Date: 8/11/2013 12:32:48 PM ******/
DROP VIEW [dbo].[vwAgencyInterventionPersonMeasureSubscaleValue]
GO

/****** Object:  View [dbo].[vwAgencyInterventionPersonMeasureSubscaleValue]    Script Date: 8/11/2013 12:32:48 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vwAgencyInterventionPersonMeasureSubscaleValue]
AS
/*
select * from vwAgencyInterventionPersonMeasureSubscaleValue
where NumericScore is null 
and NumericOrVerbose = 'Numeric'


*/

SELECT DISTINCT
	a.AgencyID											as [AgencyID],
	a.AgencyAbbreviation								as [Agency],
	a.AgencyName										as [Agency Name],

	i.InterventionID									as [InterventionID],	
	i.InterventionName									as [Intervention],	

	i.InterventionStartDate								as [InterventionStartDate],
	i.InterventionEndDate								as [InterventionEndDate],

	i.InterventionTypeID								as [InterventionTypeID],
	it.InterventionType									as [Intervention Type],	

	i.InterventionSubtypeID								as [InterventionSubtypeID],
	ist.InterventionSubtype								as [InterventionSubtype],

	i.DeliveryFormatTypeID								as DeliveryFormatTypeID,
	df.DeliveryFormatType								as DeliveryFormatType,

	i.LanguageID,

	fi.FormInstanceID ,
	fis.FormInstanceMeasureSubscaleValueID				as FormInstanceMeasureSubscaleValueID,

	fi.AssessedPersonID									as AssessedPersonID,
	ap.FullName											as [Assessed Person],

	fi.RespondentPersonID								as RespondentPersonID,
	rp.FullName											as Respondent,

	fi.MeasureTypeID									as [MeasureTypeID],
	mt.Abbreviation										as [Measure],

	fi.OcassionTypeID									as OcassionTypeID,
	ot.OcassionTypeName									as [Ocassion],
	ot.SortOrder										as OccasionSortOrder,

	fis.MeasureSubscaleTypeID							as MeasureSubscaleTypeID,
	mst.MeasureSubscaleType								as MeasureSubscaleType,
	fis.MeasureSubscaleValue							as MeasureSubscaleValue,
	
	st.ScoreTypeID										AS ScoreTypeID,
	st.ScoreType										AS [Score Type],
	st.SortOrder,
	st.NumericOrVerbose									AS NumericOrVerbose,
	s.NumericScore										AS NumericScore	

FROM
	Agency																					a

	LEFT JOIN Intervention																	i
		ON i.AgencyID = a.AgencyID

	LEFT JOIN InterventionType																it
		ON it.InterventionTypeID = i.InterventionTypeID 

	LEFT JOIN InterventionSubtype															ist
		ON ist.InterventionSubtypeID = i.InterventionSubtypeID 

	LEFT JOIN DeliveryFormatType															df
		ON i.DeliveryFormatTypeID=df.DeliveryFormatTypeID

	LEFT JOIN FormInstance																	fi
		ON fi.InterventionID = i.InterventionID

	LEFT JOIN vwPerson																		rp
		ON rp.PersonID = fi.RespondentPersonID

	LEFT JOIN vwPerson																		ap
		ON ap.PersonID = fi.AssessedPersonID

	LEFT JOIN MeasureType																	mt
		ON mt.MeasureTypeID = fi.MeasureTypeID

	LEFT JOIN OcassionType																	ot
		ON ot.OcassionTypeID = fi.OcassionTypeID

	LEFT JOIN FormInstance_MeasureSubscaleValue												fis
		ON fis.FormInstanceID = fi.FormInstanceID 

	LEFT JOIN MeasureSubscaleType															mst
		ON mst.MeasureSubscaleTypeID = fis.MeasureSubscaleTypeID 

	LEFT JOIN MeasureSubscaleType_ScoreType													mstst
		ON mstst.MeasureSubscaleID = mst.MeasureSubscaleTypeID

	LEFT JOIN ScoreType																		st
		ON st.ScoreTypeID = mstst.ScoreTypeID
		--AND NumericOrVerbose = 'Numeric'

	LEFT JOIN FormInstance_MeasureSubscaleValue_ScoreTypeID_Score							s
		ON s.FormInstanceMeasureSubscaleValueID = fis.FormInstanceMeasureSubscaleValueID 
		AND s.ScoreTypeID=st.ScoreTypeID
WHERE
	( fis.Invalid = 0 OR fis.Invalid IS NULL )
	AND fis.MeasureSubscaleValue IS NOT NULL
-----------------------------------------------------------------------------------------------------
/*
select distinct [Measure]
FROM vwAgencyInterventionPersonMeasureSubscaleValue
where Ocassion = 'posttest'

SELECT COUNT(*) FROM vwAgencyInterventionPersonMeasureSubscaleValue
WHERE InterventionID=4

select * from vwAgencyInterventionPersonMeasureSubscaleValue


SELECT COUNT(*) FROM vwAgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest
WHERE InterventionID=4


-----------------------------------------------------------------------------------------------------
SELECT  
	fi.InterventionID,
	st.ScoreTypeID,
	COUNT(*),
	MIN ( s.NumericScore ),
	MAX ( s.NumericScore )
FROM
	Intervention																			i

	JOIN FormInstance																	fi
		ON fi.InterventionID = i.InterventionID

	JOIN FormInstance_MeasureSubscaleValue												fis
		ON fis.FormInstanceID=fi.FormInstanceID
		
	JOIN FormInstance_MeasureSubscaleValue_ScoreTypeID_Score							s
		ON s.FormInstanceMeasureSubscaleValueID = fis.FormInstanceMeasureSubscaleValueID 
		
	JOIN ScoreType																		st
		ON st.ScoreTypeID = s.ScoreTypeID
		AND NumericOrVerbose = 'Numeric' 
WHERE
	fis.Invalid = 0 OR fis.Invalid IS NULL
	--AND s.NumericScore IS NOT NULL
	AND OcassionTypeID=1
GROUP BY
	fi.InterventionID,
	st.ScoreTypeID
ORDER BY
	fi.InterventionID,
	st.ScoreTypeID
	*/


GO


