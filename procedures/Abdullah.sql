CREATE PROCEDURE RegisterInnovationInitiative
@SubmitterID INT, @FacultyID INT, @Title VARCHAR(150), @Description VARCHAR(1000), @Motivation VARCHAR(1000),
@CourseCode VARCHAR(20), @SemesterID INT, @SectionID VARCHAR(20), @TargetStartSemesterID INT,
@ImplementationDeadline DATE, @AssessmentID INT
AS
BEGIN
    DECLARE @InitiativeID INT
    IF @Title IS NULL OR @Title = ''
        PRINT 'Error: the initiative needs a title.'
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @SubmitterID)
        PRINT 'Error: the submitting member does not exist.'
    ELSE IF NOT EXISTS (SELECT * FROM Faculty WHERE FacultyID = @FacultyID)
        PRINT 'Error: the faculty does not exist.'
    ELSE IF NOT EXISTS (SELECT * FROM Course_Offering WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID
AND SectionID = @SectionID)
        PRINT 'Error: this course offering (course, semester, section) does not exist.'
    ELSE IF NOT EXISTS (SELECT * FROM Semester WHERE SemesterID = @TargetStartSemesterID)
        PRINT 'Error: the target start semester does not exist.'
    ELSE IF @AssessmentID IS NOT NULL AND NOT EXISTS (SELECT * FROM Outcome_Assessment WHERE AssessmentID =
@AssessmentID)
        PRINT 'Error: assessment ' + CAST(@AssessmentID AS VARCHAR(10)) + ' does not exist.'
    ELSE IF @ImplementationDeadline < CAST(GETDATE() AS DATE)
        PRINT 'Error: the implementation deadline cannot be in the past.'
    ELSE
    BEGIN
        INSERT INTO Innovation_Initiative (Title, Description, Motivation, RegistrationDate,
ImplementationDeadline, Status,
                                           CourseCode, SemesterID, SectionID, FacultyID, SubmitterID,
TargetStartSemesterID, AssessmentID)
        VALUES (@Title, @Description, @Motivation, CAST(GETDATE() AS DATE), @ImplementationDeadline, 'Draft',
                @CourseCode, @SemesterID, @SectionID, @FacultyID, @SubmitterID, @TargetStartSemesterID,
@AssessmentID)
        SELECT @InitiativeID = MAX(InitiativeID) FROM Innovation_Initiative
        INSERT INTO Audit_Log (ActionType, ChangeSummary, ActorID, InitiativeID)
        VALUES ('Create', 'Initiative registered: ' + @Title, @SubmitterID, @InitiativeID)
        PRINT 'Initiative registered as Draft. New InitiativeID = ' + CAST(@InitiativeID AS VARCHAR(10))
    END
END
GO

CREATE PROCEDURE AssignInitiativeMember
@InitiativeID INT, @MemberID INT, @Role VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: this initiative does not exist.'
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: this member does not exist.'
    ELSE IF @Role IS NULL OR @Role = ''
        PRINT 'Error: a role is required (e.g. Lead, Contributor, Supporting TA).'
    ELSE IF @Role = 'Supporting TA' AND NOT EXISTS (SELECT * FROM Teaching_Assistant WHERE MemberID = @MemberID)
        PRINT 'Error: member ' + CAST(@MemberID AS VARCHAR(10)) + ' is not a teaching assistant.'
    ELSE IF EXISTS (SELECT * FROM Initiative_Member WHERE InitiativeID = @InitiativeID AND MemberID = @MemberID)
        PRINT 'Error: member ' + CAST(@MemberID AS VARCHAR(10)) + ' is already assigned to initiative ' +
CAST(@InitiativeID AS VARCHAR(10)) + '.'
    ELSE
    BEGIN
        INSERT INTO Initiative_Member (InitiativeID, MemberID, Role)
        VALUES (@InitiativeID, @MemberID, @Role)
        PRINT 'Member ' + CAST(@MemberID AS VARCHAR(10)) + ' assigned to initiative ' + CAST(@InitiativeID AS
VARCHAR(10)) + ' as ' + @Role + '.'

    END
END
GO

