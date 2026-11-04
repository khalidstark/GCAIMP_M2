CREATE DATABASE GCAIMP;
GO
USE GCAIMP;
GO

CREATE TABLE Semester (
    SemesterID    INT IDENTITY(1,1) PRIMARY KEY,
    Name          VARCHAR(50) NOT NULL,
    AcademicYear  VARCHAR(50) NOT NULL,
    StartDate     DATE NOT NULL,
    EndDate       DATE NOT NULL,
    UNIQUE (Name, AcademicYear),
    CHECK (EndDate > StartDate)
);
GO

CREATE TABLE Course (
    CourseCode   VARCHAR(20) PRIMARY KEY,
    Title        VARCHAR(150) NOT NULL,
    Description  VARCHAR(1000) NULL,
    CreditHours  INT NOT NULL CHECK (CreditHours > 0),
    Level        VARCHAR(50) NULL
);
GO

CREATE TABLE Tool (
    ToolID       INT IDENTITY(1,1) PRIMARY KEY,
    Name         VARCHAR(150) NOT NULL UNIQUE,
    Description  VARCHAR(1000) NULL,
    Category     VARCHAR(50) NULL,
    Status       VARCHAR(50) NOT NULL DEFAULT 'Under Review'
                 CHECK (Status IN ('Approved', 'Under Review', 'Suspended'))
);
GO

CREATE TABLE Notification (
    NotificationID  INT IDENTITY(1,1) PRIMARY KEY,
    MessageContent  VARCHAR(1000) NOT NULL,
    CreatedAt       DATETIME NOT NULL DEFAULT GETDATE(),
    Urgency         VARCHAR(50) NULL CHECK (Urgency IN ('Low', 'Medium', 'High')),
    Category        VARCHAR(50) NULL
);
GO

CREATE TABLE Faculty (
    FacultyID          INT IDENTITY(1,1) PRIMARY KEY,
    Name               VARCHAR(150) NOT NULL UNIQUE,
    Description        VARCHAR(1000) NULL,
    EstablishmentDate  DATE NULL,
    DeanID             INT NULL
);
GO

CREATE TABLE Academic_Member (
    MemberID          INT IDENTITY(1,1) PRIMARY KEY,
    FullName          VARCHAR(150) NOT NULL,
    UniversityIDNo    VARCHAR(50) NOT NULL UNIQUE,
    Email             VARCHAR(150) NOT NULL UNIQUE,
    Phone             VARCHAR(50) NULL,
    AcademicRank      VARCHAR(50) NULL,
    EmploymentStatus  VARCHAR(50) NULL,
    AccountStatus     VARCHAR(50) NOT NULL DEFAULT 'Active'
                      CHECK (AccountStatus IN ('Active', 'Suspended', 'Deactivated')),
    FacultyID         INT NULL REFERENCES Faculty(FacultyID)
);
GO

CREATE TABLE Member_Access_Scope (
    MemberID     INT NOT NULL REFERENCES Academic_Member(MemberID) ON DELETE CASCADE,
    AccessScope  VARCHAR(50) NOT NULL,
    PRIMARY KEY (MemberID, AccessScope)
);
GO

CREATE TABLE Academic_Instructor (
    MemberID        INT PRIMARY KEY REFERENCES Academic_Member(MemberID) ON DELETE CASCADE,
    ResearchArea    VARCHAR(150) NULL,
    OfficeLocation  VARCHAR(50) NULL,
    TeachingLoad    INT NULL CHECK (TeachingLoad >= 0)
);
GO

CREATE TABLE Teaching_Assistant (
    MemberID        INT PRIMARY KEY REFERENCES Academic_Member(MemberID) ON DELETE CASCADE,
    AssistantLevel  VARCHAR(50) NULL,
    SupervisorID    INT NOT NULL REFERENCES Academic_Instructor(MemberID),
    CHECK (SupervisorID <> MemberID)
);
GO

CREATE TABLE Dean (
    MemberID                INT PRIMARY KEY REFERENCES Academic_Member(MemberID) ON DELETE CASCADE,
    ApprovalAuthorityScope  VARCHAR(150) NULL
);
GO

ALTER TABLE Faculty ADD FOREIGN KEY (DeanID) REFERENCES Dean(MemberID);
GO

CREATE TABLE University_Management (
    MemberID                INT PRIMARY KEY REFERENCES Academic_Member(MemberID) ON DELETE CASCADE,
    ManagementTitle         VARCHAR(150) NULL,
    DecisionAuthorityLevel  VARCHAR(50) NULL,
    GovernanceScope         VARCHAR(150) NULL
);
GO

