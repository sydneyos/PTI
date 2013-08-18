USE [PTI]
GO

/****** Object:  StoredProcedure [dbo].[spReport_ClinicalChangeSummary]    Script Date: 8/18/2013 10:02:54 AM ******/
DROP PROCEDURE [dbo].[spReport_ClinicalChangeSummary]
GO

/****** Object:  StoredProcedure [dbo].[spReport_ClinicalChangeSummary]    Script Date: 8/18/2013 10:02:54 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spReport_ClinicalChangeSummary]
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

EXEC spMeasureSubscaleType_ScoreType_SetClinicalCutOff

DECLARE 
	@Dass INT,
	@Ecbi INT,
	@Ps INT

SELECT @Dass = 4, @Ecbi = 1, @Ps = 3 

DECLARE @SummaryTable TABLE (
	ParticipantTotal INT
	, ParticipantInterventionTotal INT
	, Measure VARCHAR(50)
	, MeasureTypeID INT
	, MeasureSubscaleTypeID INT
	, ValidPretestCount INT
	, OverCutoffPretestCount INT
	, OverCutoffPretestPercent DECIMAL(5,2)
	, IncompleteInvalidPosttestCount INT
	, IncompleteInvalidPosttestPercent DECIMAL(5,2)
	, SameAtPostestCount INT
	, SameAtPostestPercent DECIMAL(5,2)
	, ImprovedAtPosttestCount INT
	, ImprovedAtPosttestPercent DECIMAL(5,2)
	, WorseAtPosttestCount INT
	, WorseAtPosttestPercent DECIMAL(5,2)
)

DECLARE @AllScores TABLE (
	InterventionID INT
	, AssessedPersonID INT
	, RespondentPersonID INT
	, MeasureTypeID INT
	, Measure VARCHAR(50)
	, MeasureSubscaleTypeID INT
	, MeasureSubscaleValue NUMERIC(10,2)
	, ScoreTypeID INT
	, PretestScore DECIMAL(5,2)
	, PosttestScore DECIMAL(5,2)
)

SELECT @MeasureTypeID = 4

DECLARE @PreTestCount INT

--PRETESTS
INSERT INTO @AllScores
SELECT InterventionID
	, AssessedPersonID
	, RespondentPersonID
	, a.MeasureTypeID
	, Measure
	, a.MeasureSubscaleTypeID
	, MeasureSubscaleValue
	, a.ScoreTypeID
	, [Pretest Numeric Score] as PretestScore
	, [Posttest Numeric Score] as PosttestScore
FROM  [dbo].[vwAgencyInterventionPersonMeasureSubscaleValuee_Pretest_Posttest] a
INNER JOIN [dbo].[vwMeasureType_MeasureSubscaleType_ScoreType] st
		ON a.MeasureTypeID = st.MeasureTypeID
		AND a.MeasureSubscaleTypeID = st.MeasureSubscaleTypeID
WHERE AssessedPersonID = Posttest_AssessedPersonID
AND a.MeasureTypeID IN (@Dass, @Ecbi, @Ps)
AND st.ClinicalCutOff IS NOT NULL

INSERT INTO @SummaryTable (Measure, MeasureTypeID, MeasureSubscaleTypeID, ValidPretestCount)
SELECT Measure, MeasureTypeID, MeasureSubscaleTypeID, COUNT(PretestScore)
FROM @AllScores
GROUP BY Measure, MeasureTypeID, MeasureSubscaleTypeID

--Total number of people participants
UPDATE @SummaryTable
SET ParticipantInterventionTotal = (
	SELECT COUNT(*)
	FROM (
		SELECT DISTINCT AssessedPersonID, InterventionID
		FROM @AllScores
	) X
)

--Total number of people taking into account multiple interventions per person
UPDATE @SummaryTable
SET ParticipantTotal = (SELECT COUNT(DISTINCT AssessedPersonID)
FROM @AllScores
)

UPDATE s
SET OverCutoffPretestCount = c.PretestOverCutoffCount,
IncompleteInvalidPosttestCount = s.ValidPretestCount - c.StableCount - c.ImprovedCount - c.WorsenedCount,
SameAtPostestCount = c.StableCount,
ImprovedAtPosttestCount = c.ImprovedCount,
WorseAtPosttestCount = c.WorsenedCount 
FROM @SummaryTable s
INNER JOIN (
	SELECT 
		MeasureTypeID,
		MeasureSubscaleTypeID,
		SUM(PretestOverCutoff) as PretestOverCutoffCount,
		SUM(PosttestInvalidOrNotComplete) as PosttestInvalidCount,
		SUM(Stable) as StableCount,
		SUM(Improved) as ImprovedCount,
		SUM(Worsened) as WorsenedCount
	FROM 
	(
	SELECT  
	a.MeasureTypeID,
	a.MeasureSubscaleTypeID,
	CASE WHEN PretestScore >= st.ClinicalCutoff THEN 1 ELSE 0 END AS PretestOverCutoff,
	CASE WHEN PosttestScore IS NULL THEN 1 ELSE 0 END AS PosttestInvalidOrNotComplete,
	CASE WHEN PretestScore >= st.ClinicalCutoff AND PosttestScore >= st.ClinicalCutoff THEN 1 ELSE 0 END AS Stable,
	CASE WHEN PretestScore >= st.ClinicalCutoff AND PosttestScore < st.ClinicalCutoff THEN 1 ELSE 0 END AS Improved,
	CASE WHEN PretestScore < st.ClinicalCutoff AND PosttestScore >= st.ClinicalCutoff THEN 1 ELSE 0 END AS Worsened
	FROM @AllScores a
	INNER JOIN [dbo].[vwMeasureType_MeasureSubscaleType_ScoreType] st
		ON a.MeasureTypeID = st.MeasureTypeID
		AND a.MeasureSubscaleTypeID = st.MeasureSubscaleTypeID
	) T
	GROUP BY MeasureTypeID, MeasureSubscaleTypeID
) c
ON s.MeasureTypeID = c.MeasureTypeID
AND s.MeasureSubscaleTypeID = c.MeasureSubscaleTypeID

UPDATE @SummaryTable
SET OverCutoffPretestPercent = (OverCutoffPretestCount * 100)/ValidPretestCount
, IncompleteInvalidPosttestPercent = (IncompleteInvalidPosttestCount * 100)/ValidPretestCount
, SameAtPostestPercent = (SameAtPostestCount * 100)/ValidPretestCount
, ImprovedAtPosttestPercent = (ImprovedAtPosttestCount * 100)/ValidPretestCount
, WorseAtPosttestPercent = (WorseAtPosttestCount * 100)/(ValidPretestCount - OverCutoffPretestCount)

SELECT * FROM @SummaryTable

GO