CREATE PROCEDURE AddMilestone
@InitiativeID INT, @Title VARCHAR(150), @Description VARCHAR(1000), @DueDate DATE
AS
BEGIN
    DECLARE @SeqNo INT
    IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: this initiative does not exist.'
    ELSE IF @Title IS NULL OR @Title = ''
        PRINT 'Error: the milestone needs a title.'
    ELSE IF @DueDate IS NULL
        PRINT 'Error: the milestone needs a due date.'
    ELSE
    BEGIN
        SELECT @SeqNo = MAX(SeqNo) FROM Milestone WHERE InitiativeID = @InitiativeID
        IF @SeqNo IS NULL
            SET @SeqNo = 1
        ELSE
            SET @SeqNo = @SeqNo + 1
        INSERT INTO Milestone (InitiativeID, SeqNo, Title, Description, DueDate, CompletionDate, Status)
        VALUES (@InitiativeID, @SeqNo, @Title, @Description, @DueDate, NULL, 'Pending')
        PRINT 'Milestone added to initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + '. New SeqNo = ' +
CAST(@SeqNo AS VARCHAR(10))
    END
END
GO

CREATE PROCEDURE CompleteMilestone
@InitiativeID INT, @SeqNo INT, @CompletionDate DATE
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Milestone WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo)
        PRINT 'Error: this milestone does not exist.'
    ELSE IF EXISTS (SELECT * FROM Milestone WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo AND Status =
'Completed')
        PRINT 'Error: this milestone is already completed.'
    ELSE IF @CompletionDate IS NULL OR @CompletionDate > CAST(GETDATE() AS DATE)
        PRINT 'Error: the completion date is missing or in the future.'
    ELSE
    BEGIN
        UPDATE Milestone
        SET CompletionDate = @CompletionDate, Status = 'Completed'
        WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo
        PRINT 'Milestone ' + CAST(@SeqNo AS VARCHAR(10)) + ' of initiative ' + CAST(@InitiativeID AS VARCHAR(10))
            + ' completed on ' + CAST(@CompletionDate AS VARCHAR(10)) + '.'
    END
END
GO

CREATE PROCEDURE RequestInitiativeApproval
@InitiativeID INT, @MemberID INT
AS
BEGIN
    DECLARE @DeanName VARCHAR(150)
    IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: this initiative does not exist.'
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: this member does not exist.'
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID AND SubmitterID =
@MemberID)
        AND NOT EXISTS (SELECT * FROM Initiative_Member WHERE InitiativeID = @InitiativeID AND MemberID =
@MemberID)
        PRINT 'Error: member ' + CAST(@MemberID AS VARCHAR(10)) + ' did not submit and is not assigned to this initiative.'
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID AND Status IN
('Draft', 'Returned'))
        PRINT 'Error: only a Draft or Returned initiative can be sent for approval.'
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative I JOIN Faculty F ON F.FacultyID = I.FacultyID
                        WHERE I.InitiativeID = @InitiativeID AND F.DeanID IS NOT NULL)
        PRINT 'Error: the faculty of this initiative has no dean.'
    ELSE
    BEGIN
        SELECT @DeanName = M.FullName
        FROM Innovation_Initiative I
        JOIN Faculty F ON F.FacultyID = I.FacultyID
        JOIN Academic_Member M ON M.MemberID = F.DeanID
        WHERE I.InitiativeID = @InitiativeID
        UPDATE Innovation_Initiative
        SET Status = 'Pending Approval'
        WHERE InitiativeID = @InitiativeID
        INSERT INTO Audit_Log (ActionType, ChangeSummary, ActorID, InitiativeID)
        VALUES ('Update', 'Approval requested for initiative ' + CAST(@InitiativeID AS VARCHAR(10)), @MemberID,
@InitiativeID)
        PRINT 'Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' is now Pending Approval by Dean ' + @DeanName
+ '.'
    END
END
GO

CREATE FUNCTION ViewInitiativeProgress (@InitiativeID INT)
RETURNS TABLE
AS
RETURN (
    SELECT SeqNo, Title, DueDate, CompletionDate, Status,
           CASE WHEN DueDate < CAST(GETDATE() AS DATE) AND Status <> 'Completed' THEN 'Yes' ELSE 'No' END AS
IsOverdue
    FROM Milestone
    WHERE InitiativeID = @InitiativeID
)
GO