CREATE TABLE Curriculum_Reviewer (
    MemberID              INT PRIMARY KEY REFERENCES Academic_Member(MemberID) ON DELETE CASCADE,
    ReviewDomain          VARCHAR(150) NULL,
    ReviewAuthorityLevel  VARCHAR(50) NULL
);
GO

CREATE TABLE Reviewer_Committee (
    MemberID             INT NOT NULL REFERENCES Curriculum_Reviewer(MemberID) ON DELETE CASCADE,
    CommitteeMembership  VARCHAR(150) NOT NULL,
    PRIMARY KEY (MemberID, CommitteeMembership)
);
GO

CREATE TABLE Dean_Term (
    DeanID      INT NOT NULL REFERENCES Dean(MemberID) ON DELETE CASCADE,
    SemesterID  INT NOT NULL REFERENCES Semester(SemesterID),
    PRIMARY KEY (DeanID, SemesterID)
);
GO

CREATE TABLE Program (
    ProgramID         INT IDENTITY(1,1) PRIMARY KEY,
    Name              VARCHAR(150) NOT NULL,
    DegreeLevel       VARCHAR(50) NULL,
    TotalCreditHours  INT NULL CHECK (TotalCreditHours > 0),
    StandardDuration  VARCHAR(50) NULL,
    Description       VARCHAR(1000) NULL,
    FacultyID         INT NOT NULL REFERENCES Faculty(FacultyID),
    UNIQUE (FacultyID, Name)
);
GO

CREATE TABLE PLO (
    ProgramID  INT NOT NULL REFERENCES Program(ProgramID) ON DELETE CASCADE,
    PLOCode    VARCHAR(20) NOT NULL,
    Statement  VARCHAR(1000) NOT NULL,
    Category   VARCHAR(50) NULL,
    PRIMARY KEY (ProgramID, PLOCode)
);
GO

CREATE TABLE Curriculum_Version (
    ProgramID        INT NOT NULL REFERENCES Program(ProgramID) ON DELETE CASCADE,
    VersionLabel     VARCHAR(20) NOT NULL,
    AcademicYear     VARCHAR(50) NOT NULL,
    EffectivePeriod  VARCHAR(50) NULL,
    Status           VARCHAR(50) NOT NULL DEFAULT 'Draft'
                     CHECK (Status IN ('Draft', 'Active', 'Archived')),
    ApprovalDate     DATE NULL,
    PRIMARY KEY (ProgramID, VersionLabel, AcademicYear)
);
GO

CREATE TABLE Core_Course (
    CourseCode            VARCHAR(20) PRIMARY KEY REFERENCES Course(CourseCode) ON DELETE CASCADE,
    DefaultStudySemester  INT NULL CHECK (DefaultStudySemester > 0),
    RequiredForProgram    VARCHAR(150) NULL
);
GO

CREATE TABLE Elective_Course (
    CourseCode        VARCHAR(20) PRIMARY KEY REFERENCES Course(CourseCode) ON DELETE CASCADE,
    ElectivePool      VARCHAR(150) NULL,
    MinSelectionRule  VARCHAR(150) NULL
);
GO

CREATE TABLE Version_Course (
    ProgramID        INT NOT NULL,
    VersionLabel     VARCHAR(20) NOT NULL,
    AcademicYear     VARCHAR(50) NOT NULL,
    CourseCode       VARCHAR(20) NOT NULL REFERENCES Course(CourseCode),
    StudySemesterNo  INT NOT NULL CHECK (StudySemesterNo > 0),
    IsMandatory      BIT NOT NULL DEFAULT 1,
    PRIMARY KEY (ProgramID, VersionLabel, AcademicYear, CourseCode),
    FOREIGN KEY (ProgramID, VersionLabel, AcademicYear)
        REFERENCES Curriculum_Version(ProgramID, VersionLabel, AcademicYear)
);
GO

CREATE TABLE Course_Requisite (
    CourseCode     VARCHAR(20) NOT NULL REFERENCES Course(CourseCode) ON DELETE CASCADE,
    RequisiteCode  VARCHAR(20) NOT NULL REFERENCES Course(CourseCode),
    RequisiteType  VARCHAR(50) NOT NULL CHECK (RequisiteType IN ('Prerequisite', 'Co-requisite')),
    PRIMARY KEY (CourseCode, RequisiteCode),
    CHECK (CourseCode <> RequisiteCode)
);
GO

