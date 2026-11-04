USE GCAIMP;
GO

INSERT INTO Semester (Name, AcademicYear, StartDate, EndDate) VALUES
('Winter', '2025-2026', '2025-09-20', '2026-01-31'),
('Spring', '2025-2026', '2026-02-14', '2026-06-30'),
('Winter', '2026-2027', '2026-09-19', '2027-01-30'),
('Spring', '2026-2027', '2027-02-13', '2027-06-30');
GO

INSERT INTO Course (CourseCode, Title, Description, CreditHours, Level) VALUES
('CSEN202', 'Introduction to Programming', 'Basics of structured programming', 4, 'Year 1'),
('MATH203', 'Discrete Mathematics', 'Logic, sets, graphs and counting', 3, 'Year 1'),
('CSEN301', 'Data Structures and Algorithms', 'Lists, trees, graphs, complexity', 4, 'Year 2'),
('BINF301', 'Business Informatics', 'Modelling business processes', 3, 'Year 2'),
('CSEN501', 'Database I', 'EER modelling, relational model, SQL', 4, 'Year 3'),
('CSEN502', 'Software Engineering', 'Agile development and testing', 4, 'Year 3'),
('BINF402', 'Enterprise Systems', 'ERP and enterprise architecture', 3, 'Year 3'),
('DMET501', 'Media Design', 'Visual and interaction design', 3, 'Year 3'),
('CSEN601', 'Machine Learning', 'Supervised and unsupervised learning', 4, 'Year 4'),
('CSEN602', 'Computer Networks', 'Network layers and protocols', 4, 'Year 4');
GO

INSERT INTO Tool (Name, Description, Category, Status) VALUES
('ChatGPT Edu', 'Generative AI assistant licensed for teaching', 'Generative AI', 'Approved'),
('GitHub Copilot', 'AI pair programmer for programming courses', 'Code Assistant', 'Approved'),
('Flipped Classroom', 'Students watch lectures before class, class time is for practice', 'Pedagogy', 'Approved'),
('Problem-Based Learning', 'Learning driven by realistic open problems', 'Pedagogy', 'Approved'),
('AutoGrader AI', 'Automatic grading of written answers', 'Assessment', 'Suspended');
GO

INSERT INTO Notification (MessageContent, CreatedAt, Urgency, Category) VALUES
('Training session "ChatGPT Edu for Course Design" is now full', '2026-10-30 10:00', 'Medium', 'Training'),
('Your proposal "Revise Database I ILOs" was returned for revision', '2026-10-12 14:30', 'High', 'Approval'),
('Milestone "Pilot in two lab groups" is overdue', '2026-10-27 09:00', 'High', 'Milestone'),
('Accreditation review for Computer Science is due on 2026-11-25', '2026-10-26 08:00', 'High', 'Accreditation'),
('New university policy on AI tools in teaching', '2026-09-15 12:00', 'Low', 'Announcement');
GO

INSERT INTO Faculty (Name, Description, EstablishmentDate, DeanID) VALUES
('Informatics and Computer Science', 'Computer science, media engineering and business informatics programs', '2019-09-01', NULL),
('Business Administration', 'Business and management programs', '2019-09-01', NULL),
('Design', 'Design and architecture programs', '2021-09-01', NULL);
GO

