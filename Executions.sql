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

EXEC AddSemester 'Summer', '2026-2027', '2027-07-10', '2027-08-31';
EXEC AddSemester 'Winter', '2026-2027', '2026-09-19', '2027-01-30';
GO

DECLARE @s INT;
SELECT @s = SemesterID FROM Semester WHERE Name = 'Summer' AND AcademicYear = '2026-2027';
EXEC CreateCourseOffering 'CSEN501', @s, 'T1', 'Hybrid', 40, 3;
EXEC CreateCourseOffering 'CSEN501', @s, 'T2', 'Online', 30, 14;
GO

DECLARE @s INT;
SELECT @s = SemesterID FROM Semester WHERE Name = 'Summer' AND AcademicYear = '2026-2027';
EXEC AssignTAToOffering 'CSEN501', @s, 'T1', 7;
EXEC AssignTAToOffering 'CSEN501', @s, 'T1', 3;
GO

SELECT * FROM dbo.ViewMyCourseOfferings(3, 3);
SELECT * FROM dbo.ViewMyCourseOfferings(999, 3);
GO

DECLARE @s INT;
SELECT @s = SemesterID FROM Semester WHERE Name = 'Summer' AND AcademicYear = '2026-2027';
EXEC RecordOutcomeAssessment 'CSEN501', 'ILO1', @s, 'T1', 1, 'Summer final Q2', 'EER to relational mapping question', 70, 64, 40, 'Weak entities still confusing';
EXEC RecordOutcomeAssessment 'CSEN501', 'ILO1', @s, 'T1', 3, 'Summer quiz', NULL, 70, 80, 40, NULL;
GO

DECLARE @a INT;
SELECT @a = MAX(AssessmentID) FROM Outcome_Assessment WHERE Instrument = 'Summer final Q2';
EXEC AddCorrectiveAction @a, 'Extra tutorial on weak entities before the final';
EXEC AddCorrectiveAction 2, 'Not needed';
GO

SELECT * FROM dbo.ViewUnmetAssessments(3);
SELECT * FROM dbo.ViewUnmetAssessments(999);
GO

SELECT * FROM dbo.ViewSupportedOfferings(7);
SELECT * FROM dbo.ViewSupportedOfferings(3);
GO

SELECT * FROM dbo.ViewOfferingAssessments('CSEN501', 1, 'T1');
SELECT * FROM dbo.ViewOfferingAssessments('CSEN501', 1, 'X9');
GO

DECLARE @s INT;
SELECT @s = SemesterID FROM Semester WHERE Name = 'Summer' AND AcademicYear = '2026-2027';
EXEC UpdateEnrolledCount 'CSEN501', @s, 'T1', 45;
EXEC UpdateEnrolledCount 'CSEN501', @s, 'T1', -5;
GO

SELECT dbo.GetPLOAttainment(1, 'PLO1', 2) AS PLOAttainment;
SELECT dbo.GetPLOAttainment(1, 'PLO9', 2) AS PLOAttainment;
GO

SELECT * FROM dbo.ViewAssessmentsBelowTarget(1, 2);
SELECT * FROM dbo.ViewAssessmentsBelowTarget(999, 2);
GO

SELECT * FROM dbo.TrackCorrectiveActionEffect('CSEN501', 'ILO1') ORDER BY StartDate;
SELECT * FROM dbo.TrackCorrectiveActionEffect('CSEN501', 'ILO9') ORDER BY StartDate;
GO

DECLARE @due DATE;
SET @due = DATEADD(DAY, 20, CAST(GETDATE() AS DATE));
EXEC CreateAccreditationReview 1, 'ASIIN', 'Program', '6-year', @due;
EXEC CreateAccreditationReview 999, 'ASIIN', 'Program', '6-year', @due;
GO

DECLARE @r INT;
SELECT @r = MAX(ReviewID) FROM Accreditation_Review WHERE AccreditingBody = 'ASIIN';
EXEC AttachMappingsToReview @r;
EXEC AttachMappingsToReview 999;
GO

DECLARE @r INT;
DECLARE @a INT;
SELECT @r = MAX(ReviewID) FROM Accreditation_Review WHERE AccreditingBody = 'ASIIN';
SELECT @a = MAX(AssessmentID) FROM Outcome_Assessment WHERE Instrument = 'Summer final Q2';
EXEC AttachAssessmentToReview @r, @a;
EXEC AttachAssessmentToReview @r, @a;
GO