CREATE TABLE ILO (
    CourseCode      VARCHAR(20) NOT NULL REFERENCES Course(CourseCode) ON DELETE CASCADE,
    ILOCode         VARCHAR(20) NOT NULL,
    Statement       VARCHAR(1000) NOT NULL,
    CognitiveLevel  VARCHAR(50) NULL,
    PRIMARY KEY (CourseCode, ILOCode)
);
GO

CREATE TABLE Course_Offering (
    CourseCode     VARCHAR(20) NOT NULL REFERENCES Course(CourseCode) ON DELETE CASCADE,
    SemesterID     INT NOT NULL REFERENCES Semester(SemesterID) ON DELETE CASCADE,
    SectionID      VARCHAR(20) NOT NULL,
    DeliveryMode   VARCHAR(50) NULL,
    EnrolledCount  INT NOT NULL DEFAULT 0 CHECK (EnrolledCount >= 0),
    Status         VARCHAR(50) NULL,
    InstructorID   INT NOT NULL REFERENCES Academic_Instructor(MemberID),
    PRIMARY KEY (CourseCode, SemesterID, SectionID)
);
GO

CREATE TABLE Offering_TA (
    CourseCode  VARCHAR(20) NOT NULL,
    SemesterID  INT NOT NULL,
    SectionID   VARCHAR(20) NOT NULL,
    TAID        INT NOT NULL REFERENCES Teaching_Assistant(MemberID),
    PRIMARY KEY (CourseCode, SemesterID, SectionID, TAID),
    FOREIGN KEY (CourseCode, SemesterID, SectionID)
        REFERENCES Course_Offering(CourseCode, SemesterID, SectionID)
);
GO

CREATE TABLE Outcome_Mapping (
    MappingID          INT IDENTITY(1,1) PRIMARY KEY,
    CoverageLevel      VARCHAR(50) NOT NULL CHECK (CoverageLevel IN ('Introduced', 'Reinforced', 'Mastered')),
    IsAssessmentPoint  BIT NOT NULL DEFAULT 0,
    MappingStatus      VARCHAR(50) NOT NULL DEFAULT 'Pending'
                       CHECK (MappingStatus IN ('Pending', 'Approved', 'Rejected')),
    CourseCode         VARCHAR(20) NOT NULL,
    ILOCode            VARCHAR(20) NOT NULL,
    ProgramID          INT NOT NULL,
    PLOCode            VARCHAR(20) NOT NULL,
    UNIQUE (CourseCode, ILOCode, ProgramID, PLOCode),
    FOREIGN KEY (CourseCode, ILOCode) REFERENCES ILO(CourseCode, ILOCode),
    FOREIGN KEY (ProgramID, PLOCode) REFERENCES PLO(ProgramID, PLOCode)
);
GO

CREATE TABLE Outcome_Assessment (
    AssessmentID      INT IDENTITY(1,1) PRIMARY KEY,
    Instrument        VARCHAR(150) NOT NULL,
    Description       VARCHAR(1000) NULL,
    TargetThreshold   DECIMAL(10,2) NOT NULL CHECK (TargetThreshold >= 0),
    AttainedValue     DECIMAL(10,2) NOT NULL CHECK (AttainedValue >= 0),
    SampleSize        INT NULL CHECK (SampleSize > 0),
    TargetMet         AS (CASE WHEN AttainedValue >= TargetThreshold THEN 1 ELSE 0 END),
    AnalysisNotes     VARCHAR(1000) NULL,
    CorrectiveAction  VARCHAR(1000) NULL,
    CourseCode        VARCHAR(20) NOT NULL,
    ILOCode           VARCHAR(20) NOT NULL,
    SemesterID        INT NOT NULL,
    SectionID         VARCHAR(20) NOT NULL,
    MappingID         INT NOT NULL REFERENCES Outcome_Mapping(MappingID),
    FOREIGN KEY (CourseCode, ILOCode) REFERENCES ILO(CourseCode, ILOCode),
    FOREIGN KEY (CourseCode, SemesterID, SectionID)
        REFERENCES Course_Offering(CourseCode, SemesterID, SectionID)
);
GO