INSERT INTO Academic_Member (FullName, UniversityIDNo, Email, Phone, AcademicRank, EmploymentStatus, AccountStatus, FacultyID) VALUES
('Hany Elsayed',   'GIU-0001', 'hany.elsayed@giu-uni.de',   '01000000001', 'Professor',           'Full-Time', 'Active',    1),
('Mona Farouk',    'GIU-0002', 'mona.farouk@giu-uni.de',    '01000000002', 'Professor',           'Full-Time', 'Active',    2),
('Ahmed Nabil',    'GIU-0003', 'ahmed.nabil@giu-uni.de',    '01000000003', 'Associate Professor', 'Full-Time', 'Active',    1),
('Sara Hamdy',     'GIU-0004', 'sara.hamdy@giu-uni.de',     '01000000004', 'Assistant Professor', 'Full-Time', 'Active',    1),
('Omar Fathy',     'GIU-0005', 'omar.fathy@giu-uni.de',     '01000000005', 'Assistant Professor', 'Full-Time', 'Active',    2),
('Nour Adel',      'GIU-0006', 'nour.adel@giu-uni.de',      '01000000006', 'Associate Professor', 'Full-Time', 'Active',    1),
('Youssef Samir',  'GIU-0007', 'youssef.samir@giu-uni.de',  '01000000007', 'Teaching Assistant',  'Full-Time', 'Active',    1),
('Mariam Tarek',   'GIU-0008', 'mariam.tarek@giu-uni.de',   '01000000008', 'Teaching Assistant',  'Full-Time', 'Active',    1),
('Karim Hassan',   'GIU-0009', 'karim.hassan@giu-uni.de',   '01000000009', 'Teaching Assistant',  'Part-Time', 'Active',    2),
('Laila Mostafa',  'GIU-0010', 'laila.mostafa@giu-uni.de',  '01000000010', 'Professor',           'Full-Time', 'Active',    1),
('Tamer Ali',      'GIU-0011', 'tamer.ali@giu-uni.de',      '01000000011', 'Associate Professor', 'Full-Time', 'Active',    2),
('Hossam Kamel',   'GIU-0012', 'hossam.kamel@giu-uni.de',   '01000000012', 'Professor',           'Full-Time', 'Active',    NULL),
('Dina Ibrahim',   'GIU-0013', 'dina.ibrahim@giu-uni.de',   '01000000013', 'Professor',           'Full-Time', 'Active',    NULL),
('Walid Sherif',   'GIU-0014', 'walid.sherif@giu-uni.de',   '01000000014', 'Lecturer',            'Part-Time', 'Suspended', 2),
('Rana Magdy',     'GIU-0015', 'rana.magdy@giu-uni.de',     '01000000015', 'Lecturer',            'Full-Time', 'Active',    1);
GO

INSERT INTO Member_Access_Scope (MemberID, AccessScope) VALUES
(1, 'Approve Initiatives'), (1, 'Approve Proposals'),
(2, 'Approve Initiatives'), (2, 'Approve Proposals'),
(3, 'Submit Proposals'), (4, 'Submit Proposals'), (5, 'Submit Proposals'),
(6, 'Submit Proposals'), (6, 'Review Mappings'),
(10, 'Review Mappings'), (11, 'Review Mappings'),
(12, 'Approve Initiatives');
GO

INSERT INTO Academic_Instructor (MemberID, ResearchArea, OfficeLocation, TeachingLoad) VALUES
(3,  'Databases', 'C3.201', 2),
(4,  'Algorithms', 'C3.205', 1),
(5,  'Information Systems', 'B2.110', 1),
(6,  'Artificial Intelligence', 'C3.210', 1),
(14, 'Enterprise Systems', 'B2.115', 0);
GO

INSERT INTO Teaching_Assistant (MemberID, AssistantLevel, SupervisorID) VALUES
(7, 'Junior', 3),
(8, 'Senior', 4),
(9, 'Junior', 5);
GO

INSERT INTO Dean (MemberID, ApprovalAuthorityScope) VALUES
(1, 'Faculty proposals and initiatives'),
(2, 'Faculty proposals and initiatives');
GO

UPDATE Faculty SET DeanID = 1 WHERE FacultyID = 1;
UPDATE Faculty SET DeanID = 2 WHERE FacultyID = 2;
GO

INSERT INTO University_Management (MemberID, ManagementTitle, DecisionAuthorityLevel, GovernanceScope) VALUES
(12, 'University President', 'Final', 'University-wide'),
(13, 'Vice President for Academic Affairs', 'High', 'Academic programs');
GO

INSERT INTO Curriculum_Reviewer (MemberID, ReviewDomain, ReviewAuthorityLevel) VALUES
(6,  'Artificial Intelligence courses', 'Course'),
(10, 'Computer Science curriculum', 'Program'),
(11, 'Business Informatics curriculum', 'Program');
GO

INSERT INTO Reviewer_Committee (MemberID, CommitteeMembership) VALUES
(6, 'CS Curriculum Committee'),
(10, 'CS Curriculum Committee'),
(10, 'Quality Assurance Committee'),
(11, 'BI Curriculum Committee');
GO

INSERT INTO Dean_Term (DeanID, SemesterID) VALUES
(1, 1), (1, 2), (1, 3),
(2, 2), (2, 3);
GO

