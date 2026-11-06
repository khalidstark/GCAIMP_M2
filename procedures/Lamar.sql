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