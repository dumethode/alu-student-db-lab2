-- ALU Rwanda Student Performance Database
-- Group: Coding Lab 2
-- Course: Database Systems
-- Date: August 2025

-- Drop existing database if it exists to ensure clean setup
DROP DATABASE IF EXISTS alu_student_performance;
CREATE DATABASE alu_student_performance;
USE alu_student_performance;

-- ================================================================
-- TABLE CREATION SECTION
-- ================================================================

-- Create students table to store basic student information
CREATE TABLE students (
    student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_name VARCHAR(100) NOT NULL,
    intake_year INT NOT NULL CHECK (intake_year >= 2020 AND intake_year <= 2025)
);

-- Create linux_grades table to track Linux course performance
CREATE TABLE linux_grades (
    course_id VARCHAR(20) PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL DEFAULT 'Linux Fundamentals',
    student_id INT NOT NULL,
    grade_obtained DECIMAL(5,2) NOT NULL CHECK (grade_obtained >= 0 AND grade_obtained <= 100),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

-- Create python_grades table to track Python course performance
CREATE TABLE python_grades (
    course_id VARCHAR(20) PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL DEFAULT 'Python Programming',
    student_id INT NOT NULL,
    grade_obtained DECIMAL(5,2) NOT NULL CHECK (grade_obtained >= 0 AND grade_obtained <= 100),
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
);

-- ================================================================
-- QUERY 1: INSERT SAMPLE DATA
-- ================================================================

-- Insert diverse student data representing different intake years and backgrounds
INSERT INTO students (student_name, intake_year) VALUES
('Amina Uwimana', 2023),           -- Rwanda
('James Ochieng', 2024),           -- Kenya
('Fatima Al-Zahra', 2022),         -- Morocco
('Samuel Nkomo', 2023),            -- Zimbabwe
('Grace Mensah', 2024),            -- Ghana
('Omar Hassan', 2022),             -- Sudan
('Nalaka Perera', 2023),           -- Sri Lanka
('Adaora Okwu', 2024),             -- Nigeria
('Thierry Mugisha', 2022),         -- Rwanda
('Priya Sharma', 2023),            -- India
('David Tembo', 2024),             -- Zambia
('Aisha Kone', 2022),              -- Mali
('Michael Chen', 2023),            -- China
('Leila Benjelloun', 2024),        -- Morocco
('Joseph Kamau', 2022),            -- Kenya
('Nadia Osman', 2023),             -- Ethiopia
('Robert Ndayisenga', 2024),       -- Rwanda
('Zara Ibrahim', 2022);            -- Nigeria

-- Insert Linux grades data (mix of students with varying performance)
INSERT INTO linux_grades (course_id, course_name, student_id, grade_obtained) VALUES
('LNX2023-001', 'Linux System Administration', 1, 78.50),
('LNX2024-002', 'Linux Fundamentals', 2, 42.25),
('LNX2022-003', 'Advanced Linux', 3, 89.75),
('LNX2023-004', 'Linux Networking', 4, 34.80),
('LNX2024-005', 'Linux Security', 5, 91.20),
('LNX2022-006', 'Linux Shell Scripting', 7, 67.40),
('LNX2023-007', 'Linux Server Management', 8, 45.60),
('LNX2024-008', 'Linux Fundamentals', 9, 83.90),
('LNX2022-009', 'Linux System Administration', 11, 72.30),
('LNX2023-010', 'Linux Networking', 13, 56.80),
('LNX2024-011', 'Advanced Linux', 14, 38.70),
('LNX2022-012', 'Linux Security', 16, 94.40),
('LNX2023-013', 'Linux Fundamentals', 17, 81.60);

-- Insert Python grades data (different mix of students, some overlap with Linux)
INSERT INTO python_grades (course_id, course_name, student_id, grade_obtained) VALUES
('PYT2023-001', 'Python Basics', 1, 85.30),
('PYT2024-002', 'Python Web Development', 3, 92.80),
('PYT2022-003', 'Data Science with Python', 5, 88.70),
('PYT2023-004', 'Python Automation', 6, 76.20),
('PYT2024-005', 'Machine Learning Python', 7, 41.90),
('PYT2022-006', 'Python GUI Development', 8, 79.50),
('PYT2023-007', 'Python Basics', 10, 63.40),
('PYT2024-008', 'Advanced Python', 12, 95.20),
('PYT2022-009', 'Python Web Development', 13, 48.60),
('PYT2023-010', 'Data Science with Python', 15, 87.90),
('PYT2024-011', 'Python Automation', 16, 93.10),
('PYT2022-012', 'Python Basics', 18, 71.80),
('PYT2023-013', 'Machine Learning Python', 4, 69.50),
('PYT2024-014', 'Advanced Python', 11, 84.20);

-- ================================================================
-- QUERY 2: FIND STUDENTS WHO SCORED LESS THAN 50% IN LINUX COURSE
-- ================================================================

-- This query identifies underperforming students in Linux who need academic support
SELECT 
    s.student_id,
    s.student_name,
    s.intake_year,
    lg.course_name,
    lg.grade_obtained
FROM students s
INNER JOIN linux_grades lg ON s.student_id = lg.student_id
WHERE lg.grade_obtained < 50.00
ORDER BY lg.grade_obtained ASC;

-- ================================================================
-- QUERY 3: FIND STUDENTS WHO TOOK ONLY ONE COURSE (EITHER LINUX OR PYTHON)
-- ================================================================

-- Using UNION to combine students who took only Linux or only Python
-- Students who took only Linux (not in Python grades)
SELECT 
    s.student_id,
    s.student_name,
    'Linux Only' as course_taken,
    lg.grade_obtained
FROM students s
INNER JOIN linux_grades lg ON s.student_id = lg.student_id
WHERE s.student_id NOT IN (
    SELECT DISTINCT student_id FROM python_grades
)

UNION ALL

-- Students who took only Python (not in Linux grades)
SELECT 
    s.student_id,
    s.student_name,
    'Python Only' as course_taken,
    pg.grade_obtained
FROM students s
INNER JOIN python_grades pg ON s.student_id = pg.student_id
WHERE s.student_id NOT IN (
    SELECT DISTINCT student_id FROM linux_grades
)
ORDER BY student_id;

-- ================================================================
-- QUERY 4: FIND STUDENTS WHO TOOK BOTH COURSES
-- ================================================================

-- Using INNER JOIN to find intersection of students in both courses
SELECT 
    s.student_id,
    s.student_name,
    s.intake_year,
    lg.course_name as linux_course,
    lg.grade_obtained as linux_grade,
    pg.course_name as python_course,
    pg.grade_obtained as python_grade
FROM students s
INNER JOIN linux_grades lg ON s.student_id = lg.student_id
INNER JOIN python_grades pg ON s.student_id = pg.student_id
ORDER BY s.student_name;

-- ================================================================
-- QUERY 5: CALCULATE AVERAGE GRADE PER COURSE (LINUX AND PYTHON SEPARATELY)
-- ================================================================

-- Calculate comprehensive statistics for each course
SELECT 
    'Linux Fundamentals' as course_type,
    COUNT(*) as total_students,
    ROUND(AVG(grade_obtained), 2) as average_grade,
    ROUND(MIN(grade_obtained), 2) as lowest_grade,
    ROUND(MAX(grade_obtained), 2) as highest_grade,
    ROUND(STDDEV(grade_obtained), 2) as grade_std_deviation
FROM linux_grades

UNION ALL

SELECT 
    'Python Programming' as course_type,
    COUNT(*) as total_students,
    ROUND(AVG(grade_obtained), 2) as average_grade,
    ROUND(MIN(grade_obtained), 2) as lowest_grade,
    ROUND(MAX(grade_obtained), 2) as highest_grade,
    ROUND(STDDEV(grade_obtained), 2) as grade_std_deviation
FROM python_grades;

-- ================================================================
-- QUERY 6: IDENTIFY TOP-PERFORMING STUDENT ACROSS BOTH COURSES
-- ================================================================

-- Find student with highest average grade across both courses
-- Using subquery to calculate averages and identify the top performer
SELECT 
    combined_grades.student_id,
    combined_grades.student_name,
    combined_grades.intake_year,
    combined_grades.total_courses,
    combined_grades.overall_average,
    combined_grades.linux_grade,
    combined_grades.python_grade,
    CASE 
        WHEN combined_grades.overall_average >= 90 THEN 'Excellent'
        WHEN combined_grades.overall_average >= 80 THEN 'Very Good'
        WHEN combined_grades.overall_average >= 70 THEN 'Good'
        WHEN combined_grades.overall_average >= 60 THEN 'Satisfactory'
        ELSE 'Needs Improvement'
    END as performance_category
FROM (
    SELECT 
        s.student_id,
        s.student_name,
        s.intake_year,
        COUNT(*) as total_courses,
        ROUND(AVG(all_grades.grade), 2) as overall_average,
        MAX(CASE WHEN all_grades.course_type = 'Linux' THEN all_grades.grade END) as linux_grade,
        MAX(CASE WHEN all_grades.course_type = 'Python' THEN all_grades.grade END) as python_grade
    FROM students s
    INNER JOIN (
        -- Combine all grades from both courses
        SELECT student_id, grade_obtained as grade, 'Linux' as course_type
        FROM linux_grades
        UNION ALL
        SELECT student_id, grade_obtained as grade, 'Python' as course_type
        FROM python_grades
    ) all_grades ON s.student_id = all_grades.student_id
    GROUP BY s.student_id, s.student_name, s.intake_year
    HAVING total_courses >= 2  -- Only students who took both courses
) combined_grades
ORDER BY combined_grades.overall_average DESC
LIMIT 1;

-- ================================================================
-- ADDITIONAL ANALYTICAL QUERIES FOR ENHANCED INSIGHTS
-- ================================================================

-- Bonus Query: Performance distribution by intake year
SELECT 
    s.intake_year,
    COUNT(DISTINCT s.student_id) as students_count,
    ROUND(AVG(CASE WHEN lg.grade_obtained IS NOT NULL THEN lg.grade_obtained END), 2) as avg_linux_grade,
    ROUND(AVG(CASE WHEN pg.grade_obtained IS NOT NULL THEN pg.grade_obtained END), 2) as avg_python_grade
FROM students s
LEFT JOIN linux_grades lg ON s.student_id = lg.student_id
LEFT JOIN python_grades pg ON s.student_id = pg.student_id
GROUP BY s.intake_year
ORDER BY s.intake_year;

-- Bonus Query: Course enrollment statistics
SELECT 
    'Total Students' as metric,
    COUNT(*) as count
FROM students

UNION ALL

SELECT 
    'Linux Enrolled' as metric,
    COUNT(DISTINCT student_id) as count
FROM linux_grades

UNION ALL

SELECT 
    'Python Enrolled' as metric,
    COUNT(DISTINCT student_id) as count
FROM python_grades

UNION ALL

SELECT 
    'Both Courses' as metric,
    COUNT(*) as count
FROM (
    SELECT student_id
    FROM linux_grades
    WHERE student_id IN (SELECT student_id FROM python_grades)
) dual_enrollment;