CREATE FUNCTION CalculateInitiativeCompletion (@InitiativeID INT)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Total INT
    DECLARE @Completed INT
    DECLARE @Result DECIMAL(5,2)
    SELECT @Total = COUNT(*) FROM Milestone WHERE InitiativeID = @InitiativeID

    SELECT @Completed = COUNT(*) FROM Milestone WHERE InitiativeID = @InitiativeID AND Status = 'Completed'
    IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        SET @Result = NULL
    ELSE IF @Total = 0
        SET @Result = 0
    ELSE
        SET @Result = @Completed * 100.0 / @Total
    RETURN @Result
END
GO

CREATE PROCEDURE UpdateMilestoneStatus
@InitiativeID INT, @SeqNo INT, @Status VARCHAR(50)
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Milestone WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo)
        PRINT 'Error: this milestone does not exist.'
    ELSE IF @Status IS NULL OR @Status NOT IN ('Pending', 'In Progress', 'Delayed', 'Completed')
        PRINT 'Error: status must be Pending, In Progress, Delayed or Completed.'
    ELSE
    BEGIN
        IF @Status = 'Completed'
        BEGIN
            UPDATE Milestone
            SET Status = @Status
            WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo
            UPDATE Milestone
            SET CompletionDate = CAST(GETDATE() AS DATE)
            WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo AND CompletionDate IS NULL
        END
        ELSE
            UPDATE Milestone
            SET Status = @Status, CompletionDate = NULL
            WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo
        PRINT 'Milestone ' + CAST(@SeqNo AS VARCHAR(10)) + ' of initiative ' + CAST(@InitiativeID AS VARCHAR(10))
            + ' is now ' + @Status + '.'
    END
END
GO

CREATE FUNCTION ViewFacultyPendingApprovals (@DeanID INT)
RETURNS TABLE
AS
RETURN (
    SELECT 'Proposal' AS ItemType, P.ProposalID AS ItemID, P.Title, M.FullName AS Submitter, P.SubmissionDate
    FROM Modification_Proposal P
    JOIN Program G ON G.ProgramID = P.ProgramID
    JOIN Faculty F ON F.FacultyID = G.FacultyID
    JOIN Academic_Member M ON M.MemberID = P.ProposerID
    WHERE F.DeanID = @DeanID
      AND NOT EXISTS (SELECT * FROM Approval_Record A
                      WHERE A.ProposalID = P.ProposalID AND A.Decision IN ('Approved', 'Rejected')
                        AND A.DecisionLevel IN ('Dean', 'University'))
      AND NOT EXISTS (SELECT * FROM Approval_Record A
                      WHERE A.ProposalID = P.ProposalID AND A.Decision = 'Escalated'
                        AND A.ApprovalID = (SELECT TOP 1 A2.ApprovalID FROM Approval_Record A2
                                            WHERE A2.ProposalID = P.ProposalID
                                            ORDER BY A2.DecisionDate DESC, A2.ApprovalID DESC))
    UNION ALL
    SELECT 'Initiative', I.InitiativeID, I.Title, M.FullName, I.RegistrationDate
    FROM Innovation_Initiative I
    JOIN Faculty F ON F.FacultyID = I.FacultyID

    JOIN Academic_Member M ON M.MemberID = I.SubmitterID
    WHERE F.DeanID = @DeanID AND I.Status = 'Pending Approval'
)
GO

CREATE PROCEDURE DecideOnInitiative
@InitiativeID INT, @DeanID INT, @Decision VARCHAR(50), @Comments VARCHAR(1000)
AS
BEGIN
    DECLARE @ApprovalID INT
    IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: this initiative does not exist.'
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative I JOIN Faculty F ON F.FacultyID = I.FacultyID
                        WHERE I.InitiativeID = @InitiativeID AND F.DeanID = @DeanID)
        PRINT 'Error: this member is not the dean of the initiative''s faculty.'
    ELSE IF @Decision IS NULL OR @Decision NOT IN ('Approved', 'Rejected', 'Returned')
        PRINT 'Error: decision must be Approved, Rejected or Returned.'
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID AND Status =
'Pending Approval')
        PRINT 'Error: initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' is not pending approval.'
    ELSE
    BEGIN
        INSERT INTO Approval_Record (Decision, DecisionLevel, DecisionDate, Comments, DeciderID, ProposalID,
InitiativeID)
        VALUES (@Decision, 'Dean', GETDATE(), @Comments, @DeanID, NULL, @InitiativeID)
        SELECT @ApprovalID = MAX(ApprovalID) FROM Approval_Record
        UPDATE Innovation_Initiative
        SET Status = @Decision
        WHERE InitiativeID = @InitiativeID
        INSERT INTO Audit_Log (ActionType, ChangeSummary, ActorID, ApprovalID)
        VALUES ('Create', 'Dean decision ' + @Decision + ' on initiative ' + CAST(@InitiativeID AS VARCHAR(10)),
@DeanID, @ApprovalID)
        PRINT 'Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' was ' + @Decision + ' by the dean.'
    END
