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
------------------------

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