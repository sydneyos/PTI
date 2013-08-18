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
			FROM vwAgencyInterventionPersonMeasureSubscaleValue vw
			CROSS APPLY dbo.udfHasAllSubtests(vw.InterventionID, vw.AssessedPersonID, vw.MeasureTypeID, vw.MeasureSubscaleTypeID, 1, 1, @IncludeThreeMonth, @IncludeSixMonth, 0, @IncludeTwelveMonth) c
			WHERE
				(
					c.MissingCount = 0
					AND vw.NumericScore IS NOT NULL
					AND ( vw.AgencyID				= @AgencyID				OR @AgencyID IS NULL )
					AND ( vw.InterventionID			= @InterventionID		OR @InterventionID IS NULL )
					AND ( vw.InterventionTypeID		= @InterventionTypeID	OR @InterventionTypeID IS NULL )
					AND ( vw.InterventionSubtypeID	= @InterventionSubtypeID	OR @InterventionSubtypeID IS NULL )
					
					AND ( vw.MeasureTypeID IN (@Dass, @Ecbi, @Ps))
					AND ( vw.MeasureTypeID			= @MeasureTypeID		OR @MeasureTypeID IS NULL )
					--AND ( ScoreTypeID				= @ScoreTypeID			OR @ScoreTypeID IS NULL	 )	
			
					AND ( @InterventionFacilitatorID IS NULL OR vw.InterventionID IN (SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID=@InterventionFacilitatorID) )
					AND ( @InterventionStartDateFrom IS NULL OR vw.InterventionStartDate BETWEEN @InterventionStartDateFrom AND @InterventionStartDateTo )
	
					AND ( vw.LanguageID		= @InterventionLanguageID	OR @InterventionLanguageID	IS NULL )
					AND ( vw.AgencyID		<> @Exclude_AgencyID		OR @Exclude_AgencyID	IS NULL )
					AND 
						(	
						vw.InterventionID NOT IN ( SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID = @Exclude_InterventionFacilitatorID )	
						OR @Exclude_InterventionFacilitatorID IS NULL
						)
					AND ( @EthnicityID IS NULL OR vw.RespondentPersonID IN ( SELECT PersonID FROM Person_Ethnicity WHERE EthnicityID = @EthnicityID ) )
					AND ( @EthnicityMajorGroupID IS NULL OR vw.RespondentPersonID IN ( SELECT PersonID FROM Person_Ethnicity pe JOIN Ethnicity e ON e.EthnicityID = pe.EthnicityID WHERE EthnicityMajorGroupID = @EthnicityMajorGroupID ) )
					AND ( @AnnualIncomeTypeID IS NULL OR vw.RespondentPersonID In ( SELECT PersonID FROM Person WHERE HouseholdIncomeTypeID = @AnnualIncomeTypeID ) )
					AND ( @RespondentGenderID IS NULL OR vw.RespondentPersonID In ( SELECT PersonID FROM Person WHERE GenderID = @RespondentGenderID ) )
						
					AND ( @RespondentIsClientOfAgencyID IS NULL OR vw.RespondentPersonID IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
					AND ( @AssessedPersonIsClientOfAgencyID IS NULL OR vw.AssessedPersonID IN  ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @AssessedPersonIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )

					AND ( @RespondentIsNotClientOfAgencyID IS NULL OR vw.RespondentPersonID NOT IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
					AND ( @AssessedPersonIsNotClientOfAgencyID IS NULL OR vw.AssessedPersonID NOT IN  ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @AssessedPersonIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )

					AND ( vw.DeliveryFormatTypeID	= @DeliveryFormatTypeID	OR @DeliveryFormatTypeID IS NULL )
					--is a pre, post or specified f/u
					AND (
							( vw.OcassionTypeID IN (@PreTest, @PostTest) ) OR --is pre/post test
							( (@IncludeThreeMonth = 0) OR (@IncludeThreeMonth = 1 AND vw.OcassionTypeID = @ThreeMonth) ) OR --is 3mo f/u and or 3mo f/u not selected
							( (@IncludeSixMonth = 0) OR (@IncludeSixMonth = 1 AND vw.OcassionTypeID = @SixMonth) ) OR --is 6mo f/u or 6mo f/u not selected
							( (@IncludeTwelveMonth = 0) OR (@IncludeTwelveMonth = 1 AND vw.OcassionTypeID = @TwelveMonth) ) --is 12mo f/u or 12mo f/u not selected
						)
					AND vw.ScoreTypeID IN (@Raw, @RawDoubled)
				)
			) AS I
		GROUP BY 
		InterventionID
		, MeasureTypeID 
		, Measure
		, MeasureSubscaleTypeID
		, MeasureSubscaleType
		, AssessedPersonID
		, ScoreTypeID
		, SortOrder
		, [Score Type]
	) 
	AS T
	INNER JOIN (
		SELECT DISTINCT MeasureTypeID, MeasureSubscaleTypeID, ScoreTypeID, COUNT(*) as PreTestCount
		FROM [dbo].[FormInstance] ifi
			INNER JOIN [dbo].[FormInstance_MeasureSubscaleValue] fim
				ON fim.FormInstanceID = ifi.FormInstanceID
			LEFT JOIN [dbo].[FormInstance_MeasureSubscaleValue_ScoreTypeID_Score] fis --include to ensure valid score
				ON fis.FormInstanceMeasureSubscaleValueID = fim.FormInstanceMeasureSubscaleValueID
		WHERE OcassionTypeID = @PreTest
			AND (fim.FormInstanceMeasureSubscaleValueID IS NOT NULL)
			AND (fim.Invalid = 0 OR fim.Invalid IS NULL)
			--AND fis.NumericScore IS NOT NULL
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