END
GO

CREATE PROCEDURE EscalateToUniversity
@InitiativeID INT, @DeanID INT, @Comments VARCHAR(1000)
AS
BEGIN
    DECLARE @ApprovalID INT
    IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: this initiative does not exist.'
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative I JOIN Faculty F ON F.FacultyID = I.FacultyID
                        WHERE I.InitiativeID = @InitiativeID AND F.DeanID = @DeanID)
        PRINT 'Error: this member is not the dean of the initiative''s faculty.'
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID AND Status =
'Pending Approval')
        PRINT 'Error: initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' is not pending approval, so it cannot be escalated.'
    ELSE
    BEGIN
        INSERT INTO Approval_Record (Decision, DecisionLevel, DecisionDate, Comments, DeciderID, ProposalID,
InitiativeID)
        VALUES ('Escalated', 'Dean', GETDATE(), @Comments, @DeanID, NULL, @InitiativeID)
        SELECT @ApprovalID = MAX(ApprovalID) FROM Approval_Record
        UPDATE Innovation_Initiative
        SET Status = 'Escalated'
        WHERE InitiativeID = @InitiativeID
        INSERT INTO Audit_Log (ActionType, ChangeSummary, ActorID, ApprovalID)
        VALUES ('Create', 'Dean escalated initiative ' + CAST(@InitiativeID AS VARCHAR(10)), @DeanID, @ApprovalID)

        PRINT 'Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' was escalated to University Management.'
    END
END
GO

CREATE FUNCTION ViewFacultyInitiatives (@FacultyID INT, @Status VARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT I.InitiativeID, I.Title, I.CourseCode, C.Title AS CourseTitle, S.Name + ' ' + S.AcademicYear AS
Semester,
           I.SectionID, M.FullName AS Submitter, I.ImplementationDeadline, I.Status
    FROM Innovation_Initiative I
    JOIN Course C ON C.CourseCode = I.CourseCode
    JOIN Semester S ON S.SemesterID = I.SemesterID
    JOIN Academic_Member M ON M.MemberID = I.SubmitterID
    WHERE I.FacultyID = @FacultyID AND (@Status IS NULL OR I.Status = @Status)
)
GO

CREATE FUNCTION ViewOverdueMilestones (@FacultyID INT)
RETURNS TABLE
AS
RETURN (
    SELECT I.InitiativeID, I.Title AS InitiativeTitle, MS.SeqNo, MS.Title AS MilestoneTitle, MS.DueDate,
           DATEDIFF(DAY, MS.DueDate, CAST(GETDATE() AS DATE)) AS DaysOverdue,
           M.FullName AS AssignedMember, IM.Role
    FROM Milestone MS
    JOIN Innovation_Initiative I ON I.InitiativeID = MS.InitiativeID
    LEFT JOIN Initiative_Member IM ON IM.InitiativeID = I.InitiativeID
    LEFT JOIN Academic_Member M ON M.MemberID = IM.MemberID
    WHERE I.FacultyID = @FacultyID AND MS.DueDate < CAST(GETDATE() AS DATE) AND MS.Status <> 'Completed'
)
GO

