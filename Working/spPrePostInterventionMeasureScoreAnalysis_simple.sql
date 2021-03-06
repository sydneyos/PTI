USE [PTI]
GO
/****** Object:  StoredProcedure [dbo].[spPrePostInterventionMeasureScoreAnalysis_simple]    Script Date: 8/11/2013 10:43:04 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[spPrePostInterventionMeasureScoreAnalysis_simple]
@AgencyID						int = NULL,
@InterventionID					int = NULL,
@RespondentPersonID				int = NULL,
@AssessedPersonID				int = NULL,
@MeasureTypeID					int = NULL,
@InterventionTypeID				int = NULL,
@InterventionSubtypeID			int = NULL,
@InterventionFacilitatorID		int = NULL,
@InterventionStartDateFrom		datetime = NULL,
@InterventionStartDateTo		datetime = NULL,
------------------------------------------------------------------------------------------------------------------------------------------------------
-- added by MF 9/26/2010
------------------------------------------------------------------------------------------------------------------------------------------------------
@InterventionLanguageID				int = NULL,
@AnnualIncomeTypeID					int = NULL,
@EthnicityID						int = NULL,
@EthnicityMajorGroupID              int = NULL,
@Exclude_AgencyID					int = NULL,
@Exclude_InterventionFacilitatorID	int = NULL,
@DeliveryFormatTypeID				int = NULL,
@RespondentGenderID					int = NULL,
@RespondentIsClientOfAgencyID		int = NULL,
@AssessedPersonIsClientOfAgencyID	int = NULL,
@RespondentIsNotClientOfAgencyID		int = NULL,
@AssessedPersonIsNotClientOfAgencyID	int = NULL
AS

--SELECT @RespondentIsNotClientOfAgencyID, @AssessedPersonIsNotClientOfAgencyID

DECLARE @StdDevMultiplierConstant int

/*
SELECT * FROM INTERVENTION 
WHERE InterventionName LIKE 'SYS_TEEN%'


EXEC spPrePostInterventionMeasureScoreAnalysis_simple NULL,324

*/

SELECT
	ar.*,		
	cr.[Completers],
	CAST ( cr.[Average Pretest (completers)] as decimal ( 10 , 2 ) )			as [Average Pretest (completers)],
	cr.[Standard Deviation Pretest(completers)],
	cr.[Minimum Pretest (completers)],
	cr.[Maximum Pretest (completers)],
	cr.[Variance Pretest (completers)],
	cr.Posttesters,
	CAST ( cr.[Average Posttest] as decimal ( 10 , 2 ) )						as [Average Posttest],
	cr.[Standard Deviation Posttest],
	cr.[Minimum Posttest],
	cr.[Maximum Posttest],
	cr.[Variance Posttest],
	CASE
		WHEN [Completers] > 1 AND ([Standard Deviation Pretest(completers)] <> 0 OR [Standard Deviation Posttest] <> 0 ) THEN
			PTI.dbo.fn_EffectSize([Average Pretest (completers)],[Average Posttest],[Standard Deviation Pretest(completers)],[Standard Deviation Posttest])
		ELSE NULL
	END as EffectSize
