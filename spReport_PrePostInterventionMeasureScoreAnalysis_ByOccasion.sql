USE [PTI]
GO

/****** Object:  StoredProcedure [dbo].[spReport_PrePostInterventionMeasureScoreAnalysis_ByOccasion]    Script Date: 8/11/2013 3:59:02 PM ******/
DROP PROCEDURE [dbo].[spReport_PrePostInterventionMeasureScoreAnalysis_ByOccasion]
GO


/****** Object:  StoredProcedure [dbo].[spReport_PrePostInterventionMeasureScoreAnalysis_ByOccasion]    Script Date: 8/11/2013 9:19:32 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spReport_PrePostInterventionMeasureScoreAnalysis_ByOccasion]
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
	@AssessedPersonIsNotClientOfAgencyID	int = NULL,
	@IncludeThreeMonth					bit = 1,
	@IncludeSixMonth					bit = 1,
	@IncludeTwelveMonth					bit = 1
AS

	SET NOCOUNT ON

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
	
	EXEC spMeasureSubscaleType_ScoreType_SetClinicalCutOff

	SELECT 
		 T.MeasureTypeID 
		, Measure
		, T.MeasureSubscaleTypeID
		, MeasureSubscaleType
		, T.ScoreTypeID
		, SortOrder
		, [Score Type]
		, PreTestCount
		, COUNT(PreTest) as CompletedCount
		, CAST(AVG(PreTest) as decimal (10,2)) as AvgPreTest
		, CAST(AVG(PostTest) as decimal (10,2)) as AvgPostTest
		, CAST(AVG(ThreeMo) as decimal (10,2)) as AvgThreeMo
		, CAST(AVG(SixMo) as decimal (10,2)) as AvgSixMo
		, CAST(AVG(TwelveMo) as decimal (10,2)) as AvgTwelveMo
		, CAST(STDEV(PreTest) as decimal (10,2)) as StdevPreTest
		, CAST(STDEV(PostTest) as decimal (10,2)) as StdevPostTest
		, CAST(STDEV(ThreeMo) as decimal (10,2)) as StdevThreeMo
		, CAST(STDEV(SixMo) as decimal (10,2)) as StdevSixMo
		, CAST(STDEV(TwelveMo) as decimal (10,2)) as StdevTwelveMo
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
		INNER JOIN (
			SELECT DISTINCT MeasureTypeID, MeasureSubscaleTypeID, ScoreTypeID, COUNT(*) as PreTestCount
			FROM dbo.udfReport_AgencyInterventionPersonMeasureSubscaleValue_Filtered(
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
			GROUP BY MeasureTypeID, MeasureSubscaleTypeID, ScoreTypeID
		) U
			ON T.MeasureTypeID = U.MeasureTypeID
			AND T.MeasureSubscaleTypeID = U.MeasureSubscaleTypeID
			AND T.ScoreTypeID = U.ScoreTypeID

	GROUP BY T.MeasureTypeID 
		, Measure
		, T.MeasureSubscaleTypeID
		, MeasureSubscaleType
		, T.ScoreTypeID
		, SortOrder
		, [Score Type]
		, PreTestCount
	ORDER BY
		Measure, 
		MeasureSubscaleType,
		SortOrder

	SET NOCOUNT OFF