CREATE TABLE Modification_Proposal (
    ProposalID            INT IDENTITY(1,1) PRIMARY KEY,
    Title                 VARCHAR(150) NOT NULL,
    Rationale             VARCHAR(1000) NOT NULL,
    ModificationType      VARCHAR(50) NOT NULL,
    CurrentStateSummary   VARCHAR(1000) NULL,
    ProposedStateSummary  VARCHAR(1000) NULL,
    SubmissionDate        DATETIME NOT NULL DEFAULT GETDATE(),
    ProposerID            INT NOT NULL REFERENCES Academic_Instructor(MemberID),
    CourseCode            VARCHAR(20) NOT NULL REFERENCES Course(CourseCode),
    ProgramID             INT NOT NULL REFERENCES Program(ProgramID),
    VersionLabel          VARCHAR(20) NOT NULL,
    AcademicYear          VARCHAR(50) NOT NULL,
    AssessmentID          INT NULL REFERENCES Outcome_Assessment(AssessmentID),
    FOREIGN KEY (ProgramID, VersionLabel, AcademicYear)
        REFERENCES Curriculum_Version(ProgramID, VersionLabel, AcademicYear)
);
GO

CREATE TABLE Innovation_Initiative (
    InitiativeID            INT IDENTITY(1,1) PRIMARY KEY,
    Title                   VARCHAR(150) NOT NULL,
    Description             VARCHAR(1000) NULL,
    Motivation              VARCHAR(1000) NULL,
    RegistrationDate        DATE NOT NULL DEFAULT GETDATE(),
    ImplementationDeadline  DATE NULL,
    Status                  VARCHAR(50) NOT NULL DEFAULT 'Draft'
                            CHECK (Status IN ('Draft', 'Pending Approval', 'Returned', 'Approved', 'Rejected',
                                              'Escalated', 'In Progress', 'Completed')),
    CourseCode              VARCHAR(20) NOT NULL,
    SemesterID              INT NOT NULL,
    SectionID               VARCHAR(20) NOT NULL,
    FacultyID               INT NOT NULL REFERENCES Faculty(FacultyID),
    SubmitterID             INT NOT NULL REFERENCES Academic_Member(MemberID),
    TargetStartSemesterID   INT NOT NULL REFERENCES Semester(SemesterID),
    AssessmentID            INT NULL REFERENCES Outcome_Assessment(AssessmentID),
    FOREIGN KEY (CourseCode, SemesterID, SectionID)
        REFERENCES Course_Offering(CourseCode, SemesterID, SectionID),
    CHECK (ImplementationDeadline >= RegistrationDate)
);
GO

CREATE TABLE AI_Tool_Integration (
    InitiativeID            INT PRIMARY KEY REFERENCES Innovation_Initiative(InitiativeID) ON DELETE CASCADE,
    IntegrationObjective    VARCHAR(1000) NULL,
    ToolCategory            VARCHAR(50) NULL,
    DataPrivacyNotes        VARCHAR(1000) NULL,
    AcademicIntegrityNotes  VARCHAR(1000) NULL
);
GO

CREATE TABLE Methodology_Change (
    InitiativeID         INT PRIMARY KEY REFERENCES Innovation_Initiative(InitiativeID) ON DELETE CASCADE,
    PedagogicalApproach  VARCHAR(150) NULL,
    DeliveryChange       VARCHAR(1000) NULL,
    ReferenceFramework   VARCHAR(150) NULL
);
GO

CREATE TABLE Assessment_Redesign (
    InitiativeID            INT PRIMARY KEY REFERENCES Innovation_Initiative(InitiativeID) ON DELETE CASCADE,
    AssessmentTypeAffected  VARCHAR(50) NULL,
    RubricWeightingChanges  VARCHAR(1000) NULL,
    FairnessSafeguards      VARCHAR(1000) NULL
);
GO

CREATE TABLE Initiative_Member (
    InitiativeID  INT NOT NULL REFERENCES Innovation_Initiative(InitiativeID),
    MemberID      INT NOT NULL REFERENCES Academic_Member(MemberID),
    Role          VARCHAR(50) NOT NULL,
    PRIMARY KEY (InitiativeID, MemberID)
);
GO

CREATE TABLE Approval_Record (
    ApprovalID     INT IDENTITY(1,1) PRIMARY KEY,
    Decision       VARCHAR(50) NOT NULL CHECK (Decision IN ('Approved', 'Rejected', 'Returned', 'Escalated')),
    DecisionLevel  VARCHAR(50) NOT NULL CHECK (DecisionLevel IN ('Reviewer', 'Dean', 'University')),
    DecisionDate   DATETIME NOT NULL DEFAULT GETDATE(),
    Comments       VARCHAR(1000) NULL,
    DeciderID      INT NOT NULL REFERENCES Academic_Member(MemberID),
    ProposalID     INT NULL REFERENCES Modification_Proposal(ProposalID),
    InitiativeID   INT NULL REFERENCES Innovation_Initiative(InitiativeID),
    CHECK ((ProposalID IS NULL AND InitiativeID IS NOT NULL)
                                       OR (ProposalID IS NOT NULL AND InitiativeID IS NULL))
);
GO