CREATE PROCEDURE SendOverdueAlerts
@FacultyID INT
AS
BEGIN
    DECLARE @LastID INT
    DECLARE @Count INT
    DECLARE @Recipients INT
    IF NOT EXISTS (SELECT * FROM Faculty WHERE FacultyID = @FacultyID)
        PRINT 'Error: this faculty does not exist.'
    ELSE
    BEGIN
        SELECT @LastID = MAX(NotificationID) FROM Notification
        IF @LastID IS NULL
            SET @LastID = 0
        INSERT INTO Notification (MessageContent, CreatedAt, Urgency, Category)
        SELECT 'Milestone ' + CAST(MS.SeqNo AS VARCHAR(10)) + ' "' + MS.Title + '" of initiative '
               + CAST(I.InitiativeID AS VARCHAR(10)) + ' "' + I.Title + '" is overdue (due ' + CAST(MS.DueDate AS
VARCHAR(10)) + ')',
               GETDATE(), 'High', 'Milestone'
        FROM Milestone MS

        JOIN Innovation_Initiative I ON I.InitiativeID = MS.InitiativeID
        WHERE I.FacultyID = @FacultyID AND MS.DueDate < CAST(GETDATE() AS DATE) AND MS.Status <> 'Completed'
          AND EXISTS (SELECT * FROM Initiative_Member IM WHERE IM.InitiativeID = I.InitiativeID)
        INSERT INTO Notification_Recipient (NotificationID, MemberID, ReadStatus)
        SELECT N.NotificationID, IM.MemberID, 0
        FROM Milestone MS
        JOIN Innovation_Initiative I ON I.InitiativeID = MS.InitiativeID
        JOIN Initiative_Member IM ON IM.InitiativeID = I.InitiativeID
        JOIN Notification N ON N.MessageContent = 'Milestone ' + CAST(MS.SeqNo AS VARCHAR(10)) + ' "' + MS.Title +
'" of initiative '
               + CAST(I.InitiativeID AS VARCHAR(10)) + ' "' + I.Title + '" is overdue (due ' + CAST(MS.DueDate AS
VARCHAR(10)) + ')'
        WHERE N.NotificationID > @LastID
        SELECT @Count = COUNT(*) FROM Notification WHERE NotificationID > @LastID
        SELECT @Recipients = COUNT(*) FROM Notification_Recipient WHERE NotificationID > @LastID
        PRINT CAST(@Count AS VARCHAR(10)) + ' overdue notification(s) sent to ' + CAST(@Recipients AS VARCHAR(10))
            + ' recipient(s) in faculty ' + CAST(@FacultyID AS VARCHAR(10)) + '.'
    END
END
GO

CREATE FUNCTION GetFacultyDashboard (@FacultyID INT, @SemesterID INT)
RETURNS TABLE
AS
RETURN (
    SELECT F.FacultyID, F.Name AS Faculty, S.Name + ' ' + S.AcademicYear AS Semester,
           (SELECT COUNT(*) FROM Innovation_Initiative I
            WHERE I.FacultyID = F.FacultyID AND I.SemesterID = S.SemesterID
              AND I.Status IN ('Approved', 'In Progress')) AS ActiveInitiatives,
           (SELECT COUNT(*) FROM Innovation_Initiative I
            WHERE I.FacultyID = F.FacultyID AND I.SemesterID = S.SemesterID
              AND I.Status IN ('Pending Approval', 'Escalated'))
           + (SELECT COUNT(*) FROM Modification_Proposal P
              JOIN Program G ON G.ProgramID = P.ProgramID
              WHERE G.FacultyID = F.FacultyID
                AND P.SubmissionDate >= S.StartDate AND P.SubmissionDate < DATEADD(DAY, 1, S.EndDate)
                AND NOT EXISTS (SELECT * FROM Approval_Record A
                                WHERE A.ProposalID = P.ProposalID AND A.Decision IN ('Approved', 'Rejected')
                                  AND A.DecisionLevel IN ('Dean', 'University'))) AS PendingApprovals,
           (SELECT COUNT(*) FROM Milestone MS
            JOIN Innovation_Initiative I ON I.InitiativeID = MS.InitiativeID
            WHERE I.FacultyID = F.FacultyID AND I.SemesterID = S.SemesterID
              AND MS.DueDate < CAST(GETDATE() AS DATE) AND MS.Status <> 'Completed') AS OverdueMilestones,
           (SELECT AVG(A.TargetMet * 100.0)
            FROM Outcome_Assessment A
            JOIN Outcome_Mapping OM ON OM.MappingID = A.MappingID
            JOIN Program G ON G.ProgramID = OM.ProgramID
            WHERE G.FacultyID = F.FacultyID AND A.SemesterID = S.SemesterID) AS PctAssessmentsMetTarget
    FROM Faculty F
    JOIN Semester S ON S.SemesterID = @SemesterID
    WHERE F.FacultyID = @FacultyID
)
GO