INSERT INTO Program (Name, DegreeLevel, TotalCreditHours, StandardDuration, Description, FacultyID) VALUES
('Computer Science', 'Bachelor', 136, '4 years', 'BSc in Computer Science', 1),
('Media Engineering and Technology', 'Bachelor', 140, '4 years', 'BSc in Media Engineering', 1),
('Business Informatics', 'Bachelor', 130, '4 years', 'BSc in Business Informatics', 2);
GO

INSERT INTO PLO (ProgramID, PLOCode, Statement, Category) VALUES
(1, 'PLO1', 'Apply mathematics and computing theory to solve problems', 'Knowledge'),
(1, 'PLO2', 'Design and implement software systems', 'Skills'),
(1, 'PLO3', 'Communicate and work effectively in teams', 'Competence'),
(1, 'PLO4', 'Act ethically and professionally', 'Competence'),
(2, 'PLO1', 'Design interactive media systems', 'Skills'),
(3, 'PLO1', 'Analyze and model business processes', 'Skills'),
(3, 'PLO2', 'Select enterprise systems for an organization', 'Knowledge');
GO

INSERT INTO Curriculum_Version (ProgramID, VersionLabel, AcademicYear, EffectivePeriod, Status, ApprovalDate) VALUES
(1, 'v1', '2024-2025', '2024-09-01 to 2025-08-31', 'Archived', '2024-07-15'),
(1, 'v2', '2025-2026', '2025-09-01 to 2026-08-31', 'Active',   '2025-07-20'),
(1, 'v3', '2026-2027', '2026-09-01 to 2027-08-31', 'Draft',    NULL),
(2, 'v1', '2025-2026', '2025-09-01 to 2026-08-31', 'Active',   '2025-07-20'),
(3, 'v1', '2025-2026', '2025-09-01 to 2026-08-31', 'Active',   '2025-07-22');
GO

INSERT INTO Core_Course (CourseCode, DefaultStudySemester, RequiredForProgram) VALUES
('CSEN202', 1, 'Computer Science'),
('MATH203', 2, 'Computer Science'),
('CSEN301', 3, 'Computer Science'),
('BINF301', 3, 'Business Informatics'),
('CSEN501', 5, 'Computer Science'),
('CSEN502', 6, 'Computer Science'),
('CSEN601', 7, 'Computer Science');
GO

INSERT INTO Elective_Course (CourseCode, ElectivePool, MinSelectionRule) VALUES
('CSEN601', 'AI Electives', 'Choose 1 of 3'),
('CSEN602', 'Systems Electives', 'Choose 2 of 4'),
('BINF402', 'Business Electives', 'Choose 1 of 2'),
('DMET501', 'Media Electives', 'Choose 1 of 3'),
('CSEN502', 'Software Electives', 'Choose 1 of 2');
GO

INSERT INTO Version_Course (ProgramID, VersionLabel, AcademicYear, CourseCode, StudySemesterNo, IsMandatory) VALUES
(1, 'v1', '2024-2025', 'CSEN202', 1, 1),
(1, 'v1', '2024-2025', 'MATH203', 2, 1),
(1, 'v1', '2024-2025', 'CSEN301', 3, 1),
(1, 'v1', '2024-2025', 'CSEN501', 5, 1),
(1, 'v1', '2024-2025', 'CSEN502', 6, 1),
(1, 'v1', '2024-2025', 'CSEN602', 7, 0),
(1, 'v2', '2025-2026', 'CSEN202', 1, 1),
(1, 'v2', '2025-2026', 'MATH203', 2, 1),
(1, 'v2', '2025-2026', 'CSEN301', 3, 1),
(1, 'v2', '2025-2026', 'CSEN501', 4, 1),
(1, 'v2', '2025-2026', 'CSEN502', 6, 1),
(1, 'v2', '2025-2026', 'CSEN601', 7, 1),
(1, 'v3', '2026-2027', 'CSEN202', 1, 1),
(1, 'v3', '2026-2027', 'MATH203', 2, 1),
(1, 'v3', '2026-2027', 'CSEN301', 3, 1),
(1, 'v3', '2026-2027', 'CSEN501', 4, 1),
(1, 'v3', '2026-2027', 'CSEN502', 6, 1),
(1, 'v3', '2026-2027', 'CSEN601', 7, 1),
(1, 'v3', '2026-2027', 'CSEN602', 8, 0),
(2, 'v1', '2025-2026', 'CSEN202', 1, 1),
(2, 'v1', '2025-2026', 'DMET501', 5, 0),
(3, 'v1', '2025-2026', 'CSEN202', 1, 1),
(3, 'v1', '2025-2026', 'BINF301', 3, 1),
(3, 'v1', '2025-2026', 'BINF402', 5, 0);
GO

