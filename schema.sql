-- Table is used to store the faculty member login information and id
CREATE TABLE Faculty(
    faculty_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    fname                   VARCHAR(100) NOT NULL,
    lname                   VARCHAR(100) NOT NULL,
    username                VARCHAR(100) NOT NULL,
    password                VARCHAR(255) NOT NULL,

    PRIMARY KEY(faculty_id),
    UNIQUE KEY faculty_username_unique(username),
    UNIQUE KEY faculty_password_unique(password)
);

-- table is used to store the student login information and id
-- Used for the /students/<id> and /students/ endpoints to get student information
CREATE TABLE Students(
    student_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    fname                   VARCHAR(100) NOT NULL,
    lname                   VARCHAR(100) NOT NULL,
    username                VARCHAR(100) NOT NULL,
    password                VARCHAR(255) NOT NULL,
    email                   VARCHAR(255) NOT NULL,

    PRIMARY KEY(student_id),
    UNIQUE KEY students_username_unique(username),
    UNIQUE KEY students_email_unique(email)
);

-- Stores scenarios and who created them.
-- Scenarios are also copied and linked to their children scenarios.
-- Used for the /scenarios/<id> and /scenarios/ endpoints to get scenario information
-- Basis for all the questions, attempts, assignments, etc.
CREATE TABLE Scenarios(
    scenario_id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    faculty_id              BIGINT UNSIGNED NOT NULL,
    name                    VARCHAR(255) NOT NULL,
    description             LONGTEXT NULL,
    status                  varchar(30) NOT NULL,
    copied_from_id          BIGINT UNSIGNED NULL,

    PRIMARY KEY(scenario_id),
    
    CONSTRAINT scenarios_faculty_fk
        FOREIGN KEY (faculty_id)
        REFERENCES Faculty (faculty_id)
        ON DELETE RESTRICT,

    CONSTRAINT scenarios_copied_from_fk
        FOREIGN KEY (copied_from_id)
        REFERENCES Scenarios (scenario_id)
        ON DELETE SET NULL
    
);

-- A profile that serves the questions to the student based on an scenario/question
CREATE TABLE Characters(
    character_id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    scenario_id             BIGINT UNSIGNED NOT NULL,
    name                    VARCHAR(200) NOT NULL,
    role                    VARCHAR(255) NOT NULL,
    role_description        LONGTEXT NOT NULL,

    PRIMARY KEY(character_id, scenario_id)

    -- Allows foreign keys to verify that a character belongs to a scenario.
    UNIQUE KEY characters_scenario_character_unique (
        scenario_id,
        character_id
    ),

    CONSTRAINT characters_scenario_fk
        FOREIGN KEY (scenario_id)
        REFERENCES Scenarios (scenario_id)
        ON DELETE RESTRICT
    
);


-- Crosses the two tables of students and scenarios to create a many to many relationship
-- Used in the /students/<id>/scenarios/<scenario_id> or /students/<id>/scenarios/
CREATE TABLE Assignments(
    assignment_id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id              BIGINT UNSIGNED NOT NULL,
    scenario_id             BIGINT UNSIGNED NOT NULL,
    due_date                DATETIME NULL,
    attempts_allowed        BIGINT UNSIGNED NOT NULL DEFAULT 1,
    status                  varchar(30) NOT NULL,
    
    PRIMARY KEY(assignment_id),

    -- A student may receive a particular scenario only once.
    UNIQUE KEY assignments_student_scenario_unique (
        student_id,
        scenario_id
    ),
   
    -- Supports scenario-consistent references from Attempts.
    UNIQUE KEY assignments_assignment_scenario_unique (
        assignment_id,
        scenario_id
    ),

    CONSTRAINT assignments_student_fk
        FOREIGN KEY (student_id)
        REFERENCES Students (student_id)
        ON DELETE RESTRICT,

    CONSTRAINT assignments_scenario_fk
        FOREIGN KEY (scenario_id)
        REFERENCES Scenarios (scenario_id)
        ON DELETE RESTRICT,

    CONSTRAINT assignments_attempts_allowed_check
        CHECK (attempts_allowed >= 1)

);

-- Stores each attempt at an assignment.
-- scenario_id ensures that answers match the assigned scenario.
CREATE TABLE Attempts(
    attempt_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    assignment_id           BIGINT UNSIGNED NOT NULL,
    attempt_number          INT NOT NULL,
    status                  varchar(30) NOT NULL,
    started_at              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ended_at                DATETIME NULL, --Ended at is null until the attempt is completed
    score                   DECIMAL NULL, --Score is added later, null til then

    -- Score is added later, null til then
    -- Updated: score is now stored only in Results. Until grading,
    -- the attempt has no Results row rather than a nullable score here.

    PRIMARY KEY (attempt_id),

    UNIQUE KEY attempts_assignment_number_unique (
        assignment_id,
        attempt_number
    ),

    -- Supports scenario-consistent references from Answers.
    UNIQUE KEY attempts_attempt_scenario_unique (
        attempt_id,
        scenario_id
    ),

    CONSTRAINT attempts_assignment_fk
        FOREIGN KEY (assignment_id, scenario_id)
        REFERENCES Assignments (assignment_id, scenario_id)
        ON DELETE RESTRICT,

    CONSTRAINT attempts_number_check
        CHECK (attempt_number >= 1),

    CONSTRAINT attempts_dates_check
        CHECK (ended_at IS NULL OR ended_at >= started_at) 
);

