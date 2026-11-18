--Table is used to store the faculty member login information and id
CREATE TABLE Faculty(
    faculty_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    name                    LINESTRING NOT NULL,
    username                LINESTRING NOT NULL,
    password                LINESTRING NOT NULL,

    PRIMARY KEY(faculty_id),
    UNIQUE KEY faculty_username_unique(username),
    UNIQUE KEY faculty_password_unique(password)
);

--table is used to store the student login information and id
--Used for the /students/<id> and /students/ endpoints to get student information
CREATE TABLE Students(
    student_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    fname                   LINESTRING NOT NULL,
    lname                   LINESTRING NOT NULL,
    username                LINESTRING NOT NULL,
    password                LINESTRING NOT NULL,
    email                   LINESTRING NOT NULL,

    PRIMARY KEY(student_id),
    UNIQUE KEY students_username_unique(username),
    UNIQUE KEY students_password_unique(password),
    UNIQUE KEY students_email_unique(email)
);

--Stores scenarios and who created them.
--Scenarios are also copied and linked to their children scenarios.
--Used for the /scenarios/<id> and /scenarios/ endpoints to get scenario information
--Basis for all the questions, attempts, assignments, etc.
CREATE TABLE Scenarios(
    scenario_id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    faculty_id              BIGINT UNSIGNED NOT NULL,
    name                    TEXT NOT NULL,
    description             LONGTEXT NULL,
    status                  LINESTRING NOT NULL,
    copied_from_id          BIGINT UNSIGNED NULL,

    PRIMARY KEY(scenario_id),
    FOREIGN KEY(faculty_id) references Faculty(faculty_id),
    FOREIGN KEY(copied_from_id) references Scenarios(scenario_id)
    
);

--A profile that serves the questions to the student based on an scenario/question
CREATE TABLE Characters(
    character_id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    scenario_id             BIGINT UNSIGNED NOT NULL,
    name                    LINESTRING NOT NULL,
    role                    TEXT NOT NULL,
    role_description        LONGTEXT NOT NULL,
    PRIMARY KEY(character_id, scenario_id)
);


--Crosses the two tables of students and scenarios to create a many to many relationship
--Used in the /students/<id>/scenarios/<scenario_id> or /students/<id>/scenarios/
CREATE TABLE Assignments(
    assignment_id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id              BIGINT UNSIGNED NOT NULL,
    scenario_id             BIGINT UNSIGNED NOT NULL,
    due_date                DATETIME NULL,
    attempts_allowed        BIGINT UNSIGNED NOT NULL DEFAULT 1,
    status                  LINESTRING NOT NULL,
    
    PRIMARY KEY(assignment_id),
    FOREIGN KEY(student_id) references Students(student_id),
    FOREIGN KEY(scenario_id) references Scenarios(scenario_id)
);

--
CREATE TABLE Attempts(
    attempt_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    assignment_id           BIGINT UNSIGNED NOT NULL,
    attempt_number          INT NOT NULL,
    status                  LINESTRING NOT NULL,
    started_at              DATETIME NOT NULL,
    ended_at                DATETIME NULL, --Ended at is null until the attempt is completed
    score                   INT NULL, --Score is added later, null til then

    PRIMARY KEY(attempt_id, assignment_id),
    FOREIGN KEY(assignment_id) references Assignments(assignment_id)
);

--Check with Murphy about this one?
--original intention is to be a response from the student on what 
--they answered for each question, not what the correct answer for a question is
CREATE TABLE Answer(
    answer_id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    attempt_id              BIGINT UNSIGNED NOT NULL,
    question_id             BIGINT UNSIGNED NOT NULL,
    answer_text             TEXT NOT NULL,

    PRIMARY KEY(answer_id)
);


CREATE TABLE Results(
    result_id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    attempt_id              BIGINT UNSIGNED NOT NULL,
    score                   MULTILINESTRING NOT NULL,
    selfRating              INT NOT NULL

    PRIMARY KEY(result_id),
    FOREIGN KEY(attempt_id) REFERENCES Attempts(attempt_id)
);

--The landing page of the scenario, contains a brief description of the scenario
--Also refers to the first question in the scenario, which is used to start the scenario
--That first question ID is used to get the first question, its info, then serve the next question
--after a post to /questions/next/
CREATE TABLE Briefing(
    scenario_id             BIGINT UNSIGNED NOT NULL,
    character_id            BIGINT UNSIGNED NOT NULL, --NOT a forign key, just a reference to the character in the scenario
    role_description        TEXT NOT NULL,
    company_info            TEXT NOT NULL,
    first_question_id       BIGINT UNSIGNED NOT NULL, --refers to the first question in the scenario
    
    PRIMARY KEY(scenario_id),
    FOREIGN KEY(scenario_id) REFERENCES Scenarios(scenario_id),
    FOREIGN KEY(scenario_id, character_id) REFERENCES Characters(scenario_id, character_id),
    FOREIGN KEY(first_question_id) REFERENCES Questions(question_id)
);


--Used to store each question in a scenario
--Foreign key to scenario it is related to and the character that is
--prompting the question.
--Next question is linked as a reference
--Character_id is nullable because some questions may not be prompted 
--by a character, and refers to the character_id in the Characters table
CREATE TABLE Questions(
    question_id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    scenario_id             BIGINT UNSIGNED NOT NULL,
    character_id            BIGINT UNSIGNED NULL,
    text                    TEXT NOT NULL,
    next_question_id        BIGINT UNSIGNED NULL, --Sends the questions after post with current_question_id
    
    PRIMARY KEY(question_id),
    FOREIGN KEY(scenario_id) REFERENCES Scenarios(scenario_id),
    FOREIGN KEY(character_id) REFERENCES Characters(character_id),
    FOREIGN KEY(next_question_id) REFERENCES Questions(question_id) ON DELETE SET NULL
    
);