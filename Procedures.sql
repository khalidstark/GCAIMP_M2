USE GCAIMP;
GO

CREATE FUNCTION ViewMemberInfo (@MemberID INT)
RETURNS TABLE
AS
RETURN (
    SELECT m.MemberID, m.FullName, m.UniversityIDNo, m.Email, m.Phone, m.AcademicRank,
           m.EmploymentStatus, m.AccountStatus, m.FacultyID, f.Name AS FacultyName,
           r.InfoType, r.InfoValue
    FROM Academic_Member m
    LEFT JOIN Faculty f ON f.FacultyID = m.FacultyID
    LEFT JOIN (
        SELECT MemberID, 'Role' AS InfoType, 'Academic Instructor' AS InfoValue FROM Academic_Instructor
        UNION ALL
        SELECT MemberID, 'Role', 'Teaching Assistant' FROM Teaching_Assistant
        UNION ALL
        SELECT MemberID, 'Role', 'Dean' FROM Dean
        UNION ALL
        SELECT MemberID, 'Role', 'University Management' FROM University_Management
        UNION ALL
        SELECT MemberID, 'Role', 'Curriculum Reviewer' FROM Curriculum_Reviewer
        UNION ALL
        SELECT DeanID, 'Dean Of Faculty', Name FROM Faculty WHERE DeanID IS NOT NULL
        UNION ALL
        SELECT MemberID, 'Access Scope', AccessScope FROM Member_Access_Scope
    ) r ON r.MemberID = m.MemberID
    WHERE m.MemberID = @MemberID
);
GO

CREATE PROCEDURE AddAcademicMember
    @FullName         VARCHAR(150),
    @UniversityIDNo   VARCHAR(50),
    @Email            VARCHAR(150),
    @Phone            VARCHAR(50),
    @AcademicRank     VARCHAR(50),
    @EmploymentStatus VARCHAR(50),
    @AccountStatus    VARCHAR(50),
    @FacultyID        INT
AS
BEGIN
    DECLARE @MemberID INT;

    IF @AccountStatus IS NULL
        SET @AccountStatus = 'Active';

    IF @FullName IS NULL OR @FullName = ''
        PRINT 'Error: Full name is required.';
    ELSE IF @UniversityIDNo IS NULL OR @Email IS NULL
        PRINT 'Error: University ID and email are required.';
    ELSE IF EXISTS (SELECT * FROM Academic_Member WHERE UniversityIDNo = @UniversityIDNo)
        PRINT 'Error: University ID ' + @UniversityIDNo + ' is already used by another member.';
    ELSE IF EXISTS (SELECT * FROM Academic_Member WHERE Email = @Email)
        PRINT 'Error: Email ' + @Email + ' is already used by another member.';
    ELSE IF @AccountStatus NOT IN ('Active', 'Suspended', 'Deactivated')
        PRINT 'Error: Account status must be Active, Suspended or Deactivated.';
    ELSE IF @FacultyID IS NOT NULL AND NOT EXISTS (SELECT * FROM Faculty WHERE FacultyID = @FacultyID)
        PRINT 'Error: Faculty ' + CAST(@FacultyID AS VARCHAR(10)) + ' does not exist.';
    ELSE
    BEGIN
        INSERT INTO Academic_Member (FullName, UniversityIDNo, Email, Phone, AcademicRank,
                                     EmploymentStatus, AccountStatus, FacultyID)
        VALUES (@FullName, @UniversityIDNo, @Email, @Phone, @AcademicRank,
                @EmploymentStatus, @AccountStatus, @FacultyID);

        SELECT @MemberID = MAX(MemberID) FROM Academic_Member;
        PRINT 'Member ' + @FullName + ' added, new MemberID ' + CAST(@MemberID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE UpdateMemberContactInfo
    @MemberID INT,
    @Email    VARCHAR(150),
    @Phone    VARCHAR(50)
AS
BEGIN
    IF @MemberID IS NULL
        PRINT 'Error: Member ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @Email IS NULL AND @Phone IS NULL
        PRINT 'Error: Give a new email, a new phone or both.';
    ELSE IF EXISTS (SELECT * FROM Academic_Member WHERE Email = @Email AND MemberID <> @MemberID)
        PRINT 'Error: Email ' + @Email + ' already belongs to another member.';
    ELSE
    BEGIN
        UPDATE Academic_Member
        SET Email = ISNULL(@Email, Email),
            Phone = ISNULL(@Phone, Phone)
        WHERE MemberID = @MemberID;

        PRINT 'Contact details of member ' + CAST(@MemberID AS VARCHAR(10)) + ' updated.';
    END
END
GO

CREATE PROCEDURE UpdateAccountStatus
    @MemberID      INT,
    @AccountStatus VARCHAR(50)
AS
BEGIN
    IF @MemberID IS NULL
        PRINT 'Error: Member ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @AccountStatus IS NULL OR @AccountStatus NOT IN ('Active', 'Suspended', 'Deactivated')
        PRINT 'Error: Account status must be Active, Suspended or Deactivated.';
    ELSE IF EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID AND AccountStatus = @AccountStatus)
        PRINT 'Error: The account of member ' + CAST(@MemberID AS VARCHAR(10)) + ' is already ' + @AccountStatus + '.';
    ELSE
    BEGIN
        UPDATE Academic_Member
        SET AccountStatus = @AccountStatus
        WHERE MemberID = @MemberID;

        PRINT 'Account of member ' + CAST(@MemberID AS VARCHAR(10)) + ' is now ' + @AccountStatus + '.';
    END
END
GO

CREATE PROCEDURE AssignInstructorRole
    @MemberID       INT,
    @ResearchArea   VARCHAR(150),
    @OfficeLocation VARCHAR(50),
    @TeachingLoad   INT
AS
BEGIN
    IF @MemberID IS NULL
        PRINT 'Error: Member ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF EXISTS (SELECT * FROM Academic_Instructor WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is already an academic instructor.';
    ELSE IF @TeachingLoad < 0
        PRINT 'Error: Teaching load cannot be negative.';
    ELSE
    BEGIN
        INSERT INTO Academic_Instructor (MemberID, ResearchArea, OfficeLocation, TeachingLoad)
        VALUES (@MemberID, @ResearchArea, @OfficeLocation, @TeachingLoad);

        PRINT 'Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is now an academic instructor.';
    END
END
GO

CREATE PROCEDURE AssignTeachingAssistantRole
    @MemberID       INT,
    @AssistantLevel VARCHAR(50),
    @SupervisorID   INT
