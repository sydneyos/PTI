USE [PTI]
GO

/****** Object:  View [dbo].[vwAgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest]    Script Date: 8/11/2013 10:49:43 AM ******/
DROP VIEW [dbo].[vwAgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest]
GO

/****** Object:  View [dbo].[vwAgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest]    Script Date: 8/11/2013 10:49:43 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vwAgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest]
AS
/*

select * from vwAgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest
order by interventionid

*/

SELECT
	vw.AgencyID, 
	vw.Agency, 
	vw.[Agency Name], 
	vw.[InterventionID], 
	vw.Intervention, 
	vw.InterventionStartDate,
	vw.InterventionEndDate,
	vw.InterventionTypeID, 
	vw.InterventionSubtypeID,
	vw.[Intervention Type], 
	vw.DeliveryFormatTypeID,
	vw.DeliveryFormatType,
	vw.LanguageID,
	vw.FormInstanceID				as Pretest_FormInstanceID,
	vw.[AssessedPersonID], 
	vw.[Assessed Person], 
	vw.RespondentPersonID, 
	vw.Respondent, 
	vw.MeasureTypeID, 
	vw.Measure, 
	vw.MeasureSubscaleTypeID,
	vw.MeasureSubscaleType, 
	--vw.FormInstanceMeasureSubscaleValueID,
	vw.MeasureSubscaleValue,
	vw.ScoreTypeID,
	vw.[Score Type]				as [Score Type],	
	vw.SortOrder, 
	vw.NumericOrVerbose			,
	vw.NumericScore				as [Pretest Numeric Score],
	-----------------------------------------------------------------
	CASE
		WHEN vw2.InterventionID > 0 THEN 1
		ELSE 0
	END as RespondentIsCompleter,
	-----------------------------------------------------------------
	--CASE
	--	WHEN vw2.InterventionID > 0 THEN vw.Score
	--	ELSE 0
	--END as [Completer Pretest Score],
	-----------------------------------------------------------------
	--vw2.[Ocassion],
	vw2.AssessedPersonID		as Posttest_AssessedPersonID,
	vw2.NumericScore			as [Posttest Numeric Score],
	vw2.FormInstanceID			as Posttest_FormInstanceID
FROM
	( SELECT * FROM vwAgencyInterventionPersonMeasureSubscaleValue WHERE OcassionTypeID=1 )				vw

	LEFT JOIN 
			( 

				SELECT 
					vw_2.*
				FROM 
					vwAgencyInterventionPersonMeasureSubscaleValue					vw_2

					LEFT JOIN vwAgencyInterventionPersonMeasureSubscaleValue		vw_1
						ON vw_1.InterventionID						= vw_2.InterventionID
						AND vw_1.AssessedPersonID					= vw_2.AssessedPersonID
						AND vw_1.RespondentPersonID					= vw_2.RespondentPersonID
						AND vw_1.MeasureTypeID						= vw_2.MeasureTypeID
						AND vw_1.MeasureSubscaleTypeID				= vw_2.MeasureSubscaleTypeID
						AND vw_1.ScoreTypeID						= vw_2.ScoreTypeID --both have a valid score
						AND vw_2.OcassionTypeID=2 
						AND vw_1.OcassionTypeID=1
				WHERE 
					vw_1.InterventionID IS NOT NULL

			)	vw2
		ON vw.InterventionID						= vw2.InterventionID
		AND vw.AssessedPersonID						= vw2.AssessedPersonID
		AND vw.RespondentPersonID					= vw2.RespondentPersonID
		AND vw.MeasureTypeID						= vw2.MeasureTypeID
		AND vw.MeasureSubscaleTypeID				= vw2.MeasureSubscaleTypeID
		AND vw.ScoreTypeID							= vw2.ScoreTypeID

		
/*
select distinct [Measure]
FROM [vwAgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest]
where RespondentIsCompleter=1

		WHERE
			NumericOrVerbose='Numeric'
			or NumericOrVerbose is null


AgencyID, 
Agency, 
Agency Name, 
InterventionID, 
Intervention, 
InterventionTypeID, 
Intervention Type, 
, 
AssessedPersonID, 
Assessed Person, 
RespondentPersonID, 
Respondent, 
MeasureTypeID, 
Measure, 
OcassionTypeID, 
Ocassion, 
MeasureSubscaleTypeID, 
Score Type, 
MeasureSubscaleValue
*/


GO


