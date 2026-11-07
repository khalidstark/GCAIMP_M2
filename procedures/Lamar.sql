-- Lamar's procedures
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
-----------------------------------------------------------------------------------------------------------------------------

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
----------------------------------------------------------------------------------------------------------------------------

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
------------------------------------------------------------------------------------------------------------------------------

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

----------------------------------------------------------------------------------------------------------------------------

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
--------------------------------------------------------------------------------------------------------------------------------
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

--------------------------------------------------------------------

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
 ----------------------------------------------------------------------------------------------------------------------------------- 

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

-------------------------------------------------------------------------------------------------------------------------------------------

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

--------------------------------------------------------------------------------------------------------------------------------------------------------

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
      ON o.CurseCode = n.CourseCode
    WHERE o.CourseCode IS NULL
       OR n.CourseCode IS NULL
       OR o.StudySemesterNo <> n.StudySemesterNo;
GO

 -----------------------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------------------------------------------------------

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
 ----------------------------------------------------------------------------------------------------------------------------------------------------

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
-----------------------------------------------------------------------------------------------------------------------------------------------------
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

-----------------------------------------------------------------------------------------------------------------------------------------------------

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

 ----------------------------------------------------------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------------------------------------------------------

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

-----------------------------------------------------------------------------------------------------------------------------------------------------

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