INSERT INTO Course_Requisite (CourseCode, RequisiteCode, RequisiteType) VALUES
('CSEN301', 'CSEN202', 'Prerequisite'),
('CSEN501', 'CSEN301', 'Prerequisite'),
('CSEN601', 'MATH203', 'Prerequisite'),
('CSEN502', 'CSEN501', 'Co-requisite'),
('BINF402', 'BINF301', 'Prerequisite');
GO

INSERT INTO ILO (CourseCode, ILOCode, Statement, CognitiveLevel) VALUES
('CSEN501', 'ILO1', 'Design a relational schema from an EER diagram', 'Create'),
('CSEN501', 'ILO2', 'Write SQL queries to answer business questions', 'Apply'),
('CSEN501', 'ILO3', 'Normalize relations up to BCNF', 'Analyze'),
('CSEN301', 'ILO1', 'Analyze the time complexity of algorithms', 'Analyze'),
('CSEN301', 'ILO2', 'Implement trees and graphs', 'Apply'),
('CSEN202', 'ILO1', 'Write structured programs', 'Apply'),
('CSEN601', 'ILO1', 'Train and evaluate supervised models', 'Evaluate'),
('BINF301', 'ILO1', 'Model business processes in BPMN', 'Apply'),
('CSEN502', 'ILO1', 'Apply agile practices in a team project', 'Apply');
GO

INSERT INTO Course_Offering (CourseCode, SemesterID, SectionID, DeliveryMode, EnrolledCount, Status, InstructorID) VALUES
('CSEN501', 1, 'T1', 'In-Person', 120, 'Completed', 3),
('BINF301', 1, 'T1', 'In-Person',  75, 'Completed', 5),
('CSEN301', 2, 'T1', 'Hybrid',    150, 'Completed', 4),
('CSEN601', 2, 'T1', 'In-Person',  60, 'Completed', 6),
('CSEN501', 3, 'T1', 'In-Person', 130, 'Running',   3),
('CSEN301', 3, 'T2', 'In-Person', 140, 'Running',   4),
('CSEN202', 3, 'T1', 'In-Person', 200, 'Running',   6),
('BINF301', 3, 'T1', 'Online',     80, 'Running',   5),
('CSEN502', 3, 'T1', 'Hybrid',     90, 'Running',   3);
GO

INSERT INTO Offering_TA (CourseCode, SemesterID, SectionID, TAID) VALUES
('CSEN501', 1, 'T1', 7),
('CSEN501', 3, 'T1', 7),
('CSEN502', 3, 'T1', 7),
('CSEN301', 3, 'T2', 8),
('BINF301', 3, 'T1', 9);
GO

INSERT INTO Outcome_Mapping (CoverageLevel, IsAssessmentPoint, MappingStatus, CourseCode, ILOCode, ProgramID, PLOCode) VALUES
('Reinforced', 1, 'Approved', 'CSEN501', 'ILO1', 1, 'PLO2'),
('Mastered',   1, 'Approved', 'CSEN501', 'ILO2', 1, 'PLO1'),
('Introduced', 1, 'Approved', 'CSEN301', 'ILO1', 1, 'PLO1'),
('Introduced', 0, 'Approved', 'CSEN202', 'ILO1', 1, 'PLO2'),
('Reinforced', 0, 'Pending',  'CSEN502', 'ILO1', 1, 'PLO3'),
('Mastered',   1, 'Approved', 'CSEN601', 'ILO1', 1, 'PLO1'),
('Introduced', 1, 'Approved', 'BINF301', 'ILO1', 3, 'PLO1'),
('Mastered',   1, 'Pending',  'CSEN501', 'ILO3', 1, 'PLO2');
GO

