-- 2.13) RegisterInnovationInitiative Stored procedure
EXEC RegisterInnovationInitiative 4, 1, 'AI quiz generator for Data Structures', 'ChatGPT Edu generates weekly 
practice quizzes', 'Complexity quiz results are still close to the target', 'CSEN301', 3, 'T2', 4, '2027-06-30', 
7;
EXEC RegisterInnovationInitiative 4, 1, 'Wrong offering', NULL, NULL, 'CSEN999', 3, 'T1', 4, '2027-06-30', NULL;
GO

-- 2.18) AssignInitiativeMember Stored procedure
DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC AssignInitiativeMember @init, 8, 'Supporting TA';
EXEC AssignInitiativeMember @init, 8, 'Contributor';
GO

-- 2.20) AddMilestone Stored procedure
DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC AddMilestone @init, 'Write quiz prompts', 'Prompt templates for 10 topics', '2026-12-15';
EXEC AddMilestone @init, 'Pilot in section T2', 'Weekly quizzes for one month', '2027-03-31';
EXEC AddMilestone 9999, 'Nothing', NULL, '2027-01-01';
GO

-- 2.21) CompleteMilestone Stored procedure
DECLARE @init INT;
DECLARE @today DATE;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
SET @today = CAST(GETDATE() AS DATE);
EXEC CompleteMilestone @init, 1, @today;
EXEC CompleteMilestone @init, 99, @today;
GO

-- 2.25) RequestInitiativeApproval Stored procedure
DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC RequestInitiativeApproval @init, 4;
EXEC RequestInitiativeApproval @init, 4;
GO

-- 2.26) ViewInitiativeProgress Function
SELECT * FROM dbo.ViewInitiativeProgress(1);
SELECT * FROM dbo.ViewInitiativeProgress(9999);
GO

-- 2.27) CalculateInitiativeCompletion Function
SELECT dbo.CalculateInitiativeCompletion(1) AS CompletionPct;
SELECT dbo.CalculateInitiativeCompletion(9999) AS CompletionPct;
GO

-- 3.6) UpdateMilestoneStatus Stored procedure
DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC UpdateMilestoneStatus @init, 2, 'In Progress';
EXEC UpdateMilestoneStatus @init, 2, 'Done';
GO

-- 5.1) ViewFacultyPendingApprovals Function
SELECT * FROM dbo.ViewFacultyPendingApprovals(1);
SELECT * FROM dbo.ViewFacultyPendingApprovals(3);
GO

-- 5.3) DecideOnInitiative Stored procedure
DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC DecideOnInitiative @init, 1, 'Returned', 'Explain how quiz quality is checked';
EXEC DecideOnInitiative @init, 2, 'Approved', NULL;
GO

-- 5.4) EscalateToUniversity Stored procedure
DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC RequestInitiativeApproval @init, 4;
EXEC EscalateToUniversity @init, 1, 'Needs a university-wide licence for ChatGPT Edu';
EXEC EscalateToUniversity @init, 1, 'Again';
GO

-- 5.9) ViewFacultyInitiatives Function
SELECT * FROM dbo.ViewFacultyInitiatives(1, 'Escalated');
SELECT * FROM dbo.ViewFacultyInitiatives(9999, 'Escalated');
GO

-- 5.10) ViewOverdueMilestones Function
SELECT * FROM dbo.ViewOverdueMilestones(1);
SELECT * FROM dbo.ViewOverdueMilestones(9999);
GO

-- 5.11) SendOverdueAlerts Stored procedure
EXEC SendOverdueAlerts 1;
EXEC SendOverdueAlerts 9999;
GO

-- 5.17) GetFacultyDashboard Function
SELECT * FROM dbo.GetFacultyDashboard(1, 3);
SELECT * FROM dbo.GetFacultyDashboard(1, 9999);
GO

-- 6.1) ViewEscalatedItems Function
SELECT * FROM dbo.ViewEscalatedItems();
SELECT * FROM dbo.ViewEscalatedItems() WHERE ItemType = 'Proposal' AND ItemID = 9999;
GO

-- 6.2) MakeUniversityDecision Stored procedure
DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC MakeUniversityDecision 'Initiative', @init, 12, 'Approved', 'Licence approved for one year';
EXEC MakeUniversityDecision 'Proposal', 1, 12, 'Approved', NULL;
GO

-- 6.3) GetUniversityDashboard Function
SELECT * FROM dbo.GetUniversityDashboard(3);
SELECT * FROM dbo.GetUniversityDashboard(9999);
GO

-- 6.4) GetInitiativeStatsByType Function
SELECT * FROM dbo.GetInitiativeStatsByType();
SELECT * FROM dbo.GetInitiativeStatsByType() WHERE InitiativeType = 'Unknown Type';
GO

-- 6.6) GetApprovalTurnaround Function
SELECT dbo.GetApprovalTurnaround(1) AS AvgTurnaroundDays;
SELECT dbo.GetApprovalTurnaround(9999) AS AvgTurnaroundDays;
GO

-- 6.9) RankInitiativesByImpact Function
SELECT * FROM dbo.RankInitiativesByImpact('Pass Rate') ORDER BY ImprovementPct DESC;
SELECT * FROM dbo.RankInitiativesByImpact('Unknown Metric');
GO

-- 7.5) ViewMyInitiatives Function
SELECT * FROM dbo.ViewMyInitiatives(4);
SELECT * FROM dbo.ViewMyInitiatives(9999);
GO

-- 7.13) NotifyOverdueMilestone Stored procedure
EXEC NotifyOverdueMilestone 3, 1, 2;
EXEC NotifyOverdueMilestone 10, 1, 2;
GO
