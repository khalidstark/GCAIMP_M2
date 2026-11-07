USE GCAIMP;
GO

-- Lamar's executions
EXEC AddProgram 'Data Science', 'Bachelor', 136, '4 years', 'BSc in Data Science', 1;
GO

EXEC AddCourse 'CSEN701', 'Data Engineering', 'Data pipelines and warehousing', 4, 'Year 4', 'Core', 8, 'Computer Science', NULL, NULL;
EXEC AddCourse 'CSEN702', 'Cloud Computing', 'Cloud services and deployment', 3, 'Year 4', 'Elective', NULL, NULL, 'Systems Electives', 'Choose 2 of 4';
GO

EXEC AddCourseRequisite 'CSEN701', 'CSEN501', 'Prerequisite';
GO

EXEC AddILO 'CSEN701', 'ILO1', 'Build a data pipeline', 'Apply';
GO

EXEC UpdateILO 'CSEN701', 'ILO1', 'Build and test a data pipeline', NULL;
GO

EXEC MapILOToPLO 'CSEN701', 'ILO1', 1, 'PLO4', 'Introduced', 1;
GO

EXEC SubmitModificationProposal 3, 'Add Data Engineering', 'Industry needs data skills', 'Add Course',
     'Not offered', 'Core in semester 8', 'CSEN701', 1, 'v3', '2026-2027', NULL;
GO

EXEC ReviseModificationProposal 2, 'ILO1 target not met, ILO3 now measurable', NULL;
GO

SELECT * FROM ViewProposalStatus(2);
SELECT * FROM ViewCurriculumVersion(1, 'v3', '2026-2027') ORDER BY StudySemesterNo;
SELECT * FROM ViewCourseILOs('CSEN501');
GO

SELECT * FROM CompareCurriculumVersions(1, 'v1', '2024-2025', 'v2', '2025-2026');
SELECT * FROM ViewProgramCurriculumMap(1);
GO

SELECT * FROM GetUncoveredPLOs(1);

DECLARE @MapID int = (SELECT MappingID FROM Outcome_Mapping
                      WHERE CourseCode = 'CSEN701' AND ILOCode = 'ILO1'
                        AND ProgramID = 1 AND PLOCode = 'PLO4');
EXEC ReviewOutcomeMapping @MapID, 'Approved';
GO

SELECT * FROM GetUncoveredPLOs(1);
SELECT * FROM GetPLOCoverageSummary(1);
GO

SELECT * FROM ViewPendingProposals(1);
GO

DECLARE @PropID int = (SELECT ProposalID FROM Modification_Proposal WHERE Title = 'Add Data Engineering');
EXEC ReviewModificationProposal @PropID, 10, 'Approved', 'Good addition to the curriculum';
GO

SELECT * FROM ViewCourseProposalHistory('CSEN701');
GO

DECLARE @PropID int = (SELECT ProposalID FROM Modification_Proposal WHERE Title = 'Add Data Engineering');
EXEC DecideOnProposal @PropID, 1, 'Approved', 'Approved for next year';
GO 

SELECT * FROM ViewPendingProposals(1);
GO

EXEC AddPLO 1, 'PLO5', 'Manage and analyze large datasets', 'Skills';
GO 

EXEC CreateCurriculumVersion 1, 'v4', '2027-2028', '2027-09-01 to 2028-08-31', 'v3', '2026-2027';
EXEC PlaceCourseInVersion 1, 'v4', '2027-2028', 'CSEN701', 8, 1;
GO

SELECT * FROM CompareCurriculumVersions(1, 'v3', '2026-2027', 'v4', '2027-2028');
GO

EXEC ApproveCurriculumVersion 1, 'v4', '2027-2028';
GO

SELECT * FROM Curriculum_Version WHERE ProgramID = 1;
GO

-- =============================================
-- Error tests
-- =============================================
EXEC AddCourse 'CSEN701', 'Again', 'Test', 3, 'Year 4', 'Core', 8, 'CS', NULL, NULL;
EXEC AddCourse 'CSEN799', 'Test', 'Test', 3, 'Year 4', 'Optional', NULL, NULL, NULL, NULL;
EXEC AddCourseRequisite 'CSEN701', 'CSEN701', 'Prerequisite';
EXEC AddCourseRequisite 'CSEN701', 'XXXX999', 'Prerequisite';
EXEC AddILO 'NOPE123', 'ILO1', 'Test', 'Apply';
EXEC AddILO 'CSEN701', 'ILO1', 'Test', 'Apply';
EXEC UpdateILO 'CSEN701', 'ILO9', 'Test', NULL;
EXEC MapILOToPLO 'CSEN701', 'ILO1', 1, 'PLO4', 'Expert', 1;
EXEC SubmitModificationProposal 1, 'Test', 'Test', 'Add Course', NULL, NULL, 'CSEN701', 1, 'v3', '2026-2027', NULL;
EXEC ReviseModificationProposal 1, 'Test', NULL;
EXEC ReviewOutcomeMapping 999, 'Approved';
EXEC ReviewModificationProposal 2, 3, 'Approved', 'Test';
EXEC ReviewModificationProposal 2, 10, 'Maybe', 'Test';
EXEC DecideOnProposal 2, 2, 'Approved', 'Test';
EXEC AddPLO 99, 'PLO1', 'Test', 'Skills';
EXEC CreateCurriculumVersion 1, 'v4', '2027-2028', NULL, NULL, NULL;
EXEC CreateCurriculumVersion 1, 'v5', '2028-2029', NULL, 'v9', '2020-2021';
EXEC PlaceCourseInVersion 1, 'v4', '2027-2028', 'CSEN702', 8, 0;
EXEC ApproveCurriculumVersion 1, 'v2', '2025-2026';
GO

GO