DECLARE @r INT;
SELECT @r = MAX(ReviewID) FROM Accreditation_Review WHERE AccreditingBody = 'ASIIN';
EXEC AttachEvidenceToReview @r, 1;
EXEC AttachEvidenceToReview @r, 999;
GO

DECLARE @r INT;
SELECT @r = MAX(ReviewID) FROM Accreditation_Review WHERE AccreditingBody = 'ASIIN';
EXEC UpdateAccreditationStatus @r, 'In Progress', NULL, NULL;
EXEC UpdateAccreditationStatus @r, 'Finished', NULL, NULL;
GO

DECLARE @r INT;
SELECT @r = MAX(ReviewID) FROM Accreditation_Review WHERE AccreditingBody = 'ASIIN';
SELECT * FROM dbo.GenerateAccreditationPack(@r);
SELECT * FROM dbo.GenerateAccreditationPack(999);
GO

SELECT * FROM dbo.GetUpcomingAccreditations(30);
SELECT * FROM dbo.GetUpcomingAccreditations(-5);
GO

SELECT * FROM dbo.GetAccreditationOverview();
GO

SELECT * FROM dbo.GetAttainmentTrend(1) ORDER BY StartDate;
SELECT * FROM dbo.GetAttainmentTrend(999) ORDER BY StartDate;
GO

EXEC NotifyAccreditationDeadline 1, 30;
EXEC NotifyAccreditationDeadline 999, 30;
GO

EXEC RegisterInnovationInitiative 4, 1, 'AI quiz generator for Data Structures', 'ChatGPT Edu generates weekly practice quizzes', 'Complexity quiz results are still close to the target', 'CSEN301', 3, 'T2', 4, '2027-06-30',
7;
EXEC RegisterInnovationInitiative 4, 1, 'Wrong offering', NULL, NULL, 'CSEN999', 3, 'T1', 4, '2027-06-30', NULL;
GO

DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC AssignInitiativeMember @init, 8, 'Supporting TA';
EXEC AssignInitiativeMember @init, 8, 'Contributor';
GO

DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC AddMilestone @init, 'Write quiz prompts', 'Prompt templates for 10 topics', '2026-12-15';
EXEC AddMilestone @init, 'Pilot in section T2', 'Weekly quizzes for one month', '2027-03-31';
EXEC AddMilestone 9999, 'Nothing', NULL, '2027-01-01';
GO

DECLARE @init INT;
DECLARE @today DATE;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
SET @today = CAST(GETDATE() AS DATE);
EXEC CompleteMilestone @init, 1, @today;
EXEC CompleteMilestone @init, 99, @today;
GO

DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC RequestInitiativeApproval @init, 4;
EXEC RequestInitiativeApproval @init, 4;
GO

SELECT * FROM dbo.ViewInitiativeProgress(1);
SELECT * FROM dbo.ViewInitiativeProgress(9999);
GO

SELECT dbo.CalculateInitiativeCompletion(1) AS CompletionPct;
SELECT dbo.CalculateInitiativeCompletion(9999) AS CompletionPct;
GO

DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC UpdateMilestoneStatus @init, 2, 'In Progress';
EXEC UpdateMilestoneStatus @init, 2, 'Done';
GO

SELECT * FROM dbo.ViewFacultyPendingApprovals(1);
SELECT * FROM dbo.ViewFacultyPendingApprovals(3);
GO

DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC DecideOnInitiative @init, 1, 'Returned', 'Explain how quiz quality is checked';
EXEC DecideOnInitiative @init, 2, 'Approved', NULL;
GO

DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC RequestInitiativeApproval @init, 4;
EXEC EscalateToUniversity @init, 1, 'Needs a university-wide licence for ChatGPT Edu';
EXEC EscalateToUniversity @init, 1, 'Again';
GO

SELECT * FROM dbo.ViewFacultyInitiatives(1, 'Escalated');
SELECT * FROM dbo.ViewFacultyInitiatives(9999, 'Escalated');
GO

SELECT * FROM dbo.ViewOverdueMilestones(1);
SELECT * FROM dbo.ViewOverdueMilestones(9999);
GO

