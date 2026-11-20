EXEC AddSemester 'Summer', '2026-2027', '2027-07-10', '2027-08-31';
EXEC AddSemester 'Winter', '2026-2027', '2026-09-19', '2027-01-30';
GO

DECLARE @s INT;
SELECT @s = SemesterID FROM Semester WHERE Name = 'Summer' AND AcademicYear = '2026-2027';
EXEC CreateCourseOffering 'CSEN501', @s, 'T1', 'Hybrid', 40, 3;
EXEC CreateCourseOffering 'CSEN501', @s, 'T2', 'Online', 30, 14;
GO

DECLARE @s INT;
SELECT @s = SemesterID FROM Semester WHERE Name = 'Summer' AND AcademicYear = '2026-2027';
EXEC AssignTAToOffering 'CSEN501', @s, 'T1', 7;
EXEC AssignTAToOffering 'CSEN501', @s, 'T1', 3;
GO

SELECT * FROM dbo.ViewMyCourseOfferings(3, 3);
SELECT * FROM dbo.ViewMyCourseOfferings(999, 3);
GO

DECLARE @s INT;
SELECT @s = SemesterID FROM Semester WHERE Name = 'Summer' AND AcademicYear = '2026-2027';
EXEC RecordOutcomeAssessment 'CSEN501', 'ILO1', @s, 'T1', 1, 'Summer final Q2', 'EER to relational mapping question', 70, 64, 40, 'Weak entities still confusing';
EXEC RecordOutcomeAssessment 'CSEN501', 'ILO1', @s, 'T1', 3, 'Summer quiz', NULL, 70, 80, 40, NULL;
GO

DECLARE @a INT;
SELECT @a = MAX(AssessmentID) FROM Outcome_Assessment WHERE Instrument = 'Summer final Q2';
EXEC AddCorrectiveAction @a, 'Extra tutorial on weak entities before the final';
EXEC AddCorrectiveAction 2, 'Not needed';
GO

SELECT * FROM dbo.ViewUnmetAssessments(3);
SELECT * FROM dbo.ViewUnmetAssessments(999);
GO

SELECT * FROM dbo.ViewSupportedOfferings(7);
SELECT * FROM dbo.ViewSupportedOfferings(3);
GO

SELECT * FROM dbo.ViewOfferingAssessments('CSEN501', 1, 'T1');
SELECT * FROM dbo.ViewOfferingAssessments('CSEN501', 1, 'X9');
GO

DECLARE @s INT;
SELECT @s = SemesterID FROM Semester WHERE Name = 'Summer' AND AcademicYear = '2026-2027';
EXEC UpdateEnrolledCount 'CSEN501', @s, 'T1', 45;
EXEC UpdateEnrolledCount 'CSEN501', @s, 'T1', -5;
GO

SELECT dbo.GetPLOAttainment(1, 'PLO1', 2) AS PLOAttainment;
SELECT dbo.GetPLOAttainment(1, 'PLO9', 2) AS PLOAttainment;
GO

SELECT * FROM dbo.ViewAssessmentsBelowTarget(1, 2);
SELECT * FROM dbo.ViewAssessmentsBelowTarget(999, 2);
GO

SELECT * FROM dbo.TrackCorrectiveActionEffect('CSEN501', 'ILO1') ORDER BY StartDate;
SELECT * FROM dbo.TrackCorrectiveActionEffect('CSEN501', 'ILO9') ORDER BY StartDate;
GO

DECLARE @due DATE;
SET @due = DATEADD(DAY, 20, CAST(GETDATE() AS DATE));
EXEC CreateAccreditationReview 1, 'ASIIN', 'Program', '6-year', @due;
EXEC CreateAccreditationReview 999, 'ASIIN', 'Program', '6-year', @due;
GO

DECLARE @r INT;
SELECT @r = MAX(ReviewID) FROM Accreditation_Review WHERE AccreditingBody = 'ASIIN';
EXEC AttachMappingsToReview @r;
EXEC AttachMappingsToReview 999;
GO

DECLARE @r INT;
DECLARE @a INT;
SELECT @r = MAX(ReviewID) FROM Accreditation_Review WHERE AccreditingBody = 'ASIIN';
SELECT @a = MAX(AssessmentID) FROM Outcome_Assessment WHERE Instrument = 'Summer final Q2';
EXEC AttachAssessmentToReview @r, @a;
EXEC AttachAssessmentToReview @r, @a;
GO

DECLARE @r INT;
SELECT @r = MAX(ReviewID) FROM Accreditation_Review WHERE AccreditingBody = 'ASIIN';
EXEC AttachEvidenceToReview @r, 1;
EXEC AttachEvidenceToReview @r, 999;
GO

DECLARE @r INT;
SELECT @r = MAX(ReviewID) FROM Accreditation_Review WHERE AccreditingBody = 'ASIIN';
EXEC UpdateAccreditationStatus @r, 'In Progress', NULL, NULL;
EXEC UpdateAccreditationStatus @r, 'Finished', NULL, NULL;
GO

DECLARE @r INT;
SELECT @r = MAX(ReviewID) FROM Accreditation_Review WHERE AccreditingBody = 'ASIIN';
SELECT * FROM dbo.GenerateAccreditationPack(@r);
SELECT * FROM dbo.GenerateAccreditationPack(999);
GO

SELECT * FROM dbo.GetUpcomingAccreditations(30);
SELECT * FROM dbo.GetUpcomingAccreditations(-5);
GO

SELECT * FROM dbo.GetAccreditationOverview();
GO

SELECT * FROM dbo.GetAttainmentTrend(1) ORDER BY StartDate;
SELECT * FROM dbo.GetAttainmentTrend(999) ORDER BY StartDate;
GO

EXEC NotifyAccreditationDeadline 1, 30;
EXEC NotifyAccreditationDeadline 999, 30;
GO