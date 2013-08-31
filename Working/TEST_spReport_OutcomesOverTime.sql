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
DECLARE @MeasureSubscaleTypeID INT

DECLARE @PreTest INT,
	@PostTest INT,
	@ThreeMonth INT,
	@SixMonth INT,
	@TwelveMonth INT,
	@Dass INT,
	@Ecbi INT,
	@Ps INT,
	@Raw INT,
	@RawDoubled INT

SELECT @PreTest = 1, @PostTest = 2, @ThreeMonth = 5, @SixMonth = 3, @TwelveMonth = 4,
	@Dass = 4, @Ecbi = 1, @Ps = 3,
	@Raw = 5, @RawDoubled = 3
	
SELECT @IncludeThreeMonth = 1
, @IncludeSixMonth = 0
, @IncludeTwelveMonth = 0
, @MeasureTypeID = @Ps
, @MeasureSubscaleTypeID = 25


EXECUTE @RC = [dbo].[spReport_OutcomesOverTime] 
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


  	SELECT 
		 U.MeasureTypeID 
		, U.Measure
		, U.MeasureSubscaleTypeID
		, U.MeasureSubscaleType
		, U.ScoreTypeID
		, SortOrder
		, U.[Score Type]
		, PreTestCount
		, COUNT(PreTest) as CompletedCount
		, CAST(AVG(PreTest) as decimal (10,2)) as AvgPreTest
		, CAST(AVG(PostTest) as decimal (10,2)) as AvgPostTest
		, CASE WHEN @IncludeThreeMonth=0 THEN NULL ELSE CAST(AVG(ThreeMo) as decimal (10,2)) END as AvgThreeMo		-- CASE...THEN added by MF 8/25/2013 to hide columns for occasions not selected
		, CASE WHEN @IncludeSixMonth=0 THEN NULL ELSE CAST(AVG(SixMo) as decimal (10,2)) END as AvgSixMo			-- CASE...THEN added by MF 8/25/2013 to hide columns for occasions not selected
		, CASE WHEN @IncludeTwelveMonth=0 THEN NULL ELSE CAST(AVG(TwelveMo) as decimal (10,2)) END as AvgTwelveMo	-- CASE...THEN added by MF 8/25/2013 to hide columns for occasions not selected

		, CAST(STDEV(PreTest) as decimal (10,2)) as StdevPreTest
		, CAST(STDEV(PostTest) as decimal (10,2)) as StdevPostTest
		, CASE WHEN @IncludeThreeMonth=0 THEN NULL ELSE CAST(STDEV(ThreeMo) as decimal (10,2)) END as StdevThreeMo		-- CASE...THEN added by MF 8/25/2013 to hide columns for occasions not selected
		, CASE WHEN @IncludeSixMonth=0 THEN NULL ELSE CAST(STDEV(SixMo) as decimal (10,2)) END as StdevSixMo			-- CASE...THEN added by MF 8/25/2013 to hide columns for occasions not selected
		, CASE WHEN @IncludeTwelveMonth=0 THEN NULL ELSE CAST(STDEV(TwelveMo) as decimal (10,2)) END as StdevTwelveMo	-- CASE...THEN added by MF 8/25/2013 to hide columns for occasions not selected
	FROM  (
		SELECT DISTINCT
			 InterventionID
			, MeasureTypeID 
			, Measure
			, MeasureSubscaleTypeID
			, MeasureSubscaleType
			, AssessedPersonID
			, RespondentPersonID
			, ScoreTypeID
			, SortOrder
			, [Score Type]
			, MAX(CASE OcassionTypeID WHEN @PreTest THEN NumericScore ELSE NULL END) as PreTest
			, MAX(CASE OcassionTypeID WHEN @PostTest THEN NumericScore ELSE NULL END) as PostTest
			, MAX(CASE OcassionTypeID WHEN @ThreeMonth THEN NumericScore ELSE NULL END) as ThreeMo
			, MAX(CASE OcassionTypeID WHEN @SixMonth THEN NumericScore ELSE NULL END) as SixMo
			, MAX(CASE OcassionTypeID WHEN @TwelveMonth THEN NumericScore ELSE NULL END) as TwelveMo
		FROM 
			(
				SELECT vw.*
				FROM dbo.udfValidSubtestForAllOccasions(@MeasureTypeID, 1, @IncludeThreeMonth, @IncludeSixMonth, 0, @IncludeTwelveMonth) s
				INNER JOIN
					(
						SELECT *
						FROM vwAgencyInterventionPersonMeasureSubscaleValue
						WHERE
						(
							NumericScore IS NOT NULL
							AND ( AgencyID				= @AgencyID				OR @AgencyID IS NULL )
							AND ( InterventionID			= @InterventionID		OR @InterventionID IS NULL )
							AND ( InterventionTypeID		= @InterventionTypeID	OR @InterventionTypeID IS NULL )
							AND ( InterventionSubtypeID	= @InterventionSubtypeID	OR @InterventionSubtypeID IS NULL )
					
							AND ( MeasureTypeID IN (@Dass, @Ecbi, @Ps))
							AND ( MeasureTypeID			= @MeasureTypeID		OR @MeasureTypeID IS NULL )
			
							AND ( @InterventionFacilitatorID IS NULL OR InterventionID IN (SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID=@InterventionFacilitatorID) )
							AND ( @InterventionStartDateFrom IS NULL OR InterventionStartDate BETWEEN @InterventionStartDateFrom AND @InterventionStartDateTo )
	
							AND ( LanguageID		= @InterventionLanguageID	OR @InterventionLanguageID	IS NULL )
							AND ( AgencyID		<> @Exclude_AgencyID		OR @Exclude_AgencyID	IS NULL )
							AND 
								(	
								InterventionID NOT IN ( SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID = @Exclude_InterventionFacilitatorID )	
								OR @Exclude_InterventionFacilitatorID IS NULL
								)
							AND ( @EthnicityID IS NULL OR RespondentPersonID IN ( SELECT PersonID FROM Person_Ethnicity WHERE EthnicityID = @EthnicityID ) )
							AND ( @EthnicityMajorGroupID IS NULL OR RespondentPersonID IN ( SELECT PersonID FROM Person_Ethnicity pe JOIN Ethnicity e ON e.EthnicityID = pe.EthnicityID WHERE EthnicityMajorGroupID = @EthnicityMajorGroupID ) )
							AND ( @AnnualIncomeTypeID IS NULL OR RespondentPersonID In ( SELECT PersonID FROM Person WHERE HouseholdIncomeTypeID = @AnnualIncomeTypeID ) )
							AND ( @RespondentGenderID IS NULL OR RespondentPersonID In ( SELECT PersonID FROM Person WHERE GenderID = @RespondentGenderID ) )
						
							AND ( @RespondentIsClientOfAgencyID IS NULL OR RespondentPersonID IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
							AND ( @AssessedPersonIsClientOfAgencyID IS NULL OR AssessedPersonID IN  ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @AssessedPersonIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )

							AND ( @RespondentIsNotClientOfAgencyID IS NULL OR RespondentPersonID NOT IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
							AND ( @AssessedPersonIsNotClientOfAgencyID IS NULL OR AssessedPersonID NOT IN  ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @AssessedPersonIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )

							AND ( DeliveryFormatTypeID	= @DeliveryFormatTypeID	OR @DeliveryFormatTypeID IS NULL )
							AND ScoreTypeID IN (@Raw, @RawDoubled)
						) 
					) vw
					ON vw.InterventionID = s.InterventionID
					AND vw.AssessedPersonID = s.AssessedPersonID
					AND vw.RespondentPersonID = s.RespondentPersonID
					AND vw.MeasureTypeID = s.MeasureTypeID
					AND vw.MeasureSubscaleTypeID = s.MeasureSubscaleTypeID
					AND vw.ScoreTypeID = s.ScoreTypeID
				) AS I
			GROUP BY 
			InterventionID
			, MeasureTypeID 
			, Measure
			, MeasureSubscaleTypeID
			, MeasureSubscaleType
			, AssessedPersonID
			, RespondentPersonID
			, ScoreTypeID
			, SortOrder
			, [Score Type]
		) 
		AS T
		--Pre-Test Counts
		RIGHT JOIN (
			SELECT DISTINCT MeasureTypeID, Measure, MeasureSubscaleTypeID, MeasureSubscaleType, ScoreTypeID, [Score Type], COUNT(*) as PreTestCount
			FROM dbo.udfReport_AgencyInterventionPersonMeasureSubscaleValue_Filtered (
			@AgencyID,
			@InterventionID,
			@RespondentPersonID,
			@AssessedPersonID,
			@MeasureTypeID,
			@InterventionTypeID,
			@InterventionSubtypeID,
			@InterventionFacilitatorID,
			@InterventionStartDateFrom,
			@InterventionStartDateTo,
			@InterventionLanguageID,
			@AnnualIncomeTypeID,
			@EthnicityID,
			@EthnicityMajorGroupID,
			@Exclude_AgencyID,
			@Exclude_InterventionFacilitatorID,
			@DeliveryFormatTypeID,
			@RespondentGenderID,
			@RespondentIsClientOfAgencyID,
			@AssessedPersonIsClientOfAgencyID,
			@RespondentIsNotClientOfAgencyID,
			@AssessedPersonIsNotClientOfAgencyID)
			WHERE OcassionTypeID = @PreTest
			GROUP BY MeasureTypeID, Measure, MeasureSubscaleTypeID, MeasureSubscaleType, ScoreTypeID, [Score Type]
		) U
			ON T.MeasureTypeID = U.MeasureTypeID
			AND T.MeasureSubscaleTypeID = U.MeasureSubscaleTypeID
			AND T.ScoreTypeID = U.ScoreTypeID

	GROUP BY U.MeasureTypeID 
		, U.Measure
		, U.MeasureSubscaleTypeID
		, U.MeasureSubscaleType
		, U.ScoreTypeID
		, SortOrder
		, U.[Score Type]
		, PreTestCount
	ORDER BY
		Measure, 
		MeasureSubscaleType,
		SortOrder