INSERT INTO Outcome_Assessment (Instrument, Description, TargetThreshold, AttainedValue, SampleSize, AnalysisNotes, CorrectiveAction, CourseCode, ILOCode, SemesterID, SectionID, MappingID) VALUES
('Final exam Q3', 'EER to relational mapping question', 70, 62, 120, 'Weak on mapping weak entities', 'Added two lab sessions on EER mapping', 'CSEN501', 'ILO1', 1, 'T1', 1),
('Midterm Q2', 'EER to relational mapping question', 70, 74, 130, 'Improved after extra labs', NULL, 'CSEN501', 'ILO1', 3, 'T1', 1),
('SQL project', 'Team SQL project', 75, 81, 120, 'Good results', NULL, 'CSEN501', 'ILO2', 1, 'T1', 2),
('Final exam Q1', 'Complexity analysis question', 65, 58, 150, 'Students struggle with recurrences', NULL, 'CSEN301', 'ILO1', 2, 'T1', 3),
('ML project', 'Supervised learning project', 70, 77, 60, 'Strong projects', NULL, 'CSEN601', 'ILO1', 2, 'T1', 6),
('BPMN assignment', 'Process modelling assignment', 70, 66, 80, 'Gateways often wrong', NULL, 'BINF301', 'ILO1', 3, 'T1', 7),
('Quiz 2', 'Complexity quiz', 65, 69, 140, 'Better than last semester', NULL, 'CSEN301', 'ILO1', 3, 'T2', 3);
GO

INSERT INTO Modification_Proposal (Title, Rationale, ModificationType, CurrentStateSummary, ProposedStateSummary, SubmissionDate, ProposerID, CourseCode, ProgramID, VersionLabel, AcademicYear, AssessmentID) VALUES
('Add Machine Learning as core course', 'AI skills are required by the market', 'Add Course', 'Machine Learning is only an elective', 'Machine Learning is core in semester 7', '2026-03-01 09:30', 6, 'CSEN601', 1, 'v2', '2025-2026', NULL),
('Revise Database I ILOs', 'ILO1 target not met in Winter 2025', 'Revise ILOs', 'Three ILOs', 'ILO1 split into two measurable ILOs', '2026-10-05 10:15', 3, 'CSEN501', 1, 'v3', '2026-2027', 1),
('Move Data Structures earlier', 'Students need it before Database I', 'Change Placement', 'Semester 3', 'Semester 2', '2026-10-28 11:00', 4, 'CSEN301', 1, 'v3', '2026-2027', 4),
('Make Computer Networks mandatory', 'Needed for the systems track', 'Change Placement', 'Elective in semester 8', 'Mandatory in semester 8', '2026-09-25 12:00', 3, 'CSEN602', 1, 'v3', '2026-2027', NULL),
('Retire Enterprise Systems', 'Content overlaps with Business Informatics', 'Retire Course', 'Elective in semester 5', 'Removed', '2026-09-01 08:00', 5, 'BINF402', 3, 'v1', '2025-2026', NULL);
GO

INSERT INTO Innovation_Initiative (Title, Description, Motivation, RegistrationDate, ImplementationDeadline, Status, CourseCode, SemesterID, SectionID, FacultyID, SubmitterID, TargetStartSemesterID, AssessmentID) VALUES
('AI tutor for Database I labs', 'ChatGPT Edu tutor that explains EER mapping', 'ILO1 below target', '2026-02-20', '2026-12-20', 'In Progress', 'CSEN501', 3, 'T1', 1, 3, 3, 1),
('Flipped classroom for Data Structures', 'Lectures as videos, class time for problems', 'Low results on complexity', '2026-10-15', '2027-05-30', 'Pending Approval', 'CSEN301', 3, 'T2', 1, 4, 4, 4),
('Copilot-assisted programming labs', 'Copilot in all Intro to Programming labs', 'Faster feedback in labs', '2026-09-30', '2027-06-15', 'Escalated', 'CSEN202', 3, 'T1', 1, 6, 4, NULL),
('Problem-based learning in Business Informatics', 'Weekly PBL cases', 'More practical learning', '2025-09-01', '2026-01-25', 'Completed', 'BINF301', 1, 'T1', 2, 5, 1, NULL),
('AI-graded BPMN quizzes', 'Automatic feedback on process models', 'BPMN assignment below target', '2026-10-18', '2027-04-30', 'Returned', 'BINF301', 3, 'T1', 2, 5, 4, 6);
GO

