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