CREATE TABLE AI_Tool (
    ToolID        INT PRIMARY KEY REFERENCES Tool(ToolID) ON DELETE CASCADE,
    Provider      VARCHAR(150) NULL,
    ModelVersion  VARCHAR(50) NULL,
    LicenseType   VARCHAR(50) NULL,
    HostingMode   VARCHAR(50) NULL,
    CostModel     VARCHAR(50) NULL
);
GO

CREATE TABLE Teaching_Methodology (
    ToolID                INT PRIMARY KEY REFERENCES Tool(ToolID) ON DELETE CASCADE,
    OriginatingFramework  VARCHAR(150) NULL,
    ReferenceSource       VARCHAR(150) NULL,
    RequiredResources     VARCHAR(1000) NULL
);
GO

CREATE TABLE Initiative_Tool (
    InitiativeID  INT NOT NULL REFERENCES Innovation_Initiative(InitiativeID),
    ToolID        INT NOT NULL REFERENCES Tool(ToolID),
    PRIMARY KEY (InitiativeID, ToolID)
);
GO

CREATE TABLE Milestone (
    InitiativeID    INT NOT NULL REFERENCES Innovation_Initiative(InitiativeID) ON DELETE CASCADE,
    SeqNo           INT NOT NULL CHECK (SeqNo > 0),
    Title           VARCHAR(150) NOT NULL,
    Description     VARCHAR(1000) NULL,
    DueDate         DATE NOT NULL,
    CompletionDate  DATE NULL,
    Status          VARCHAR(50) NOT NULL DEFAULT 'Pending'
                    CHECK (Status IN ('Pending', 'In Progress', 'Delayed', 'Completed')),
    PRIMARY KEY (InitiativeID, SeqNo)
);
GO

CREATE TABLE Evidence (
    EvidenceID      INT IDENTITY(1,1) PRIMARY KEY,
    Title           VARCHAR(150) NOT NULL,
    ArtifactType    VARCHAR(50) NULL,
    FilePathOrURL   VARCHAR(1000) NOT NULL,
    UploadDate      DATE NOT NULL DEFAULT GETDATE(),
    Description     VARCHAR(1000) NULL,
    InitiativeID    INT NOT NULL REFERENCES Innovation_Initiative(InitiativeID),
    MilestoneSeqNo  INT NULL,
    FOREIGN KEY (InitiativeID, MilestoneSeqNo) REFERENCES Milestone(InitiativeID, SeqNo)
);
GO

CREATE TABLE Outcome_Report (
    ReportID            INT IDENTITY(1,1) PRIMARY KEY,
    MetricType          VARCHAR(50) NOT NULL,
    QuantitativeValue   DECIMAL(10,2) NULL,
    BaselineValue       DECIMAL(10,2) NULL,
    QualitativeSummary  VARCHAR(1000) NULL,
    InitiativeID        INT NOT NULL REFERENCES Innovation_Initiative(InitiativeID),
    SemesterID          INT NOT NULL REFERENCES Semester(SemesterID)
);
GO

CREATE TABLE Student_Feedback (
    FeedbackID         INT IDENTITY(1,1) PRIMARY KEY,
    Rating             INT NOT NULL CHECK (Rating BETWEEN 1 AND 5),
    Comment            VARCHAR(1000) NULL,
    CategorySentiment  VARCHAR(50) NULL,
    CollectionMethod   VARCHAR(50) NULL,
    InitiativeID       INT NOT NULL REFERENCES Innovation_Initiative(InitiativeID),
    SemesterID         INT NOT NULL REFERENCES Semester(SemesterID)
);
GO

CREATE TABLE Training_Session (
    SessionID        INT IDENTITY(1,1) PRIMARY KEY,
    Title            VARCHAR(150) NOT NULL,
    Topic            VARCHAR(150) NULL,
    Description      VARCHAR(1000) NULL,
    SessionDate      DATE NOT NULL,
    DurationMinutes  INT NULL CHECK (DurationMinutes > 0),
    Trainer          VARCHAR(150) NULL,
    Capacity         INT NOT NULL CHECK (Capacity > 0),
    Status           VARCHAR(50) NOT NULL DEFAULT 'Scheduled'
                     CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled')),
    ToolID           INT NOT NULL REFERENCES Tool(ToolID)
);
GO