AS
BEGIN
    IF @MemberID IS NULL OR @SupervisorID IS NULL
        PRINT 'Error: Member ID and supervisor ID are required.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF EXISTS (SELECT * FROM Teaching_Assistant WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is already a teaching assistant.';
    ELSE IF @SupervisorID = @MemberID
        PRINT 'Error: A teaching assistant cannot supervise themself.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Instructor WHERE MemberID = @SupervisorID)
        PRINT 'Error: Supervisor ' + CAST(@SupervisorID AS VARCHAR(10)) + ' is not an academic instructor.';
    ELSE
    BEGIN
        INSERT INTO Teaching_Assistant (MemberID, AssistantLevel, SupervisorID)
        VALUES (@MemberID, @AssistantLevel, @SupervisorID);

        PRINT 'Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is now a teaching assistant supervised by member '
              + CAST(@SupervisorID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE AssignDean
    @MemberID               INT,
    @FacultyID              INT,
    @ApprovalAuthorityScope VARCHAR(150)
AS
BEGIN
    DECLARE @OldDeanID INT;

    SELECT @OldDeanID = DeanID FROM Faculty WHERE FacultyID = @FacultyID;

    IF @MemberID IS NULL OR @FacultyID IS NULL
        PRINT 'Error: Member ID and faculty ID are required.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF NOT EXISTS (SELECT * FROM Faculty WHERE FacultyID = @FacultyID)
        PRINT 'Error: Faculty ' + CAST(@FacultyID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF EXISTS (SELECT * FROM Faculty WHERE FacultyID = @FacultyID AND DeanID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is already the dean of this faculty.';
    ELSE IF EXISTS (SELECT * FROM Faculty WHERE DeanID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is already the dean of another faculty.';
    ELSE
    BEGIN
        IF EXISTS (SELECT * FROM Dean WHERE MemberID = @MemberID)
            UPDATE Dean
            SET ApprovalAuthorityScope = ISNULL(@ApprovalAuthorityScope, ApprovalAuthorityScope)
            WHERE MemberID = @MemberID;
        ELSE
            INSERT INTO Dean (MemberID, ApprovalAuthorityScope)
            VALUES (@MemberID, @ApprovalAuthorityScope);

        UPDATE Faculty
        SET DeanID = @MemberID
        WHERE FacultyID = @FacultyID;

        IF @OldDeanID IS NULL
            PRINT 'Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is now the dean of faculty '
                  + CAST(@FacultyID AS VARCHAR(10)) + '.';
        ELSE
            PRINT 'Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is now the dean of faculty '
                  + CAST(@FacultyID AS VARCHAR(10)) + ' (replacing dean ' + CAST(@OldDeanID AS VARCHAR(10)) + ').';
    END
END
GO

CREATE PROCEDURE AssignManagementRole
    @MemberID               INT,
    @ManagementTitle        VARCHAR(150),
    @DecisionAuthorityLevel VARCHAR(50),
    @GovernanceScope        VARCHAR(150)
AS
BEGIN
    IF @MemberID IS NULL
        PRINT 'Error: Member ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF EXISTS (SELECT * FROM University_Management WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is already in university management.';
    ELSE
    BEGIN
        INSERT INTO University_Management (MemberID, ManagementTitle, DecisionAuthorityLevel, GovernanceScope)
        VALUES (@MemberID, @ManagementTitle, @DecisionAuthorityLevel, @GovernanceScope);

        PRINT 'Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is now part of university management.';
    END
END
GO

CREATE PROCEDURE AssignReviewerRole
    @MemberID             INT,
    @ReviewDomain         VARCHAR(150),
    @ReviewAuthorityLevel VARCHAR(50),
    @CommitteeMembership  VARCHAR(150)
AS
BEGIN
    IF @MemberID IS NULL
        PRINT 'Error: Member ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF EXISTS (SELECT * FROM Curriculum_Reviewer WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is already a curriculum reviewer.';
    ELSE
    BEGIN
        INSERT INTO Curriculum_Reviewer (MemberID, ReviewDomain, ReviewAuthorityLevel)
        VALUES (@MemberID, @ReviewDomain, @ReviewAuthorityLevel);

        IF @CommitteeMembership IS NULL OR @CommitteeMembership = ''
            PRINT 'Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is now a curriculum reviewer (no committee recorded).';
        ELSE
        BEGIN
            INSERT INTO Reviewer_Committee (MemberID, CommitteeMembership)
            VALUES (@MemberID, @CommitteeMembership);

            PRINT 'Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is now a curriculum reviewer (committee membership: '
                  + @CommitteeMembership + ').';
        END
    END
END
GO

CREATE PROCEDURE GrantAccessScope
    @MemberID    INT,
    @AccessScope VARCHAR(50)
AS
BEGIN
    IF @MemberID IS NULL
        PRINT 'Error: Member ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @AccessScope IS NULL OR @AccessScope = ''
        PRINT 'Error: Access scope is required.';
    ELSE IF EXISTS (SELECT * FROM Member_Access_Scope WHERE MemberID = @MemberID AND AccessScope = @AccessScope)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' already has the scope ''' + @AccessScope + '''.';
    ELSE
    BEGIN
        INSERT INTO Member_Access_Scope (MemberID, AccessScope)
        VALUES (@MemberID, @AccessScope);

        PRINT 'Scope ''' + @AccessScope + ''' granted to member ' + CAST(@MemberID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE RevokeAccessScope
    @MemberID    INT,
    @AccessScope VARCHAR(50)
AS
BEGIN
    IF @MemberID IS NULL
        PRINT 'Error: Member ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @AccessScope IS NULL
        PRINT 'Error: Access scope is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Member_Access_Scope WHERE MemberID = @MemberID AND AccessScope = @AccessScope)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' does not have the scope ''' + @AccessScope + '''.';
    ELSE
    BEGIN
        DELETE FROM Member_Access_Scope
        WHERE MemberID = @MemberID AND AccessScope = @AccessScope;

        PRINT 'Scope ''' + @AccessScope + ''' revoked from member ' + CAST(@MemberID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE AddFaculty
    @Name              VARCHAR(150),
    @Description       VARCHAR(1000),
    @EstablishmentDate DATE,
    @DeanID            INT
AS
BEGIN
    DECLARE @FacultyID INT;

    IF @Name IS NULL OR @Name = ''
        PRINT 'Error: Faculty name is required.';
    ELSE IF EXISTS (SELECT * FROM Faculty WHERE Name = @Name)
        PRINT 'Error: A faculty called ' + @Name + ' already exists.';
    ELSE IF @DeanID IS NOT NULL AND NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @DeanID)
        PRINT 'Error: Member ' + CAST(@DeanID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @DeanID IS NOT NULL AND EXISTS (SELECT * FROM Faculty WHERE DeanID = @DeanID)
        PRINT 'Error: Member ' + CAST(@DeanID AS VARCHAR(10)) + ' is already the dean of another faculty.';
    ELSE
    BEGIN
        IF @DeanID IS NOT NULL AND NOT EXISTS (SELECT * FROM Dean WHERE MemberID = @DeanID)
            INSERT INTO Dean (MemberID, ApprovalAuthorityScope)
            VALUES (@DeanID, 'Faculty proposals and initiatives');

        INSERT INTO Faculty (Name, Description, EstablishmentDate, DeanID)
        VALUES (@Name, @Description, @EstablishmentDate, @DeanID);

        SELECT @FacultyID = MAX(FacultyID) FROM Faculty;

        IF @DeanID IS NULL
            PRINT 'Faculty ' + @Name + ' added, new FacultyID ' + CAST(@FacultyID AS VARCHAR(10)) + '.';
        ELSE
            PRINT 'Faculty ' + @Name + ' added, new FacultyID ' + CAST(@FacultyID AS VARCHAR(10))
                  + ' and dean member ' + CAST(@DeanID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE RecordDeanTerm
    @DeanID     INT,
    @SemesterID INT
AS
BEGIN
    IF @DeanID IS NULL OR @SemesterID IS NULL
        PRINT 'Error: Dean ID and semester ID are required.';
    ELSE IF NOT EXISTS (SELECT * FROM Dean WHERE MemberID = @DeanID)
        PRINT 'Error: Member ' + CAST(@DeanID AS VARCHAR(10)) + ' is not a dean.';
    ELSE IF NOT EXISTS (SELECT * FROM Semester WHERE SemesterID = @SemesterID)
        PRINT 'Error: Semester ' + CAST(@SemesterID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF EXISTS (SELECT * FROM Dean_Term WHERE DeanID = @DeanID AND SemesterID = @SemesterID)
        PRINT 'Error: Semester ' + CAST(@SemesterID AS VARCHAR(10)) + ' is already recorded for dean '
              + CAST(@DeanID AS VARCHAR(10)) + '.';
    ELSE
    BEGIN
        INSERT INTO Dean_Term (DeanID, SemesterID)
        VALUES (@DeanID, @SemesterID);

        PRINT 'Semester ' + CAST(@SemesterID AS VARCHAR(10)) + ' recorded as a term of dean '
              + CAST(@DeanID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE FUNCTION ViewAuditLog (@StartDate DATE, @EndDate DATE)
RETURNS TABLE
AS
RETURN (
    SELECT l.LogID,
           l.ActionType,
           l.ActorID,
           m.FullName AS ActorName,
           CASE WHEN l.ProposalID   IS NOT NULL THEN 'Proposal'
                WHEN l.ApprovalID   IS NOT NULL THEN 'Approval'
                WHEN l.InitiativeID IS NOT NULL THEN 'Initiative'
                WHEN l.AssessmentID IS NOT NULL THEN 'Assessment'
                ELSE 'Evidence' END AS ItemType,
           CASE WHEN l.ProposalID   IS NOT NULL THEN l.ProposalID
                WHEN l.ApprovalID   IS NOT NULL THEN l.ApprovalID
                WHEN l.InitiativeID IS NOT NULL THEN l.InitiativeID
                WHEN l.AssessmentID IS NOT NULL THEN l.AssessmentID
                ELSE l.EvidenceID END AS ItemID,
           l.LoggedAt,
           l.ChangeSummary
    FROM Audit_Log l
    JOIN Academic_Member m ON m.MemberID = l.ActorID
    WHERE l.LoggedAt >= @StartDate AND l.LoggedAt < DATEADD(DAY, 1, @EndDate)
);
GO

CREATE FUNCTION GetFacultyMemberStats ()
RETURNS TABLE
AS
RETURN (
    SELECT f.Name AS FacultyName,
           r.Role,
           COUNT(*) AS NumberOfMembers
    FROM (
        SELECT ai.MemberID, 'Academic Instructor' AS Role, m.FacultyID
        FROM Academic_Instructor ai JOIN Academic_Member m ON m.MemberID = ai.MemberID
        UNION ALL
        SELECT ta.MemberID, 'Teaching Assistant', m.FacultyID
        FROM Teaching_Assistant ta JOIN Academic_Member m ON m.MemberID = ta.MemberID
        UNION ALL
        SELECT DeanID, 'Dean', FacultyID
        FROM Faculty WHERE DeanID IS NOT NULL
        UNION ALL
        SELECT d.MemberID, 'Dean', m.FacultyID
        FROM Dean d JOIN Academic_Member m ON m.MemberID = d.MemberID
        WHERE d.MemberID NOT IN (SELECT DeanID FROM Faculty WHERE DeanID IS NOT NULL)
        UNION ALL
        SELECT um.MemberID, 'University Management', m.FacultyID
        FROM University_Management um JOIN Academic_Member m ON m.MemberID = um.MemberID
        UNION ALL
        SELECT cr.MemberID, 'Curriculum Reviewer', m.FacultyID
        FROM Curriculum_Reviewer cr JOIN Academic_Member m ON m.MemberID = cr.MemberID
        UNION ALL
        SELECT MemberID, 'No Role', FacultyID FROM Academic_Member
        WHERE MemberID NOT IN (SELECT MemberID FROM Academic_Instructor)
          AND MemberID NOT IN (SELECT MemberID FROM Teaching_Assistant)
          AND MemberID NOT IN (SELECT MemberID FROM Dean)
          AND MemberID NOT IN (SELECT MemberID FROM University_Management)
          AND MemberID NOT IN (SELECT MemberID FROM Curriculum_Reviewer)
    ) r
    LEFT JOIN Faculty f ON f.FacultyID = r.FacultyID
    GROUP BY f.Name, r.Role
);
GO

CREATE FUNCTION ViewMySupervisor (@TAID INT)
RETURNS TABLE
AS
RETURN (
    SELECT ai.MemberID AS SupervisorID,
           m.FullName AS SupervisorName,
           m.Email,
           ai.OfficeLocation
    FROM Teaching_Assistant ta
    JOIN Academic_Instructor ai ON ai.MemberID = ta.SupervisorID
    JOIN Academic_Member m ON m.MemberID = ai.MemberID
    WHERE ta.MemberID = @TAID
);
GO

CREATE PROCEDURE BroadcastNotification
    @MessageContent VARCHAR(1000),
    @Urgency        VARCHAR(50),
    @Category       VARCHAR(50),
    @TargetRole     VARCHAR(50)
AS
BEGIN
    DECLARE @Count INT;
    DECLARE @NotificationID INT;

    SELECT @Count = COUNT(*)
    FROM (
        SELECT MemberID FROM Academic_Instructor WHERE @TargetRole = 'Academic Instructor'
        UNION ALL
        SELECT MemberID FROM Teaching_Assistant WHERE @TargetRole = 'Teaching Assistant'
        UNION ALL
        SELECT MemberID FROM Dean WHERE @TargetRole = 'Dean'
        UNION ALL
        SELECT MemberID FROM University_Management WHERE @TargetRole = 'University Management'
        UNION ALL
        SELECT MemberID FROM Curriculum_Reviewer WHERE @TargetRole = 'Curriculum Reviewer'
    ) t;

    IF @MessageContent IS NULL OR @MessageContent = ''
        PRINT 'Error: The message cannot be empty.';
    ELSE IF @Urgency IS NULL OR @Urgency NOT IN ('Low', 'Medium', 'High')
        PRINT 'Error: Urgency must be Low, Medium or High.';
    ELSE IF @TargetRole IS NULL OR @TargetRole NOT IN ('Academic Instructor', 'Teaching Assistant', 'Dean',
                                                       'University Management', 'Curriculum Reviewer')
        PRINT 'Error: Target role must be Academic Instructor, Teaching Assistant, Dean, University Management or Curriculum Reviewer.';
    ELSE IF @Count = 0
        PRINT 'Error: No member holds the role ' + @TargetRole + '.';
    ELSE
    BEGIN
        INSERT INTO Notification (MessageContent, CreatedAt, Urgency, Category)
        VALUES (@MessageContent, GETDATE(), @Urgency, @Category);

        SELECT @NotificationID = MAX(NotificationID) FROM Notification;

        INSERT INTO Notification_Recipient (NotificationID, MemberID, ReadStatus)
        SELECT @NotificationID, t.MemberID, 0
        FROM (
            SELECT MemberID FROM Academic_Instructor WHERE @TargetRole = 'Academic Instructor'
            UNION ALL
            SELECT MemberID FROM Teaching_Assistant WHERE @TargetRole = 'Teaching Assistant'
            UNION ALL
            SELECT MemberID FROM Dean WHERE @TargetRole = 'Dean'
            UNION ALL
            SELECT MemberID FROM University_Management WHERE @TargetRole = 'University Management'
            UNION ALL
            SELECT MemberID FROM Curriculum_Reviewer WHERE @TargetRole = 'Curriculum Reviewer'
        ) t;

        PRINT 'Notification ' + CAST(@NotificationID AS VARCHAR(10)) + ' sent to '
              + CAST(@Count AS VARCHAR(10)) + ' member(s) holding the role ' + @TargetRole + '.';
    END
END
GO

CREATE FUNCTION ViewItemAuditTrail (@ItemType VARCHAR(20), @ItemID INT)
RETURNS TABLE
AS
RETURN (
    SELECT l.LogID,
           l.ActionType,
           l.ActorID,
           m.FullName AS ActorName,
           l.LoggedAt,
           l.ChangeSummary
    FROM Audit_Log l
    JOIN Academic_Member m ON m.MemberID = l.ActorID
    WHERE (@ItemType = 'Proposal'   AND l.ProposalID   = @ItemID)
       OR (@ItemType = 'Initiative' AND l.InitiativeID = @ItemID)
       OR (@ItemType = 'Approval'   AND l.ApprovalID   = @ItemID)
       OR (@ItemType = 'Assessment' AND l.AssessmentID = @ItemID)
       OR (@ItemType = 'Evidence'   AND l.EvidenceID   = @ItemID)
       OR (@ItemType = 'Proposal'   AND l.ApprovalID IN (SELECT ApprovalID FROM Approval_Record WHERE ProposalID = @ItemID))
       OR (@ItemType = 'Initiative' AND l.ApprovalID IN (SELECT ApprovalID FROM Approval_Record WHERE InitiativeID = @ItemID))
);
GO

CREATE FUNCTION ViewMyProfile (@MemberID INT)
RETURNS TABLE
AS
RETURN (
    SELECT * FROM dbo.ViewMemberInfo(@MemberID)
);
GO

CREATE FUNCTION ViewMyNotifications (@MemberID INT, @UnreadOnly BIT)
RETURNS TABLE
AS
RETURN (
    SELECT n.NotificationID,
           n.MessageContent,
           n.CreatedAt,
           n.Urgency,
           n.Category,
           r.ReadStatus
    FROM Notification_Recipient r
    JOIN Notification n ON n.NotificationID = r.NotificationID
    WHERE r.MemberID = @MemberID
      AND (@UnreadOnly IS NULL OR @UnreadOnly = 0 OR r.ReadStatus = 0)
);
GO

CREATE FUNCTION GetUnreadNotificationCount (@MemberID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Count INT;

    IF EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        SELECT @Count = COUNT(*)
        FROM Notification_Recipient
        WHERE MemberID = @MemberID AND ReadStatus = 0;

    RETURN @Count;
END
GO

CREATE PROCEDURE MarkNotificationRead
    @NotificationID INT,
    @MemberID       INT
AS
BEGIN
    IF @NotificationID IS NULL OR @MemberID IS NULL
        PRINT 'Error: Notification ID and member ID are required.';
    ELSE IF NOT EXISTS (SELECT * FROM Notification_Recipient WHERE NotificationID = @NotificationID AND MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' did not receive notification '
              + CAST(@NotificationID AS VARCHAR(10)) + '.';
    ELSE IF EXISTS (SELECT * FROM Notification_Recipient WHERE NotificationID = @NotificationID AND MemberID = @MemberID AND ReadStatus = 1)
        PRINT 'Error: Notification ' + CAST(@NotificationID AS VARCHAR(10)) + ' is already marked as read.';
    ELSE
    BEGIN
        UPDATE Notification_Recipient
        SET ReadStatus = 1
        WHERE NotificationID = @NotificationID AND MemberID = @MemberID;

        PRINT 'Notification ' + CAST(@NotificationID AS VARCHAR(10)) + ' marked as read for member '
              + CAST(@MemberID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE NotifyApprovalDecision
    @MemberID INT,
    @ItemType VARCHAR(20),
    @ItemID   INT,
    @Decision VARCHAR(50)
AS
BEGIN
    DECLARE @Title VARCHAR(150);
    DECLARE @LastDecision VARCHAR(50);
    DECLARE @LastLevel VARCHAR(50);
    DECLARE @Urgency VARCHAR(50);
    DECLARE @Message VARCHAR(1000);
    DECLARE @NotificationID INT;

    IF @ItemType = 'Proposal'
    BEGIN
        SELECT @Title = Title FROM Modification_Proposal
        WHERE ProposalID = @ItemID AND ProposerID = @MemberID;

        SELECT @LastDecision = Decision, @LastLevel = DecisionLevel
        FROM Approval_Record
        WHERE ApprovalID = (SELECT MAX(ApprovalID) FROM Approval_Record
                            WHERE ProposalID = @ItemID
                              AND DecisionDate = (SELECT MAX(DecisionDate) FROM Approval_Record
                                                  WHERE ProposalID = @ItemID));
    END
    ELSE
    BEGIN
        SELECT @Title = Title FROM Innovation_Initiative
        WHERE InitiativeID = @ItemID AND SubmitterID = @MemberID;

        SELECT @LastDecision = Decision, @LastLevel = DecisionLevel
        FROM Approval_Record
        WHERE ApprovalID = (SELECT MAX(ApprovalID) FROM Approval_Record
                            WHERE InitiativeID = @ItemID
                              AND DecisionDate = (SELECT MAX(DecisionDate) FROM Approval_Record
                                                  WHERE InitiativeID = @ItemID));
    END

    IF @ItemType IS NULL OR @ItemType NOT IN ('Proposal', 'Initiative')
        PRINT 'Error: Item type must be Proposal or Initiative.';
    ELSE IF @Decision IS NULL OR @Decision NOT IN ('Approved', 'Rejected', 'Returned', 'Escalated')
        PRINT 'Error: Decision must be Approved, Rejected, Returned or Escalated.';
    ELSE IF @ItemID IS NULL OR @MemberID IS NULL
        PRINT 'Error: Member ID and item ID are required.';
    ELSE IF @ItemType = 'Proposal' AND NOT EXISTS (SELECT * FROM Modification_Proposal WHERE ProposalID = @ItemID)
        PRINT 'Error: Proposal ' + CAST(@ItemID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @ItemType = 'Initiative' AND NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @ItemID)
        PRINT 'Error: Initiative ' + CAST(@ItemID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @Title IS NULL
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' did not submit '
              + @ItemType + ' ' + CAST(@ItemID AS VARCHAR(10)) + '.';
    ELSE IF @LastDecision IS NULL
        PRINT 'Error: No decision has been made on ' + @ItemType + ' ' + CAST(@ItemID AS VARCHAR(10)) + ' yet.';
    ELSE IF @LastDecision <> @Decision
        PRINT 'Error: The latest decision on ' + @ItemType + ' ' + CAST(@ItemID AS VARCHAR(10))
              + ' is ' + @LastDecision + ', not ' + @Decision + '.';
    ELSE
    BEGIN
        IF @Decision = 'Approved'
            SET @Urgency = 'Medium';
        ELSE
            SET @Urgency = 'High';

        SET @Message = 'Your ' + @ItemType + ' "' + @Title + '" was ' + @Decision
                       + ' at ' + @LastLevel + ' level';

        INSERT INTO Notification (MessageContent, CreatedAt, Urgency, Category)
        VALUES (@Message, GETDATE(), @Urgency, 'Approval');

        SELECT @NotificationID = MAX(NotificationID) FROM Notification;

        INSERT INTO Notification_Recipient (NotificationID, MemberID, ReadStatus)
        VALUES (@NotificationID, @MemberID, 0);

        PRINT 'Notification ' + CAST(@NotificationID AS VARCHAR(10)) + ' sent to member '
              + CAST(@MemberID AS VARCHAR(10)) + ': ' + @Message;
    END
END
GO

CREATE PROCEDURE AddProgram
    @Name varchar(150),
    @DegreeLevel varchar(50),
    @TotalCreditHours int,
    @StandardDuration varchar(50),
    @Description varchar(1000),
    @FacultyID int
AS
BEGIN
    INSERT INTO Program (Name, DegreeLevel, TotalCreditHours, StandardDuration, Description, FacultyID)
    VALUES (@Name, @DegreeLevel, @TotalCreditHours, @StandardDuration, @Description, @FacultyID);

    SELECT SCOPE_IDENTITY() AS ProgramID;
END;
GO

CREATE PROCEDURE AddCourse
    @CourseCode varchar(20),
    @Title varchar(150),
    @Description varchar(1000),
    @CreditHours int,
    @Level varchar(50),
    @CourseType varchar(20),
    @DefaultStudySemester int,
    @RequiredForProgram varchar(150),
    @ElectivePool varchar(150),
    @MinSelectionRule varchar(150)
AS
BEGIN
    IF @CourseType NOT IN ('Core', 'Elective')
    BEGIN
        PRINT 'Course type must be Core or Elective.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Course WHERE CourseCode = @CourseCode)
    BEGIN
        PRINT 'This course already exists.';
        RETURN;
    END

    INSERT INTO Course (CourseCode, Title, Description, CreditHours, Level)
    VALUES (@CourseCode, @Title, @Description, @CreditHours, @Level);

    IF @CourseType = 'Core'
        INSERT INTO Core_Course (CourseCode, DefaultStudySemester, RequiredForProgram)
        VALUES (@CourseCode, @DefaultStudySemester, @RequiredForProgram);
    ELSE
        INSERT INTO Elective_Course (CourseCode, ElectivePool, MinSelectionRule)
        VALUES (@CourseCode, @ElectivePool, @MinSelectionRule);

    PRINT 'Course added.';
END;
GO

CREATE PROCEDURE AddCourseRequisite
    @CourseCode varchar(20),
    @RequisiteCode varchar(20),
    @RequisiteType varchar(50)
AS
BEGIN
    IF @RequisiteType NOT IN ('Prerequisite', 'Co-requisite')
    BEGIN
        PRINT 'Requisite type must be Prerequisite or Co-requisite.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseCode = @CourseCode)
       OR NOT EXISTS (SELECT 1 FROM Course WHERE CourseCode = @RequisiteCode)
    BEGIN
        PRINT 'Both courses must exist.';
        RETURN;
    END

    IF @CourseCode = @RequisiteCode
    BEGIN
        PRINT 'A course cannot be a requisite of itself.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Course_Requisite
               WHERE CourseCode = @CourseCode AND RequisiteCode = @RequisiteCode)
    BEGIN
        PRINT 'This requisite already exists.';
        RETURN;
    END

    INSERT INTO Course_Requisite (CourseCode, RequisiteCode, RequisiteType)
    VALUES (@CourseCode, @RequisiteCode, @RequisiteType);

    PRINT 'Requisite added.';
END;
GO

CREATE PROCEDURE AddILO
    @CourseCode varchar(20),
    @ILOCode varchar(20),
    @Statement varchar(1000),
    @CognitiveLevel varchar(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseCode = @CourseCode)
    BEGIN
        PRINT 'This course does not exist.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM ILO WHERE CourseCode = @CourseCode AND ILOCode = @ILOCode)
    BEGIN
        PRINT 'This ILO already exists for this course.';
        RETURN;
    END

    INSERT INTO ILO (CourseCode, ILOCode, Statement, CognitiveLevel)
    VALUES (@CourseCode, @ILOCode, @Statement, @CognitiveLevel);

    PRINT 'ILO added.';
END;
GO

CREATE PROCEDURE UpdateILO
    @CourseCode varchar(20),
    @ILOCode varchar(20),
    @Statement varchar(1000),
    @CognitiveLevel varchar(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ILO WHERE CourseCode = @CourseCode AND ILOCode = @ILOCode)
    BEGIN
        PRINT 'This ILO does not exist.';
        RETURN;
    END

    UPDATE ILO
    SET Statement      = ISNULL(@Statement, Statement),
        CognitiveLevel = ISNULL(@CognitiveLevel, CognitiveLevel)
    WHERE CourseCode = @CourseCode AND ILOCode = @ILOCode;

    PRINT 'ILO updated.';
END;
GO

CREATE PROCEDURE MapILOToPLO
    @CourseCode varchar(20),
    @ILOCode varchar(20),
    @ProgramID int,
    @PLOCode varchar(20),
    @CoverageLevel varchar(50),
    @IsAssessmentPoint bit
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ILO WHERE CourseCode = @CourseCode AND ILOCode = @ILOCode)
    BEGIN
        PRINT 'This ILO does not exist.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM PLO WHERE ProgramID = @ProgramID AND PLOCode = @PLOCode)
    BEGIN
        PRINT 'This PLO does not exist.';
        RETURN;
    END

    IF @CoverageLevel NOT IN ('Introduced', 'Reinforced', 'Mastered')
    BEGIN
        PRINT 'Coverage level must be Introduced, Reinforced or Mastered.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Outcome_Mapping
               WHERE CourseCode = @CourseCode AND ILOCode = @ILOCode
                 AND ProgramID = @ProgramID AND PLOCode = @PLOCode)
    BEGIN
        PRINT 'This mapping already exists.';
        RETURN;
    END

    INSERT INTO Outcome_Mapping (CoverageLevel, IsAssessmentPoint, CourseCode, ILOCode, ProgramID, PLOCode)
    VALUES (@CoverageLevel, @IsAssessmentPoint, @CourseCode, @ILOCode, @ProgramID, @PLOCode);

    SELECT SCOPE_IDENTITY() AS MappingID;
END;
GO

CREATE PROCEDURE SubmitModificationProposal
    @ProposerID int,
    @Title varchar(150),
    @Rationale varchar(1000),
    @ModificationType varchar(50),
    @CurrentStateSummary varchar(1000),
    @ProposedStateSummary varchar(1000),
    @CourseCode varchar(20),
    @ProgramID int,
    @VersionLabel varchar(20),
    @AcademicYear varchar(50),
    @AssessmentID int
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Academic_Instructor WHERE MemberID = @ProposerID)
    BEGIN
        PRINT 'Only an academic instructor can submit a proposal.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseCode = @CourseCode)
    BEGIN
        PRINT 'This course does not exist.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Curriculum_Version
                   WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel
                     AND AcademicYear = @AcademicYear)
    BEGIN
        PRINT 'This curriculum version does not exist.';
        RETURN;
    END

    IF @AssessmentID IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Outcome_Assessment WHERE AssessmentID = @AssessmentID)
    BEGIN
        PRINT 'This assessment does not exist.';
        RETURN;
    END

    INSERT INTO Modification_Proposal (Title, Rationale, ModificationType, CurrentStateSummary,
        ProposedStateSummary, ProposerID, CourseCode, ProgramID, VersionLabel, AcademicYear, AssessmentID)
    VALUES (@Title, @Rationale, @ModificationType, @CurrentStateSummary,
        @ProposedStateSummary, @ProposerID, @CourseCode, @ProgramID, @VersionLabel, @AcademicYear, @AssessmentID);

    SELECT SCOPE_IDENTITY() AS ProposalID;
END;
GO

CREATE PROCEDURE ReviseModificationProposal
    @ProposalID int,
    @Rationale varchar(1000),
    @ProposedStateSummary varchar(1000)
AS
BEGIN
    DECLARE @LastDecision varchar(50);

    SELECT TOP 1 @LastDecision = Decision
    FROM Approval_Record
    WHERE ProposalID = @ProposalID
    ORDER BY DecisionDate DESC, ApprovalID DESC;

    IF @LastDecision IS NULL OR @LastDecision <> 'Returned'
    BEGIN
        PRINT 'Only a proposal that was returned for revision can be revised.';
        RETURN;
    END

    UPDATE Modification_Proposal
    SET Rationale            = ISNULL(@Rationale, Rationale),
        ProposedStateSummary = ISNULL(@ProposedStateSummary, ProposedStateSummary),
        SubmissionDate       = GETDATE()
    WHERE ProposalID = @ProposalID;

    PRINT 'Proposal revised and resubmitted.';
END;
GO

CREATE FUNCTION ViewProposalStatus (@ProposalID int)
RETURNS TABLE
AS
RETURN
    SELECT ar.Decision,
           ar.DecisionLevel,
           am.FullName AS Approver,
           ar.DecisionDate,
           ar.Comments
    FROM Approval_Record ar
    JOIN Academic_Member am ON am.MemberID = ar.DeciderID
    WHERE ar.ProposalID = @ProposalID;
GO

CREATE FUNCTION ViewCurriculumVersion (@ProgramID int, @VersionLabel varchar(20), @AcademicYear varchar(50))
RETURNS TABLE
AS
RETURN
    SELECT vc.StudySemesterNo,
           c.CourseCode,
           c.Title,
           c.CreditHours,
           vc.IsMandatory
    FROM Version_Course vc
    JOIN Course c ON c.CourseCode = vc.CourseCode
    WHERE vc.ProgramID = @ProgramID
      AND vc.VersionLabel = @VersionLabel
      AND vc.AcademicYear = @AcademicYear;
GO

CREATE FUNCTION ViewCourseILOs (@CourseCode varchar(20))
RETURNS TABLE
AS
RETURN
    SELECT ILOCode, Statement, CognitiveLevel
    FROM ILO
    WHERE CourseCode = @CourseCode;
GO

CREATE FUNCTION CompareCurriculumVersions (@ProgramID int,
    @OldVersionLabel varchar(20), @OldAcademicYear varchar(50),
    @NewVersionLabel varchar(20), @NewAcademicYear varchar(50))
RETURNS TABLE
AS
RETURN
    SELECT COALESCE(n.CourseCode, o.CourseCode) AS CourseCode,
           CASE WHEN o.CourseCode IS NULL THEN 'Added'
                WHEN n.CourseCode IS NULL THEN 'Removed'
                ELSE 'Moved'
           END AS ChangeType,
           o.StudySemesterNo AS OldStudySemester,
           n.StudySemesterNo AS NewStudySemester
    FROM (SELECT CourseCode, StudySemesterNo FROM Version_Course
          WHERE ProgramID = @ProgramID AND VersionLabel = @OldVersionLabel
            AND AcademicYear = @OldAcademicYear) o
    FULL OUTER JOIN
         (SELECT CourseCode, StudySemesterNo FROM Version_Course
          WHERE ProgramID = @ProgramID AND VersionLabel = @NewVersionLabel
            AND AcademicYear = @NewAcademicYear) n
      ON o.CourseCode = n.CourseCode
    WHERE o.CourseCode IS NULL
       OR n.CourseCode IS NULL
       OR o.StudySemesterNo <> n.StudySemesterNo;
GO

CREATE FUNCTION ViewProgramCurriculumMap (@ProgramID int)
RETURNS TABLE
AS
RETURN
    SELECT om.PLOCode,
           p.Statement AS PLOStatement,
           om.CourseCode,
           om.ILOCode,
           i.Statement AS ILOStatement,
           om.CoverageLevel,
           om.IsAssessmentPoint,
           om.MappingStatus
    FROM Outcome_Mapping om
    JOIN PLO p ON p.ProgramID = om.ProgramID AND p.PLOCode = om.PLOCode
    JOIN ILO i ON i.CourseCode = om.CourseCode AND i.ILOCode = om.ILOCode
    WHERE om.ProgramID = @ProgramID;
GO

CREATE FUNCTION GetUncoveredPLOs (@ProgramID int)
RETURNS TABLE
AS
RETURN
    SELECT p.PLOCode, p.Statement
    FROM PLO p
    WHERE p.ProgramID = @ProgramID
      AND NOT EXISTS (SELECT 1 FROM Outcome_Mapping om
                      WHERE om.ProgramID = p.ProgramID
                        AND om.PLOCode = p.PLOCode
                        AND om.MappingStatus = 'Approved');
GO

CREATE FUNCTION GetPLOCoverageSummary (@ProgramID int)
RETURNS TABLE
AS
RETURN
    SELECT p.PLOCode,
           p.Statement,
           COUNT(DISTINCT CASE WHEN om.CoverageLevel = 'Introduced' THEN om.CourseCode END) AS IntroducedCourses,
           COUNT(DISTINCT CASE WHEN om.CoverageLevel = 'Reinforced' THEN om.CourseCode END) AS ReinforcedCourses,
           COUNT(DISTINCT CASE WHEN om.CoverageLevel = 'Mastered'   THEN om.CourseCode END) AS MasteredCourses,
           SUM(CASE WHEN om.IsAssessmentPoint = 1 THEN 1 ELSE 0 END) AS AssessmentPoints
    FROM PLO p
    LEFT JOIN Outcome_Mapping om
           ON om.ProgramID = p.ProgramID
          AND om.PLOCode = p.PLOCode
          AND om.MappingStatus = 'Approved'
    WHERE p.ProgramID = @ProgramID
    GROUP BY p.PLOCode, p.Statement;
GO

CREATE PROCEDURE ReviewOutcomeMapping
    @MappingID int,
    @MappingStatus varchar(50)
AS
BEGIN
    IF @MappingStatus NOT IN ('Approved', 'Rejected')
    BEGIN
        PRINT 'Status must be Approved or Rejected.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Outcome_Mapping WHERE MappingID = @MappingID)
    BEGIN
        PRINT 'This mapping does not exist.';
        RETURN;
    END

    UPDATE Outcome_Mapping
    SET MappingStatus = @MappingStatus
    WHERE MappingID = @MappingID;

    PRINT 'Mapping reviewed.';
END;
GO

CREATE FUNCTION ViewPendingProposals (@ProgramID int)
RETURNS TABLE
AS
RETURN
    SELECT mp.ProposalID,
           mp.Title,
           mp.ModificationType,
           mp.CourseCode,
           am.FullName AS Proposer,
           mp.SubmissionDate
    FROM Modification_Proposal mp
    JOIN Academic_Member am ON am.MemberID = mp.ProposerID
    WHERE mp.ProgramID = @ProgramID
      AND NOT EXISTS (SELECT 1 FROM Approval_Record ar
                      WHERE ar.ProposalID = mp.ProposalID
                        AND ar.Decision IN ('Approved', 'Rejected')
                        AND ar.DecisionLevel IN ('Dean', 'University'));
GO

CREATE PROCEDURE ReviewModificationProposal
    @ProposalID int,
    @ReviewerID int,
    @Decision varchar(50),
    @Comments varchar(1000)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Curriculum_Reviewer WHERE MemberID = @ReviewerID)
    BEGIN
        PRINT 'Only a curriculum reviewer can review a proposal.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Modification_Proposal WHERE ProposalID = @ProposalID)
    BEGIN
        PRINT 'This proposal does not exist.';
        RETURN;
    END

    IF @Decision NOT IN ('Approved', 'Rejected', 'Returned')
    BEGIN
        PRINT 'Decision must be Approved, Rejected or Returned.';
        RETURN;
    END

    INSERT INTO Approval_Record (Decision, DecisionLevel, Comments, DeciderID, ProposalID)
    VALUES (@Decision, 'Reviewer', @Comments, @ReviewerID, @ProposalID);

    PRINT 'Review recorded.';
END;
GO

CREATE FUNCTION ViewCourseProposalHistory (@CourseCode varchar(20))
RETURNS TABLE
AS
RETURN
    SELECT mp.ProposalID,
           mp.Title,
           mp.ModificationType,
           mp.SubmissionDate,
           latest.Decision AS LatestDecision,
           latest.DecisionLevel AS LatestDecisionLevel
    FROM Modification_Proposal mp
    OUTER APPLY (SELECT TOP 1 ar.Decision, ar.DecisionLevel
                 FROM Approval_Record ar
                 WHERE ar.ProposalID = mp.ProposalID
                 ORDER BY ar.DecisionDate DESC, ar.ApprovalID DESC) latest
    WHERE mp.CourseCode = @CourseCode;
GO

CREATE PROCEDURE DecideOnProposal
    @ProposalID int,
    @DeanID int,
    @Decision varchar(50),
    @Comments varchar(1000)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Dean WHERE MemberID = @DeanID)
    BEGIN
        PRINT 'Only a dean can decide on a proposal.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Modification_Proposal WHERE ProposalID = @ProposalID)
    BEGIN
        PRINT 'This proposal does not exist.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1
                   FROM Modification_Proposal mp
                   JOIN Program p ON p.ProgramID = mp.ProgramID
                   JOIN Faculty f ON f.FacultyID = p.FacultyID
                   WHERE mp.ProposalID = @ProposalID AND f.DeanID = @DeanID)
    BEGIN
        PRINT 'This proposal is not in your faculty.';
        RETURN;
    END

    IF @Decision NOT IN ('Approved', 'Rejected', 'Returned')
    BEGIN
        PRINT 'Decision must be Approved, Rejected or Returned.';
        RETURN;
    END

    INSERT INTO Approval_Record (Decision, DecisionLevel, Comments, DeciderID, ProposalID)
    VALUES (@Decision, 'Dean', @Comments, @DeanID, @ProposalID);

    PRINT 'Decision recorded.';
END;
GO

CREATE PROCEDURE AddPLO
    @ProgramID int,
    @PLOCode varchar(20),
    @Statement varchar(1000),
    @Category varchar(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Program WHERE ProgramID = @ProgramID)
    BEGIN
        PRINT 'This program does not exist.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM PLO WHERE ProgramID = @ProgramID AND PLOCode = @PLOCode)
    BEGIN
        PRINT 'This PLO already exists for this program.';
        RETURN;
    END

    INSERT INTO PLO (ProgramID, PLOCode, Statement, Category)
    VALUES (@ProgramID, @PLOCode, @Statement, @Category);

    PRINT 'PLO added.';
END;
GO

CREATE PROCEDURE CreateCurriculumVersion
    @ProgramID int,
    @VersionLabel varchar(20),
    @AcademicYear varchar(50),
    @EffectivePeriod varchar(50),
    @CopyFromVersionLabel varchar(20),
    @CopyFromAcademicYear varchar(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Program WHERE ProgramID = @ProgramID)
    BEGIN
        PRINT 'This program does not exist.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Curriculum_Version
               WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel
                 AND AcademicYear = @AcademicYear)
    BEGIN
        PRINT 'This curriculum version already exists.';
        RETURN;
    END

    IF @CopyFromVersionLabel IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Curriculum_Version
                       WHERE ProgramID = @ProgramID AND VersionLabel = @CopyFromVersionLabel
                         AND AcademicYear = @CopyFromAcademicYear)
    BEGIN
        PRINT 'The version to copy from does not exist.';
        RETURN;
    END

    INSERT INTO Curriculum_Version (ProgramID, VersionLabel, AcademicYear, EffectivePeriod, Status)
    VALUES (@ProgramID, @VersionLabel, @AcademicYear, @EffectivePeriod, 'Draft');

    IF @CopyFromVersionLabel IS NOT NULL
        INSERT INTO Version_Course (ProgramID, VersionLabel, AcademicYear, CourseCode, StudySemesterNo, IsMandatory)
        SELECT @ProgramID, @VersionLabel, @AcademicYear, CourseCode, StudySemesterNo, IsMandatory
        FROM Version_Course
        WHERE ProgramID = @ProgramID
          AND VersionLabel = @CopyFromVersionLabel
          AND AcademicYear = @CopyFromAcademicYear;

    PRINT 'Curriculum version created.';
END;
GO

CREATE PROCEDURE PlaceCourseInVersion
    @ProgramID int,
    @VersionLabel varchar(20),
    @AcademicYear varchar(50),
    @CourseCode varchar(20),
    @StudySemesterNo int,
    @IsMandatory bit
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Curriculum_Version
                   WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel
                     AND AcademicYear = @AcademicYear AND Status = 'Draft')
    BEGIN
        PRINT 'Courses can only be placed in an existing draft version.';
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM Course WHERE CourseCode = @CourseCode)
    BEGIN
        PRINT 'This course does not exist.';
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Version_Course
               WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel
                 AND AcademicYear = @AcademicYear AND CourseCode = @CourseCode)
    BEGIN
        UPDATE Version_Course
        SET StudySemesterNo = @StudySemesterNo,
            IsMandatory     = @IsMandatory
        WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel
          AND AcademicYear = @AcademicYear AND CourseCode = @CourseCode;

        PRINT 'Course placement updated.';
        RETURN;
    END

    INSERT INTO Version_Course (ProgramID, VersionLabel, AcademicYear, CourseCode, StudySemesterNo, IsMandatory)
    VALUES (@ProgramID, @VersionLabel, @AcademicYear, @CourseCode, @StudySemesterNo, @IsMandatory);

    PRINT 'Course placed in version.';
END;
GO

CREATE PROCEDURE ApproveCurriculumVersion
    @ProgramID int,
    @VersionLabel varchar(20),
    @AcademicYear varchar(50)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Curriculum_Version
                   WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel
                     AND AcademicYear = @AcademicYear AND Status = 'Draft')
    BEGIN
        PRINT 'Only an existing draft version can be approved.';
        RETURN;
    END

    UPDATE Curriculum_Version
    SET Status = 'Archived'
    WHERE ProgramID = @ProgramID AND Status = 'Active';

    UPDATE Curriculum_Version
    SET Status = 'Active',
        ApprovalDate = GETDATE()
    WHERE ProgramID = @ProgramID AND VersionLabel = @VersionLabel
      AND AcademicYear = @AcademicYear;

    PRINT 'Curriculum version approved.';
END;
GO

CREATE PROCEDURE AddSemester
    @Name VARCHAR(50),
    @AcademicYear VARCHAR(50),
    @StartDate DATE,
    @EndDate DATE
AS
BEGIN
    DECLARE @SemesterID INT;

    IF @Name IS NULL OR @AcademicYear IS NULL OR @StartDate IS NULL OR @EndDate IS NULL
        PRINT 'Error: name, academic year, start date and end date are all required.';
    ELSE IF @EndDate <= @StartDate
        PRINT 'Error: the end date must be after the start date.';
    ELSE IF EXISTS (SELECT * FROM Semester WHERE Name = @Name AND AcademicYear = @AcademicYear)
        PRINT 'Error: semester ' + @Name + ' ' + @AcademicYear + ' already exists.';
    ELSE
    BEGIN
        INSERT INTO Semester (Name, AcademicYear, StartDate, EndDate)
        VALUES (@Name, @AcademicYear, @StartDate, @EndDate);

        SELECT @SemesterID = MAX(SemesterID) FROM Semester;

        PRINT 'Semester ' + @Name + ' ' + @AcademicYear + ' added. New SemesterID = ' + CAST(@SemesterID AS VARCHAR(10));
    END
END;
GO

CREATE PROCEDURE CreateCourseOffering
    @CourseCode VARCHAR(20),
    @SemesterID INT,
    @SectionID VARCHAR(20),
    @DeliveryMode VARCHAR(50),
    @EnrolledCount INT,
    @InstructorID INT
AS
BEGIN
    DECLARE @Today DATE;
    DECLARE @Start DATE;
    DECLARE @End DATE;
    DECLARE @Status VARCHAR(50);

    IF NOT EXISTS (SELECT * FROM Course WHERE CourseCode = @CourseCode)
        PRINT 'Error: this course does not exist.';
    ELSE IF NOT EXISTS (SELECT * FROM Semester WHERE SemesterID = @SemesterID)
        PRINT 'Error: this semester does not exist.';
    ELSE IF NOT EXISTS (
        SELECT *
        FROM Academic_Instructor ai
        JOIN Academic_Member m ON m.MemberID = ai.MemberID
        WHERE ai.MemberID = @InstructorID AND m.AccountStatus = 'Active'
    )
        PRINT 'Error: this member is not an active academic instructor.';
    ELSE IF @SectionID IS NULL OR @EnrolledCount IS NULL OR @EnrolledCount < 0
        PRINT 'Error: a section is required and the enrolled count must be 0 or more.';
    ELSE IF @DeliveryMode IS NULL OR @DeliveryMode NOT IN ('In-Person', 'Hybrid', 'Online')
        PRINT 'Error: delivery mode must be In-Person, Hybrid or Online.';
    ELSE IF EXISTS (
        SELECT *
        FROM Course_Offering
        WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID
    )
        PRINT 'Error: section ' + @SectionID + ' of ' + @CourseCode + ' already exists in this semester.';
    ELSE
    BEGIN
        SET @Today = CAST(GETDATE() AS DATE);
        SELECT @Start = StartDate, @End = EndDate FROM Semester WHERE SemesterID = @SemesterID;

        IF @Today < @Start
            SET @Status = 'Planned';
        ELSE IF @Today > @End
            SET @Status = 'Completed';
        ELSE
            SET @Status = 'Running';

        INSERT INTO Course_Offering (CourseCode, SemesterID, SectionID, DeliveryMode, EnrolledCount, Status, InstructorID)
        VALUES (@CourseCode, @SemesterID, @SectionID, @DeliveryMode, @EnrolledCount, @Status, @InstructorID);

        PRINT 'Offering ' + @CourseCode + ' section ' + @SectionID + ' created in semester '
            + CAST(@SemesterID AS VARCHAR(10)) + ' for instructor ' + CAST(@InstructorID AS VARCHAR(10))
            + ' (status ' + @Status + ').';
    END
END;
GO

CREATE PROCEDURE AssignTAToOffering
    @CourseCode VARCHAR(20),
    @SemesterID INT,
    @SectionID VARCHAR(20),
    @TAID INT
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Teaching_Assistant WHERE MemberID = @TAID)
        PRINT 'Error: this member is not a teaching assistant.';
    ELSE IF NOT EXISTS (
        SELECT *
        FROM Course_Offering
        WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID
    )
        PRINT 'Error: this course offering does not exist.';
    ELSE IF EXISTS (
        SELECT *
        FROM Offering_TA
        WHERE TAID = @TAID AND CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID
    )
        PRINT 'Error: this TA already supports this offering.';
    ELSE
    BEGIN
        INSERT INTO Offering_TA (CourseCode, SemesterID, SectionID, TAID)
        VALUES (@CourseCode, @SemesterID, @SectionID, @TAID);

        PRINT 'TA ' + CAST(@TAID AS VARCHAR(10)) + ' now supports ' + @CourseCode + ' section ' + @SectionID
            + ' in semester ' + CAST(@SemesterID AS VARCHAR(10)) + '.';
    END
END;
GO

CREATE FUNCTION ViewMyCourseOfferings
(
    @InstructorID INT,
    @SemesterID INT
)
RETURNS TABLE
AS
RETURN (
    SELECT co.CourseCode, c.Title AS CourseTitle, co.SectionID, co.DeliveryMode, co.EnrolledCount, co.Status
    FROM Course_Offering co
    JOIN Course c ON c.CourseCode = co.CourseCode
    WHERE co.InstructorID = @InstructorID AND co.SemesterID = @SemesterID
);
GO

CREATE PROCEDURE RecordOutcomeAssessment
    @CourseCode VARCHAR(20),
    @ILOCode VARCHAR(20),
    @SemesterID INT,
    @SectionID VARCHAR(20),
    @MappingID INT,
    @Instrument VARCHAR(150),
    @Description VARCHAR(1000),
    @TargetThreshold DECIMAL(10,2),
    @AttainedValue DECIMAL(10,2),
    @SampleSize INT,
    @AnalysisNotes VARCHAR(1000)
AS
BEGIN
    DECLARE @ActorID INT;
    DECLARE @AssessmentID INT;
    DECLARE @TargetMet INT;

    IF NOT EXISTS (
        SELECT *
        FROM Course_Offering
        WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID
    )
        PRINT 'Error: this course offering does not exist.';
    ELSE IF NOT EXISTS (
        SELECT *
        FROM ILO
        WHERE CourseCode = @CourseCode AND ILOCode = @ILOCode
    )
        PRINT 'Error: this ILO is not an ILO of ' + @CourseCode + '.';
    ELSE IF NOT EXISTS (
        SELECT *
        FROM Outcome_Mapping
        WHERE MappingID = @MappingID AND CourseCode = @CourseCode AND ILOCode = @ILOCode
    )
        PRINT 'Error: this mapping does not exist or is not a mapping of ' + @CourseCode + ' ' + @ILOCode + '.';
    ELSE IF @Instrument IS NULL OR @TargetThreshold IS NULL OR @AttainedValue IS NULL
         OR @TargetThreshold < 0 OR @AttainedValue < 0 OR @SampleSize <= 0
        PRINT 'Error: instrument, target and attained value are required, values cannot be negative and the sample size must be positive.';
    ELSE
    BEGIN
        SELECT @ActorID = InstructorID
        FROM Course_Offering
        WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID;

        INSERT INTO Outcome_Assessment (Instrument, Description, TargetThreshold, AttainedValue, SampleSize, AnalysisNotes, CourseCode, ILOCode, SemesterID, SectionID, MappingID)
        VALUES (@Instrument, @Description, @TargetThreshold, @AttainedValue, @SampleSize, @AnalysisNotes, @CourseCode, @ILOCode, @SemesterID, @SectionID, @MappingID);

        SELECT @AssessmentID = MAX(AssessmentID) FROM Outcome_Assessment;

        INSERT INTO Audit_Log (ActionType, ChangeSummary, ActorID, AssessmentID)
        VALUES ('Create', 'Assessment recorded: ' + @Instrument + ', ' + @CourseCode + ' ' + @ILOCode, @ActorID, @AssessmentID);

        SELECT @TargetMet = TargetMet FROM Outcome_Assessment WHERE AssessmentID = @AssessmentID;

        IF @TargetMet = 1
            PRINT 'Assessment ' + CAST(@AssessmentID AS VARCHAR(10)) + ' recorded: attained '
                + CAST(@AttainedValue AS VARCHAR(20)) + ' vs target ' + CAST(@TargetThreshold AS VARCHAR(20)) + ', target MET.';
        ELSE
            PRINT 'Assessment ' + CAST(@AssessmentID AS VARCHAR(10)) + ' recorded: attained '
                + CAST(@AttainedValue AS VARCHAR(20)) + ' vs target ' + CAST(@TargetThreshold AS VARCHAR(20)) + ', target NOT met.';
    END
END;
GO

CREATE PROCEDURE AddCorrectiveAction
    @AssessmentID INT,
    @CorrectiveAction VARCHAR(1000)
AS
BEGIN
    DECLARE @ActorID INT;

    IF NOT EXISTS (SELECT * FROM Outcome_Assessment WHERE AssessmentID = @AssessmentID)
        PRINT 'Error: this assessment does not exist.';
    ELSE IF EXISTS (SELECT * FROM Outcome_Assessment WHERE AssessmentID = @AssessmentID AND TargetMet = 1)
        PRINT 'Error: assessment ' + CAST(@AssessmentID AS VARCHAR(10)) + ' met its target, so it does not need a corrective action.';
    ELSE IF @CorrectiveAction IS NULL OR @CorrectiveAction = ''
        PRINT 'Error: the corrective action text is empty.';
    ELSE
    BEGIN
        SELECT @ActorID = co.InstructorID
        FROM Outcome_Assessment oa
        JOIN Course_Offering co ON co.CourseCode = oa.CourseCode AND co.SemesterID = oa.SemesterID AND co.SectionID = oa.SectionID
        WHERE oa.AssessmentID = @AssessmentID;

        UPDATE Outcome_Assessment
        SET CorrectiveAction = @CorrectiveAction
        WHERE AssessmentID = @AssessmentID;

        INSERT INTO Audit_Log (ActionType, ChangeSummary, ActorID, AssessmentID)
        VALUES ('Update', 'Corrective action added to assessment ' + CAST(@AssessmentID AS VARCHAR(10)), @ActorID, @AssessmentID);

        PRINT 'Corrective action added to assessment ' + CAST(@AssessmentID AS VARCHAR(10)) + '.';
    END
END;
GO

CREATE FUNCTION ViewUnmetAssessments
(
    @InstructorID INT
)
RETURNS TABLE
AS
RETURN (
    SELECT oa.AssessmentID, oa.CourseCode, oa.ILOCode, i.Statement AS ILOStatement,
           s.Name + ' ' + s.AcademicYear AS Semester, oa.SectionID,
           oa.Instrument, oa.TargetThreshold, oa.AttainedValue, oa.CorrectiveAction
    FROM Outcome_Assessment oa
    JOIN Course_Offering co ON co.CourseCode = oa.CourseCode AND co.SemesterID = oa.SemesterID AND co.SectionID = oa.SectionID
    JOIN ILO i ON i.CourseCode = oa.CourseCode AND i.ILOCode = oa.ILOCode
    JOIN Semester s ON s.SemesterID = oa.SemesterID
    WHERE co.InstructorID = @InstructorID AND oa.TargetMet = 0
);
GO

CREATE FUNCTION ViewSupportedOfferings
(
    @TAID INT
)
RETURNS TABLE
AS
RETURN (
    SELECT co.CourseCode, c.Title AS CourseTitle, s.Name + ' ' + s.AcademicYear AS Semester,
           co.SectionID, m.FullName AS InstructorName
    FROM Offering_TA ot
    JOIN Course_Offering co ON co.CourseCode = ot.CourseCode AND co.SemesterID = ot.SemesterID AND co.SectionID = ot.SectionID
    JOIN Course c ON c.CourseCode = co.CourseCode
    JOIN Semester s ON s.SemesterID = co.SemesterID
    JOIN Academic_Member m ON m.MemberID = co.InstructorID
    WHERE ot.TAID = @TAID
);
GO

CREATE FUNCTION ViewOfferingAssessments
(
    @CourseCode VARCHAR(20),
    @SemesterID INT,
    @SectionID VARCHAR(20)
)
RETURNS TABLE
AS
RETURN (
    SELECT AssessmentID, ILOCode, Instrument, TargetThreshold, AttainedValue,
           CASE WHEN TargetMet = 1 THEN 'Met' ELSE 'Not Met' END AS Result
    FROM Outcome_Assessment
    WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID
);
GO

CREATE PROCEDURE UpdateEnrolledCount
    @CourseCode VARCHAR(20),
    @SemesterID INT,
    @SectionID VARCHAR(20),
    @EnrolledCount INT
AS
BEGIN
    IF NOT EXISTS (
        SELECT *
        FROM Course_Offering
        WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID
    )
        PRINT 'Error: this course offering does not exist.';
    ELSE IF @EnrolledCount IS NULL OR @EnrolledCount < 0
        PRINT 'Error: the enrolled count must be 0 or more.';
    ELSE
    BEGIN
        UPDATE Course_Offering
        SET EnrolledCount = @EnrolledCount
        WHERE CourseCode = @CourseCode AND SemesterID = @SemesterID AND SectionID = @SectionID;

        PRINT 'Enrolled count of ' + @CourseCode + ' section ' + @SectionID + ' in semester '
            + CAST(@SemesterID AS VARCHAR(10)) + ' set to ' + CAST(@EnrolledCount AS VARCHAR(10)) + '.';
    END
END;
GO

CREATE FUNCTION GetPLOAttainment
(
    @ProgramID INT,
    @PLOCode VARCHAR(20),
    @SemesterID INT
)
RETURNS DECIMAL(5,2)
AS
BEGIN
    DECLARE @Total INT;
    DECLARE @Met INT;
    DECLARE @Result DECIMAL(5,2);

    SELECT @Total = COUNT(*), @Met = SUM(oa.TargetMet)
    FROM Outcome_Assessment oa
    JOIN Outcome_Mapping om ON om.MappingID = oa.MappingID
    WHERE om.ProgramID = @ProgramID AND om.PLOCode = @PLOCode AND oa.SemesterID = @SemesterID;

    IF @Total = 0
        SET @Result = NULL;
    ELSE
        SET @Result = 100.0 * @Met / @Total;

    RETURN @Result;
END;
GO

CREATE FUNCTION ViewAssessmentsBelowTarget
(
    @ProgramID INT,
    @SemesterID INT
)
RETURNS TABLE
AS
RETURN (
    SELECT oa.AssessmentID, oa.CourseCode, c.Title AS CourseTitle, oa.ILOCode, oa.SectionID,
           om.PLOCode, oa.Instrument, oa.TargetThreshold, oa.AttainedValue, oa.CorrectiveAction
    FROM Outcome_Assessment oa
    JOIN Outcome_Mapping om ON om.MappingID = oa.MappingID
    JOIN Course c ON c.CourseCode = oa.CourseCode
    WHERE om.ProgramID = @ProgramID AND oa.SemesterID = @SemesterID AND oa.TargetMet = 0
);
GO

CREATE FUNCTION TrackCorrectiveActionEffect
(
    @CourseCode VARCHAR(20),
    @ILOCode VARCHAR(20)
)
RETURNS TABLE
AS
RETURN (
    SELECT s.SemesterID, s.Name + ' ' + s.AcademicYear AS Semester, s.StartDate,
           oa.SectionID, oa.Instrument, oa.TargetThreshold, oa.AttainedValue,
           CASE WHEN oa.TargetMet = 1 THEN 'Met' ELSE 'Not Met' END AS Result,
           oa.CorrectiveAction
    FROM Outcome_Assessment oa
    JOIN Semester s ON s.SemesterID = oa.SemesterID
    WHERE oa.CourseCode = @CourseCode AND oa.ILOCode = @ILOCode
);
GO

CREATE PROCEDURE CreateAccreditationReview
    @ProgramID INT,
    @AccreditingBody VARCHAR(150),
    @ReviewType VARCHAR(50),
    @ReviewCycle VARCHAR(50),
    @NextReviewDue DATE
AS
BEGIN
    DECLARE @ReviewID INT;

    IF NOT EXISTS (SELECT * FROM Program WHERE ProgramID = @ProgramID)
        PRINT 'Error: this program does not exist.';
    ELSE IF @AccreditingBody IS NULL OR @AccreditingBody = ''
        PRINT 'Error: the accrediting body is required.';
    ELSE
    BEGIN
        INSERT INTO Accreditation_Review (AccreditingBody, ReviewType, ReviewCycle, Status, NextReviewDue, ProgramID)
        VALUES (@AccreditingBody, @ReviewType, @ReviewCycle, 'Open', @NextReviewDue, @ProgramID);

        SELECT @ReviewID = MAX(ReviewID) FROM Accreditation_Review;

        PRINT 'Accreditation review opened for program ' + CAST(@ProgramID AS VARCHAR(10))
            + '. New ReviewID = ' + CAST(@ReviewID AS VARCHAR(10));
    END
END;
GO

CREATE PROCEDURE AttachMappingsToReview
    @ReviewID INT
AS
BEGIN
    DECLARE @ProgramID INT;
    DECLARE @Count INT;

    IF NOT EXISTS (SELECT * FROM Accreditation_Review WHERE ReviewID = @ReviewID)
        PRINT 'Error: this accreditation review does not exist.';
    ELSE
    BEGIN
        SELECT @ProgramID = ProgramID FROM Accreditation_Review WHERE ReviewID = @ReviewID;

        SELECT @Count = COUNT(*)
        FROM Outcome_Mapping om
        WHERE om.ProgramID = @ProgramID AND om.MappingStatus = 'Approved'
          AND NOT EXISTS (
              SELECT *
              FROM Review_Mapping rm
              WHERE rm.ReviewID = @ReviewID AND rm.MappingID = om.MappingID
          );

        INSERT INTO Review_Mapping (ReviewID, MappingID)
        SELECT @ReviewID, om.MappingID
        FROM Outcome_Mapping om
        WHERE om.ProgramID = @ProgramID AND om.MappingStatus = 'Approved'
          AND NOT EXISTS (
              SELECT *
              FROM Review_Mapping rm
              WHERE rm.ReviewID = @ReviewID AND rm.MappingID = om.MappingID
          );

        PRINT CAST(@Count AS VARCHAR(10)) + ' approved mapping(s) attached to review ' + CAST(@ReviewID AS VARCHAR(10)) + '.';
    END
END;
GO

CREATE PROCEDURE AttachAssessmentToReview
    @ReviewID INT,
    @AssessmentID INT
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Accreditation_Review WHERE ReviewID = @ReviewID)
        PRINT 'Error: this accreditation review does not exist.';
    ELSE IF NOT EXISTS (SELECT * FROM Outcome_Assessment WHERE AssessmentID = @AssessmentID)
        PRINT 'Error: this assessment does not exist.';
    ELSE IF NOT EXISTS (
        SELECT *
        FROM Outcome_Assessment oa
        JOIN Outcome_Mapping om ON om.MappingID = oa.MappingID
        JOIN Accreditation_Review ar ON ar.ProgramID = om.ProgramID
        WHERE oa.AssessmentID = @AssessmentID AND ar.ReviewID = @ReviewID
    )
        PRINT 'Error: assessment ' + CAST(@AssessmentID AS VARCHAR(10)) + ' does not belong to the program of review ' + CAST(@ReviewID AS VARCHAR(10)) + '.';
    ELSE IF EXISTS (SELECT * FROM Review_Assessment WHERE ReviewID = @ReviewID AND AssessmentID = @AssessmentID)
        PRINT 'Error: assessment ' + CAST(@AssessmentID AS VARCHAR(10)) + ' is already attached to this review.';
    ELSE
    BEGIN
        INSERT INTO Review_Assessment (ReviewID, AssessmentID)
        VALUES (@ReviewID, @AssessmentID);

        PRINT 'Assessment ' + CAST(@AssessmentID AS VARCHAR(10)) + ' attached to review ' + CAST(@ReviewID AS VARCHAR(10)) + '.';
    END
END;
GO

CREATE PROCEDURE AttachEvidenceToReview
    @ReviewID INT,
    @EvidenceID INT
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Accreditation_Review WHERE ReviewID = @ReviewID)
        PRINT 'Error: this accreditation review does not exist.';
    ELSE IF NOT EXISTS (SELECT * FROM Evidence WHERE EvidenceID = @EvidenceID)
        PRINT 'Error: this evidence does not exist.';
    ELSE IF NOT EXISTS (
        SELECT *
        FROM Evidence e
        JOIN Innovation_Initiative ii ON ii.InitiativeID = e.InitiativeID
        JOIN Program p ON p.FacultyID = ii.FacultyID
        JOIN Accreditation_Review ar ON ar.ProgramID = p.ProgramID
        WHERE e.EvidenceID = @EvidenceID AND ar.ReviewID = @ReviewID
    )
        PRINT 'Error: evidence ' + CAST(@EvidenceID AS VARCHAR(10)) + ' comes from an initiative outside the faculty of review ' + CAST(@ReviewID AS VARCHAR(10)) + '.';
    ELSE IF EXISTS (SELECT * FROM Review_Evidence WHERE ReviewID = @ReviewID AND EvidenceID = @EvidenceID)
        PRINT 'Error: evidence ' + CAST(@EvidenceID AS VARCHAR(10)) + ' is already attached to this review.';
    ELSE
    BEGIN
        INSERT INTO Review_Evidence (ReviewID, EvidenceID)
        VALUES (@ReviewID, @EvidenceID);

        PRINT 'Evidence ' + CAST(@EvidenceID AS VARCHAR(10)) + ' attached to review ' + CAST(@ReviewID AS VARCHAR(10)) + '.';
    END
END;
GO

CREATE PROCEDURE UpdateAccreditationStatus
    @ReviewID INT,
    @Status VARCHAR(50),
    @Decision VARCHAR(50),
    @SubmissionDate DATE
AS
BEGIN
    IF NOT EXISTS (SELECT * FROM Accreditation_Review WHERE ReviewID = @ReviewID)
        PRINT 'Error: this accreditation review does not exist.';
    ELSE IF @Status IS NULL OR @Status NOT IN ('Open', 'In Progress', 'Submitted', 'Closed')
        PRINT 'Error: status must be Open, In Progress, Submitted or Closed.';
    ELSE
    BEGIN
        UPDATE Accreditation_Review
        SET Status = @Status,
            Decision = ISNULL(@Decision, Decision),
            SubmissionDate = ISNULL(@SubmissionDate, SubmissionDate)
        WHERE ReviewID = @ReviewID;

        IF @Decision IS NULL
            PRINT 'Review ' + CAST(@ReviewID AS VARCHAR(10)) + ' updated: status ' + @Status + ', decision (unchanged).';
        ELSE
            PRINT 'Review ' + CAST(@ReviewID AS VARCHAR(10)) + ' updated: status ' + @Status + ', decision ' + @Decision + '.';
    END
END;
GO

CREATE FUNCTION GenerateAccreditationPack
(
    @ReviewID INT
)
RETURNS TABLE
AS
RETURN (
    SELECT 'Mapping' AS ItemType, om.MappingID AS ItemID,
           om.CourseCode + ' ' + om.ILOCode + ' to ' + om.PLOCode AS Title,
           om.CoverageLevel + ', ' + om.MappingStatus AS Details,
           NULL AS ArtifactType, NULL AS TargetThreshold, NULL AS AttainedValue, NULL AS Result
    FROM Review_Mapping rm
    JOIN Outcome_Mapping om ON om.MappingID = rm.MappingID
    WHERE rm.ReviewID = @ReviewID

    UNION ALL

    SELECT 'Assessment', oa.AssessmentID,
           oa.CourseCode + ' ' + oa.ILOCode + ': ' + oa.Instrument,
           oa.Description,
           NULL, oa.TargetThreshold, oa.AttainedValue,
           CASE WHEN oa.TargetMet = 1 THEN 'Met' ELSE 'Not Met' END
    FROM Review_Assessment ra
    JOIN Outcome_Assessment oa ON oa.AssessmentID = ra.AssessmentID
    WHERE ra.ReviewID = @ReviewID

    UNION ALL

    SELECT 'Evidence', e.EvidenceID, e.Title, e.FilePathOrURL,
           e.ArtifactType, NULL, NULL, NULL
    FROM Review_Evidence re
    JOIN Evidence e ON e.EvidenceID = re.EvidenceID
    WHERE re.ReviewID = @ReviewID
);
GO

CREATE FUNCTION GetUpcomingAccreditations
(
    @DaysAhead INT
)
RETURNS TABLE
AS
RETURN (
    SELECT ar.ReviewID, p.Name AS ProgramName, ar.AccreditingBody, ar.Status, ar.NextReviewDue
    FROM Accreditation_Review ar
    JOIN Program p ON p.ProgramID = ar.ProgramID
    WHERE ar.NextReviewDue BETWEEN CAST(GETDATE() AS DATE) AND DATEADD(DAY, @DaysAhead, CAST(GETDATE() AS DATE))
);
GO

CREATE FUNCTION GetAccreditationOverview
()
RETURNS TABLE
AS
RETURN (
    SELECT p.ProgramID, p.Name AS ProgramName, f.Name AS FacultyName,
           ar.ReviewID, ar.AccreditingBody, ar.Status, ar.Decision, ar.NextReviewDue
    FROM Program p
    JOIN Faculty f ON f.FacultyID = p.FacultyID
    LEFT JOIN Accreditation_Review ar ON ar.ProgramID = p.ProgramID
    WHERE ar.ReviewID IS NULL
       OR ar.ReviewID = (
           SELECT MAX(a2.ReviewID)
           FROM Accreditation_Review a2
           WHERE a2.ProgramID = p.ProgramID AND a2.SubmissionDate IS NULL
       )
       OR (
           NOT EXISTS (
               SELECT *
               FROM Accreditation_Review a3
               WHERE a3.ProgramID = p.ProgramID AND a3.SubmissionDate IS NULL
           )
           AND ar.ReviewID = (
               SELECT MAX(a4.ReviewID)
               FROM Accreditation_Review a4
               WHERE a4.ProgramID = p.ProgramID
                 AND a4.SubmissionDate = (
                     SELECT MAX(a5.SubmissionDate)
                     FROM Accreditation_Review a5
                     WHERE a5.ProgramID = p.ProgramID
                 )
           )
       )
);
GO

CREATE FUNCTION GetAttainmentTrend
(
    @ProgramID INT
)
RETURNS TABLE
AS
RETURN (
    SELECT s.SemesterID, s.Name + ' ' + s.AcademicYear AS Semester, s.StartDate,
           COUNT(*) AS TotalAssessments,
           SUM(oa.TargetMet) AS MetAssessments,
           100.0 * SUM(oa.TargetMet) / COUNT(*) AS MetPercentage
    FROM Outcome_Assessment oa
    JOIN Outcome_Mapping om ON om.MappingID = oa.MappingID
    JOIN Semester s ON s.SemesterID = oa.SemesterID
    WHERE om.ProgramID = @ProgramID
    GROUP BY s.SemesterID, s.Name, s.AcademicYear, s.StartDate
);
GO

CREATE PROCEDURE NotifyAccreditationDeadline
    @ProgramID INT,
    @DaysAhead INT
AS
BEGIN
    DECLARE @Today DATE;
    DECLARE @DueDate DATE;
    DECLARE @ReviewID INT;
    DECLARE @Body VARCHAR(150);
    DECLARE @ProgramName VARCHAR(150);
    DECLARE @FacultyID INT;
    DECLARE @Message VARCHAR(1000);
    DECLARE @NotificationID INT;
    DECLARE @Count INT;

    IF NOT EXISTS (SELECT * FROM Program WHERE ProgramID = @ProgramID)
        PRINT 'Error: this program does not exist.';
    ELSE IF @DaysAhead IS NULL OR @DaysAhead < 0
        PRINT 'Error: the number of days must be 0 or more.';
    ELSE
    BEGIN
        SET @Today = CAST(GETDATE() AS DATE);
        SELECT @DueDate = MIN(NextReviewDue)
        FROM Accreditation_Review
        WHERE ProgramID = @ProgramID AND NextReviewDue BETWEEN @Today AND DATEADD(DAY, @DaysAhead, @Today);

        IF @DueDate IS NULL
            PRINT 'No accreditation deadline for program ' + CAST(@ProgramID AS VARCHAR(10))
                + ' in the next ' + CAST(@DaysAhead AS VARCHAR(10)) + ' days. Nobody was notified.';
        ELSE
        BEGIN
            SELECT @ReviewID = MIN(ReviewID)
            FROM Accreditation_Review
            WHERE ProgramID = @ProgramID AND NextReviewDue = @DueDate;

            SELECT @Body = AccreditingBody
            FROM Accreditation_Review
            WHERE ReviewID = @ReviewID;

            SELECT @ProgramName = Name, @FacultyID = FacultyID
            FROM Program
            WHERE ProgramID = @ProgramID;

            SET @Message = 'Accreditation review for ' + @ProgramName + ' (' + @Body + ') is due on ' + CAST(@DueDate AS VARCHAR(10));

            INSERT INTO Notification (MessageContent, Urgency, Category)
            VALUES (@Message, 'High', 'Accreditation');

            SELECT @NotificationID = MAX(NotificationID) FROM Notification;

            SELECT @Count = COUNT(*)
            FROM Academic_Member
            WHERE FacultyID = @FacultyID AND AccountStatus = 'Active';

            INSERT INTO Notification_Recipient (NotificationID, MemberID, ReadStatus)
            SELECT @NotificationID, MemberID, 0
            FROM Academic_Member
            WHERE FacultyID = @FacultyID AND AccountStatus = 'Active';

            PRINT 'Notification ' + CAST(@NotificationID AS VARCHAR(10)) + ' sent to ' + CAST(@Count AS VARCHAR(10))
                + ' member(s): ' + @Message;
        END
    END
END;
GO

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

CREATE PROCEDURE AddTool
    @Name                 VARCHAR(150),
    @Description          VARCHAR(1000),
    @Category             VARCHAR(50),
    @Status               VARCHAR(50),
    @ToolType             VARCHAR(30),
    @Provider             VARCHAR(150),
    @ModelVersion         VARCHAR(50),
    @LicenseType          VARCHAR(50),
    @HostingMode          VARCHAR(50),
    @CostModel            VARCHAR(50),
    @OriginatingFramework VARCHAR(150),
    @ReferenceSource      VARCHAR(150),
    @RequiredResources    VARCHAR(1000)
AS
BEGIN
    DECLARE @ToolID INT;

    IF @Status IS NULL
        SET @Status = 'Under Review';

    IF @Name IS NULL OR @Name = ''
        PRINT 'Error: Tool name is required.';
    ELSE IF @ToolType IS NULL OR @ToolType NOT IN ('AI Tool', 'Teaching Methodology')
        PRINT 'Error: Tool type must be AI Tool or Teaching Methodology.';
    ELSE IF @Status NOT IN ('Approved', 'Under Review', 'Suspended')
        PRINT 'Error: Status must be Approved, Under Review or Suspended.';
    ELSE IF EXISTS (SELECT * FROM Tool WHERE Name = @Name)
        PRINT 'Error: A tool called ' + @Name + ' already exists.';
    ELSE
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            INSERT INTO Tool (Name, Description, Category, Status)
            VALUES (@Name, @Description, @Category, @Status);

            SET @ToolID = SCOPE_IDENTITY();

            IF @ToolType = 'AI Tool'
                INSERT INTO AI_Tool (ToolID, Provider, ModelVersion, LicenseType, HostingMode, CostModel)
                VALUES (@ToolID, @Provider, @ModelVersion, @LicenseType, @HostingMode, @CostModel);
            ELSE
                INSERT INTO Teaching_Methodology (ToolID, OriginatingFramework, ReferenceSource, RequiredResources)
                VALUES (@ToolID, @OriginatingFramework, @ReferenceSource, @RequiredResources);

            COMMIT TRANSACTION;

            PRINT 'Tool ' + @Name + ' added as ' + @ToolType + ', new ToolID ' + CAST(@ToolID AS VARCHAR(10)) + '.';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            PRINT 'Error: The tool could not be added. ' + ERROR_MESSAGE();
        END CATCH
    END
END
GO

CREATE PROCEDURE AddAIToolIntegration
    @InitiativeID           INT,
    @IntegrationObjective   VARCHAR(1000),
    @ToolCategory           VARCHAR(50),
    @DataPrivacyNotes       VARCHAR(1000),
    @AcademicIntegrityNotes VARCHAR(1000)
AS
BEGIN
    IF @InitiativeID IS NULL
        PRINT 'Error: Initiative ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF EXISTS (SELECT * FROM AI_Tool_Integration WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' already has an AI tool integration description.';
    ELSE
    BEGIN
        INSERT INTO AI_Tool_Integration (InitiativeID, IntegrationObjective, ToolCategory,
                                         DataPrivacyNotes, AcademicIntegrityNotes)
        VALUES (@InitiativeID, @IntegrationObjective, @ToolCategory,
                @DataPrivacyNotes, @AcademicIntegrityNotes);

        PRINT 'AI tool integration added to initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE AddMethodologyChange
    @InitiativeID        INT,
    @PedagogicalApproach VARCHAR(150),
    @DeliveryChange      VARCHAR(1000),
    @ReferenceFramework  VARCHAR(150)
AS
BEGIN
    IF @InitiativeID IS NULL
        PRINT 'Error: Initiative ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF EXISTS (SELECT * FROM Methodology_Change WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' already has a methodology change description.';
    ELSE
    BEGIN
        INSERT INTO Methodology_Change (InitiativeID, PedagogicalApproach, DeliveryChange, ReferenceFramework)
        VALUES (@InitiativeID, @PedagogicalApproach, @DeliveryChange, @ReferenceFramework);

        PRINT 'Methodology change added to initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE AddAssessmentRedesign
    @InitiativeID           INT,
    @AssessmentTypeAffected VARCHAR(50),
    @RubricWeightingChanges VARCHAR(1000),
    @FairnessSafeguards     VARCHAR(1000)
AS
BEGIN
    IF @InitiativeID IS NULL
        PRINT 'Error: Initiative ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF EXISTS (SELECT * FROM Assessment_Redesign WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' already has an assessment redesign description.';
    ELSE
    BEGIN
        INSERT INTO Assessment_Redesign (InitiativeID, AssessmentTypeAffected, RubricWeightingChanges, FairnessSafeguards)
        VALUES (@InitiativeID, @AssessmentTypeAffected, @RubricWeightingChanges, @FairnessSafeguards);

        PRINT 'Assessment redesign added to initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE AdoptTool
    @InitiativeID INT,
    @ToolID       INT
AS
BEGIN
    IF @InitiativeID IS NULL OR @ToolID IS NULL
        PRINT 'Error: Initiative ID and tool ID are required.';
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF NOT EXISTS (SELECT * FROM Tool WHERE ToolID = @ToolID)
        PRINT 'Error: Tool ' + CAST(@ToolID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF EXISTS (SELECT * FROM Tool WHERE ToolID = @ToolID AND Status = 'Suspended')
        PRINT 'Error: Tool ' + CAST(@ToolID AS VARCHAR(10)) + ' is suspended and cannot be adopted.';
    ELSE IF EXISTS (SELECT * FROM Initiative_Tool WHERE InitiativeID = @InitiativeID AND ToolID = @ToolID)
        PRINT 'Error: Tool ' + CAST(@ToolID AS VARCHAR(10)) + ' is already linked to initiative '
              + CAST(@InitiativeID AS VARCHAR(10)) + '.';
    ELSE
    BEGIN
        INSERT INTO Initiative_Tool (InitiativeID, ToolID)
        VALUES (@InitiativeID, @ToolID);

        PRINT 'Tool ' + CAST(@ToolID AS VARCHAR(10)) + ' linked to initiative '
              + CAST(@InitiativeID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE AddTrainingRequirement
    @InitiativeID   INT,
    @ToolID         INT,
    @Description    VARCHAR(1000),
    @TargetAudience VARCHAR(150),
    @RequiredByDate DATE,
    @IsMandatory    BIT
AS
BEGIN
    IF @IsMandatory IS NULL
        SET @IsMandatory = 1;

    IF @InitiativeID IS NULL
        PRINT 'Error: Initiative ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @ToolID IS NOT NULL AND NOT EXISTS (SELECT * FROM Tool WHERE ToolID = @ToolID)
        PRINT 'Error: Tool ' + CAST(@ToolID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @Description IS NULL OR @Description = ''
        PRINT 'Error: A description of the training requirement is required.';
    ELSE IF EXISTS (SELECT * FROM Training_Requirement
                    WHERE InitiativeID = @InitiativeID
                      AND Description = @Description
                      AND ISNULL(ToolID, 0) = ISNULL(@ToolID, 0))
        PRINT 'Error: This training requirement is already recorded for initiative '
              + CAST(@InitiativeID AS VARCHAR(10)) + '.';
    ELSE
    BEGIN
        INSERT INTO Training_Requirement (Description, TargetAudience, RequiredByDate, IsMandatory, InitiativeID, ToolID)
        VALUES (@Description, @TargetAudience, @RequiredByDate, @IsMandatory, @InitiativeID, @ToolID);

        PRINT 'Training requirement recorded for initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE UploadEvidence
    @InitiativeID   INT,
    @MilestoneSeqNo INT,
    @Title          VARCHAR(150),
    @ArtifactType   VARCHAR(50),
    @FilePathOrURL  VARCHAR(1000),
    @Description    VARCHAR(1000)
AS
BEGIN
    DECLARE @EvidenceID INT;

    IF @InitiativeID IS NULL
        PRINT 'Error: Initiative ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @Title IS NULL OR @Title = ''
        PRINT 'Error: Evidence title is required.';
    ELSE IF @FilePathOrURL IS NULL OR @FilePathOrURL = ''
        PRINT 'Error: File path or URL is required.';
    ELSE IF @MilestoneSeqNo IS NOT NULL
            AND NOT EXISTS (SELECT * FROM Milestone WHERE InitiativeID = @InitiativeID AND SeqNo = @MilestoneSeqNo)
        PRINT 'Error: Milestone ' + CAST(@MilestoneSeqNo AS VARCHAR(10)) + ' does not exist for initiative '
              + CAST(@InitiativeID AS VARCHAR(10)) + '.';
    ELSE
    BEGIN
        INSERT INTO Evidence (Title, ArtifactType, FilePathOrURL, UploadDate, Description, InitiativeID, MilestoneSeqNo)
        VALUES (@Title, @ArtifactType, @FilePathOrURL, GETDATE(), @Description, @InitiativeID, @MilestoneSeqNo);

        SET @EvidenceID = SCOPE_IDENTITY();

        INSERT INTO Audit_Log (ActionType, ChangeSummary, ActorID, EvidenceID)
        SELECT 'Create', 'Evidence uploaded: ' + @Title, SubmitterID, @EvidenceID
        FROM Innovation_Initiative
        WHERE InitiativeID = @InitiativeID;

        PRINT 'Evidence ' + @Title + ' uploaded for initiative ' + CAST(@InitiativeID AS VARCHAR(10))
              + ', new EvidenceID ' + CAST(@EvidenceID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE SubmitOutcomeReport
    @InitiativeID       INT,
    @SemesterID         INT,
    @MetricType         VARCHAR(50),
    @QuantitativeValue  DECIMAL(10,2),
    @BaselineValue      DECIMAL(10,2),
    @QualitativeSummary VARCHAR(1000)
AS
BEGIN
    IF @InitiativeID IS NULL OR @SemesterID IS NULL
        PRINT 'Error: Initiative ID and semester ID are required.';
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF NOT EXISTS (SELECT * FROM Semester WHERE SemesterID = @SemesterID)
        PRINT 'Error: Semester ' + CAST(@SemesterID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @MetricType IS NULL OR @MetricType = ''
        PRINT 'Error: Metric type is required.';
    ELSE IF @QuantitativeValue IS NULL AND (@QualitativeSummary IS NULL OR @QualitativeSummary = '')
        PRINT 'Error: Give a quantitative value, a qualitative summary or both.';
    ELSE IF EXISTS (SELECT * FROM Outcome_Report
                    WHERE InitiativeID = @InitiativeID AND SemesterID = @SemesterID AND MetricType = @MetricType)
        PRINT 'Error: A ' + @MetricType + ' report already exists for initiative '
              + CAST(@InitiativeID AS VARCHAR(10)) + ' in semester ' + CAST(@SemesterID AS VARCHAR(10)) + '.';
    ELSE
    BEGIN
        INSERT INTO Outcome_Report (MetricType, QuantitativeValue, BaselineValue, QualitativeSummary, InitiativeID, SemesterID)
        VALUES (@MetricType, @QuantitativeValue, @BaselineValue, @QualitativeSummary, @InitiativeID, @SemesterID);

        PRINT 'Outcome report (' + @MetricType + ') submitted for initiative '
              + CAST(@InitiativeID AS VARCHAR(10)) + ' in semester ' + CAST(@SemesterID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE RecordStudentFeedback
    @InitiativeID      INT,
    @SemesterID        INT,
    @Rating            INT,
    @Comment           VARCHAR(1000),
    @CategorySentiment VARCHAR(50),
    @CollectionMethod  VARCHAR(50)
AS
BEGIN
    IF @InitiativeID IS NULL OR @SemesterID IS NULL
        PRINT 'Error: Initiative ID and semester ID are required.';
    ELSE IF NOT EXISTS (SELECT * FROM Innovation_Initiative WHERE InitiativeID = @InitiativeID)
        PRINT 'Error: Initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF NOT EXISTS (SELECT * FROM Semester WHERE SemesterID = @SemesterID)
        PRINT 'Error: Semester ' + CAST(@SemesterID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @Rating IS NULL OR @Rating NOT BETWEEN 1 AND 5
        PRINT 'Error: Rating must be a number between 1 and 5.';
    ELSE
    BEGIN
        INSERT INTO Student_Feedback (Rating, Comment, CategorySentiment, CollectionMethod, InitiativeID, SemesterID)
        VALUES (@Rating, @Comment, @CategorySentiment, @CollectionMethod, @InitiativeID, @SemesterID);

        PRINT 'Feedback recorded for initiative ' + CAST(@InitiativeID AS VARCHAR(10)) + '.';
    END
END
GO

CREATE FUNCTION ViewInitiativeEvidence (@InitiativeID INT)
RETURNS TABLE
AS
RETURN (
    SELECT e.EvidenceID,
           e.Title,
           e.ArtifactType,
           e.MilestoneSeqNo,
           ms.Title AS MilestoneTitle,
           e.UploadDate,
           e.FilePathOrURL
    FROM Evidence e
    LEFT JOIN Milestone ms ON ms.InitiativeID = e.InitiativeID AND ms.SeqNo = e.MilestoneSeqNo
    WHERE e.InitiativeID = @InitiativeID
);
GO

CREATE PROCEDURE ScheduleTrainingSession
    @ToolID            INT,
    @Title             VARCHAR(150),
    @Topic             VARCHAR(150),
    @Description       VARCHAR(1000),
    @SessionDate       DATE,
    @DurationMinutes   INT,
    @Trainer           VARCHAR(150),
    @Capacity          INT,
    @Mode              VARCHAR(20),
    @Platform          VARCHAR(50),
    @MeetingLink       VARCHAR(1000),
    @RecordingAvailable BIT,
    @Venue             VARCHAR(150),
    @Campus            VARCHAR(50),
    @RequiredEquipment VARCHAR(1000)
AS
BEGIN
    DECLARE @SessionID INT;

    IF @RecordingAvailable IS NULL
        SET @RecordingAvailable = 0;

    IF @Mode = 'In-Person'
        SET @Mode = 'In Person';

    IF @ToolID IS NULL
        PRINT 'Error: Tool ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Tool WHERE ToolID = @ToolID)
        PRINT 'Error: Tool ' + CAST(@ToolID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF EXISTS (SELECT * FROM Tool WHERE ToolID = @ToolID AND Status = 'Suspended')
        PRINT 'Error: Tool ' + CAST(@ToolID AS VARCHAR(10)) + ' is suspended, no training can be scheduled for it.';
    ELSE IF @Title IS NULL OR @Title = ''
        PRINT 'Error: Session title is required.';
    ELSE IF @SessionDate IS NULL
        PRINT 'Error: Session date is required.';
    ELSE IF @SessionDate < CAST(GETDATE() AS DATE)
        PRINT 'Error: A session cannot be scheduled in the past.';
    ELSE IF @Capacity IS NULL OR @Capacity <= 0
        PRINT 'Error: Capacity must be greater than zero.';
    ELSE IF @DurationMinutes IS NOT NULL AND @DurationMinutes <= 0
        PRINT 'Error: Duration must be greater than zero.';
    ELSE IF @Mode IS NULL OR @Mode NOT IN ('Online', 'In Person')
        PRINT 'Error: Mode must be Online or In Person.';
    ELSE IF @Mode = 'Online' AND (@Platform IS NULL OR @Platform = '')
        PRINT 'Error: An online session needs a platform.';
    ELSE IF @Mode = 'In Person' AND (@Venue IS NULL OR @Venue = '')
        PRINT 'Error: An in-person session needs a venue.';
    ELSE
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;

            INSERT INTO Training_Session (Title, Topic, Description, SessionDate, DurationMinutes,
                                          Trainer, Capacity, Status, ToolID)
            VALUES (@Title, @Topic, @Description, @SessionDate, @DurationMinutes,
                    @Trainer, @Capacity, 'Scheduled', @ToolID);

            SET @SessionID = SCOPE_IDENTITY();

            IF @Mode = 'Online'
                INSERT INTO Online_Training (SessionID, Platform, MeetingLink, RecordingAvailable)
                VALUES (@SessionID, @Platform, @MeetingLink, @RecordingAvailable);
            ELSE
                INSERT INTO In_Person_Training (SessionID, Venue, Campus, RequiredEquipment)
                VALUES (@SessionID, @Venue, @Campus, @RequiredEquipment);

            COMMIT TRANSACTION;

            PRINT 'Training session ' + @Title + ' scheduled (' + @Mode + '), new SessionID '
                  + CAST(@SessionID AS VARCHAR(10)) + '.';
        END TRY
        BEGIN CATCH
            IF @@TRANCOUNT > 0
                ROLLBACK TRANSACTION;
            PRINT 'Error: The session could not be scheduled. ' + ERROR_MESSAGE();
        END CATCH
    END
END
GO

CREATE FUNCTION ViewTrainingAttendance (@SessionID INT)
RETURNS TABLE
AS
RETURN (
    SELECT m.MemberID,
           m.FullName,
           m.AcademicRank,
           m.Email
    FROM Session_Attendance sa
    JOIN Academic_Member m ON m.MemberID = sa.MemberID
    WHERE sa.SessionID = @SessionID
);
GO

CREATE FUNCTION GetFacultyTrainingCompliance (@FacultyID INT)
RETURNS TABLE
AS
RETURN (
    SELECT i.InitiativeID,
           i.Title AS InitiativeTitle,
           r.RequirementID,
           r.Description AS Requirement,
           t.Name AS ToolName,
           r.IsMandatory,
           (SELECT COUNT(*)
            FROM Initiative_Member im
            WHERE im.InitiativeID = i.InitiativeID) AS AssignedMembers,
           (SELECT COUNT(DISTINCT im.MemberID)
            FROM Initiative_Member im
            JOIN Session_Attendance sa ON sa.MemberID = im.MemberID
            JOIN Training_Session s ON s.SessionID = sa.SessionID
            WHERE im.InitiativeID = i.InitiativeID
              AND s.Status <> 'Cancelled'
              AND s.ToolID = r.ToolID) AS TrainedMembers
    FROM Innovation_Initiative i
    JOIN Training_Requirement r ON r.InitiativeID = i.InitiativeID
    LEFT JOIN Tool t ON t.ToolID = r.ToolID
    WHERE i.FacultyID = @FacultyID
);
GO

CREATE FUNCTION GetInitiativeImpact (@InitiativeID INT)
RETURNS TABLE
AS
RETURN (
    SELECT o.SemesterID,
           s.Name AS Semester,
           s.AcademicYear,
           o.MetricType,
           o.BaselineValue,
           o.QuantitativeValue,
           CASE WHEN o.BaselineValue IS NULL OR o.BaselineValue = 0 OR o.QuantitativeValue IS NULL
                THEN NULL
                ELSE CAST((o.QuantitativeValue - o.BaselineValue) * 100.0 / o.BaselineValue AS DECIMAL(10,2))
           END AS PercentageChange
    FROM Outcome_Report o
    JOIN Semester s ON s.SemesterID = o.SemesterID
    WHERE o.InitiativeID = @InitiativeID
);
GO

CREATE FUNCTION GetAverageFeedbackRating (@InitiativeID INT, @SemesterID INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @Avg DECIMAL(3,2);

    IF EXISTS (SELECT * FROM Student_Feedback WHERE InitiativeID = @InitiativeID AND SemesterID = @SemesterID)
        SELECT @Avg = CAST(AVG(CAST(Rating AS DECIMAL(10,2))) AS DECIMAL(3,2))
        FROM Student_Feedback
        WHERE InitiativeID = @InitiativeID AND SemesterID = @SemesterID;

    RETURN @Avg;
END
GO

CREATE FUNCTION GetToolAdoptionReport ()
RETURNS TABLE
AS
RETURN (
    SELECT t.ToolID,
           t.Name AS ToolName,
           t.Status,
           (SELECT COUNT(DISTINCT it.InitiativeID)
            FROM Initiative_Tool it
            WHERE it.ToolID = t.ToolID) AS NumberOfInitiatives,
           (SELECT COUNT(DISTINCT i.FacultyID)
            FROM Initiative_Tool it
            JOIN Innovation_Initiative i ON i.InitiativeID = it.InitiativeID
            WHERE it.ToolID = t.ToolID) AS NumberOfFaculties,
           (SELECT COUNT(DISTINCT sa.MemberID)
            FROM Training_Session s
            JOIN Session_Attendance sa ON sa.SessionID = s.SessionID
            WHERE s.ToolID = t.ToolID AND s.Status <> 'Cancelled') AS NumberOfTrainedMembers
    FROM Tool t
);
GO

CREATE PROCEDURE UpdateToolStatus
    @ToolID INT,
    @Status VARCHAR(50)
AS
BEGIN
    IF @ToolID IS NULL
        PRINT 'Error: Tool ID is required.';
    ELSE IF NOT EXISTS (SELECT * FROM Tool WHERE ToolID = @ToolID)
        PRINT 'Error: Tool ' + CAST(@ToolID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF @Status IS NULL OR @Status NOT IN ('Approved', 'Under Review', 'Suspended')
        PRINT 'Error: Status must be Approved, Under Review or Suspended.';
    ELSE IF EXISTS (SELECT * FROM Tool WHERE ToolID = @ToolID AND Status = @Status)
        PRINT 'Error: Tool ' + CAST(@ToolID AS VARCHAR(10)) + ' is already ' + @Status + '.';
    ELSE
    BEGIN
        UPDATE Tool
        SET Status = @Status
        WHERE ToolID = @ToolID;

        PRINT 'Tool ' + CAST(@ToolID AS VARCHAR(10)) + ' is now ' + @Status + '.';
    END
END
GO

CREATE FUNCTION GetRemainingSeats (@SessionID INT)
RETURNS INT
AS
BEGIN
    DECLARE @Seats INT;

    IF EXISTS (SELECT * FROM Training_Session WHERE SessionID = @SessionID)
        SELECT @Seats = s.Capacity - (SELECT COUNT(*) FROM Session_Attendance sa WHERE sa.SessionID = s.SessionID)
        FROM Training_Session s
        WHERE s.SessionID = @SessionID;

    RETURN @Seats;
END
GO

CREATE FUNCTION ViewAvailableTrainingSessions (@ToolID INT)
RETURNS TABLE
AS
RETURN (
    SELECT s.SessionID,
           s.Title,
           s.SessionDate,
           CASE WHEN EXISTS (SELECT * FROM Online_Training o WHERE o.SessionID = s.SessionID) THEN 'Online'
                WHEN EXISTS (SELECT * FROM In_Person_Training p WHERE p.SessionID = s.SessionID) THEN 'In Person'
                ELSE NULL END AS Mode,
           s.Trainer,
           dbo.GetRemainingSeats(s.SessionID) AS RemainingSeats
    FROM Training_Session s
    WHERE s.ToolID = @ToolID
      AND s.Status = 'Scheduled'
      AND s.SessionDate >= CAST(GETDATE() AS DATE)
);
GO

CREATE PROCEDURE RegisterForTraining
    @SessionID INT,
    @MemberID  INT
AS
BEGIN
    IF @SessionID IS NULL OR @MemberID IS NULL
        PRINT 'Error: Session ID and member ID are required.';
    ELSE IF NOT EXISTS (SELECT * FROM Training_Session WHERE SessionID = @SessionID)
        PRINT 'Error: Session ' + CAST(@SessionID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF NOT EXISTS (SELECT * FROM Academic_Member WHERE MemberID = @MemberID AND AccountStatus = 'Active')
        PRINT 'Error: The account of member ' + CAST(@MemberID AS VARCHAR(10)) + ' is not active.';
    ELSE IF NOT EXISTS (SELECT * FROM Training_Session WHERE SessionID = @SessionID AND Status = 'Scheduled')
        PRINT 'Error: Session ' + CAST(@SessionID AS VARCHAR(10)) + ' is not open for registration.';
    ELSE IF EXISTS (SELECT * FROM Training_Session WHERE SessionID = @SessionID AND SessionDate < CAST(GETDATE() AS DATE))
        PRINT 'Error: Session ' + CAST(@SessionID AS VARCHAR(10)) + ' is in the past.';
    ELSE IF EXISTS (SELECT * FROM Session_Attendance WHERE SessionID = @SessionID AND MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is already registered for session '
              + CAST(@SessionID AS VARCHAR(10)) + '.';
    ELSE IF dbo.GetRemainingSeats(@SessionID) <= 0
        PRINT 'Error: Session ' + CAST(@SessionID AS VARCHAR(10)) + ' is full.';
    ELSE
    BEGIN
        INSERT INTO Session_Attendance (SessionID, MemberID)
        VALUES (@SessionID, @MemberID);

        PRINT 'Member ' + CAST(@MemberID AS VARCHAR(10)) + ' registered for session '
              + CAST(@SessionID AS VARCHAR(10)) + '. Remaining seats: '
              + CAST(dbo.GetRemainingSeats(@SessionID) AS VARCHAR(10)) + '.';
    END
END
GO

CREATE PROCEDURE CancelTrainingRegistration
    @SessionID INT,
    @MemberID  INT
AS
BEGIN
    IF @SessionID IS NULL OR @MemberID IS NULL
        PRINT 'Error: Session ID and member ID are required.';
    ELSE IF NOT EXISTS (SELECT * FROM Training_Session WHERE SessionID = @SessionID)
        PRINT 'Error: Session ' + CAST(@SessionID AS VARCHAR(10)) + ' does not exist.';
    ELSE IF NOT EXISTS (SELECT * FROM Session_Attendance WHERE SessionID = @SessionID AND MemberID = @MemberID)
        PRINT 'Error: Member ' + CAST(@MemberID AS VARCHAR(10)) + ' is not registered for session '
              + CAST(@SessionID AS VARCHAR(10)) + '.';
    ELSE IF EXISTS (SELECT * FROM Training_Session
                    WHERE SessionID = @SessionID
                      AND (Status <> 'Scheduled' OR SessionDate <= CAST(GETDATE() AS DATE)))
        PRINT 'Error: Session ' + CAST(@SessionID AS VARCHAR(10))
              + ' has already taken place or is not scheduled, so the registration cannot be cancelled.';
    ELSE
    BEGIN
        DELETE FROM Session_Attendance
        WHERE SessionID = @SessionID AND MemberID = @MemberID;

        PRINT 'Registration of member ' + CAST(@MemberID AS VARCHAR(10)) + ' in session '
              + CAST(@SessionID AS VARCHAR(10)) + ' cancelled.';
    END
END
GO

CREATE FUNCTION ViewMyTrainingHistory (@MemberID INT)
RETURNS TABLE
AS
RETURN (
    SELECT s.SessionID,
           s.Title,
           t.Name AS ToolName,
           s.SessionDate,
           CASE WHEN EXISTS (SELECT * FROM Online_Training o WHERE o.SessionID = s.SessionID) THEN 'Online'
                WHEN EXISTS (SELECT * FROM In_Person_Training p WHERE p.SessionID = s.SessionID) THEN 'In Person'
                ELSE NULL END AS Mode,
           s.Status
    FROM Session_Attendance sa
    JOIN Training_Session s ON s.SessionID = sa.SessionID
    JOIN Tool t ON t.ToolID = s.ToolID
    WHERE sa.MemberID = @MemberID
      AND s.Status <> 'Cancelled'
);
GO

CREATE FUNCTION ViewMyPendingTraining (@MemberID INT)
RETURNS TABLE
AS
RETURN (
    SELECT i.InitiativeID,
           i.Title AS InitiativeTitle,
           r.RequirementID,
           r.Description AS Requirement,
           t.Name AS ToolName,
           r.RequiredByDate
    FROM Initiative_Member im
    JOIN Innovation_Initiative i ON i.InitiativeID = im.InitiativeID
    JOIN Training_Requirement r ON r.InitiativeID = i.InitiativeID
    LEFT JOIN Tool t ON t.ToolID = r.ToolID
    WHERE im.MemberID = @MemberID
      AND r.IsMandatory = 1
      AND i.Status NOT IN ('Completed', 'Rejected')
      AND NOT EXISTS (SELECT *
                      FROM Session_Attendance sa
                      JOIN Training_Session s ON s.SessionID = sa.SessionID
                      WHERE sa.MemberID = @MemberID
                        AND s.Status <> 'Cancelled'
                        AND s.ToolID = r.ToolID)
);
GO
