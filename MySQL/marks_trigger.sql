DELIMITER //

CREATE TRIGGER before_submission_insert
BEFORE INSERT ON Submissions
FOR EACH ROW
BEGIN
    DECLARE assignment_due_date DATETIME;
    DECLARE submission_date DATETIME;
    DECLARE days_late INT;

    -- Get the due date of the corresponding assignment
    SELECT DueDate INTO assignment_due_date
    FROM Assignments
    WHERE AssignmentId = NEW.AssignmentId;

    -- Get the submission date
    SET submission_date = IFNULL(NEW.SubmissionDate, NOW());

    -- Calculate the number of days late
    SET days_late = IF(submission_date > assignment_due_date, 
                      DATEDIFF(submission_date, assignment_due_date), 
                      0);

    -- Check if late submissions are accepted and calculate the reduced marks
    IF days_late > 0 AND (SELECT AcceptLateSub FROM Assignments WHERE AssignmentId = NEW.AssignmentId) = 1 THEN
        SET NEW.Remarks = CONCAT('Submitted ', days_late, ' days late.');
        SET NEW.Grade = GREATEST(0, (SELECT MaxMarks FROM Assignments WHERE AssignmentId = NEW.AssignmentId) - (days_late * (SELECT ReduceMarks FROM Assignments WHERE AssignmentId = NEW.AssignmentId)));
    ELSE
        SET NEW.Remarks = NULL;
        SET NEW.Grade = NULL;
    END IF;

END;

//

DELIMITER ;