CREATE TABLE Online_Training (
    SessionID           INT PRIMARY KEY REFERENCES Training_Session(SessionID) ON DELETE CASCADE,
    Platform            VARCHAR(50) NULL,
    MeetingLink         VARCHAR(1000) NULL,
    RecordingAvailable  BIT NOT NULL DEFAULT 0
);
GO

CREATE TABLE In_Person_Training (
    SessionID          INT PRIMARY KEY REFERENCES Training_Session(SessionID) ON DELETE CASCADE,
    Venue              VARCHAR(150) NULL,
    Campus             VARCHAR(50) NULL,
    RequiredEquipment  VARCHAR(1000) NULL
);
GO

CREATE TABLE Session_Attendance (
    SessionID  INT NOT NULL REFERENCES Training_Session(SessionID),
    MemberID   INT NOT NULL REFERENCES Academic_Member(MemberID),
    PRIMARY KEY (SessionID, MemberID)
);
GO

CREATE TABLE Training_Requirement (
    RequirementID   INT IDENTITY(1,1) PRIMARY KEY,
    Description     VARCHAR(1000) NOT NULL,
    TargetAudience  VARCHAR(150) NULL,
    RequiredByDate  DATE NULL,
    IsMandatory     BIT NOT NULL DEFAULT 1,
    InitiativeID    INT NOT NULL REFERENCES Innovation_Initiative(InitiativeID),
    ToolID          INT NULL REFERENCES Tool(ToolID)
);
GO

CREATE TABLE Accreditation_Review (
    ReviewID         INT IDENTITY(1,1) PRIMARY KEY,
    AccreditingBody  VARCHAR(150) NOT NULL,
    ReviewType       VARCHAR(50) NULL,
    ReviewCycle      VARCHAR(50) NULL,
    Status           VARCHAR(50) NOT NULL DEFAULT 'Open',
    Decision         VARCHAR(50) NULL,
    SubmissionDate   DATE NULL,
    NextReviewDue    DATE NULL,
    ProgramID        INT NOT NULL REFERENCES Program(ProgramID)
);
GO

CREATE TABLE Review_Mapping (
    ReviewID   INT NOT NULL REFERENCES Accreditation_Review(ReviewID),
    MappingID  INT NOT NULL REFERENCES Outcome_Mapping(MappingID),
    PRIMARY KEY (ReviewID, MappingID)
);
GO

CREATE TABLE Review_Assessment (
    ReviewID      INT NOT NULL REFERENCES Accreditation_Review(ReviewID),
    AssessmentID  INT NOT NULL REFERENCES Outcome_Assessment(AssessmentID),
    PRIMARY KEY (ReviewID, AssessmentID)
);
GO

CREATE TABLE Review_Evidence (
    ReviewID    INT NOT NULL REFERENCES Accreditation_Review(ReviewID),
    EvidenceID  INT NOT NULL REFERENCES Evidence(EvidenceID),
    PRIMARY KEY (ReviewID, EvidenceID)
);
GO

CREATE TABLE Notification_Recipient (
    NotificationID  INT NOT NULL REFERENCES Notification(NotificationID) ON DELETE CASCADE,
    MemberID        INT NOT NULL REFERENCES Academic_Member(MemberID) ON DELETE CASCADE,
    ReadStatus      BIT NOT NULL DEFAULT 0,
    PRIMARY KEY (NotificationID, MemberID)
);
GO

CREATE TABLE Audit_Log (
    LogID          INT IDENTITY(1,1) PRIMARY KEY,
    ActionType     VARCHAR(50) NOT NULL,
    LoggedAt       DATETIME NOT NULL DEFAULT GETDATE(),
    ChangeSummary  VARCHAR(1000) NULL,
    ActorID        INT NOT NULL REFERENCES Academic_Member(MemberID),
    ProposalID     INT NULL REFERENCES Modification_Proposal(ProposalID),
    ApprovalID     INT NULL REFERENCES Approval_Record(ApprovalID),
    InitiativeID   INT NULL REFERENCES Innovation_Initiative(InitiativeID),
    AssessmentID   INT NULL REFERENCES Outcome_Assessment(AssessmentID),
    EvidenceID     INT NULL REFERENCES Evidence(EvidenceID)
);
GO