EXEC SendOverdueAlerts 1;
EXEC SendOverdueAlerts 9999;
GO

SELECT * FROM dbo.GetFacultyDashboard(1, 3);
SELECT * FROM dbo.GetFacultyDashboard(1, 9999);
GO

SELECT * FROM dbo.ViewEscalatedItems();
SELECT * FROM dbo.ViewEscalatedItems() WHERE ItemType = 'Proposal' AND ItemID = 9999;
GO

DECLARE @init INT;
SELECT @init = MAX(InitiativeID) FROM Innovation_Initiative WHERE Title = 'AI quiz generator for Data Structures';
EXEC MakeUniversityDecision 'Initiative', @init, 12, 'Approved', 'Licence approved for one year';
EXEC MakeUniversityDecision 'Proposal', 1, 12, 'Approved', NULL;
GO

SELECT * FROM dbo.GetUniversityDashboard(3);
SELECT * FROM dbo.GetUniversityDashboard(9999);
GO

SELECT * FROM dbo.GetInitiativeStatsByType();
SELECT * FROM dbo.GetInitiativeStatsByType() WHERE InitiativeType = 'Unknown Type';
GO

SELECT dbo.GetApprovalTurnaround(1) AS AvgTurnaroundDays;
SELECT dbo.GetApprovalTurnaround(9999) AS AvgTurnaroundDays;
GO

SELECT * FROM dbo.RankInitiativesByImpact('Pass Rate') ORDER BY ImprovementPct DESC;
SELECT * FROM dbo.RankInitiativesByImpact('Unknown Metric');
GO

SELECT * FROM dbo.ViewMyInitiatives(4);
SELECT * FROM dbo.ViewMyInitiatives(9999);
GO

EXEC NotifyOverdueMilestone 3, 1, 2;
EXEC NotifyOverdueMilestone 10, 1, 2;
GO

EXEC AddTool 'Gradescope AI', 'AI assisted grading of programming assignments', 'Assessment', 'Under Review', 'AI Tool',
             'Turnitin', 'v3.0', 'Institutional', 'Cloud', 'Per seat', NULL, NULL, NULL;
EXEC AddTool 'Peer Instruction', 'Students discuss concept questions in class', 'Pedagogy', 'Approved', 'Teaching Methodology',
             NULL, NULL, NULL, NULL, NULL, 'Mazur model', 'Peer Instruction (1997)', 'Clicker quizzes, Concept question bank';
EXEC AddTool 'ChatGPT Edu', 'Duplicate tool name', 'Generative AI', 'Approved', 'AI Tool',
             'OpenAI', 'GPT-4o', 'Institutional', 'Cloud', 'Per seat', NULL, NULL, NULL;
EXEC AddTool 'Mystery Tool', 'Unknown type', 'Other', 'Approved', 'Hardware',
             NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
GO

EXEC AddAIToolIntegration 2, 'AI generated practice problems for class time', 'Generative AI',
                          'No student data is shared with the tool', 'Problems are only used for practice, not grading';
EXEC AddAIToolIntegration 1, 'Duplicate description', 'Generative AI', NULL, NULL;
EXEC AddAIToolIntegration 999, 'Initiative does not exist', 'Generative AI', NULL, NULL;
GO

EXEC AddMethodologyChange 3, 'Pair programming', 'Students work in pairs with Copilot in every lab', 'Williams and Kessler';
EXEC AddMethodologyChange 2, 'Duplicate description', NULL, NULL;
GO

EXEC AddAssessmentRedesign 1, 'Lab quiz', 'Lab quizzes 20% instead of 10%', 'Quizzes are taken without the AI tutor';
EXEC AddAssessmentRedesign 4, 'Duplicate description', NULL, NULL;
GO

EXEC AdoptTool 1, 2;
EXEC AdoptTool 1, 1;
EXEC AdoptTool 2, 5;
GO

EXEC AddTrainingRequirement 2, 1, 'Using ChatGPT Edu to prepare flipped lessons', 'Course team', '2027-02-15', 1;
EXEC AddTrainingRequirement 999, 1, 'Initiative does not exist', 'Course team', '2027-02-15', 1;
GO