CREATE FUNCTION ViewEscalatedItems ()
RETURNS TABLE
AS
RETURN (
    SELECT 'Proposal' AS ItemType, P.ProposalID AS ItemID, P.Title, F.Name AS Faculty, A.DecisionDate AS
EscalationDate
    FROM Modification_Proposal P
    JOIN Program G ON G.ProgramID = P.ProgramID
    JOIN Faculty F ON F.FacultyID = G.FacultyID
    JOIN Approval_Record A ON A.ProposalID = P.ProposalID

    WHERE A.Decision = 'Escalated'
      AND A.ApprovalID = (SELECT TOP 1 A2.ApprovalID FROM Approval_Record A2
                          WHERE A2.ProposalID = P.ProposalID
                          ORDER BY A2.DecisionDate DESC, A2.ApprovalID DESC)
    UNION ALL
    SELECT 'Initiative', I.InitiativeID, I.Title, F.Name,
           (SELECT MAX(A.DecisionDate) FROM Approval_Record A
            WHERE A.InitiativeID = I.InitiativeID AND A.Decision = 'Escalated')
    FROM Innovation_Initiative I
    JOIN Faculty F ON F.FacultyID = I.FacultyID
    WHERE I.Status = 'Escalated'
)
GO

CREATE PROCEDURE MakeUniversityDecision
@ItemType VARCHAR(20), @ItemID INT, @ManagerID INT, @Decision VARCHAR(50), @Comments VARCHAR(1000)
AS
BEGIN
    DECLARE @ApprovalID INT
    IF @ItemType IS NULL OR @ItemType NOT IN ('Proposal', 'Initiative')
        PRINT 'Error: item type must be Proposal or Initiative.'
    ELSE IF NOT EXISTS (SELECT * FROM University_Management WHERE MemberID = @ManagerID)
        PRINT 'Error: this member is not in University Management.'
    ELSE IF @Decision IS NULL OR @Decision NOT IN ('Approved', 'Rejected', 'Returned')
        PRINT 'Error: decision must be Approved, Rejected or Returned.'
    ELSE IF @ItemType = 'Proposal' AND NOT EXISTS (SELECT * FROM Modification_Proposal WHERE ProposalID = @ItemID)
        PRINT 'Error: this proposal does not exist.'
    ELSE IF @ItemType = 'Initiative' AND NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID =
@ItemID)
        PRINT 'Error: this initiative does not exist.'
    ELSE IF @ItemType = 'Proposal'
        AND NOT EXISTS (SELECT * FROM Approval_Record A
                        WHERE A.ProposalID = @ItemID AND A.Decision = 'Escalated'
                          AND A.ApprovalID = (SELECT TOP 1 A2.ApprovalID FROM Approval_Record A2
                                              WHERE A2.ProposalID = @ItemID
                                              ORDER BY A2.DecisionDate DESC, A2.ApprovalID DESC))
        PRINT 'Error: proposal ' + CAST(@ItemID AS VARCHAR(10)) + ' has not been escalated to the university.'
    ELSE IF @ItemType = 'Initiative'
        AND NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @ItemID AND Status = 'Escalated')
        PRINT 'Error: initiative ' + CAST(@ItemID AS VARCHAR(10)) + ' has not been escalated to the university.'
    ELSE
    BEGIN
        IF @ItemType = 'Proposal'
            INSERT INTO Approval_Record (Decision, DecisionLevel, DecisionDate, Comments, DeciderID, ProposalID,
InitiativeID)
            VALUES (@Decision, 'University', GETDATE(), @Comments, @ManagerID, @ItemID, NULL)
        ELSE
        BEGIN
            INSERT INTO Approval_Record (Decision, DecisionLevel, DecisionDate, Comments, DeciderID, ProposalID,
InitiativeID)
            VALUES (@Decision, 'University', GETDATE(), @Comments, @ManagerID, NULL, @ItemID)
            UPDATE Innovation_Initiative
            SET Status = @Decision
            WHERE InitiativeID = @ItemID
        END
        SELECT @ApprovalID = MAX(ApprovalID) FROM Approval_Record
        INSERT INTO Audit_Log (ActionType, ChangeSummary, ActorID, ApprovalID)
        VALUES ('Create', 'University decision ' + @Decision + ' on ' + @ItemType + ' ' + CAST(@ItemID AS
VARCHAR(10)), @ManagerID, @ApprovalID)
        PRINT @ItemType + ' ' + CAST(@ItemID AS VARCHAR(10)) + ' was ' + @Decision + ' at university level.'
    END
