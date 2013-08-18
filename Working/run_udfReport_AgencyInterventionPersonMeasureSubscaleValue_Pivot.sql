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
, @IncludeThreeMonth = 0
, @IncludeSixMonth = 0
, @IncludeTwelveMonth = 0


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


-- TODO: Set parameter values here.

EXECUTE @RC = [dbo].[spPrePostInterventionMeasureScoreAnalysis_simple] 
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
GO