EXEC UploadEvidence 1, 2, 'Pilot attendance sheet', 'Spreadsheet', 'https://drive.giu-uni.de/ev/6.xlsx', 'Attendance of the two pilot lab groups';
EXEC UploadEvidence 2, NULL, 'Draft video script', 'Document', 'https://drive.giu-uni.de/ev/7.pdf', 'Script of the first lecture video';
EXEC UploadEvidence 1, 9, 'Wrong milestone', 'Document', 'https://drive.giu-uni.de/ev/8.pdf', NULL;
GO

EXEC SubmitOutcomeReport 1, 3, 'Attendance Rate', 88, 80, 'More students attend the labs';
EXEC SubmitOutcomeReport 1, 3, 'Pass Rate', 80, 65, 'Duplicate metric for the same semester';
GO

EXEC RecordStudentFeedback 1, 3, 5, 'The tutor explains weak entities well', 'Positive', 'Online survey';
EXEC RecordStudentFeedback 1, 3, 7, 'Rating out of range', 'Positive', 'Online survey';
GO

SELECT * FROM ViewInitiativeEvidence(1);
SELECT * FROM ViewInitiativeEvidence(999);
GO

EXEC ScheduleTrainingSession 3, 'Flipped Classroom Advanced', 'Flipped teaching', 'Recording and sharing lecture videos', '2027-01-20', 90, 'Dr. Nour Adel', 25,
                             'Online', 'Zoom', 'https://zoom.us/j/6666666666', 1, NULL, NULL, NULL;
EXEC ScheduleTrainingSession 2, 'Copilot for Lab Assistants', 'AI pair programming', 'Hands-on session for TAs', '2027-01-25', 120, 'Eng. Youssef Samir', 20,
                             'In Person', NULL, NULL, NULL, 'Lab B2.07', 'New Administrative Capital', 'Laptops, Projector';
EXEC ScheduleTrainingSession 1, 'Invalid capacity', 'Prompting', NULL, '2027-02-01', 60, 'Dr. Hany Elsayed', 0,
                             'Online', 'Zoom', NULL, 0, NULL, NULL, NULL;
EXEC ScheduleTrainingSession 1, 'Invalid mode', 'Prompting', NULL, '2027-02-01', 60, 'Dr. Hany Elsayed', 10,
                             'Hybrid', NULL, NULL, NULL, NULL, NULL, NULL;
GO

SELECT * FROM ViewTrainingAttendance(1);
SELECT * FROM ViewTrainingAttendance(999);
GO

SELECT * FROM GetFacultyTrainingCompliance(1) ORDER BY InitiativeID, RequirementID;
SELECT * FROM GetFacultyTrainingCompliance(999);
GO

SELECT * FROM GetInitiativeImpact(4) ORDER BY SemesterID, MetricType;
SELECT * FROM GetInitiativeImpact(999);
GO

SELECT dbo.GetAverageFeedbackRating(4, 1) AS AverageRating;
SELECT dbo.GetAverageFeedbackRating(999, 1) AS AverageRating;
GO

SELECT * FROM GetToolAdoptionReport() ORDER BY ToolID;
GO

EXEC UpdateToolStatus 5, 'Under Review';
EXEC UpdateToolStatus 5, 'Under Review';
EXEC UpdateToolStatus 5, 'Retired';
EXEC UpdateToolStatus 999, 'Approved';
GO

SELECT dbo.GetRemainingSeats(1) AS RemainingSeats;
SELECT dbo.GetRemainingSeats(2) AS RemainingSeats;
SELECT dbo.GetRemainingSeats(999) AS RemainingSeats;
GO

SELECT * FROM ViewAvailableTrainingSessions(1);
SELECT * FROM ViewAvailableTrainingSessions(2);
SELECT * FROM ViewAvailableTrainingSessions(999);
GO

EXEC RegisterForTraining 4, 3;
EXEC RegisterForTraining 4, 9;
EXEC RegisterForTraining 1, 5;
EXEC RegisterForTraining 2, 14;
GO

EXEC CancelTrainingRegistration 4, 3;
EXEC CancelTrainingRegistration 4, 3;
EXEC CancelTrainingRegistration 3, 3;
GO

SELECT * FROM ViewMyTrainingHistory(3) ORDER BY SessionDate;
SELECT * FROM ViewMyTrainingHistory(999);
GO

SELECT * FROM ViewMyPendingTraining(4);
SELECT * FROM ViewMyPendingTraining(999);
GO
