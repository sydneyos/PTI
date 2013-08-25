USE [PTI]
GO

/****** Object:  StoredProcedure [dbo].[spReport_AttritionUndated]    Script Date: 8/25/2013 12:37:49 PM ******/
DROP PROCEDURE [dbo].[spReport_AttritionUndated]
GO

/****** Object:  StoredProcedure [dbo].[spReport_AttritionUndated]    Script Date: 8/25/2013 12:37:49 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spReport_AttritionUndated]
@AgencyID							int = NULL,
@InterventionID						int = NULL,
@RespondentPersonID					int = NULL,
@AssessedPersonID					int = NULL,
@MeasureTypeID						int = NULL,
@InterventionTypeID					int = NULL,
@InterventionSubtypeID				int = NULL,
@InterventionFacilitatorID			int = NULL,
@InterventionStartDateFrom			datetime = NULL,
@InterventionStartDateTo			datetime = NULL,
@InterventionLanguageID				int = NULL,
@AnnualIncomeTypeID					int = NULL,
@EthnicityID						int = NULL,
@EthnicityMajorGroupID              int = NULL,
@Exclude_AgencyID					int = NULL,
@Exclude_InterventionFacilitatorID	int = NULL,

@Pretesters							int = NULL,
@Completers							int = NULL,
@OcassionTypeID						int = NULL,
@DeliveryFormatTypeID				int = NULL,
@RespondentGenderID					int = NULL,
@RespondentIsClientOfAgencyID		int = NULL,
@AssessedPersonIsClientOfAgencyID	int = NULL,
@RespondentIsNotClientOfAgencyID		int = NULL,
@AssessedPersonIsNotClientOfAgencyID	int = NULL
AS
-------------------------------------------------------------------------------------------------------------------------------------------
SELECT
	InterventionID,
	AgencyID,
	AgencyName,
	AgencyAbbreviation,
	InterventionTypeID,
	InterventionType,
	InterventionName,
	TotalSessions,
	TotalMembers,
	SessionsCompleted,
	AvgSessionsCompletedForPeopleWithData,
	SessionsCompleted/TotalMembers as AvgSessionsCompleted
FROM
(
	SELECT
		i.InterventionID, 
		i.AgencyID, 
		i.AgencyName, 
		i.AgencyAbbreviation, 
		i.InterventionTypeID, 
		i.InterventionType, 
		i.InterventionName, 
		SUM ( DISTINCT i.NumberOfIntendedSessions )					as TotalSessions,
		COUNT ( DISTINCT m.PersonID )									as TotalMembers,
		SUM ( DISTINCT a.SessionAttended )								as SessionsCompleted,
		AVG ( DISTINCT a.SessionAttended)								as AvgSessionsCompletedForPeopleWithData,

		------------------------------------------------------------------------------------------------------------
		( 

				SELECT 
					COUNT( DISTINCT PersonID ) 
				FROM 
					vwIntervention_Member_EthnicityMajorGroup im 
				WHERE 
					im.InterventionID = i.InterventionID 
					AND im.GraduatedID = 1 
					AND ( @EthnicityMajorGroupID IS NULL OR im.EthnicityMajorGroupID = @EthnicityMajorGroupID ) 
					AND PersonID IN ( SELECT PersonID FROM Person WHERE @RespondentGenderID IS NULL OR ISNULL(GenderID ,4) = @RespondentGenderID )
					AND ( @RespondentIsClientOfAgencyID IS NULL OR im.PersonID IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
					AND ( @RespondentIsNotClientOfAgencyID IS NULL OR im.PersonID NOT IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
					AND 
						( 
							@AssessedPersonIsClientOfAgencyID IS NULL OR im.PersonID IN
								(
									SELECT
										fi.RespondentPersonID
									FROM
										FormInstance											fi

										JOIN Person_AgencyRelationship							pa
											ON fi.AssessedPersonID=pa.PersonID
											AND pa.AgencyID = @AssessedPersonIsClientOfAgencyID
											AND PersonAgencyRelationshipTypeID = 2 
									WHERE
										i.InterventionID = fi.InterventionID
								)
						)
					AND 
						( 
							@AssessedPersonIsNotClientOfAgencyID IS NULL OR im.PersonID NOT IN
								(
									SELECT
										fi.RespondentPersonID
									FROM
										FormInstance											fi

										JOIN Person_AgencyRelationship							pa
											ON fi.AssessedPersonID=pa.PersonID
											AND pa.AgencyID = @AssessedPersonIsNotClientOfAgencyID
											AND PersonAgencyRelationshipTypeID = 2 
									WHERE
										i.InterventionID = fi.InterventionID
								)
						)		
					AND ( @Exclude_InterventionFacilitatorID IS NULL OR InterventionID NOT IN ( SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID = @Exclude_InterventionFacilitatorID ) )
			)
													
		as MembersWhoGraduated,
		------------------------------------------------------------------------------------------------------------
		CAST 
			(
				CASE
					WHEN COUNT ( DISTINCT m.PersonID ) = 0 THEN 0
					ELSE 
						1.0 *  
						( 
								SELECT 
									COUNT( DISTINCT PersonID ) 
								FROM 
									vwIntervention_Member_EthnicityMajorGroup im 
								WHERE 
									im.InterventionID = i.InterventionID 
									AND im.GraduatedID = 1 
									AND ( @EthnicityMajorGroupID IS NULL OR im.EthnicityMajorGroupID = @EthnicityMajorGroupID ) 
									AND PersonID IN ( SELECT PersonID FROM Person WHERE @RespondentGenderID IS NULL OR ISNULL(GenderID, 4) = @RespondentGenderID )
									AND ( @RespondentIsClientOfAgencyID IS NULL OR im.PersonID IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
									AND ( @RespondentIsNotClientOfAgencyID IS NULL OR im.PersonID NOT IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
									AND 
										( 
											@AssessedPersonIsClientOfAgencyID IS NULL OR im.PersonID IN
												(
													SELECT
														fi.RespondentPersonID
													FROM
														FormInstance											fi

														JOIN Person_AgencyRelationship							pa
															ON fi.AssessedPersonID=pa.PersonID
															AND pa.AgencyID = @AssessedPersonIsClientOfAgencyID
															AND PersonAgencyRelationshipTypeID = 2 
													WHERE
														i.InterventionID = fi.InterventionID
												)
										)
									AND 
										( 
											@AssessedPersonIsNotClientOfAgencyID IS NULL OR im.PersonID NOT IN
												(
													SELECT
														fi.RespondentPersonID
													FROM
														FormInstance											fi

														JOIN Person_AgencyRelationship							pa
															ON fi.AssessedPersonID=pa.PersonID
															AND pa.AgencyID = @AssessedPersonIsNotClientOfAgencyID
															AND PersonAgencyRelationshipTypeID = 2 
													WHERE
														i.InterventionID = fi.InterventionID
												)
										)								
									AND ( @Exclude_InterventionFacilitatorID IS NULL OR InterventionID NOT IN ( SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID = @Exclude_InterventionFacilitatorID ) )
							)						
					/ ( COUNT ( DISTINCT m.PersonID ) )
				END
				AS numeric ( 4, 2 )
			)
		as PctOfMembersWhoGraduated,
		------------------------------------------------------------------------------------------------------------
		CAST 
			(
				CASE
					WHEN COUNT ( DISTINCT a.PersonID ) = 0 THEN 0
					ELSE 
						1.0 *  
							(
								SELECT 
									COUNT( DISTINCT PersonID ) 
								FROM 
									vwIntervention_Member_EthnicityMajorGroup im 
								WHERE 
									im.InterventionID = i.InterventionID 
									AND im.GraduatedID = 1 
									AND ( @EthnicityMajorGroupID IS NULL OR im.EthnicityMajorGroupID = @EthnicityMajorGroupID ) 
									AND PersonID IN ( SELECT PersonID FROM Person WHERE @RespondentGenderID IS NULL OR ISNULL(GenderID ,4) = @RespondentGenderID )
									AND ( @RespondentIsClientOfAgencyID IS NULL OR im.PersonID IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
									AND ( @RespondentIsNotClientOfAgencyID IS NULL OR im.PersonID NOT IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
									AND 
										( 
											@AssessedPersonIsClientOfAgencyID IS NULL OR im.PersonID IN
												(
													SELECT
														fi.RespondentPersonID
													FROM
														FormInstance											fi

														JOIN Person_AgencyRelationship							pa
															ON fi.AssessedPersonID=pa.PersonID
															AND pa.AgencyID = @AssessedPersonIsClientOfAgencyID
															AND PersonAgencyRelationshipTypeID = 2 
													WHERE
														i.InterventionID = fi.InterventionID
												)
										)
									AND 
										( 
											@AssessedPersonIsNotClientOfAgencyID IS NULL OR im.PersonID NOT IN
												(
													SELECT
														fi.RespondentPersonID
													FROM
														FormInstance											fi

														JOIN Person_AgencyRelationship							pa
															ON fi.AssessedPersonID=pa.PersonID
															AND pa.AgencyID = @AssessedPersonIsNotClientOfAgencyID
															AND PersonAgencyRelationshipTypeID = 2 
													WHERE
														i.InterventionID = fi.InterventionID
												)
										)								
									AND ( @Exclude_InterventionFacilitatorID IS NULL OR InterventionID NOT IN ( SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID = @Exclude_InterventionFacilitatorID ) )
								)
							/ ( COUNT ( DISTINCT a.PersonID ) )
				END
				AS numeric ( 4, 2 )
			)
		as PctOfMembersWhoGraduated_OnePlusContentSession
		------------------------------------------------------------------------------------------------------------
	FROM
		vwIntervention												i

		INNER JOIN Intervention_Member								m
			ON i.InterventionID  = m.InterventionID
			AND m.PersonID IN ( SELECT PersonID FROM vwPerson_EthnicityMajorGroup WHERE @EthnicityMajorGroupID IS NULL OR EthnicityMajorGroupID = @EthnicityMajorGroupID )
			AND m.PersonID IN ( SELECT PersonID FROM Person WHERE @RespondentGenderID IS NULL OR ISNULL(GenderID, 4) = @RespondentGenderID )

		INNER JOIN Intervention_Member_UndatedSessionsAttended a
			ON i.InterventionID = a.InterventionID
			AND m.PersonID = a.PersonID

	WHERE
		i.InterventionEndDate <= GETDATE()
		AND ( i.InterventionTypeID = @InterventionTypeID OR @InterventionTypeID IS NULL )
		AND ( i.InterventionSubtypeID = @InterventionSubtypeID	OR @InterventionSubtypeID	IS NULL )
		AND ( i.InterventionID = @InterventionID OR @InterventionID IS NULL )
		AND ( i.InterventionSubtypeID = @InterventionSubtypeID OR @InterventionSubtypeID IS NULL )
		AND ( i.InterventionStartDate BETWEEN @InterventionStartDateFrom AND @InterventionStartDateTo OR @InterventionStartDateFrom IS NULL )
		AND ( i.AgencyID = @AgencyID OR @AgencyID IS NULL )
		AND ( i.LanguageID = @InterventionLanguageID OR @InterventionLanguageID IS NULL )
		AND ( @InterventionFacilitatorID IS NULL OR i.InterventionID IN ( SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID = @InterventionFacilitatorID ) )
		--AND ( @EthnicityMajorGroupID IS NULL OR pe.EthnicityMajorGroupID = @EthnicityMajorGroupID )
		AND ( i.DeliveryFormatTypeID = @DeliveryFormatTypeID OR @DeliveryFormatTypeID IS NULL )
		AND ( i.AgencyID <> @Exclude_AgencyID OR @Exclude_AgencyID IS NULL )
		AND ( @RespondentIsClientOfAgencyID IS NULL OR m.PersonID IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )
		AND ( @RespondentIsNotClientOfAgencyID IS NULL OR m.PersonID NOT IN ( SELECT PersonID FROM Person_AgencyRelationship WHERE AgencyID = @RespondentIsNotClientOfAgencyID and PersonAgencyRelationshipTypeID = 2 ) )							
		AND 
			( 
				@AssessedPersonIsClientOfAgencyID IS NULL OR m.PersonID IN
					(
						SELECT
							fi.RespondentPersonID
						FROM
							FormInstance											fi

							JOIN Person_AgencyRelationship							pa
								ON fi.AssessedPersonID=pa.PersonID
								AND pa.AgencyID = @AssessedPersonIsClientOfAgencyID
								AND PersonAgencyRelationshipTypeID = 2 
						WHERE
							i.InterventionID = fi.InterventionID
					)
				)
		AND 
			( 
				@AssessedPersonIsNotClientOfAgencyID IS NULL OR m.PersonID NOT IN
					(
						SELECT
							fi.RespondentPersonID
						FROM
							FormInstance											fi

							JOIN Person_AgencyRelationship							pa
								ON fi.AssessedPersonID=pa.PersonID
								AND pa.AgencyID = @AssessedPersonIsNotClientOfAgencyID
								AND PersonAgencyRelationshipTypeID = 2 
						WHERE
							i.InterventionID = fi.InterventionID
					)
			)	
		AND ( @Exclude_InterventionFacilitatorID IS NULL OR i.InterventionID NOT IN ( SELECT InterventionID FROM Intervention_Facilitator WHERE FacilitatorPersonID = @Exclude_InterventionFacilitatorID ) )
	GROUP BY
		i.InterventionID, 
		i.AgencyID, 
		i.AgencyName, 
		i.AgencyAbbreviation, 
		i.InterventionTypeID, 
		i.InterventionType, 
		i.InterventionName
		) T
	ORDER BY
		AgencyName,
		InterventionName
------------------------------------------------------------------------------------------------------

GO

