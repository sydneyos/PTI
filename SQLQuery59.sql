/*
Missing Index Details from TEST_spReport_PrePostInterventionMeasureScoreAnalysis_ByOccasion.sql - PALS\SQLEXPRESS.PTI (PALS\SydneyOs (56))
The Query Processor estimates that implementing the following index could improve the query cost by 10.0008%.
*/


USE [PTI]
GO
CREATE NONCLUSTERED INDEX [nci_InterventionID_MeasureTypeID]
ON [dbo].[FormInstance] ([InterventionID],[MeasureTypeID])
INCLUDE ([FormInstanceID],[RespondentPersonID],[AssessedPersonID],[OcassionTypeID])
GO

