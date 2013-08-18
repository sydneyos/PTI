------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE MeasureSubscaleType_ScoreType ADD ClinicalCutOff numeric (10,2)
go

CREATE PROCEDURE spMeasureSubscaleType_ScoreType_SetClinicalCutOff
AS
------------------------------------------------------------------------------------------------------------------------------------------------------
UPDATE MeasureSubscaleType_ScoreType SET ClinicalCutOff = NULL
------------------------------------------------------------------------------------------------------------------------------------------------------
--Above the clinical cutoff for the ECBI Intensity Scale is a raw score of 131 or higher; for the Problem Scale it is 15 or higher.								
UPDATE MeasureSubscaleType_ScoreType SET ClinicalCutOff = 131 WHERE MeasureSubscaleID = 1 AND ScoreTypeID = 5 --ECBI Intensity=1, Raw Score = 5
UPDATE MeasureSubscaleType_ScoreType SET ClinicalCutOff = 15 WHERE MeasureSubscaleID = 2 AND ScoreTypeID = 5 --ECBI Intensity=1, Raw Score = 5
------------------------------------------------------------------------------------------------------------------------------------------------------
--For any subscale of the Parenting Scale, above the the clinical cutoff is a raw score of 3.1 or higher.								
UPDATE	MeasureSubscaleType_ScoreType 
SET		ClinicalCutOff = 3.1 
WHERE	MeasureSubscaleID IN (11,12,13,14,23,24,25) --All PS subscales
		AND ScoreTypeID = 5 --Raw Score = 5
------------------------------------------------------------------------------------------------------------------------------------------------------
--For the DASS, above the clinical cutoff is a raw score doubled that corresponds with the descriptor "Moderate" or higher.								
UPDATE	
	stst 
SET		
	stst.ClinicalCutOff = RawValueMin
FROM	
	MeasureSubscaleType_ScoreType								stst

	JOIN ScoreConversion_Lookup_General							lk
		ON stst.MeasureSubscaleID=lk.MeasureSubscaleTypeID
		AND ConvertedScore = 'Moderate'
		AND lK.MeasureTypeID=4
WHERE
	stst.ScoreTypeID=3 --Raw score doubled
------------------------------------------------------------------------------------------------------------------------------------------------------
GO
USE [PTI]
GO
/****** Object:  View [dbo].[vwMeasureType_MeasureSubscaleType_ScoreType]    Script Date: 8/17/2013 12:15:46 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--------------------------------------------------------------------------------
ALTER VIEW [dbo].[vwMeasureType_MeasureSubscaleType_ScoreType]
AS

SELECT
	mt.MeasureTypeID,
	mt.MeasureTypeName,
	mt.Abbreviation,
	mtst.MeasureSubscaleTypeID,
	st.MeasureSubscaleType ,
	stsc.ScoreTypeID,
	sct.ScoreType,
	sct.NumericOrVerbose,
	stsc.ClinicalCutOff
FROM
	MeasureType															mt

	LEFT JOIN MeasureType_MeasureSubscaleType							mtst
		ON mt.MeasureTypeID = mtst.MeasureTypeID

	LEFT JOIN MeasureSubscaleType										st
		ON mtst.MeasureSubscaleTypeID = st.MeasureSubscaleTypeID

	LEFT JOIN MeasureSubscaleType_ScoreType								stsc
		ON st.MeasureSubscaleTypeID = stsc.MeasureSubscaleID

	LEFT JOIN ScoreType													sct
		ON stsc.ScoreTypeID = sct.ScoreTypeID
--------------------------------------------------------------------------------
GO

EXEC spMeasureSubscaleType_ScoreType_SetClinicalCutOff

SELECT * FROM vwMeasureType_MeasureSubscaleType_ScoreType
WHERE ClinicalCutOff IS NOT NULL

SELECT * FROM ScoreConversion_Lookup_General

