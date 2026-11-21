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
