
CREATE TABLE Faculty(
    faculty_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    name                    LINESTRING NOT NULL,
    username                LINESTRING NOT NULL,
    password                LINESTRING NOT NULL,
    UNIQUE KEY faculty_username_unique(username),
    UNIQUE KEY faculty_password_unique(password)
);


CREATE TABLE Students(
    student_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    fname                   LINESTRING NOT NULL,
    lname                   LINESTRING NOT NULL,
    username                LINESTRING NOT NULL,
    password                LINESTRING NOT NULL,
    email                   LINESTRING NOT NULL,
    UNIQUE KEY students_username_unique(username),
    UNIQUE KEY students_password_unique(password),
    UNIQUE KEY students_email_unique(email)
);


CREATE TABLE Scenarios(
    scenario_id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    faculty_id              BIGINT NOT NULL,
    title                   TEXT NOT NULL,
    description             LONGTEXT NULL,
    duration                INT NULL,
    company_info            BIGINT NOT NULL,
    status                  LINESTRING NOT NULL,
    copied_from_id          BIGINT NOT NULL,
    PRIMARY KEY(scenario_id),
    FOREIGN KEY(faculty_id) references Faculty(faculty_id)
    
);


CREATE TABLE Characters(
    character_id            BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    scenario_id             BIGINT NOT NULL,
    name                    LINESTRING NOT NULL,
    role                    TEXT NOT NULL,
    icon_color              LINESTRING NOT NULL,
    role_description        LONGTEXT NOT NULL,
    PRIMARY KEY(character_id, scenario_id)
);


CREATE TABLE Documents(
    document_id             BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    scenario_id             BIGINT NOT NULL,
    title                   TEXT NOT NULL,
    file_type               LINESTRING NOT NULL,
    contents                BLOB NOT NULL,
    description             MEDIUMTEXT NULL
);


CREATE TABLE Assignments(
    student_id              BIGINT NOT NULL,
    scenario_id             BIGINT NOT NULL,
    due_date                DATETIME NULL,
    attempts_allowed        BIGINT NOT NULL COMMENT 'Default 1',
    status                  LINESTRING NOT NULL,
    CONSTRAINT composite_assignment_key PRIMARY KEY(student_id, scenario_id),
    FOREIGN KEY(student_id) references Students(student_id),
    FOREIGN KEY(scenario_id) references Scenarios(scenario_id)
);


CREATE TABLE Attempts(
    attempt_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id              BIGINT NOT NULL,
    assignment_id           BIGINT NOT NULL,
    attempt_number          INT NOT NULL,
    status                  LINESTRING NOT NULL,
    started_at              DATETIME NOT NULL,
    ended_at DATETIME NULL,
    CONSTRAINT composite_attempt_key PRIMARY KEY(student_id, assignment_id)
);


CREATE TABLE Results(
    result_id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    attempt_id              BIGINT NOT NULL,
    skill_id                MULTILINESTRING NOT NULL,
    score                   MULTILINESTRING NOT NULL,
    selfRating              INT NOT NULL
);


CREATE TABLE Briefing(
    scenario_id             BIGINT NOT NULL,
    character_id            BIGINT NOT NULL, --NOT a forign key, just a reference to the character in the scenario
    role_description        TEXT NOT NULL,
    company_info            TEXT NOT NULL
    PRIMARY KEY(scenario_id) REFERENCES Scenarios(scenario_id) --Possibly wrong to do it this way?
);

--Checkpoint tbale and evaluations table are probably not ready yet
CREATE TABLE Checkpoint(
    checkpoint_id           BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    scenario_id             BIGINT NOT NULL,
    skill_ids               TEXT NOT NULL, --NOT a forign key, just a reference to the skills in the scenario
    scale_min               FLOAT(53) NOT NULL,
    scale_max               FLOAT(53) NOT NULL,
    PRIMARY KEY(scenario_id)
);


CREATE TABLE evaluations(
    attempt_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT, --foreign key???
    checkpoint_id           BIGINT NOT NULL,
    skill_ids               MULTILINESTRING NOT NULL, --NOT a forign key, just a reference to the skills in the scenario
    ratings                 MULTILINESTRING NOT NULL,   --ratings associated to the skills
    PRIMARY KEY(checkpoint_id)
);
--Check on the above tables

CREATE TABLE Messages(
    message_id              BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    scenario_id             BIGINT NOT NULL, --foreign key???
    character_id            BIGINT NULL,    --foreign key???
    text                    TEXT NOT NULL,
    settings                BLOB NOT NULL,
    type                    TEXT NOT NULL,
    PRIMARY KEY(scenario_id (fk))
);


CREATE TABLE Feedback Responses(
    attempt_id (fk)         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    message_id (fk)         BIGINT NOT NULL,
    chosen_option_id (fk)   BIGINT NOT NULL,
    feedback                TEXT NOT NULL,
    skill_id (fk)           BIGINT NOT NULL,
    score                   FLOAT(53) NOT NULL,
    PRIMARY KEY(message_id (fk))
);
ALTER TABLE
    Feedback Responses ADD PRIMARY KEY(chosen_option_id (fk));


CREATE TABLE Options(
    option_id               BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    attempt_id (fk)         BIGINT NOT NULL,
    message_id (fk)         BIGINT NOT NULL,
    skill_id(s)             MULTILINESTRING NOT NULL,
    skill_score(s)          MULTILINESTRING NOT NULL,
    PRIMARY KEY(attempt_id (fk))
);
ALTER TABLE
    Options ADD PRIMARY KEY(message_id (fk));


CREATE TABLE Skill Scores(
    skill_id                BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    student_id(fk)          BIGINT NOT NULL,
    score                   FLOAT(53) NOT NULL,
    PRIMARY KEY(student_id(fk))
);
