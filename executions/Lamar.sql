-- Lamar's executions
EXEC AddProgram 'Data Science', 'Bachelor', 136, '4 years', 'BSc in Data Science', 1;


EXEC AddCourse 'CSEN701', 'Data Engineering', 'Data pipelines and warehousing', 4, 'Year 4', 'Core', 8, 'Computer Science', NULL, NULL;
EXEC AddCourse 'CSEN702', 'Cloud Computing', 'Cloud services and deployment', 3, 'Year 4', 'Elective', NULL, NULL, 'Systems Electives', 'Choose 2 of 4';


EXEC AddCourseRequisite 'CSEN701', 'CSEN501', 'Prerequisite';


EXEC AddILO 'CSEN701', 'ILO1', 'Build a data pipeline', 'Apply';


EXEC UpdateILO 'CSEN701', 'ILO1', 'Build and test a data pipeline', NULL;


EXEC MapILOToPLO 'CSEN701', 'ILO1', 1, 'PLO4', 'Introduced', 1;


EXEC SubmitModificationProposal 3, 'Add Data Engineering', 'Industry needs data skills', 'Add Course',
     'Not offered', 'Core in semester 8', 'CSEN701', 1, 'v3', '2026-2027', NULL;

EXEC ReviseModificationProposal 2, 'ILO1 target not met, ILO3 now measurable', NULL;