-- Used to store each question in a scenario
-- Foreign key to scenario it is related to and the character that is
-- prompting the question.
-- Next question is linked as a reference
-- Character_id is nullable because some questions may not be prompted 
-- by a character, and refers to the character_id in the Characters table
CREATE TABLE Questions(
    question_id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    scenario_id             BIGINT UNSIGNED NOT NULL,
    character_id            BIGINT UNSIGNED NULL,
    text                    TEXT NOT NULL,
    
    -- Sends the questions after post with current_question_id
    next_question_id        BIGINT UNSIGNED NULL,


    PRIMARY KEY(question_id),
    
    UNIQUE KEY questions_scenario_question_unique (
        scenario_id,
        question_id
    ),

    CONSTRAINT questions_scenario_fk
        FOREIGN KEY (scenario_id)
        REFERENCES Scenarios (scenario_id)
        ON DELETE RESTRICT,

    CONSTRAINT questions_character_fk
        FOREIGN KEY (scenario_id, character_id)
        REFERENCES Characters (scenario_id, character_id)
        ON DELETE RESTRICT,

    -- The next question must belong to the same scenario.
    -- Unlink references before deleting the referenced question.
    -- SET NULL cannot be used here because scenario_id is NOT NULL.
    CONSTRAINT questions_next_question_fk
        FOREIGN KEY (scenario_id, next_question_id)
        REFERENCES Questions (scenario_id, question_id)
        ON DELETE RESTRICT

);

-- Check with Murphy about this one?
-- original intention is to be a response from the student on what 
-- they answered for each question, not what the correct answer for a question is
CREATE TABLE Answer(
    answer_id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    attempt_id              BIGINT UNSIGNED NOT NULL,
    scenario_id             BIGINT UNSIGNED NOT NULL,
    question_id             BIGINT UNSIGNED NOT NULL,
    answer_text             TEXT NOT NULL,

    PRIMARY KEY(answer_id),

    -- One stored response per question per attempt.
    UNIQUE KEY answers_attempt_question_unique (
        attempt_id,
        question_id
    ),

    -- These foreign keys ensure that the attempt and question
    -- belong to the same scenario.
    CONSTRAINT answers_attempt_fk
        FOREIGN KEY (attempt_id, scenario_id)
        REFERENCES Attempts (attempt_id, scenario_id)
        ON DELETE RESTRICT,

    CONSTRAINT answers_question_fk
        FOREIGN KEY (scenario_id, question_id)
        REFERENCES Questions (scenario_id, question_id)
        ON DELETE RESTRICT
);

-- Stores the final result for an attempt.
-- An attempt may have no result yet, but cannot have multiple results.
CREATE TABLE Results(
    result_id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    attempt_id              BIGINT UNSIGNED NOT NULL,
    score                   INT NOT NULL,
    selfRating              INT NOT NULL,

    PRIMARY KEY (result_id),    
    UNIQUE KEY results_attempt_unique (attempt_id),

    CONSTRAINT results_attempt_fk
        FOREIGN KEY (attempt_id)
        REFERENCES Attempts (attempt_id)
        ON DELETE RESTRICT,

    CONSTRAINT results_score_check
        CHECK (score >= 0)
);

-- The landing page of the scenario, contains a brief description of the scenario
-- Also refers to the first question in the scenario, which is used to start the scenario
-- That first question ID is used to get the first question, its info, then serve the next question
-- after a post to /questions/next/
CREATE TABLE Briefing(
    scenario_id             BIGINT UNSIGNED NOT NULL,
    character_id            BIGINT UNSIGNED NOT NULL,
    role_description        TEXT NOT NULL,
    company_info            TEXT NOT NULL,
    first_question_id       BIGINT UNSIGNED NOT NULL, --refers to the first question in the scenario
    
    PRIMARY KEY (scenario_id),

    CONSTRAINT briefing_scenario_fk
        FOREIGN KEY (scenario_id)
        REFERENCES Scenarios (scenario_id)
        ON DELETE RESTRICT,

    CONSTRAINT briefing_character_fk
        FOREIGN KEY (scenario_id, character_id)
        REFERENCES Characters (scenario_id, character_id)
        ON DELETE RESTRICT,

    CONSTRAINT briefing_first_question_fk
        FOREIGN KEY (scenario_id, first_question_id)
        REFERENCES Questions (scenario_id, question_id)
        ON DELETE RESTRICT        
);


