USE [PTI]
GO

/****** Object:  UserDefinedFunction [dbo].[udfReport_AgencyInterventionPersonMeasureSubscaleValue_Pivot]    Script Date: 8/11/2013 12:23:09 PM ******/
DROP FUNCTION [dbo].[udfReport_AgencyInterventionPersonMeasureSubscaleValue_Pivot]
GO


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Sydney Osborne
-- Create date: 8 Aug 2013
-- Description:	
-- =============================================
CREATE FUNCTION udfReport_AgencyInterventionPersonMeasureSubscaleValue_Pivot
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
	@AssessedPersonIsNotClientOfAgencyID	int = NULL,
	@IncludeThreeMonth					int = 1,
	@IncludeSixMonth					int = 1,
	@IncludeTwelveMonth					int = 1
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
			MeasureTypeID 
			,Measure
			,MeasureSubscaleTypeID
			,MeasureSubscaleType
			,ScoreTypeID
			,SortOrder
			,[Score Type]
			, COUNT(PreTest) as PreTestCount
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
		SELECT 
			MeasureTypeID 
			,Measure
			,MeasureSubscaleTypeID
			,MeasureSubscaleType
			,ScoreTypeID
			,SortOrder
			,[Score Type]
			, MAX(CASE OcassionTypeID WHEN 1 THEN NumericScore ELSE NULL END) as PreTest
			, MAX(CASE OcassionTypeID WHEN 2 THEN NumericScore ELSE NULL END) as PostTest
			, MAX(CASE OcassionTypeID WHEN 5 THEN NumericScore ELSE NULL END) as ThreeMo
			, MAX(CASE OcassionTypeID WHEN 3 THEN NumericScore ELSE NULL END) as SixMo
			, MAX(CASE OcassionTypeID WHEN 4 THEN NumericScore ELSE NULL END) as TwelveMo
		FROM 
			(
				SELECT vw.*
				FROM vwAgencyInterventionPersonMeasureSubscaleValue vw
				LEFT JOIN vwAgencyInterventionPersonMeasureSubscaleValue vw2 --previous occasion
					ON vw.OccasionSortOrder = vw2.OccasionSortOrder + 1
					AND vw.InterventionID						= vw2.InterventionID
					AND vw.AssessedPersonID						= vw2.AssessedPersonID
					AND vw.RespondentPersonID					= vw2.RespondentPersonID
					AND vw.MeasureTypeID						= vw2.MeasureTypeID
					AND vw.MeasureSubscaleTypeID				= vw2.MeasureSubscaleTypeID
					AND vw.ScoreTypeID							= vw2.ScoreTypeID
				WHERE
					(
						vw.NumericScore IS NOT NULL
						AND ( vw.AgencyID				= @AgencyID				OR @AgencyID IS NULL )
						AND ( vw.InterventionID		= @InterventionID		OR @InterventionID IS NULL )
						AND ( vw.InterventionTypeID	= @InterventionTypeID	OR @InterventionTypeID IS NULL )
						AND ( vw.InterventionSubtypeID	= @InterventionSubtypeID	OR @InterventionSubtypeID IS NULL )

						AND ( vw.MeasureTypeID			= @MeasureTypeID		OR @MeasureTypeID IS NULL )
						--AND ( ScoreTypeID			= @ScoreTypeID			OR @ScoreTypeID IS NULL	 )	
			
						AND ( @InterventionFacilitatorID IS NULL OR vw.InterventionID IN (SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID=@InterventionFacilitatorID) )
						AND ( @InterventionStartDateFrom IS NULL OR vw.InterventionStartDate BETWEEN @InterventionStartDateFrom AND @InterventionStartDateTo )
	
						AND ( vw.LanguageID		= @InterventionLanguageID	OR @InterventionLanguageID	IS NULL )
						AND ( vw.AgencyID			<> @Exclude_AgencyID	OR @Exclude_AgencyID	IS NULL )
						AND 
							(	
							vw.InterventionID NOT IN ( SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID	= @Exclude_InterventionFacilitatorID )	
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
						AND (
								( vw.OcassionTypeID IN (1,2) ) OR --is pre/post test
								( (@IncludeThreeMonth = 0) OR (@IncludeThreeMonth = 1 AND vw.OcassionTypeID = 5) ) OR --is 3mo f/u and or 3mo f/u not selected
								( (@IncludeSixMonth = 0) OR (@IncludeSixMonth = 1 AND vw.OcassionTypeID = 3) ) OR --is 6mo f/u or 6mo f/u not selected
								( (@IncludeTwelveMonth = 0) OR (@IncludeTwelveMonth = 1 AND vw.OcassionTypeID = 4) ) --is 12mo f/u or 12mo f/u not selected
							)
						AND ( 
							vw.OccasionSortOrder = 1 --this is a pre-test
							OR (vw.OccasionSortOrder != 1 AND vw2.InterventionID IS NOT NULL) --this is not a pre-test and there was a previous test
						) --only include completers
					)
				) AS I
			GROUP BY MeasureTypeID 
			,Measure
			,MeasureSubscaleTypeID
			,MeasureSubscaleType
			,ScoreTypeID
			,SortOrder
			,[Score Type]
			,FormInstanceID
		) 
		AS T
		GROUP BY MeasureTypeID 
			,Measure
			,MeasureSubscaleTypeID
			,MeasureSubscaleType
			,ScoreTypeID
			,SortOrder
			,[Score Type]
)
GO