END
GO

CREATE FUNCTION GetUniversityDashboard (@SemesterID INT)
RETURNS TABLE
AS
RETURN (
    SELECT F.FacultyID, F.Name AS Faculty,
           (SELECT COUNT(*) FROM Innovation_Initiative I WHERE I.FacultyID = F.FacultyID AND I.SemesterID =
@SemesterID AND I.Status = 'Draft') AS Draft,
           (SELECT COUNT(*) FROM Innovation_Initiative I WHERE I.FacultyID = F.FacultyID AND I.SemesterID =
@SemesterID AND I.Status = 'Pending Approval') AS PendingApproval,
           (SELECT COUNT(*) FROM Innovation_Initiative I WHERE I.FacultyID = F.FacultyID AND I.SemesterID =
@SemesterID AND I.Status = 'Returned') AS Returned,
           (SELECT COUNT(*) FROM Innovation_Initiative I WHERE I.FacultyID = F.FacultyID AND I.SemesterID =
@SemesterID AND I.Status = 'Escalated') AS Escalated,
           (SELECT COUNT(*) FROM Innovation_Initiative I WHERE I.FacultyID = F.FacultyID AND I.SemesterID =
@SemesterID AND I.Status = 'Approved') AS Approved,
           (SELECT COUNT(*) FROM Innovation_Initiative I WHERE I.FacultyID = F.FacultyID AND I.SemesterID =
@SemesterID AND I.Status = 'Rejected') AS Rejected,
           (SELECT COUNT(*) FROM Innovation_Initiative I WHERE I.FacultyID = F.FacultyID AND I.SemesterID =
@SemesterID AND I.Status = 'In Progress') AS InProgress,
           (SELECT COUNT(*) FROM Innovation_Initiative I WHERE I.FacultyID = F.FacultyID AND I.SemesterID =
@SemesterID AND I.Status = 'Completed') AS Completed,
           (SELECT COUNT(*) FROM Innovation_Initiative I WHERE I.FacultyID = F.FacultyID AND I.SemesterID =
@SemesterID) AS TotalInitiatives,
           (SELECT AVG(CASE WHEN I.Status = 'Rejected' THEN 0.0 ELSE 100.0 END)
            FROM Innovation_Initiative I
            WHERE I.FacultyID = F.FacultyID AND I.SemesterID = @SemesterID
              AND I.Status IN ('Approved', 'In Progress', 'Completed', 'Rejected')) AS ApprovalRate,
           (SELECT AVG(SF.Rating * 1.0)
            FROM Student_Feedback SF
            JOIN Innovation_Initiative I ON I.InitiativeID = SF.InitiativeID
            WHERE I.FacultyID = F.FacultyID AND SF.SemesterID = @SemesterID) AS AvgFeedbackRating
    FROM Faculty F
    WHERE EXISTS (SELECT * FROM Semester WHERE SemesterID = @SemesterID)
)
GO

CREATE FUNCTION GetInitiativeStatsByType ()
RETURNS TABLE
AS
RETURN (
    SELECT 'AI Tool Integration' AS InitiativeType, I.Status, COUNT(*) AS InitiativeCount
    FROM AI_Tool_Integration X JOIN Innovation_Initiative I ON I.InitiativeID = X.InitiativeID
    GROUP BY I.Status
    UNION ALL
    SELECT 'Methodology Change', I.Status, COUNT(*)
    FROM Methodology_Change X JOIN Innovation_Initiative I ON I.InitiativeID = X.InitiativeID
    GROUP BY I.Status
    UNION ALL
    SELECT 'Assessment Redesign', I.Status, COUNT(*)
    FROM Assessment_Redesign X JOIN Innovation_Initiative I ON I.InitiativeID = X.InitiativeID
    GROUP BY I.Status
)
GO

