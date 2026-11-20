USE GCAIMP;
GO

SELECT * FROM ViewMemberInfo(6);
SELECT * FROM ViewMemberInfo(999);
GO

EXEC AddAcademicMember 'Khaled Mahmoud Ali', 'GIU-0100', 'khaled.mahmoud@giu-uni.de', '01000000100', 'Lecturer', 'Full-Time', 'Active', 3;
EXEC AddAcademicMember 'Hany Copy', 'GIU-0999', 'hany.elsayed@giu-uni.de', NULL, 'Lecturer', 'Full-Time', 'Active', 1;
GO

DECLARE @m INT;
SELECT @m = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0100';
EXEC UpdateMemberContactInfo @m, 'khaled.ali@giu-uni.de', '01100000100';
EXEC UpdateMemberContactInfo @m, 'mona.farouk@giu-uni.de', '01100000100';
GO

DECLARE @m INT;
SELECT @m = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0100';
EXEC UpdateAccountStatus @m, 'Suspended';
EXEC UpdateAccountStatus @m, 'Active';
EXEC UpdateAccountStatus @m, 'Banned';
GO

DECLARE @m INT;
SELECT @m = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0100';
EXEC AssignInstructorRole @m, 'Educational Technology', 'C3.301', 0;
EXEC AssignInstructorRole 3, 'Databases', 'C3.201', 2;
GO

EXEC AddAcademicMember 'Salma Hesham', 'GIU-0101', 'salma.hesham@giu-uni.de', '01000000101', 'Teaching Assistant', 'Full-Time', 'Active', 3;
DECLARE @ta INT;
DECLARE @sup INT;
SELECT @ta = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0101';
SELECT @sup = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0100';
EXEC AssignTeachingAssistantRole @ta, 'Junior', @sup;
EXEC AssignTeachingAssistantRole 15, 'Junior', 7;
GO

EXEC AddFaculty 'Engineering', 'Mechatronics and materials programs', '2026-09-01', NULL;
DECLARE @f INT;
DECLARE @d INT;
SELECT @f = FacultyID FROM Faculty WHERE Name = 'Engineering';
EXEC AddAcademicMember 'Tarek Zaki', 'GIU-0102', 'tarek.zaki@giu-uni.de', '01000000102', 'Professor', 'Full-Time', 'Active', @f;
SELECT @d = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0102';
EXEC AssignDean @d, @f, 'Faculty proposals and initiatives';
EXEC AssignDean @d, 999, 'Faculty proposals and initiatives';
GO

EXEC AddAcademicMember 'Nadia Fawzy', 'GIU-0103', 'nadia.fawzy@giu-uni.de', '01000000103', 'Professor', 'Full-Time', 'Active', NULL;
DECLARE @m INT;
SELECT @m = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0103';
EXEC AssignManagementRole @m, 'Vice President for Quality', 'High', 'Quality assurance';
EXEC AssignManagementRole 12, 'University President', 'Final', 'University-wide';
GO

DECLARE @m INT;
SELECT @m = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0100';
EXEC AssignReviewerRole @m, 'E-learning courses', 'Course', 'CS Curriculum Committee, E-Learning Committee';
EXEC AssignReviewerRole 10, 'Computer Science curriculum', 'Program', 'Quality Assurance Committee';
GO

DECLARE @m INT;
SELECT @m = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0100';
EXEC GrantAccessScope @m, 'Review Mappings';
EXEC GrantAccessScope @m, 'Review Mappings';
GO

DECLARE @m INT;
SELECT @m = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0100';
EXEC GrantAccessScope @m, 'Approve Initiatives';
EXEC RevokeAccessScope @m, 'Approve Initiatives';
EXEC RevokeAccessScope @m, 'Approve Proposals';
GO

EXEC AddAcademicMember 'Heba Lotfy', 'GIU-0104', 'heba.lotfy@giu-uni.de', '01000000104', 'Professor', 'Full-Time', 'Active', NULL;
DECLARE @d INT;
SELECT @d = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0104';
EXEC AddFaculty 'Pharmacy', 'Pharmacy and biotechnology programs', '2027-09-01', @d;
EXEC AddFaculty 'Design', 'Duplicate', '2027-09-01', NULL;
GO

DECLARE @d INT;
SELECT @d = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0102';
EXEC RecordDeanTerm @d, 3;
EXEC RecordDeanTerm @d, 3;
GO

SELECT * FROM ViewAuditLog('2026-01-01', '2026-12-31') ORDER BY LoggedAt;
SELECT * FROM ViewAuditLog('2026-12-31', '2026-01-01');
GO

SELECT * FROM GetFacultyMemberStats() ORDER BY FacultyName, Role;
SELECT * FROM GetFacultyMemberStats() WHERE FacultyName = 'Medicine';
GO

SELECT * FROM ViewMySupervisor(7);
SELECT * FROM ViewMySupervisor(3);
GO

EXEC BroadcastNotification 'University council meeting on 2026-11-10 at 11:00 in the Senate Hall', 'Medium', 'Announcement', 'University Management';
EXEC BroadcastNotification 'Hello students', 'Low', 'Announcement', 'Student';
GO

SELECT * FROM ViewItemAuditTrail('Proposal', 1) ORDER BY LoggedAt;
SELECT * FROM ViewItemAuditTrail('Course', 1);
GO

SELECT * FROM ViewMyProfile(3);
SELECT * FROM ViewMyProfile(999);
GO

SELECT * FROM ViewMyNotifications(3, 1) ORDER BY CreatedAt DESC;
SELECT * FROM ViewMyNotifications(999, 0) ORDER BY CreatedAt DESC;
GO

SELECT dbo.GetUnreadNotificationCount(3) AS UnreadCount;
SELECT dbo.GetUnreadNotificationCount(999) AS UnreadCount;
GO

DECLARE @m INT;
DECLARE @n INT;
SELECT @m = MemberID FROM Academic_Member WHERE UniversityIDNo = 'GIU-0103';
SELECT @n = MAX(NotificationID) FROM Notification
WHERE MessageContent = 'University council meeting on 2026-11-10 at 11:00 in the Senate Hall';
EXEC MarkNotificationRead @n, @m;
EXEC MarkNotificationRead @n, 3;
GO

EXEC NotifyApprovalDecision 6, 'Proposal', 1, 'Approved';
EXEC NotifyApprovalDecision 4, 'Proposal', 1, 'Approved';
GO

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
