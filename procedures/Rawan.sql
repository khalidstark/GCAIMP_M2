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
