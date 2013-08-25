/*
Missing Index Details from spReport_PrePostInterventionMeasureScoreAnalysis_ByOccasion.sql - PALS\SQLEXPRESS.PTI (PALS\SydneyOs (56))
The Query Processor estimates that implementing the following index could improve the query cost by 17.6961%.
*/

USE [PTI]
GO

/****** Object:  Index [nci_FormInstanceID_Invalid]    Script Date: 8/25/2013 10:13:16 AM ******/
DROP INDEX [nci_FormInstanceID_Invalid] ON [dbo].[FormInstance_MeasureSubscaleValue]
GO


CREATE NONCLUSTERED INDEX [nci_FormInstanceID_Invalid]
ON [dbo].[FormInstance_MeasureSubscaleValue] ([FormInstanceID],[Invalid])
INCLUDE ([FormInstanceMeasureSubscaleValueID],[MeasureSubscaleTypeID])
GO

