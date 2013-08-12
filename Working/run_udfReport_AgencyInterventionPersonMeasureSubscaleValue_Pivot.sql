USE [PTI]
GO

DECLARE @RC int
DECLARE @AgencyID int
DECLARE @InterventionID int
DECLARE @RespondentPersonID int
DECLARE @AssessedPersonID int
DECLARE @MeasureTypeID int
DECLARE @InterventionTypeID int
DECLARE @InterventionSubtypeID int
DECLARE @InterventionFacilitatorID int
DECLARE @InterventionStartDateFrom datetime
DECLARE @InterventionStartDateTo datetime
DECLARE @InterventionLanguageID int
DECLARE @AnnualIncomeTypeID int
DECLARE @EthnicityID int
DECLARE @EthnicityMajorGroupID int
DECLARE @Exclude_AgencyID int
DECLARE @Exclude_InterventionFacilitatorID int
DECLARE @DeliveryFormatTypeID int
DECLARE @RespondentGenderID int
DECLARE @RespondentIsClientOfAgencyID int
DECLARE @AssessedPersonIsClientOfAgencyID int
DECLARE @RespondentIsNotClientOfAgencyID int
DECLARE @AssessedPersonIsNotClientOfAgencyID int
DECLARE @IncludeThreeMonth bit
DECLARE @IncludeSixMonth bit
DECLARE @IncludeTwelveMonth bit

SELECT @MeasureTypeID = 4
, @IncludeThreeMonth = 1
, @IncludeSixMonth = 1
, @IncludeTwelveMonth = 1

EXECUTE @RC = [dbo].[spReport_PrePostInterventionMeasureScoreAnalysis_ByOccasion] 
   @AgencyID
  ,@InterventionID
  ,@RespondentPersonID
  ,@AssessedPersonID
  ,@MeasureTypeID
  ,@InterventionTypeID
  ,@InterventionSubtypeID
  ,@InterventionFacilitatorID
  ,@InterventionStartDateFrom
  ,@InterventionStartDateTo
  ,@InterventionLanguageID
  ,@AnnualIncomeTypeID
  ,@EthnicityID
  ,@EthnicityMajorGroupID
  ,@Exclude_AgencyID
  ,@Exclude_InterventionFacilitatorID
  ,@DeliveryFormatTypeID
  ,@RespondentGenderID
  ,@RespondentIsClientOfAgencyID
  ,@AssessedPersonIsClientOfAgencyID
  ,@RespondentIsNotClientOfAgencyID
  ,@AssessedPersonIsNotClientOfAgencyID
  ,@IncludeThreeMonth
  ,@IncludeSixMonth
  ,@IncludeTwelveMonth
GO



--SELECT vw.RespondentPersonID, vw.Measure, Ocassion, MeasureSubscaleType, NumericScore
--FROM vwAgencyInterventionPersonMeasureSubscaleValue vw
--CROSS APPLY dbo.udfHasAllSubtests(vw.AssessedPersonID, vw.MeasureTypeID, vw.MeasureSubscaleTypeID, 1, 1, @IncludeThreeMonth, @IncludeSixMonth, 0, @IncludeTwelveMonth) c
--WHERE
--	(
--		c.MissingCount = 0
--		AND vw.NumericScore IS NOT NULL
--		AND ( vw.AgencyID				= @AgencyID				OR @AgencyID IS NULL )
--		AND ( vw.InterventionID			= @InterventionID		OR @InterventionID IS NULL )
--		AND ( vw.InterventionTypeID		= @InterventionTypeID	OR @InterventionTypeID IS NULL )
--		AND ( vw.InterventionSubtypeID	= @InterventionSubtypeID	OR @InterventionSubtypeID IS NULL )

--		AND ( vw.MeasureTypeID			= @MeasureTypeID		OR @MeasureTypeID IS NULL )
--		--AND ( ScoreTypeID				= @ScoreTypeID			OR @ScoreTypeID IS NULL	 )	
			
--		AND ( @InterventionFacilitatorID IS NULL OR vw.InterventionID IN (SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID=@InterventionFacilitatorID) )
--		AND ( @InterventionStartDateFrom IS NULL OR vw.InterventionStartDate BETWEEN @InterventionStartDateFrom AND @InterventionStartDateTo )
	
--		AND ( vw.LanguageID		= @InterventionLanguageID	OR @InterventionLanguageID	IS NULL )
--		AND ( vw.AgencyID		<> @Exclude_AgencyID		OR @Exclude_AgencyID	IS NULL )
--		AND 
--			(	
--			vw.InterventionID NOT IN ( SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID	= @Exclude_InterventionFacilitatorID )	
--			OR @Exclude_InterventionFacilitatorID IS NULL
--			)
--		AND ( @EthnicityID IS NULL OR vw.RespondentPersonID IN ( SELECT PersonID FROM Person_Ethnicity WHERE EthnicityID = @EthnicityID ) )
--		AND ( @EthnicityMajorGroupID IS NULL OR vw.RespondentPersonID IN ( SELECT PersonID FROM Person_Ethnicity pe JOIN Ethnicity e ON e.EthnicityID = pe.EthnicityID WHERE EthnicityMajorGroupID = @EthnicityMajorGroupID ) )
--		AND ( @AnnualIncomeTypeID IS NULL OR vw.RespondentPersonID In ( SELECT PersonID FROM Person WHERE HouseholdIncomeTypeID = @AnnualIncomeTypeID ) )
--		AND ( @RespondentGenderID IS NULL OR vw.RespondentPersonID In ( SELECT PersonID FROM Person WHERE GenderID = @RespondentGenderID ) )
						
--		AND ( @RespondentIsClientOfAgencyID IS NULL OR vw.RespondentPersonID IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
--		AND ( @AssessedPersonIsClientOfAgencyID IS NULL OR vw.AssessedPersonID IN  ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @AssessedPersonIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )

--		AND ( @RespondentIsNotClientOfAgencyID IS NULL OR vw.RespondentPersonID NOT IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
--		AND ( @AssessedPersonIsNotClientOfAgencyID IS NULL OR vw.AssessedPersonID NOT IN  ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @AssessedPersonIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )

--		AND ( vw.DeliveryFormatTypeID	= @DeliveryFormatTypeID	OR @DeliveryFormatTypeID IS NULL )
--		--is a pre, post or specified f/u
--		AND (
--				( vw.OcassionTypeID IN (1,2) ) OR --is pre/post test
--				( (@IncludeThreeMonth = 0) OR (@IncludeThreeMonth = 1 AND vw.OcassionTypeID = 5) ) OR --is 3mo f/u and or 3mo f/u not selected
--				( (@IncludeSixMonth = 0) OR (@IncludeSixMonth = 1 AND vw.OcassionTypeID = 3) ) OR --is 6mo f/u or 6mo f/u not selected
--				( (@IncludeTwelveMonth = 0) OR (@IncludeTwelveMonth = 1 AND vw.OcassionTypeID = 4) ) --is 12mo f/u or 12mo f/u not selected
--			)
--		)
--ORDER BY MeasureSubscaleType