INSERT INTO AI_Tool_Integration (InitiativeID, IntegrationObjective, ToolCategory, DataPrivacyNotes, AcademicIntegrityNotes) VALUES
(1, 'Step-by-step hints during labs', 'Generative AI', 'No student names sent to the tool', 'Hints only, no full answers'),
(3, 'Code suggestions in labs', 'Code Assistant', 'Education licence, no code retention', 'Disabled during graded labs'),
(5, 'Automatic feedback on BPMN models', 'Assessment', 'Models anonymised before upload', 'Final grade set by the instructor');
GO

INSERT INTO Methodology_Change (InitiativeID, PedagogicalApproach, DeliveryChange, ReferenceFramework) VALUES
(1, 'Guided practice', 'Labs split into short guided tasks', 'Cognitive apprenticeship'),
(2, 'Flipped classroom', 'Videos before class, problems in class', 'Bergmann and Sams'),
(4, 'Problem-based learning', 'Weekly case instead of lecture', 'McMaster PBL');
GO

INSERT INTO Assessment_Redesign (InitiativeID, AssessmentTypeAffected, RubricWeightingChanges, FairnessSafeguards) VALUES
(4, 'Case report', 'Report 40%, presentation 20%', 'Individual reflection per student'),
(5, 'Quiz', 'Quizzes 15% instead of 10%', 'Randomised questions per student');
GO

INSERT INTO Initiative_Member (InitiativeID, MemberID, Role) VALUES
(1, 3, 'Lead'), (1, 4, 'Contributor'), (1, 7, 'Supporting TA'),
(2, 4, 'Lead'), (2, 8, 'Supporting TA'),
(3, 6, 'Lead'),
(4, 5, 'Lead'), (4, 9, 'Supporting TA'),
(5, 5, 'Lead');
GO

INSERT INTO Approval_Record (Decision, DecisionLevel, DecisionDate, Comments, DeciderID, ProposalID, InitiativeID) VALUES
('Approved',  'Dean',     '2026-03-05 10:00', 'Approved for the winter semester pilot', 1, NULL, 1),
('Escalated', 'Dean',     '2026-10-20 12:00', 'Needs a university-wide licence decision', 1, NULL, 3),
('Approved',  'Dean',     '2025-09-10 09:00', 'Approved', 2, NULL, 4),
('Returned',  'Dean',     '2026-10-25 14:00', 'Explain how student data is protected', 2, NULL, 5),
('Approved',  'Reviewer', '2026-03-10 13:00', 'Fits the AI track', 10, 1, NULL),
('Approved',  'Dean',     '2026-03-20 11:00', 'Approved', 1, 1, NULL),
('Returned',  'Reviewer', '2026-10-12 14:30', 'ILO3 must be measurable', 6, 2, NULL),
('Approved',  'Reviewer', '2026-10-01 10:00', 'OK from the reviewer side', 10, 4, NULL),
('Rejected',  'Dean',     '2026-09-15 09:00', 'Course still needed by the program', 2, 5, NULL);
GO

INSERT INTO AI_Tool (ToolID, Provider, ModelVersion, LicenseType, HostingMode, CostModel) VALUES
(1, 'OpenAI', 'GPT-4o', 'Institutional', 'Cloud', 'Per seat'),
(2, 'GitHub', 'Copilot 2026', 'Education', 'Cloud', 'Free for education'),
(5, 'GradeTech', 'v2.1', 'Trial', 'Cloud', 'Per submission');
GO

INSERT INTO Teaching_Methodology (ToolID, OriginatingFramework, ReferenceSource, RequiredResources) VALUES
(3, 'Bergmann and Sams model', 'Flip Your Classroom (2012)', 'Pre-recorded lecture videos, Online quiz platform'),
(4, 'McMaster PBL model', 'Barrows, Problem-Based Learning (1980)', 'Case study pack, Project rubric');
GO

INSERT INTO Initiative_Tool (InitiativeID, ToolID) VALUES
(1, 1), (2, 3), (3, 2), (4, 4), (5, 1);
GO

