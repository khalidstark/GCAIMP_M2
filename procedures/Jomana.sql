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
