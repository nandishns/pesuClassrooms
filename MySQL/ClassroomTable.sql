-- CREATE TABLE IF NOT EXISTS Courses (
--   CourseId VARCHAR(30) NOT NULL,
--   CourseName VARCHAR(100) NOT NULL,
--   Description TEXT,
--   InstructorId VARCHAR(30) NOT NULL,
--   StartDate DATE,
--   EndDate DATE,
--   PRIMARY KEY (CourseId),
--   FOREIGN KEY (InstructorId) REFERENCES User(UserId)
-- );



-- CREATE TABLE IF NOT EXISTS Enrollments (
--   EnrollmentId INT AUTO_INCREMENT PRIMARY KEY,
--   StudentId VARCHAR(30) NOT NULL,
--   CourseId VARCHAR(30) NOT NULL,
--   EnrollmentDate DATE NOT NULL,
--   FOREIGN KEY (StudentId) REFERENCES User(UserId),
--   FOREIGN KEY (CourseId) REFERENCES Courses(CourseId),
--   UNIQUE (StudentId, CourseId)
-- );


CREATE TABLE IF NOT EXISTS Classes (
  ClassId INT AUTO_INCREMENT PRIMARY KEY,
  ClassName VARCHAR(100) NOT NULL,
  Description TEXT,
  CreationDate DATE NOT NULL,
  TeacherId VARCHAR(30) NOT NULL,
 
);

CREATE TABLE IF NOT EXISTS Enrollments (
  EnrollmentId INT AUTO_INCREMENT PRIMARY KEY,
  UserId VARCHAR(30) NOT NULL,
  ClassId INT NOT NULL,
  Role VARCHAR(20) NOT NULL,
  FOREIGN KEY (UserId) REFERENCES User(UserId),
  FOREIGN KEY (ClassId) REFERENCES Classes(ClassId)
);
ALTER TABLE Classes
ADD CONSTRAINT FK_TeacherId
FOREIGN  KEY (TeacherId) REFERENCES User(UserId);