INSERT INTO Milestone (InitiativeID, SeqNo, Title, Description, DueDate, CompletionDate, Status) VALUES
(1, 1, 'Prepare prompts and lab sheets', 'Prompt library for 10 labs', '2026-09-30', '2026-09-28', 'Completed'),
(1, 2, 'Pilot in two lab groups', 'Run the tutor in groups T1 and T2', '2026-10-25', NULL, 'In Progress'),
(1, 3, 'Full rollout', 'All lab groups', '2026-12-15', NULL, 'Pending'),
(2, 1, 'Record lecture videos', 'Ten short videos', '2027-02-28', NULL, 'Pending'),
(3, 1, 'Licence setup', 'Get education licences', '2026-12-01', NULL, 'Pending'),
(4, 1, 'Design PBL cases', 'Eight business cases', '2025-10-15', '2025-10-14', 'Completed'),
(4, 2, 'Run PBL sessions', 'Weekly sessions', '2025-12-20', '2025-12-18', 'Completed');
GO

INSERT INTO Evidence (Title, ArtifactType, FilePathOrURL, UploadDate, Description, InitiativeID, MilestoneSeqNo) VALUES
('Lab worksheet with AI prompts', 'Document', 'https://drive.giu-uni.de/ev/1.pdf', '2026-09-28', 'Prompts used in labs', 1, 1),
('Pilot survey results', 'Spreadsheet', 'https://drive.giu-uni.de/ev/2.xlsx', '2026-10-20', 'Survey of pilot groups', 1, NULL),
('PBL case pack', 'Document', 'https://drive.giu-uni.de/ev/3.pdf', '2025-10-14', 'All eight cases', 4, 1),
('Final initiative report', 'Report', 'https://drive.giu-uni.de/ev/4.pdf', '2026-01-20', 'Results and lessons learned', 4, NULL),
('Copilot licence quote', 'PDF', 'https://drive.giu-uni.de/ev/5.pdf', '2026-10-01', 'Price for 300 seats', 3, NULL);
GO

INSERT INTO Outcome_Report (MetricType, QuantitativeValue, BaselineValue, QualitativeSummary, InitiativeID, SemesterID) VALUES
('Pass Rate', 78, 65, 'More students pass the mapping question', 1, 3),
('Pass Rate', 82, 70, 'Clear improvement after PBL', 4, 1),
('Student Satisfaction', 4.1, 3.6, 'Students like the hints', 1, 3),
('Student Satisfaction', 4.4, 3.8, 'Students enjoyed the cases', 4, 1),
('Attendance Rate', 91, 85, 'Attendance went up', 4, 1);
GO

INSERT INTO Student_Feedback (Rating, Comment, CategorySentiment, CollectionMethod, InitiativeID, SemesterID) VALUES
(5, 'The AI hints really helped', 'Positive', 'Online survey', 1, 3),
(4, 'Useful but sometimes slow', 'Positive', 'Online survey', 1, 3),
(3, 'I prefer asking the TA', 'Neutral', 'Online survey', 1, 3),
(4, 'Good for practice', 'Positive', 'Focus group', 1, 3),
(5, 'Best course format', 'Positive', 'Paper survey', 4, 1),
(4, 'Cases were realistic', 'Positive', 'Paper survey', 4, 1);
GO

INSERT INTO Training_Session (Title, Topic, Description, SessionDate, DurationMinutes, Trainer, Capacity, Status, ToolID) VALUES
('ChatGPT Edu for Course Design', 'Prompting for teaching', 'Using ChatGPT to design labs', '2026-11-20', 90, 'Dr. Hany Elsayed', 3, 'Scheduled', 1),
('Copilot in Programming Labs', 'AI pair programming', 'Hands-on Copilot workshop', '2026-12-05', 120, 'Eng. Youssef Samir', 20, 'Scheduled', 2),
('Flipped Classroom Workshop', 'Flipped teaching', 'Designing pre-class material', '2026-10-10', 120, 'Dr. Nour Adel', 25, 'Completed', 3),
('Problem-Based Learning Basics', 'PBL facilitation', 'Writing and running PBL cases', '2026-11-28', 60, 'Dr. Omar Fathy', 30, 'Scheduled', 4),
('ChatGPT Edu Advanced', 'Assessment with AI', 'AI-assisted feedback and grading', '2027-01-10', 90, 'Dr. Sara Hamdy', 15, 'Scheduled', 1);
GO

INSERT INTO Online_Training (SessionID, Platform, MeetingLink, RecordingAvailable) VALUES
(1, 'Zoom', 'https://zoom.us/j/1111111111', 1),
(4, 'Microsoft Teams', 'https://teams.microsoft.com/l/meetup-join/4444', 0),
(5, 'Zoom', 'https://zoom.us/j/5555555555', 1);
GO

