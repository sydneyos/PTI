SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sydney Osborne
-- Create date: 8 Aug 2013
-- Description:	
-- =============================================
CREATE FUNCTION udfReport_AgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest
(	
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
)
RETURNS TABLE 
AS
RETURN 
(
		SELECT *
		FROM 
			vwAgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest
		WHERE
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
)
GO
