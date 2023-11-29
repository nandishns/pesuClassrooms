DELIMITER //
CREATE PROCEDURE GetClassMembers(IN p_ClassId INT)
BEGIN
    -- Get teachers and students for the specified class, ordered by role (Teachers first) and names
    SELECT
        CONCAT('{"', E.Role, '": {"name": "', U.Name, '", "photoURL": "', U.photoUrl, '"}}') AS MemberInfo
    FROM User U
    JOIN Enrollments E ON U.UserId = E.UserId
    WHERE E.ClassId = p_ClassId
    AND (E.Role = 'Teacher' OR E.Role = 'Student')
    
    ORDER BY CASE WHEN E.Role = 'Teacher' THEN 0 ELSE 1 END, U.Name;
END;
//
DELIMITER ;




DELIMITER //
CREATE PROCEDURE GetAssignmentStatus(IN p_ClassId INT, IN p_UserId VARCHAR(30))
BEGIN
    -- Get assignments and submission status for the specified class and user
    SELECT
        A.AssignmentId,
        A.Title,
        A.Description,
        A.DueDate,
        A.LastModifiedDate,
        S.SubmissionId,
        S.SubmissionDate,
        CASE
            WHEN S.SubmissionId IS NOT NULL AND S.SubmissionDate <= A.DueDate THEN 'Submitted'
            WHEN S.SubmissionId IS NOT NULL AND S.SubmissionDate > A.DueDate THEN 'Submitted Late'
            WHEN S.SubmissionId IS NULL AND A.DueDate IS NOT NULL AND A.DueDate > CURRENT_TIMESTAMP THEN 'Submission Due'
            ELSE 'Assigned'
        END AS SubmissionStatus
    FROM Assignments A
    LEFT JOIN Submissions S ON A.AssignmentId = S.AssignmentId AND S.UserId = p_UserId
    WHERE A.ClassId = p_ClassId
    ORDER BY A.PostedDate DESC;
END;
//
DELIMITER ;




DELIMITER //
CREATE PROCEDURE GetAssignmentSubmissions(
    IN p_AssignmentId INT,
    IN p_ClassId INT
)
BEGIN
    -- Fetch submission details along with submission status and student name
    SELECT
        U.Name AS StudentName,
        U.photoUrl,
        S.SubmissionId,
        S.SubmissionDate,
        CASE
            WHEN S.SubmissionDate IS NOT NULL AND S.SubmissionDate <= A.DueDate THEN 'Submitted'
            WHEN S.SubmissionDate IS NOT NULL AND S.SubmissionDate > A.DueDate THEN 'Submitted Late'
            ELSE 'Not Submitted'
        END AS SubmissionStatus,
        S.SubmissionText,
        S.Grade,
        S.Remarks,
        S.HasTeacherCorrected,
        GROUP_CONCAT(DISTINCT SubAtt.AttachmentFileURL) AS SubmissionAttachmentURL
    FROM User U
    LEFT JOIN Submissions S ON U.UserId = S.UserId AND S.AssignmentId = p_AssignmentId
    JOIN Enrollments E ON U.UserId = E.UserId
    LEFT JOIN Assignments A ON p_AssignmentId = A.AssignmentId
    LEFT JOIN Attachments SubAtt ON S.SubmissionId = SubAtt.SubmissionId
    WHERE E.ClassId = p_ClassId AND E.Role = 'Student'
    ORDER BY U.Name;
END;
//
DELIMITER ;


DELIMITER //
CREATE PROCEDURE GetSubmissionCount(IN p_AssignmentId INT, IN p_ClassId INT)
BEGIN
    DECLARE TotalStudents INT;
    DECLARE SubmittedCount INT;
    DECLARE NotSubmittedCount INT;

    -- Get the total number of students in the class
    SELECT GetNumberOfStudentsEnrolled(p_ClassId) INTO TotalStudents;

    -- Get the count of students who submitted the assignment
    SELECT COUNT(DISTINCT UserId) INTO SubmittedCount
    FROM Submissions
    WHERE AssignmentId = p_AssignmentId;

    -- Calculate the count of students who did not submit the assignment
    SET NotSubmittedCount = TotalStudents - SubmittedCount;

       -- Return the counts
    SELECT SubmittedCount, NotSubmittedCount;
END;
//
DELIMITER ;




DELIMITER //
CREATE PROCEDURE GetAssignmentDetailsWithSubmission(
    IN p_AssignmentId INT,
    IN p_UserId VARCHAR(30)
)
BEGIN
    -- Fetch assignment details
    SELECT
        A.MaxMarks,
        A.AcceptLateSub,
        A.ReduceMarks,
        GROUP_CONCAT(DISTINCT Att.AttachmentFileURL) AS AssignmentAttachmentURL,
        S.SubmissionText,
        S.SubmissionDate,
        S.Grade,
        S.Remarks,
        S.HasTeacherCorrected,
        GROUP_CONCAT(DISTINCT SubAtt.AttachmentFileURL) AS SubmissionAttachmentURL
    FROM Assignments A
    LEFT JOIN Submissions S ON A.AssignmentId = S.AssignmentId AND S.UserId = p_UserId
    LEFT JOIN Attachments Att ON A.AssignmentId = Att.AssignmentId
    LEFT JOIN Attachments SubAtt ON S.SubmissionId = SubAtt.SubmissionId
    WHERE A.AssignmentId = p_AssignmentId
    GROUP BY A.AssignmentId;
    
END;
//
DELIMITER ;




DELIMITER //
CREATE PROCEDURE GetAllAnnouncements( IN p_ClassId INT)
BEGIN
    -- Fetch announcements with teacher's name and attachment URLs
    SELECT
        A.AnnouncementId,
        A.PostedDate,
        A.LastModifiedDate,
        A.Description,
        U.Name AS TeacherName,
        U.photoUrl,
        GROUP_CONCAT(DISTINCT Att.AttachmentFileURL) AS AnnouncementAttachmentURLs
    FROM Announcement A
    JOIN User U ON A.TeacherId = U.UserId
    LEFT JOIN Attachments Att ON A.AnnouncementId = Att.AnnouncementId
    WHERE A.ClassId = p_ClassId
    GROUP BY A.AnnouncementId
    ORDER BY A.PostedDate DESC;

END;
//
DELIMITER ;