FROM
	( 
		SELECT 
			MeasureTypeID, 
			Measure, 
			MeasureSubscaleTypeID,
			MeasureSubscaleType, 
			ScoreTypeID, 
			SortOrder,
			[Score Type],
			---------------------------------------------------------------------------------------------------
			COUNT(*)													as [All Respondents],
			CAST ( AVG ( [Pretest Numeric Score]) as decimal ( 10,2))	as [Average Pretest (all)],
			STDEV ( [Pretest Numeric Score] )							as [Standard Deviation Pretest (all)],
			MIN ( [Pretest Numeric Score] )								as [Minimum Pretest (all)],
			MAX ( [Pretest Numeric Score] )								as [Maximum Pretest (all)],
			VAR ( [Pretest Numeric Score] )								as [Variance Pretest (all)]
		FROM 
			vwAgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest
		WHERE
			( NumericOrVerbose='Numeric' OR NumericOrVerbose IS NULL )
			AND
			(
					( AgencyID				= @AgencyID				OR @AgencyID IS NULL )
				AND ( InterventionID		= @InterventionID		OR @InterventionID IS NULL )
				AND ( InterventionTypeID	= @InterventionTypeID	OR @InterventionTypeID IS NULL )
				AND ( InterventionSubtypeID	= @InterventionSubtypeID	OR @InterventionSubtypeID IS NULL )

				AND ( MeasureTypeID			= @MeasureTypeID		OR @MeasureTypeID IS NULL )
				--AND ( ScoreTypeID			= @ScoreTypeID			OR @ScoreTypeID IS NULL	 )	
			
				AND ( @InterventionFacilitatorID IS NULL OR InterventionID IN (SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID=@InterventionFacilitatorID) )
				AND ( @InterventionStartDateFrom IS NULL OR InterventionStartDate BETWEEN @InterventionStartDateFrom AND @InterventionStartDateTo )
	
				------------------------------------------------------------------------------------------------------------------------------------------------------
				-- added by MF 9/26/2010
				------------------------------------------------------------------------------------------------------------------------------------------------------
				AND ( LanguageID		= @InterventionLanguageID	OR @InterventionLanguageID	IS NULL )
				AND ( AgencyID			<> @Exclude_AgencyID	OR @Exclude_AgencyID	IS NULL )
				AND 
					(	
					InterventionID NOT IN ( SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID	= @Exclude_InterventionFacilitatorID )	
					OR @Exclude_InterventionFacilitatorID IS NULL
					)
				------------------------------------------------------------------------------------------------------------------------------------------------------
				-- added by MF 10/23/2010
				------------------------------------------------------------------------------------------------------------------------------------------------------
				AND ( @EthnicityID IS NULL OR RespondentPersonID IN ( SELECT PersonID FROM Person_Ethnicity WHERE EthnicityID = @EthnicityID ) )
				AND ( @EthnicityMajorGroupID IS NULL OR RespondentPersonID IN ( SELECT PersonID FROM Person_Ethnicity pe JOIN Ethnicity e ON e.EthnicityID = pe.EthnicityID WHERE EthnicityMajorGroupID = @EthnicityMajorGroupID ) )
				AND ( @AnnualIncomeTypeID IS NULL OR RespondentPersonID In ( SELECT PersonID FROM Person WHERE HouseholdIncomeTypeID = @AnnualIncomeTypeID ) )
				AND ( @RespondentGenderID IS NULL OR RespondentPersonID In ( SELECT PersonID FROM Person WHERE GenderID = @RespondentGenderID ) )
				------------------------------------------------------------------------------------------------------------------------------------------------------
				-- added by MF 1/9/2012
				------------------------------------------------------------------------------------------------------------------------------------------------------
				AND ( @RespondentIsClientOfAgencyID IS NULL OR RespondentPersonID IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
				AND ( @AssessedPersonIsClientOfAgencyID IS NULL OR AssessedPersonID IN  ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @AssessedPersonIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )

				AND ( @RespondentIsNotClientOfAgencyID IS NULL OR RespondentPersonID NOT IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
				AND ( @AssessedPersonIsNotClientOfAgencyID IS NULL OR AssessedPersonID NOT IN  ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @AssessedPersonIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )

				AND ( DeliveryFormatTypeID	= @DeliveryFormatTypeID	OR @DeliveryFormatTypeID IS NULL )

			)
		GROUP BY
			MeasureTypeID, 
			Measure, 			
			MeasureSubscaleTypeID,
			MeasureSubscaleType, 
			ScoreTypeID, 
			SortOrder,
			[Score Type]
	) ar

	LEFT JOIN ( 

					SELECT
						MeasureTypeID, 
						MeasureSubscaleTypeID,
						ScoreTypeID,
						COUNT(*)								as [Completers],
						AVG ( [Pretest Numeric Score] )			as [Average Pretest (completers)],
						STDEV ( [Pretest Numeric Score] )		as [Standard Deviation Pretest(completers)],
						MIN ( [Pretest Numeric Score] )			as [Minimum Pretest (completers)],
						MAX ( [Pretest Numeric Score] )			as [Maximum Pretest (completers)],
						VAR ( [Pretest Numeric Score] )			as [Variance Pretest (completers)],
						---------------------------------------------------------------------------------------------------
						COUNT(Posttest_AssessedPersonID)		as Posttesters,
						AVG ( [Posttest Numeric Score] )		as [Average Posttest] ,
						STDEV ( [Posttest Numeric Score] )		as [Standard Deviation Posttest],
						MIN ( [Posttest Numeric Score] )		as [Minimum Posttest] ,
						MAX ( [Posttest Numeric Score] )		as [Maximum Posttest] ,
						VAR ( [Posttest Numeric Score] )		as [Variance Posttest]
					FROM 
						vwAgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest 
					WHERE
						( RespondentIsCompleter=1 AND NumericOrVerbose='Numeric' )
						AND
						(
								( AgencyID				= @AgencyID				OR @AgencyID IS NULL )
							AND ( InterventionID		= @InterventionID		OR @InterventionID IS NULL )
							AND ( InterventionTypeID	= @InterventionTypeID	OR @InterventionTypeID IS NULL )
							AND ( InterventionSubtypeID	= @InterventionSubtypeID	OR @InterventionSubtypeID IS NULL )	
							AND ( MeasureTypeID			= @MeasureTypeID		OR @MeasureTypeID IS NULL )
							--AND ( ScoreTypeID			= @ScoreTypeID			OR @ScoreTypeID IS NULL	 )
	
							AND ( @InterventionFacilitatorID IS NULL OR InterventionID IN (SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID=@InterventionFacilitatorID))
							AND ( @InterventionStartDateFrom IS NULL OR InterventionStartDate BETWEEN @InterventionStartDateFrom AND @InterventionStartDateTo )
	
							------------------------------------------------------------------------------------------------------------------------------------------------------
							-- added by MF 9/26/2010
							------------------------------------------------------------------------------------------------------------------------------------------------------
							AND ( LanguageID		= @InterventionLanguageID	OR @InterventionLanguageID	IS NULL )
							AND ( AgencyID			<> @Exclude_AgencyID		OR @Exclude_AgencyID		IS NULL )
							AND 
								(	
								InterventionID NOT IN ( SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID	= @Exclude_InterventionFacilitatorID )	
								OR @Exclude_InterventionFacilitatorID IS NULL
								)
							------------------------------------------------------------------------------------------------------------------------------------------------------
							------------------------------------------------------------------------------------------------------------------------------------------------------
							-- added by MF 10/23/2010
							------------------------------------------------------------------------------------------------------------------------------------------------------
							AND ( @EthnicityID IS NULL OR RespondentPersonID IN ( SELECT PersonID FROM Person_Ethnicity WHERE EthnicityID = @EthnicityID ))
							AND ( @EthnicityMajorGroupID IS NULL OR RespondentPersonID IN ( SELECT PersonID FROM Person_Ethnicity pe JOIN Ethnicity e ON e.EthnicityID = pe.EthnicityID WHERE EthnicityMajorGroupID = @EthnicityMajorGroupID ) )
							AND ( @AnnualIncomeTypeID IS NULL OR RespondentPersonID In ( SELECT PersonID FROM Person WHERE HouseholdIncomeTypeID = @AnnualIncomeTypeID ))
							AND ( @RespondentGenderID IS NULL OR RespondentPersonID In ( SELECT PersonID FROM Person WHERE GenderID = @RespondentGenderID ) )	
							------------------------------------------------------------------------------------------------------------------------------------------------------
							-- added by MF 1/9/2012
							------------------------------------------------------------------------------------------------------------------------------------------------------
							AND ( @RespondentIsClientOfAgencyID IS NULL OR RespondentPersonID IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
							AND ( @AssessedPersonIsClientOfAgencyID IS NULL OR AssessedPersonID IN  ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @AssessedPersonIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )								
							AND ( @RespondentIsNotClientOfAgencyID IS NULL OR RespondentPersonID NOT IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
							AND ( @AssessedPersonIsNotClientOfAgencyID IS NULL OR AssessedPersonID NOT IN  ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @AssessedPersonIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )								

							AND ( DeliveryFormatTypeID	= @DeliveryFormatTypeID	OR @DeliveryFormatTypeID IS NULL )
------------------------------------------------------------------------------------------------------------------------------------------------------
					)
					GROUP BY
						MeasureTypeID, 
						MeasureSubscaleTypeID,
						ScoreTypeID   
			)	cr
				ON
					    ar.MeasureTypeID			= cr.MeasureTypeID
					AND ar.MeasureSubscaleTypeID	= cr.MeasureSubscaleTypeID
					AND ar.ScoreTypeID				= cr.ScoreTypeID
ORDER BY
		Measure, 
		MeasureSubscaleType,
		SortOrder














