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