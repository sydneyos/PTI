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

SELECT 
@IncludeThreeMonth = 0
, @IncludeSixMonth = 0
, @IncludeTwelveMonth = 0
, @MeasureTypeID = 3


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
DECLARE @table TABLE (MeasureTypeID INT, Measure VARCHAR(50), MeasureSubscaleTypeID INT, MeasureSubscaleType VARCHAR(50), ScoreTypeID INT, SortOrder INT, ScoreType VARCHAR(50), PreTestCount INT,
					AvgPretest decimal(5,2), StdDevPre decimal(20, 13), MinPretest decimal(5,2), MaxPretest decimal(5,2), VarPretest decimal(20,13), 
					CompletedCount INT, AvgPreComp decimal(5,2), StdDevPreComp decimal(20,13), MinPreComp decimal(5,2), MaxPreComp decimal (5,2), VarPreComp decimal(20,13),
					PostCount INT, AvgPost decimal(5,2), StdDevPost decimal(20,13), MinPost decimal(5,2), MaxPost decimal(5,2), VarPost decimal(20,13), EffectSize decimal(10,4))


INSERT  @table
EXEC spPrePostInterventionMeasureScoreAnalysis_simple 
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
  
SELECT MeasureTypeID, Measure, MeasureSubscaleTypeID, MeasureSubscaleType, ScoreTypeID, SortOrder, ScoreType, PreTestCount, CompletedCount
FROM @table
WHERE ScoreTypeID IN (3,5)
GO