CREATE FUNCTION GetApprovalTurnaround (@FacultyID INT)
RETURNS INT
AS
BEGIN
    DECLARE @AvgDays INT
    SELECT @AvgDays = AVG(T.Days)
    FROM (
        SELECT DATEDIFF(DAY, P.SubmissionDate, MIN(A.DecisionDate)) AS Days

        FROM Modification_Proposal P
        JOIN Program G ON G.ProgramID = P.ProgramID
        JOIN Approval_Record A ON A.ProposalID = P.ProposalID
        WHERE G.FacultyID = @FacultyID AND A.Decision IN ('Approved', 'Rejected') AND A.DecisionLevel IN ('Dean',
'University')
        GROUP BY P.ProposalID, P.SubmissionDate
        UNION ALL
        SELECT DATEDIFF(DAY, I.RegistrationDate, MIN(A.DecisionDate))
        FROM Innovation_Initiative I
        JOIN Approval_Record A ON A.InitiativeID = I.InitiativeID
        WHERE I.FacultyID = @FacultyID AND A.Decision IN ('Approved', 'Rejected') AND A.DecisionLevel IN ('Dean',
'University')
        GROUP BY I.InitiativeID, I.RegistrationDate
    ) T
    RETURN @AvgDays
END
GO

CREATE FUNCTION RankInitiativesByImpact (@MetricType VARCHAR(50))
RETURNS TABLE
AS
RETURN (
    SELECT I.InitiativeID, I.Title, S.Name + ' ' + S.AcademicYear AS Semester, R.BaselineValue,
R.QuantitativeValue,
           CASE WHEN R.BaselineValue = 0 THEN NULL
                ELSE (R.QuantitativeValue - R.BaselineValue) * 100.0 / R.BaselineValue END AS ImprovementPct
    FROM Outcome_Report R
    JOIN Innovation_Initiative I ON I.InitiativeID = R.InitiativeID
    JOIN Semester S ON S.SemesterID = R.SemesterID
    WHERE R.MetricType = @MetricType
)
GO

CREATE FUNCTION ViewMyInitiatives (@MemberID INT)
RETURNS TABLE
AS
RETURN (
    SELECT I.InitiativeID, I.Title, 'Submitter' AS MyRole, I.Status, I.ImplementationDeadline
    FROM Innovation_Initiative I
    WHERE I.SubmitterID = @MemberID
    UNION ALL
    SELECT I.InitiativeID, I.Title, IM.Role, I.Status, I.ImplementationDeadline
    FROM Innovation_Initiative I
    JOIN Initiative_Member IM ON IM.InitiativeID = I.InitiativeID
    WHERE IM.MemberID = @MemberID
)
GO

CREATE PROCEDURE NotifyOverdueMilestone
@MemberID INT, @InitiativeID INT, @SeqNo INT
AS
BEGIN
    DECLARE @Message VARCHAR(1000)
    DECLARE @NotificationID INT
    IF NOT EXISTS (SELECT * FROM Initiative_Member WHERE MemberID = @MemberID AND InitiativeID = @InitiativeID)
        PRINT 'Error: this member is not assigned to this initiative.'
    ELSE IF NOT EXISTS (SELECT * FROM Milestone WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo)
        PRINT 'Error: this milestone does not exist.'

    ELSE IF NOT EXISTS (SELECT * FROM Milestone WHERE InitiativeID = @InitiativeID AND SeqNo = @SeqNo
                        AND DueDate < CAST(GETDATE() AS DATE) AND Status <> 'Completed')
        PRINT 'Error: this milestone is not overdue.'
    ELSE
    BEGIN
        SELECT @Message = 'Milestone "' + MS.Title + '" of initiative "' + I.Title + '" is overdue (due ' +
CAST(MS.DueDate AS VARCHAR(10)) + ')'
        FROM Milestone MS
        JOIN Innovation_Initiative I ON I.InitiativeID = MS.InitiativeID
        WHERE MS.InitiativeID = @InitiativeID AND MS.SeqNo = @SeqNo
        INSERT INTO Notification (MessageContent, CreatedAt, Urgency, Category)
        VALUES (@Message, GETDATE(), 'High', 'Milestone')
        SELECT @NotificationID = MAX(NotificationID) FROM Notification
        INSERT INTO Notification_Recipient (NotificationID, MemberID, ReadStatus)
        VALUES (@NotificationID, @MemberID, 0)
        PRINT 'Notification ' + CAST(@NotificationID AS VARCHAR(10)) + ' sent to member ' + CAST(@MemberID AS
VARCHAR(10)) + ': ' + @Message
    END
END
GO
