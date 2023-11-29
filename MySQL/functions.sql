DELIMITER //

CREATE FUNCTION GetNumberOfStudentsEnrolled(p_ClassId INT) RETURNS INT
BEGIN
    DECLARE numStudents INT;

    -- Get the number of students enrolled in the specified class
    SELECT COUNT(*) INTO numStudents
    FROM Enrollments
    WHERE ClassId = p_ClassId AND Role = 'Student';

    RETURN numStudents;
END;

//

DELIMITER ;