INSERT INTO In_Person_Training (SessionID, Venue, Campus, RequiredEquipment) VALUES
(2, 'Lab B2.05', 'New Administrative Capital', 'Laptops, Projector'),
(3, 'Hall A1.01', 'New Administrative Capital', 'Projector, Whiteboard');
GO

INSERT INTO Session_Attendance (SessionID, MemberID) VALUES
(1, 3), (1, 4), (1, 6),
(3, 3), (3, 5), (3, 7),
(2, 8),
(4, 9);
GO

INSERT INTO Training_Requirement (Description, TargetAudience, RequiredByDate, IsMandatory, InitiativeID, ToolID) VALUES
('Prompt design for AI tutors', 'Instructors and TAs', '2026-11-30', 1, 1, 1),
('Copilot basics for lab staff', 'Instructors and TAs', '2027-01-15', 1, 3, 2),
('Designing flipped lessons', 'Course team', '2027-01-31', 1, 2, 3),
('PBL facilitation', 'Course team', '2025-09-30', 0, 4, 4),
('Student data privacy briefing', 'Everyone on the initiative', '2026-11-15', 0, 1, NULL);
GO

INSERT INTO Accreditation_Review (AccreditingBody, ReviewType, ReviewCycle, Status, Decision, SubmissionDate, NextReviewDue, ProgramID) VALUES
('NAQAAE', 'Institutional', '5-year', 'In Progress', NULL, NULL, '2026-11-25', 1),
('ABET', 'Program', '6-year', 'Submitted', NULL, '2026-06-15', '2027-06-30', 3),
('ABET', 'Program', '6-year', 'Closed', 'Accredited', '2021-05-10', '2027-05-10', 1),
('NAQAAE', 'Program', '5-year', 'Open', NULL, NULL, '2027-03-01', 2),
('NAQAAE', 'Institutional', '5-year', 'Closed', 'Accredited', '2022-03-01', '2027-03-01', 3);
GO

INSERT INTO Review_Mapping (ReviewID, MappingID) VALUES
(1, 1), (1, 2), (1, 3), (2, 7);
GO

INSERT INTO Review_Assessment (ReviewID, AssessmentID) VALUES
(1, 1), (1, 3), (2, 6);
GO

INSERT INTO Review_Evidence (ReviewID, EvidenceID) VALUES
(1, 1), (1, 2), (2, 3);
GO

INSERT INTO Notification_Recipient (NotificationID, MemberID, ReadStatus) VALUES
(1, 3, 1), (1, 4, 0), (1, 6, 0),
(2, 3, 0),
(3, 3, 0), (3, 7, 1),
(4, 1, 0), (4, 3, 1), (4, 10, 0),
(5, 1, 1), (5, 2, 1), (5, 3, 0), (5, 4, 1), (5, 5, 0), (5, 6, 0);
GO

INSERT INTO Audit_Log (ActionType, LoggedAt, ChangeSummary, ActorID, ProposalID, ApprovalID, InitiativeID, AssessmentID, EvidenceID) VALUES
('Create', '2026-01-25 10:00', 'Assessment recorded: Final exam Q3, CSEN501 ILO1', 3, NULL, NULL, NULL, 1, NULL),
('Update', '2026-02-01 11:00', 'Corrective action added', 3, NULL, NULL, NULL, 1, NULL),
('Create', '2026-03-01 09:30', 'Proposal submitted: Add Machine Learning as core course', 6, 1, NULL, NULL, NULL, NULL),
('Create', '2026-03-10 13:00', 'Reviewer approved proposal 1', 10, NULL, 5, NULL, NULL, NULL),
('Create', '2026-02-20 15:00', 'Initiative registered: AI tutor for Database I labs', 3, NULL, NULL, 1, NULL, NULL),
('Create', '2026-09-28 16:00', 'Evidence uploaded: Lab worksheet with AI prompts', 3, NULL, NULL, NULL, NULL, 1),
('Create', '2026-10-05 10:15', 'Proposal submitted: Revise Database I ILOs', 3, 2, NULL, NULL, NULL, NULL),
('Create', '2026-10-20 12:00', 'Dean escalated initiative 3', 1, NULL, 2, NULL, NULL, NULL);
GO
