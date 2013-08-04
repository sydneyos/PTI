USE [PTI]
GO
/****** Object:  StoredProcedure [dbo].[spReport_AllScores]    Script Date: 8/4/2013 10:09:51 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


ALTER PROCEDURE [dbo].[spReport_AllScores]
AS

SELECT
	i.AgencyAbbreviation										as Agency,
	fi.InterventionName											as Intervention,
	i.InterventionType											as InterventionType,	
	d.DateOfAssessment											as [Pretest Date],
	----------------------------------------------------------------------------------------------------------
	fi.RespondentPersonID,
	fi.RespondentFirstMiddleLast								as Respondent,
	csa.ContentSessionsAttended									as ContentSessionsAttended,
	rp.Ethnicity_1												as [Respondent Ethncity_1]  ,
	rp.Ethnicity_2												as [Respondent Ethncity_2]  ,
	--rp.Ethnicity_3											as [Respondent Ethncity_3]  ,
	--rp.Ethnicity_4											as [Respondent Ethncity_4]  ,

	--DATEDIFF ( year , rp.BirthDate , i.InterventionStartDate)	as [Respondent Age],
	[Respondent Age]											as [Respondent Age at Pretest],

	d.MaritalStatus												as [Respondent Marital Status at Pretest],
	d.AnnualIncomeType											as [Respondent Household Income at Pretest],
	d.Education													as [Respondent Education Level at Pretest],
	----------------------------------------------------------------------------------------------------------
	fi.AssessedPersonID,
	fi.AssessedPersonFirstMiddleLast							as [Person Assessed],
	ap.Ethnicity_1												as [Person Assessed Ethncity_1]  ,
	ap.Ethnicity_2												as [Person Assessed Ethncity_2]  ,
	--ap.Ethnicity_3											as [Person Assessed Ethncity_3]  ,
	--ap.Ethnicity_4											as [Person Assessed Ethncity_4]  ,

	DATEDIFF ( year , ap.BirthDate , i.InterventionStartDate)	as [Person Assessed Age],
	----------------------------------------------------------------------------------------------------------

	fi.FormInstanceID											as FormInstanceID,

	fi.MeasureTypeName											as [Measure Type],
	fi.OcassionTypeName											as Occasion,
	fi.DateOfAssessment											as [Assessment Date],

	st.MeasureSubscaleType										as [Score Type],
	fis.MeasureSubscaleValue									as [Raw Score],	

	sct.ScoreType												as [Score Conversion Type],

	CASE
		WHEN VerboseScore > '' THEN VerboseScore
		ELSE CAST ( NumericScore as varchar )
	END															as [Score Conversion],

	SessionAttended												as [Undated Sessiond Attended]
FROM
	vwIntervention																					i

	LEFT JOIN vwFormInstance																		fi
		ON i.InterventionID = fi.InterventionID

	LEFT JOIN FormInstance_MeasureSubscaleValue														fis
		ON fi.FormInstanceID = fis.FormInstanceID

	LEFT JOIN MeasureSubscaleType																	st
		ON fis.MeasureSubscaleTypeID = st.MeasureSubscaleTypeID

	--LEFT JOIN dbo.ScoreType_ScoreConversionType													x

	LEFT JOIN FormInstance_MeasureSubscaleValue_ScoreTypeID_Score									sc
		ON fis.FormInstanceMeasureSubscaleValueID = sc.FormInstanceMeasureSubscaleValueID

	LEFT JOIN ScoreType																				sct
		ON sc.ScoreTypeID = sct.ScoreTypeID

	LEFT JOIN vwPerson																				rp
		ON rp.PersonID = fi.RespondentPersonID

	LEFT JOIN vwIntervention_Person_ContentSessionsAttended											csa
		ON i.InterventionID = csa.InterventionID
		AND csa.PersonID=rp.PersonID

	LEFT JOIN vwPerson																				ap
		ON ap.PersonID = fi.AssessedPersonID

	LEFT JOIN vwFormInstance_Respondent_DemographicsAtPretest										d
		ON d.InterventionID=i.InterventionID
		AND d.RespondentPersonID=fi.RespondentPersonID
		AND d.MeasureTypeID=fi.MeasureTypeID

	LEFT JOIN Intervention_Member_UndatedSessionsAttended											us
		ON us.InterventionID = i.InterventionID
		AND us.PersonID = rp.PersonID
ORDER BY
	i.AgencyAbbreviation										,
	fi.InterventionName											,	
	
	fi.RespondentFirstMiddleLast								,
	fi.AssessedPersonFirstMiddleLast							,
	fi.MeasureTypeName											,
	fi.OcassionTypeName											,
	fi.DateOfAssessment											,

	st.MeasureSubscaleType										,
	fis.MeasureSubscaleValue									,	

	sct.SortOrder															

























