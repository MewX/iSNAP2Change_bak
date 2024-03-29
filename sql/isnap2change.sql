#mysql -uroot -p.kHdGCD2Un%P
#mysql -uroot -p.kHdGCD2Un%P < isnap2change.sql

CREATE DATABASE IF NOT EXISTS log;
USE log;
CREATE TABLE IF NOT EXISTS `Log` (
  LogID             MEDIUMINT AUTO_INCREMENT,
  PageName          TEXT,
  RequestMethod     TEXT,
  RequestParameters TEXT,
  SessionDump       TEXT,
  ExceptionMessage  LONGTEXT,
  ExceptionTrace    LONGTEXT,
  UserFeedback      TEXT,
  Solved            BOOLEAN   DEFAULT 0,
  LogTime           TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT Log_LogID_PK PRIMARY KEY (LogID)
)
  ENGINE = INNODB;


CREATE DATABASE IF NOT EXISTS isnap2changedb;
USE isnap2changedb;

SET FOREIGN_KEY_CHECKS = 0;

# [Assert] Lines of Drop table declaration = Lines of Create table declaration
DROP TABLE IF EXISTS School;
DROP TABLE IF EXISTS Class;
DROP TABLE IF EXISTS Student;
DROP TABLE IF EXISTS Researcher;
DROP TABLE IF EXISTS Snap_Fact;
DROP TABLE IF EXISTS Verbose_Fact;
DROP TABLE IF EXISTS Topic;
DROP TABLE IF EXISTS Learning_Material;
DROP TABLE IF EXISTS Student_Week_Record;
DROP TABLE IF EXISTS Quiz;
DROP TABLE IF EXISTS Quiz_Record;
DROP TABLE IF EXISTS MCQ_Section;
DROP TABLE IF EXISTS MCQ_Question;
DROP TABLE IF EXISTS MCQ_Option;
DROP TABLE IF EXISTS MCQ_Question_Record;
DROP TABLE IF EXISTS SAQ_Section;
DROP TABLE IF EXISTS SAQ_Question;
DROP TABLE IF EXISTS SAQ_Question_Record;
DROP TABLE IF EXISTS Matching_Section;
DROP TABLE IF EXISTS Matching_Question;
DROP TABLE IF EXISTS Matching_Option;
DROP TABLE IF EXISTS Poster_Section;
DROP TABLE IF EXISTS Poster_Record;
DROP TABLE IF EXISTS Misc_Section;
DROP TABLE IF EXISTS Game;
DROP TABLE IF EXISTS Game_Record;
DROP TABLE IF EXISTS Recipe;
DROP TABLE IF EXISTS Recipe_Ingredient;
DROP TABLE IF EXISTS Recipe_Nutrition;
DROP TABLE IF EXISTS Recipe_Step;
DROP TABLE IF EXISTS Student_Question;
DROP TABLE IF EXISTS Student_Question_Feedback;
DROP TABLE IF EXISTS Public_Question;

CREATE TABLE IF NOT EXISTS `School` (
  SchoolID   MEDIUMINT AUTO_INCREMENT,
  SchoolName VARCHAR(190) UNIQUE,
  CONSTRAINT School_SchoolID_PK PRIMARY KEY (SchoolID)
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Class` (
  ClassID          MEDIUMINT             AUTO_INCREMENT,
  ClassName        VARCHAR(190) NOT NULL UNIQUE,
  SchoolID         MEDIUMINT    NOT NULL,
  TokenString      VARCHAR(100) NOT NULL UNIQUE,
  # UnlockedProgress
  UnlockedProgress MEDIUMINT    NOT NULL DEFAULT 10,
  CONSTRAINT Class_ClassID_PK PRIMARY KEY (ClassID),
  CONSTRAINT Class_SchoolID_FK FOREIGN KEY (SchoolID)
  REFERENCES School (SchoolID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Student` (
  StudentID      MEDIUMINT AUTO_INCREMENT,
  Username       TEXT      NOT NULL,
  Nickname       TEXT,
  FirstName      TEXT,
  LastName       TEXT,
  `Password`     TEXT      NOT NULL,
  Email          TEXT,
  Gender         TEXT,
  DOB            DATE,
  Identity       TEXT,
  Score          MEDIUMINT DEFAULT 0,
  SubmissionTime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  ClassID        MEDIUMINT NOT NULL,
  CONSTRAINT Student_StudentID_PK PRIMARY KEY (StudentID),
  CONSTRAINT Student_ClassID_FK FOREIGN KEY (ClassID)
  REFERENCES Class (ClassID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Researcher` (
  ResearcherID MEDIUMINT AUTO_INCREMENT,
  Username     TEXT NOT NULL,
  `Password`   TEXT NOT NULL,
  CONSTRAINT Researcher_ResearcherID_PK PRIMARY KEY (ResearcherID)
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Snap_Fact` (
  SnapFactID MEDIUMINT AUTO_INCREMENT,
  Content    TEXT,
  TopicID    MEDIUMINT,
  CONSTRAINT Snap_Fact_SnapFactID_PK PRIMARY KEY (SnapFactID),
  CONSTRAINT Snap_Fact_TopicID_FK FOREIGN KEY (TopicID)
  REFERENCES Topic (TopicID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Verbose_Fact` (
  VerboseFactID MEDIUMINT AUTO_INCREMENT,
  Title         TEXT,
  Content       TEXT,
  TopicID       MEDIUMINT NOT NULL,
  CONSTRAINT Verbose_Fact_VerboseFactID_PK PRIMARY KEY (VerboseFactID),
  CONSTRAINT Verbose_Fact_Topic_FK FOREIGN KEY (TopicID)
  REFERENCES Topic (TopicID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Topic` (
  TopicID   MEDIUMINT AUTO_INCREMENT,
  TopicName VARCHAR(190) UNIQUE,
  CONSTRAINT Topic_TopicID_PK PRIMARY KEY (TopicID)
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Quiz` (
  QuizID    MEDIUMINT AUTO_INCREMENT,
  Week      MEDIUMINT,
  QuizType  ENUM ('SAQ', 'MCQ', 'Matching', 'Poster', 'Misc'),
  ExtraQuiz BOOLEAN   DEFAULT 0,
  TopicID   MEDIUMINT,
  CONSTRAINT Quiz_QuizID_PK PRIMARY KEY (QuizID),
  CONSTRAINT Quiz_TopicID_FK FOREIGN KEY (TopicID)
  REFERENCES Topic (TopicID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Quiz_Record` (
  QuizID    MEDIUMINT,
  StudentID MEDIUMINT,
  `Status`  ENUM ('UNSUBMITTED', 'UNGRADED', 'GRADED') DEFAULT 'GRADED',
  Viewed    BOOLEAN                                    DEFAULT 0,
  CONSTRAINT Quiz_Record_PK PRIMARY KEY (QuizID, StudentID),
  CONSTRAINT Quiz_Record_QuizID_FK FOREIGN KEY (QuizID)
  REFERENCES Quiz (QuizID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT Quiz_Record_StudentID_FK FOREIGN KEY (StudentID)
  REFERENCES Student (StudentID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Learning_Material` (
  QuizID   MEDIUMINT,
  Content  LONGTEXT,
  Excluded MEDIUMINT DEFAULT 0,
  CONSTRAINT Learning_Material_QuizID_PK PRIMARY KEY (QuizID),
  CONSTRAINT Learning_Material_QuizID_FK FOREIGN KEY (QuizID)
  REFERENCES Quiz (QuizID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Student_Week_Record` (
  StudentID MEDIUMINT,
  Week      MEDIUMINT,
  DueTime   TIMESTAMP,
  CONSTRAINT Student_Week_Record_PK PRIMARY KEY (StudentID, Week),
  CONSTRAINT Student_Week_Record_StudentID_FK FOREIGN KEY (StudentID)
  REFERENCES Student (StudentID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `MCQ_Section` (
  QuizID MEDIUMINT,
  Points MEDIUMINT DEFAULT 0,
  CONSTRAINT MCQ_Section_QuizID_PK PRIMARY KEY (QuizID),
  CONSTRAINT MCQ_Section_QuizID_FK FOREIGN KEY (QuizID)
  REFERENCES Quiz (QuizID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `MCQ_Question` (
  MCQID         MEDIUMINT AUTO_INCREMENT,
  Question      TEXT,
  CorrectChoice MEDIUMINT DEFAULT NULL,
  QuizID        MEDIUMINT,
  CONSTRAINT MCQ_Question_MCQID_PK PRIMARY KEY (MCQID),
  CONSTRAINT MCQ_Question_QuizID_FK FOREIGN KEY (QuizID)
  REFERENCES MCQ_Section (QuizID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `MCQ_Option` (
  OptionID    MEDIUMINT AUTO_INCREMENT,
  Content     TEXT,
  Explanation TEXT,
  MCQID       MEDIUMINT,
  CONSTRAINT MCQ_Option_OptionID_PK PRIMARY KEY (OptionID),
  CONSTRAINT MCQ_Option_MCQID_FK FOREIGN KEY (MCQID)
  REFERENCES MCQ_Question (MCQID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `MCQ_Question_Record` (
  StudentID MEDIUMINT,
  MCQID     MEDIUMINT,
  Choice    MEDIUMINT,
  CONSTRAINT MCQ_Question_Record_PK PRIMARY KEY (StudentID, MCQID),
  CONSTRAINT MCQ_Question_Record_StudentID_FK FOREIGN KEY (StudentID)
  REFERENCES Student (StudentID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT MCQ_Question_Record_MCQID_FK FOREIGN KEY (MCQID)
  REFERENCES MCQ_Question (MCQID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT MCQ_Question_Record_Choice_FK FOREIGN KEY (Choice)
  REFERENCES MCQ_Option (OptionID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `SAQ_Section` (
  QuizID      MEDIUMINT,
  MediaTitle  TEXT,
  MediaSource TEXT,
  CONSTRAINT SAQ_Section_QuizID_PK PRIMARY KEY (QuizID),
  CONSTRAINT SAQ_Section_QuizID_FK FOREIGN KEY (QuizID)
  REFERENCES Quiz (QuizID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `SAQ_Question` (
  SAQID    MEDIUMINT AUTO_INCREMENT,
  Question TEXT,
  Points   MEDIUMINT,
  QuizID   MEDIUMINT,
  CONSTRAINT SAQ_Question_SAQID_PK PRIMARY KEY (SAQID),
  CONSTRAINT SAQ_Question_QuizID_FK FOREIGN KEY (QuizID)
  REFERENCES SAQ_Section (QuizID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `SAQ_Question_Record` (
  StudentID MEDIUMINT,
  SAQID     MEDIUMINT,
  Answer    TEXT,
  Feedback  TEXT,
  Grading   MEDIUMINT,
  CONSTRAINT SAQ_Question_Record_PK PRIMARY KEY (StudentID, SAQID),
  CONSTRAINT SAQ_Question_Record_StudentID_FK FOREIGN KEY (StudentID)
  REFERENCES Student (StudentID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT SAQ_Question_Record_SAQID_FK FOREIGN KEY (SAQID)
  REFERENCES SAQ_Question (SAQID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;


CREATE TABLE IF NOT EXISTS `Matching_Section` (
  QuizID      MEDIUMINT,
  Description TEXT,
  Points      MEDIUMINT,
  CONSTRAINT Matching_Section_QuizID_PK PRIMARY KEY (QuizID),
  CONSTRAINT Matching_Section_QuizID_FK FOREIGN KEY (QuizID)
  REFERENCES Quiz (QuizID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

# Set A: terminology/category/bucket
CREATE TABLE IF NOT EXISTS `Matching_Question` (
  MatchingID MEDIUMINT AUTO_INCREMENT,
  Question   TEXT NOT NULL,
  QuizID     MEDIUMINT,
  CONSTRAINT Matching_Question_MatchingID_PK PRIMARY KEY (MatchingID),
  CONSTRAINT Matching_Question_QuizID_FK FOREIGN KEY (QuizID)
  REFERENCES Matching_Section (QuizID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

# Set B: explanation/concept/item
CREATE TABLE IF NOT EXISTS `Matching_Option` (
  OptionID   MEDIUMINT AUTO_INCREMENT,
  Content    TEXT NOT NULL,
  MatchingID MEDIUMINT,
  CONSTRAINT Matching_Option_OptionID_PK PRIMARY KEY (OptionID),
  CONSTRAINT Matching_Option_MatchingID_FK FOREIGN KEY (MatchingID)
  REFERENCES Matching_Question (MatchingID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Poster_Section` (
  QuizID      MEDIUMINT,
  Title       TEXT,
  Description TEXT,
  Points      MEDIUMINT,
  CONSTRAINT Poster_Section_QuizID_PK PRIMARY KEY (QuizID),
  CONSTRAINT Poster_Section_QuizID_FK FOREIGN KEY (QuizID)
  REFERENCES Quiz (QuizID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Poster_Record` (
  QuizID      MEDIUMINT,
  StudentID   MEDIUMINT,
  ZwibblerDoc LONGTEXT,
  ImageURL    LONGTEXT,
  Grading     MEDIUMINT,
  CONSTRAINT Poster_Record_PK PRIMARY KEY (QuizID, StudentID),
  CONSTRAINT Poster_Record_StudentID_QuizID_FK FOREIGN KEY (QuizID, StudentID)
  REFERENCES Quiz_Record (QuizID, StudentID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Misc_Section` (
  QuizID      MEDIUMINT,
  QuizSubType TEXT,
  Points      MEDIUMINT,
  CONSTRAINT Misc_Section_QuizID_PK PRIMARY KEY (QuizID),
  CONSTRAINT Misc_Section_QuizID_FK FOREIGN KEY (QuizID)
  REFERENCES Quiz (QuizID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Game` (
  GameID      MEDIUMINT AUTO_INCREMENT,
  Description TEXT      NOT NULL,
  Levels      MEDIUMINT NOT NULL,
  CONSTRAINT Game_GameID_PK PRIMARY KEY (GameID)
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Game_Record` (
  GameID    MEDIUMINT,
  StudentID MEDIUMINT,
  `Level`   MEDIUMINT DEFAULT 0,
  Score     INT,
  CONSTRAINT Game_Record_PK PRIMARY KEY (GameID, StudentID, `Level`),
  CONSTRAINT Game_Record_GameID_FK FOREIGN KEY (GameID)
  REFERENCES Game (GameID)
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT Game_Record_StudentID_FK FOREIGN KEY (StudentID)
  REFERENCES Student (StudentID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;


CREATE TABLE IF NOT EXISTS `Recipe` (
  RecipeID        MEDIUMINT AUTO_INCREMENT,
  RecipeName      TEXT      NOT NULL,
  Source          TEXT, # for credit
  MealType        TEXT      NOT NULL,
  PreparationTime MEDIUMINT NOT NULL,
  CookingTime     MEDIUMINT NOT NULL,
  Serves          MEDIUMINT NOT NULL,
  Image           TEXT      DEFAULT NULL,
  CONSTRAINT Recipe_RecipeID_PK PRIMARY KEY (RecipeID)
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Recipe_Ingredient` (
  IngredientID MEDIUMINT AUTO_INCREMENT,
  Content      TEXT,
  RecipeID     MEDIUMINT NOT NULL,
  CONSTRAINT Recipe_Ingredient_IngredientID_PK PRIMARY KEY (IngredientID),
  CONSTRAINT Recipe_Ingredient_RecipeID_FK FOREIGN KEY (RecipeID)
  REFERENCES Recipe (RecipeID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Recipe_Step` (
  StepID      MEDIUMINT AUTO_INCREMENT,
  Description TEXT,
  RecipeID    MEDIUMINT NOT NULL,
  CONSTRAINT Recipe_Step_StepID_PK PRIMARY KEY (StepID),
  CONSTRAINT Recipe_Step_RecipeID_FK FOREIGN KEY (RecipeID)
  REFERENCES Recipe (RecipeID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Recipe_Nutrition` (
  NutritionID     MEDIUMINT AUTO_INCREMENT,
  NutritionName   TEXT,
  MeasurementUnit TEXT, # e.g. kj, g, mg, etc.
  RecipeID        MEDIUMINT NOT NULL,
  CONSTRAINT Recipe_Nutrition_NutritionID_PK PRIMARY KEY (NutritionID),
  CONSTRAINT Recipe_Nutrition_RecipeID_FK FOREIGN KEY (RecipeID)
  REFERENCES Recipe (RecipeID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;


CREATE TABLE IF NOT EXISTS `Student_Question` (
  QuestionID MEDIUMINT AUTO_INCREMENT,
  Subject    TEXT      NOT NULL,
  Content    TEXT,
  SendTime   TIMESTAMP,
  Feedback   TEXT,
  Viewed     BOOLEAN   DEFAULT 0,
  Replied	 BOOLEAN   DEFAULT 0,
  StudentID  MEDIUMINT NOT NULL,
  CONSTRAINT Student_Question_QuestionID_PK PRIMARY KEY (QuestionID),
  CONSTRAINT Student_Question_StudentID_FK FOREIGN KEY (StudentID)
  REFERENCES Student (StudentID)
    ON DELETE CASCADE
    ON UPDATE CASCADE
)
  ENGINE = INNODB;

CREATE TABLE IF NOT EXISTS `Public_Question` (
  QuestionID MEDIUMINT AUTO_INCREMENT,
  Name       TEXT      NOT NULL,
  Email      TEXT      NOT NULL,
  Content    MEDIUMINT NOT NULL,
  Solved     BOOLEAN   DEFAULT 0,
  CONSTRAINT Public_Question_QuestionID_PK PRIMARY KEY (QuestionID)
)
  ENGINE = INNODB;

SET FOREIGN_KEY_CHECKS = 1;

# INSERT RAW DATA FOR TEST

# [Example] User Info
INSERT IGNORE INTO School (SchoolName) VALUES ('Sample School');
INSERT IGNORE INTO School (SchoolName) VALUES ('Sample Adelaide High School');
INSERT IGNORE INTO School (SchoolName) VALUES ('Sample Woodville High School');
INSERT IGNORE INTO Class (ClassName, SchoolID, TokenString) VALUES ('Sample Class 1A', 1, 'TOKENSTRING01');
INSERT IGNORE INTO Class (ClassName, SchoolID, TokenString) VALUES ('Sample Class 1B', 1, 'TOKENSTRING02');
INSERT IGNORE INTO Class (ClassName, SchoolID, TokenString) VALUES ('Sample Class 1C', 1, 'TOKENSTRING03');
INSERT IGNORE INTO Class (ClassName, SchoolID, TokenString) VALUES ('Sample Class 2C', 2, 'TOKENSTRING04');

INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Fernando', 'd59324e4d5acb950c4022cd5df834cc3', 'fernado@gmail.com', 'Fernando', 'Trump', 'Male', '2003-10-20',
   'Resident', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID, Score)
VALUES
  ('Todd', 'd59324e4d5acb950c4022cd5df834cc3', 'toddyy@gmail.com', 'Todd', 'Webb', 'Male', '2003-11-20', 'Aboriginal',
   1, 55);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID, Score)
VALUES ('Theresa', 'd59324e4d5acb950c4022cd5df834cc3', 'theresa03@gmail.com', 'Theresa', 'Rios', 'Female', '2003-12-20',
        'Aboriginal', 1, 90);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID, Score)
VALUES
  ('Hai', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Hai', 'Lam', 'Male', '2003-10-22', 'Aboriginal',
   1, 30);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID, Score)
VALUES ('Lee', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Lee', 'Malone', 'Male', '2003-10-24',
        'Aboriginal', 1, 45);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID, Score)
VALUES
  ('Tim', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Tim', 'Mason', 'Male', '2003-10-25', 'Resident',
   1, 60);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Clinton', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Clinton', 'Snyder', 'Male', '2003-10-28',
   'Resident', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Elbert', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Elbert', 'Chapman', 'Male', '2003-10-22',
   'Resident', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Ervin', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Ervin', 'Murray', 'Male', '2003-11-20',
   'Resident', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Sheila', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Sheila', 'Frank', 'Female', '2003-10-20',
   'Aboriginal', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Grace', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Grace', 'Austin', 'Female', '2003-10-29',
   'Resident', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Ruby', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Ruby', 'Chavez', 'Female', '2003-10-20',
   'Resident', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Sonya', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Sonya', 'Kelly', 'Female', '2003-10-20',
   'Resident', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Donna', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Donna', 'Pratt', 'Female', '2003-10-20',
   'Resident', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Stacy', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Stacy', 'Figueroa', 'Female', '2003-10-20',
   'Resident', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Fannie', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Fannie', 'Waters', 'Female', '2003-10-28',
   'Aboriginal', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('June', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'June', 'West', 'Female', '2003-10-20',
   'Aboriginal', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Melinda', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Melinda', 'Kelley', 'Female', '2003-10-20',
   'Resident', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Leo', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Leo', 'Potter', 'Male', '2002-04-22', 'Resident',
   1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Hector', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Hector', 'Byrd', 'Male', '2002-04-20',
   'Resident', 1);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Otis', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Otis', 'Lawrence', 'Male', '2002-04-20',
   'Aboriginal', 2);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Cassandra', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Cassandra', 'James', 'Female',
   '2002-04-20', 'Aboriginal', 2);
INSERT IGNORE INTO Student (Username, `Password`, Email, FirstName, LastName, Gender, DOB, Identity, ClassID) VALUES
  ('Marilyn', 'd59324e4d5acb950c4022cd5df834cc3', 'isnap2demo@gmail.com', 'Marilyn', 'Ryan', 'Female', '2002-04-20',
   'Aboriginal', 1);

INSERT IGNORE INTO Researcher (Username, `Password`) VALUES ('Ann', 'd59324e4d5acb950c4022cd5df834cc3');
INSERT IGNORE INTO Researcher (Username, `Password`) VALUES ('Patricia', 'd59324e4d5acb950c4022cd5df834cc3');

# [Formal] Topic
INSERT IGNORE INTO Topic (TopicName) VALUES ('Smoking');
INSERT IGNORE INTO Topic (TopicName) VALUES ('Nutrition');
INSERT IGNORE INTO Topic (TopicName) VALUES ('Alcohol');
INSERT IGNORE INTO Topic (TopicName) VALUES ('Physical Activity');
INSERT IGNORE INTO Topic (TopicName) VALUES ('Drugs');
INSERT IGNORE INTO Topic (TopicName) VALUES ('Sexual Health');
INSERT IGNORE INTO Topic (TopicName) VALUES ('Health and Wellbeing');

# [Formal] insert MCQ section with multiple questions
INSERT IGNORE INTO Quiz (Week, QuizType, TopicID) VALUES (1, 'MCQ', 2);
SET @QUIZ_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO MCQ_Section (QuizID, Points) VALUES (@QUIZ_LAST_INSERT_ID, 30);
INSERT IGNORE INTO MCQ_Question (Question, QuizID)
VALUES ('Which of these breakfast foods will provide you with the most energy?', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES
  ('Candy bar', 'Candy bars will give you an instant burst of energy but will not last!', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES
  ('Whole grain cereal or oatmeal', 'Whole grains take your body longer to digest, giving you energy all morning!',
   @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES
  ('Potato chips', 'Whole grains take your body longer to digest, giving you energy all morning!',
   @MCQ_QUESTION_LAST_INSERT_ID);
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;


INSERT IGNORE INTO MCQ_Question (Question, QuizID)
VALUES ('Which type of food should take up the most space on your plate?', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Fruits and veggies',
                                                                      'Get munching on carrots, apples, and other tasty fresh foods! The veggies and fruits should take up at least half of your plate.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Meats',
                                                                      'Get munching on carrots, apples, and other tasty fresh foods! The veggies and fruits should take up at least half of your plate.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Grains',
                                                                      'Get munching on carrots, apples, and other tasty fresh foods! The veggies and fruits should take up at least half of your plate.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;

INSERT IGNORE INTO MCQ_Question (Question, QuizID)
VALUES ('What should I do if I hate broccoli?', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Feed it to your dog.',
                                                                      'Not everyone likes broccoli. But there are so many different kinds of vegetables, you are bound to find one you like!',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Give up on eating vegetables.',
                                                                      'Not everyone likes broccoli. But there are so many different kinds of vegetables, you are bound to find one you like!',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Give peas a chance!',
                                                                      'Not everyone likes broccoli. But there are so many different kinds of vegetables, you are bound to find one you like!',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;

INSERT IGNORE INTO MCQ_Question (Question, QuizID)
VALUES ('If I want to stay healthy, can I still eat French fries?', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('No fast food, ever.',
                                                                      'Eating healthy doesn\'t mean cutting out ALL fried foods. Foods like French fries are ok if you eat a small amount once or twice a month.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('No, but American fries are ok.',
                                                                      'Eating healthy doesn\'t mean cutting out ALL fried foods. Foods like French fries are ok if you eat a small amount once or twice a month.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Sure, just not every day.',
                                                                      'Eating healthy doesn\'t mean cutting out ALL fried foods. Foods like French fries are ok if you eat a small amount once or twice a month.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;

INSERT IGNORE INTO MCQ_Question (Question, QuizID)
VALUES ('What\'s a nutritious afterschool snack?', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Potato chips and soda.',
                                                                      'Eating healthy snacks is important. Snacks give you energy and help you feel full so you don\'t overeat at dinner.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('An apple, cheese, and whole grain crackers.',
                                                                      'Eating healthy snacks is important. Snacks give you energy and help you feel full so you don\'t overeat at dinner.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('A doughnut or a brownie.',
                                                                      'Eating healthy snacks is important. Snacks give you energy and help you feel full so you don\'t overeat at dinner.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;


INSERT IGNORE INTO MCQ_Question (Question, QuizID)
VALUES ('How much veggies and fruit should you eat daily?', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES
  ('1 to 2 cups of veggies and 1 to 2 pieces of fruit every day.',
   'Fortunately, there are so many types of fruits and vegetables that you\'ll never get bored!',
   @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Eat veggies or fruit once a month.',
                                                                      'Fortunately, there are so many types of fruits and vegetables that you\'ll never get bored!',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('At least 100 cups a day.',
                                                                      'Fortunately, there are so many types of fruits and vegetables that you\'ll never get bored!',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;

INSERT IGNORE INTO MCQ_Question (Question, QuizID)
VALUES ('Which of these foods is the best source of calcium?', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Bread',
                                                                      'Calcium is important for building bones. You can get your daily dose from a variety of foods, including yogurt, milk, and almonds.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Yogurt',
                                                                      'Calcium is important for building bones. You can get your daily dose from a variety of foods, including yogurt, milk, and almonds.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Apples',
                                                                      'Calcium is important for building bones. You can get your daily dose from a variety of foods, including yogurt, milk, and almonds.',
                                                                      @MCQ_QUESTION_LAST_INSERT_ID);
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;


INSERT IGNORE INTO MCQ_Question (Question, QuizID)
VALUES ('Which of these foods has lots of fiber?', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES
  ('White rice', 'Eating foods that have fiber helps with digestion and keeps you from getting hungry too soon.',
   @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES
  ('Pasta', 'Eating foods that have fiber helps with digestion and keeps you from getting hungry too soon.',
   @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES
  ('Beans and apples', 'Eating foods that have fiber helps with digestion and keeps you from getting hungry too soon.',
   @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;

INSERT IGNORE INTO MCQ_Question (Question, QuizID)
VALUES ('What should you drink the most of each day?', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Milk', 'You should drink 6-8 cups of water a day. Cheers!', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Water', 'You should drink 6-8 cups of water a day. Cheers!', @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Orange Juice', 'You should drink 6-8 cups of water a day. Cheers!', @MCQ_QUESTION_LAST_INSERT_ID);
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;


INSERT IGNORE INTO Quiz (Week, QuizType, TopicID) VALUES (1, 'MCQ', 5);
SET @QUIZ_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO MCQ_Section (QuizID, Points) VALUES (@QUIZ_LAST_INSERT_ID, 20);
INSERT IGNORE INTO MCQ_Question (Question, QuizID)
VALUES ('Alcohol has an immediate effect on the:', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Knees', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Fingers', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Chest', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Brain', 'Correct', @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;


INSERT IGNORE INTO MCQ_Question (Question, QuizID) VALUES ('Alcohol increases the risk of:', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('A person being involved in anti-social behaviour.', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Injury due to falls, burns, car crashes.', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Violence and fighting.', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('All of the above.', 'Correct', @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;


INSERT IGNORE INTO MCQ_Question (Question, QuizID) VALUES ('When a person continues to drink:', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Their  blood alcohol content (BAC) decreases.', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Their blood alcohol content (BAC) increases.', 'Correct', @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Their blood alcohol content (BAC) remains the same', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Their blood alcohol content (BAC) reduces to zero', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;


INSERT IGNORE INTO MCQ_Question (Question, QuizID) VALUES ('Alcohol is a:', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Drug that has no effects on you.', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Drug that targets the brain.', 'Correct', @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Drug that you do not need to worry about.', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID)
VALUES ('Drug that does not affect your behaviour.', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;

INSERT IGNORE INTO MCQ_Question (Question, QuizID) VALUES ('Alcohol is broken down by:', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Blood', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Heart', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Liver', 'Correct', @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('Kidney', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;

# [Example] Student Progress
# StudentID = 1 has not finished QuizID neither 1, 2 nor 3
INSERT IGNORE INTO Quiz_Record (QuizID, StudentID) VALUES (1, 2);
INSERT IGNORE INTO Quiz_Record (QuizID, StudentID) VALUES (1, 3);
INSERT IGNORE INTO Quiz_Record (QuizID, StudentID) VALUES (1, 4);
INSERT IGNORE INTO Quiz_Record (QuizID, StudentID) VALUES (1, 5);
INSERT IGNORE INTO Quiz_Record (QuizID, StudentID) VALUES (1, 6);

INSERT IGNORE INTO Quiz_Record (QuizID, StudentID) VALUES (2, 2);
INSERT IGNORE INTO Quiz_Record (QuizID, StudentID) VALUES (2, 3);
INSERT IGNORE INTO Quiz_Record (QuizID, StudentID) VALUES (2, 4);
INSERT IGNORE INTO Quiz_Record (QuizID, StudentID) VALUES (2, 5);
INSERT IGNORE INTO Quiz_Record (QuizID, StudentID) VALUES (2, 6);

# [Sample] insert SAQ section with questions
INSERT IGNORE INTO Quiz (Week, QuizType, TopicID) VALUES (1, 'SAQ', 1);
SET @QUIZ_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO SAQ_Section (QuizID, MediaTitle, MediaSource)
VALUES (@QUIZ_LAST_INSERT_ID, 'It is a trap!', 'The Truth Site');
INSERT IGNORE INTO SAQ_Question (Question, Points, QuizID) VALUES
  ('Based on the video, list 3 problems or challenges that these teenagers face as a result of their smoking?', 10,
   @QUIZ_LAST_INSERT_ID);
INSERT IGNORE INTO SAQ_Question (Question, Points, QuizID)
VALUES ('List 1 strategy that you could use to help convince a peer to stop smoking?', 10, @QUIZ_LAST_INSERT_ID);
INSERT IGNORE INTO SAQ_Question (Question, Points, QuizID) VALUES (
  'List 3 the different ways that you have seen anti-smoking messages presented to the public. With each suggest if you think they have been ‘effective�or ‘not effective� Eg. Poster-Effective.',
  20, @QUIZ_LAST_INSERT_ID);

# [Sample] Answer and Grading Feedback of SAQ 
INSERT IGNORE INTO Quiz_Record (QuizID, StudentID, `Status`) VALUES (3, 1, 'GRADED');
INSERT IGNORE INTO SAQ_Question_Record (StudentID, SAQID, Answer, Feedback, Grading) VALUES (1, 1,
                                                                                             '[ANSWER] Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pellentesque non justo et tellus venenatis consequat. Suspendisse laoreet rhoncus nulla, quis vulputate arcu interdum vel. Aenean at nisl at enim imperdiet rhoncus in non risus. Nam augue nisi, blandit sed feugiat eu, dapibus tristique ipsum. Vestibulum molestie orci risus, accumsan convallis sem sagittis mattis. Nulla ac justo sit amet erat lacinia vulputate. Aliquam accumsan pellentesque magna ac ultricies. Cras consequat feugiat suscipit. Vivamus suscipit lobortis nunc at aliquet. Nullam orci diam, viverra sed interdum ac, vehicula vel nisi. Cras blandit erat eget purus maximus condimentum. Nullam mattis pellentesque velit ac euismod. Nam vehicula est vel iaculis hendrerit. Vivamus pellentesque leo nec eleifend sodales. Phasellus eget condimentum metus.',
                                                                                             '+10: Good job!', 10);
INSERT IGNORE INTO SAQ_Question_Record (StudentID, SAQID, Answer, Feedback, Grading) VALUES (1, 2,
                                                                                             '[ANSWER] Nunc rhoncus turpis eu risus pharetra, et pharetra libero euismod. Donec ac tellus consequat, aliquam ligula in, semper erat. Praesent ut justo auctor, imperdiet nisi quis, bibendum dolor. Nunc iaculis aliquet est ac maximus. Cum sociis natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Suspendisse vel elit felis. Duis accumsan arcu cursus dapibus vulputate. Maecenas sit amet euismod orci. Sed imperdiet justo quis eros porta tristique eu a mi. Donec at est lacus. Vivamus viverra, purus ut tempor auctor, tellus massa hendrerit elit, tristique ornare mauris dolor vitae ante.',
                                                                                             '+10: Well done!', 10);
INSERT IGNORE INTO SAQ_Question_Record (StudentID, SAQID, Answer, Feedback, Grading) VALUES (1, 3,
                                                                                             '[ANSWER] Nam odio tortor, finibus sit amet metus vitae, egestas venenatis arcu. Maecenas sodales, mi vitae tincidunt interdum, urna ipsum sagittis orci, semper mollis nisl ex ut felis. Vivamus lectus justo, interdum sit amet enim id, euismod posuere erat. Pellentesque auctor elit eget finibus placerat. Vivamus sodales dolor non ligula molestie aliquam. Ut at metus ut mauris consequat sollicitudin. Suspendisse non ipsum at neque molestie feugiat.',
                                                                                             '+20: Nice try. <br> -2: You should also mention Poster-Effective.',
                                                                                             18);

INSERT IGNORE INTO Quiz (Week, QuizType, TopicID) VALUES (3, 'SAQ', 4);
SET @QUIZ_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO SAQ_Section (QuizID) VALUES (@QUIZ_LAST_INSERT_ID);
INSERT IGNORE INTO SAQ_Question (Question, Points, QuizID)
VALUES ('How much exercise do you think you do a day?', 10, @QUIZ_LAST_INSERT_ID);
INSERT IGNORE INTO SAQ_Question (Question, Points, QuizID)
VALUES ('Do you think that you are exercising enough? Why/whynot?', 10, @QUIZ_LAST_INSERT_ID);
INSERT IGNORE INTO SAQ_Question (Question, Points, QuizID)
VALUES ('What are the benefits of exercising? List 5 examples.', 20, @QUIZ_LAST_INSERT_ID);
INSERT IGNORE INTO SAQ_Question (Question, Points, QuizID) VALUES
  ('What changes can you make to your daily routine to incorporate more exercise into your life?', 20,
   @QUIZ_LAST_INSERT_ID);

# [Formal] Week 6
INSERT IGNORE INTO Quiz (Week, QuizType, TopicID) VALUES (6, 'Misc', 3);
SET @QUIZ_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO Misc_Section (QuizID, QuizSubType, Points) VALUES (@QUIZ_LAST_INSERT_ID, 'Calculator', 20);

INSERT IGNORE INTO Quiz (Week, QuizType, TopicID) VALUES (6, 'MCQ', 3);
SET @QUIZ_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO MCQ_Section (QuizID, Points) VALUES (@QUIZ_LAST_INSERT_ID, 30);
# [Formal] Matching questions
INSERT IGNORE INTO Quiz (Week, QuizType, TopicID) VALUES (6, 'Matching', 2);
SET @QUIZ_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO Matching_Section (QuizID, Description, Points) VALUES (@QUIZ_LAST_INSERT_ID,
                                                                          'Match the diseases to the causes. You may have to do some research on other websites to find out the answers.',
                                                                          20);
INSERT IGNORE INTO Matching_Question (Question, QuizID) VALUES ('Kwashiorkor', @QUIZ_LAST_INSERT_ID);
SET @MATCHING_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID)
VALUES ('A disease that occurs if your body doesn’t get enough proteins', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO Matching_Question (Question, QuizID) VALUES ('Marasmus', @QUIZ_LAST_INSERT_ID);
SET @MATCHING_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID)
VALUES ('Occurs in young children who don’t get enough calories every day', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO Matching_Question (Question, QuizID) VALUES ('Scurvy', @QUIZ_LAST_INSERT_ID);
SET @MATCHING_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID)
VALUES ('Caused by a lack of vitamin C', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO Matching_Question (Question, QuizID) VALUES ('Rickets', @QUIZ_LAST_INSERT_ID);
SET @MATCHING_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID)
VALUES ('This condition is brought on by a lack of vitamin D', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO Matching_Question (Question, QuizID) VALUES ('Beriberi', @QUIZ_LAST_INSERT_ID);
SET @MATCHING_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID)
VALUES ('Caused by the deficiency of vitamin B1 (thiamine) ', @MATCHING_QUESTION_LAST_INSERT_ID);

# [Example] Week 7 MultipleChoice Matching
INSERT IGNORE INTO Quiz (Week, QuizType, TopicID) VALUES (7, 'Matching', 2);
SET @QUIZ_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO Matching_Section (QuizID, Description, Points)
VALUES (@QUIZ_LAST_INSERT_ID, 'Classify the lists of foods into the 5 main food groups', 20);
INSERT IGNORE INTO Matching_Question (Question, QuizID) VALUES ('Protein', @QUIZ_LAST_INSERT_ID);
SET @MATCHING_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Beef', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Beef', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Beef', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Beef', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO Matching_Question (Question, QuizID) VALUES ('Fat', @QUIZ_LAST_INSERT_ID);
SET @MATCHING_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Chips', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Chips', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Chips', @MATCHING_QUESTION_LAST_INSERT_ID);
#INSERT IGNORE INTO `Matching_Option`(Content, MatchingID) VALUES('Chips', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO Matching_Question (Question, QuizID) VALUES ('Vitamin', @QUIZ_LAST_INSERT_ID);
SET @MATCHING_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Orange', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Orange', @MATCHING_QUESTION_LAST_INSERT_ID);
#INSERT IGNORE INTO `Matching_Option`(Content, MatchingID) VALUES('Orange', @MATCHING_QUESTION_LAST_INSERT_ID);
#INSERT IGNORE INTO `Matching_Option`(Content, MatchingID) VALUES('Orange', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO Matching_Question (Question, QuizID) VALUES ('Minerals', @QUIZ_LAST_INSERT_ID);
SET @MATCHING_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Fish', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Fish', @MATCHING_QUESTION_LAST_INSERT_ID);
#INSERT IGNORE INTO `Matching_Option`(Content, MatchingID) VALUES('Fish', @MATCHING_QUESTION_LAST_INSERT_ID);
#INSERT IGNORE INTO `Matching_Option`(Content, MatchingID) VALUES('Fish', @MATCHING_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO Matching_Question (Question, QuizID) VALUES ('Carbohydrate', @QUIZ_LAST_INSERT_ID);
SET @MATCHING_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `Matching_Option` (Content, MatchingID) VALUES ('Rice', @MATCHING_QUESTION_LAST_INSERT_ID);
#INSERT IGNORE INTO `Matching_Option`(Content, MatchingID) VALUES('Rice', @MATCHING_QUESTION_LAST_INSERT_ID);
#INSERT IGNORE INTO `Matching_Option`(Content, MatchingID) VALUES('Rice', @MATCHING_QUESTION_LAST_INSERT_ID);
#INSERT IGNORE INTO `Matching_Option`(Content, MatchingID) VALUES('Rice', @MATCHING_QUESTION_LAST_INSERT_ID);



# [Example] Learning_Material
INSERT IGNORE INTO Learning_Material (Content, QuizID) VALUES ('<p>Eating a balanced diet is vital for your health and wellbeing. The food we eat is responsible for providing us with the energy to do all the tasks of daily life. For optimum performance and growth a balance of protein, essential fats, vitamins and minerals are required. We need a wide variety of different foods to provide the right amounts of nutrients for good health. The different types of food and how much of it you should be aiming to eat is demonstrated on the pyramid below. (my own words)</p>
<p><img style="display: block; margin-left: auto; margin-right: auto;" src="https://cmudream.files.wordpress.com/2016/05/0.jpg" alt="" width="632" height="884" /></p>
<p>There are three main layers of the food pyramid. The bottom layer is the most important one for your daily intake of food. It contains vegetables, fruits, grains and legumes. You should be having most of your daily food from this layer. These foods are all derived or grow on plants and contain important nutrients such as vitamins, minerals and antioxidants. They are also responsible for being the main contributor of carbohydrates and fibre to our diet.<br />The middle layer is comprised of dairy based products such as milk, yoghurt, cheese. These are essential to providing our bodies with calcium and protein and important vitamins and minerals.<br />They layer also contains lean meat, poultry, fish, eggs, nuts, seeds, legumes. These foods are our main source of protein and are also responsible for providing other nutrients to us including iodine, iron, zinc, B12 vitamins and healthy fats.<br />The top layer, which is the smallest layer, is the layer you should me eating the least off. This layer is made up of food which has unsaturated fats such as sugar, butter, margarine and oils; small amounts of these unsaturated fats are needed for healthy brain and hear function.<br />(my own words)<br />Source: The Healthy Living Pyramid. Nutrition Australia. [Accessed 28/04/2016 http://www.nutritionaustralia.org/national/resource/healthy-living-pyramid]</p>',
                                                               1);
INSERT IGNORE INTO Learning_Material (Content, QuizID, Excluded) VALUES ('
<p>Learning materials for week 1...</p>', 2, 1);
INSERT IGNORE INTO Learning_Material (Content, QuizID) VALUES ('
<p>Learning material for this quiz has not been added.</p>', 4);

INSERT IGNORE INTO Learning_Material (Content, QuizID) VALUES ('
<p>Learning material for this quiz has not been added.</p>', 6);
INSERT IGNORE INTO Learning_Material (Content, QuizID) VALUES ('
<p>Nutrition: All over the world people suffer from illnesses that are caused by eating the wrong food or not having enough to eat. In developing countries deficiency diseases arise when people do not get the right nutrients. Conversely, overconsumption of foods rich in fat and cholesterols can lead to heart diseases, obesity, strokes and cancer. (Own words)</p>',
                                                               7);
INSERT IGNORE INTO Learning_Material (Content, QuizID) VALUES ('
<p>Learning material for this quiz has not been added.</p>', 8);

# [Example] Learning_Material (Excluded)
INSERT IGNORE INTO Learning_Material (Content, QuizID, Excluded) VALUES ('
<p>Learning material for this quiz has not been added.</p>', 5, 1);

# [Example] Learning_Material (for Video Quiz)

INSERT IGNORE INTO Learning_Material (Content, QuizID, Excluded) VALUES (
  '<p><iframe src="//www.youtube.com/embed/UQ0hFLUiHTg?autoplay=1&amp;start=60&amp;end=70&amp;rel=0&quot;" width="560" height="314" allowfullscreen="allowfullscreen"></iframe></p>',
  3, -1);

# [Formal] Games
INSERT IGNORE INTO Game (Description, Levels) VALUES ('Fruit Ninja', 5);
INSERT IGNORE INTO Game (Description, Levels) VALUES ('Candy Crush', 50);

# [Example] Game_Record
INSERT IGNORE INTO Game_Record (GameID, StudentID, `Level`, Score) VALUES (1, 1, 1, 5);
INSERT IGNORE INTO Game_Record (GameID, StudentID, `Level`, Score) VALUES (1, 1, 2, 40);
INSERT IGNORE INTO Game_Record (GameID, StudentID, `Level`, Score) VALUES (1, 2, 1, 30);
INSERT IGNORE INTO Game_Record (GameID, StudentID, `Level`, Score) VALUES (1, 3, 1, 30);
INSERT IGNORE INTO Game_Record (GameID, StudentID, `Level`, Score) VALUES (1, 4, 1, 30);
INSERT IGNORE INTO Game_Record (GameID, StudentID, `Level`, Score) VALUES (2, 2, 1, 35);
INSERT IGNORE INTO Game_Record (GameID, StudentID, `Level`, Score) VALUES (2, 3, 1, 30);
INSERT IGNORE INTO Game_Record (GameID, StudentID, `Level`, Score) VALUES (2, 4, 1, 30);
INSERT IGNORE INTO Game_Record (GameID, StudentID, `Level`, Score) VALUES (2, 5, 1, 40);

/*
# [Example] add Bonus and tasks
INSERT IGNORE INTO Bonus(Week) VALUES(1);
SET @BONUS_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO Bonus_Task(Question, Points, BonusID) VALUES('Prepare a meal for your mom.', 10, @BONUS_LAST_INSERT_ID);

INSERT IGNORE INTO Bonus(Week) VALUES(2);
SET @BONUS_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO Bonus_Task(Question, Points, BonusID) VALUES('Attend a basketball game.', 10, @BONUS_LAST_INSERT_ID);

INSERT IGNORE INTO Bonus(Week) VALUES(3);
SET @BONUS_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO Bonus_Task(Question, Points, BonusID) VALUES('Attend a football game', 10, @BONUS_LAST_INSERT_ID);
*/

# [Example] update Submission time
UPDATE `isnap2changedb`.`Student`
SET `Score` = '80'
WHERE `StudentID` = '10';
UPDATE `isnap2changedb`.`Student`
SET `Score` = '70', `SubmissionTime` = '2016-06-05 14:48:43'
WHERE `StudentID` = '12';
UPDATE `isnap2changedb`.`Student`
SET `Score` = '70', `SubmissionTime` = '2016-06-05 14:48:43'
WHERE `StudentID` = '8';
UPDATE `isnap2changedb`.`Student`
SET `Score` = '20'
WHERE `StudentID` = '14';
UPDATE `isnap2changedb`.`Student`
SET `Score` = '70', `SubmissionTime` = '2016-06-01 14:48:42'
WHERE `StudentID` = '16';
UPDATE `isnap2changedb`.`Student`
SET `Score` = '10'
WHERE `StudentID` = '18';
UPDATE `isnap2changedb`.`Student`
SET `SubmissionTime` = '2016-06-02 14:48:43'
WHERE `StudentID` = '2';
UPDATE `isnap2changedb`.`Student`
SET `SubmissionTime` = '2016-06-03 14:48:43'
WHERE `StudentID` = '3';
UPDATE `isnap2changedb`.`Student`
SET `SubmissionTime` = '2016-06-01 14:49:43'
WHERE `StudentID` = '4';
UPDATE `isnap2changedb`.`Student`
SET `SubmissionTime` = '2016-06-07 14:48:43'
WHERE `StudentID` = '5';
UPDATE `isnap2changedb`.`Student`
SET `SubmissionTime` = '2016-06-11 14:48:43'
WHERE `StudentID` = '6';

# [Example] insert snapfacts
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Each day, more than 3,200 people under 18 smoke their first cigarette, and approximately 2,100 youth and young adults become daily smokers.',
  1);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Nearly 9 out of 10 lung cancers are caused by smoking. Smokers today are much more likely to develop lung cancer than smokers were in 1964.',
  1);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Nearly 9 out of 10 lung cancers are caused by smoking. Smokers today are much more likely to develop lung cancer than smokers were in 1964.',
  1);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Nearly 9 out of 10 lung cancers are caused by smoking. Smokers today are much more likely to develop lung cancer than smokers were in 1964.',
  1);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Nearly 9 out of 10 lung cancers are caused by smoking. Smokers today are much more likely to develop lung cancer than smokers were in 1964.',
  1);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Nearly 9 out of 10 lung cancers are caused by smoking. Smokers today are much more likely to develop lung cancer than smokers were in 1964.',
  1);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Nearly 9 out of 10 lung cancers are caused by smoking. Smokers today are much more likely to develop lung cancer than smokers were in 1964.',
  1);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Nearly 9 out of 10 lung cancers are caused by smoking. Smokers today are much more likely to develop lung cancer than smokers were in 1964.',
  1);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Nearly 9 out of 10 lung cancers are caused by smoking. Smokers today are much more likely to develop lung cancer than smokers were in 1964.',
  1);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Nearly 9 out of 10 lung cancers are caused by smoking. Smokers today are much more likely to develop lung cancer than smokers were in 1964.',
  1);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Nearly 9 out of 10 lung cancers are caused by smoking. Smokers today are much more likely to develop lung cancer than smokers were in 1964.',
  1);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'A large part of the population is Omega-3 deficient. Avoiding a deficiency in these essential fatty acids can help prevent many diseases.',
  2);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Trans Fats are chemically processed fats that cause all sorts of damage in the body. You should avoid them like the plague.',
  2);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Excessive alcohol use is responsible for 2.5 million years of potential life lost annually, or an average of about 30 years of potential life lost for each death',
  3);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'Up to 40% of all hospital beds in the United States (except for those being used by maternity and intensive care patients) are being used to treat health conditions that are related to alcohol consumption',
  3);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`) VALUES (
  'People aged 18-64 years old should exercice at least 150 min per week at least, each of the session lasting 10 min as a minimum,',
  4);
INSERT INTO `isnap2changedb`.`Snap_Fact` (`Content`, `TopicID`)
VALUES ('Supportive environments and communities may help people to be more physically active.', '4');

# [Example] insert verbose facts with sub paddings
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Short Term Effects of Smoking', 'Short Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID) VALUES ('Emphysema', 'Emphysema is a long-term, progressive disease of the lungs that primarily causes shortness of breath due to over-inflation of the alveoli (air sacs in the lung). In people with emphysema, the lung tissue involved in exchange of gases (oxygen and carbon dioxide) is impaired or destroyed. Emphysema is included in a group of diseases called chronic obstructive pulmonary disease or COPD (pulmonary refers to the lungs).
Emphysema is called an obstructive lung disease because airflow on exhalation is slowed or stopped because over-inflated alveoli do not exchange gases when a person breaths due to little or no movement of gases out of the alveoli.
Emphysema changes the anatomy of the lung in several important ways. This is due to in part to the destruction of lung tissue around smaller airways. This tissue normally holds these small airways, called bronchioles, open, allowing air to leave the lungs on exhalation. When this tissue is damaged, these airways collapse, making it difficult for the lungs to empty and the air (gases) becomes trapped in the alveoli.
Normal lung tissue looks like a new sponge. Emphysematous lung looks like an old used sponge, with large holes and a dramatic loss of “springy-nessor elasticity. When the lung is stretched during inflation (inhalation), the nature of the stretched tissue wants to relax to its resting state. In emphysema, this elastic function is impaired, resulting in air trapping in the lungs. Emphysema destroys this spongy tissue of the lung and also severely affects the small blood vessels (capillaries of the lung) and airways that run throughout the lung. Thus, not only is airflow affected but so is blood flow. This has dramatic impact on the ability for the lung not only to empty its air sacs called alveoli (pleural for alveolus) but also for blood to flow through the lungs to receive oxygen.',
                                                                    1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
INSERT IGNORE INTO `Verbose_Fact` (Title, Content, TopicID)
VALUES ('Long Term Effects of Smoking', 'Long Term Effects of Smoking Content...', 1);
# [Example] insert a poster task into Quiz
INSERT INTO `isnap2changedb`.`Quiz` (`Week`, `QuizType`, `TopicID`) VALUES ('2', 'Poster', '3');

INSERT IGNORE INTO Quiz (Week, QuizType, TopicID) VALUES (1, 'MCQ', 5);
SET @QUIZ_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO MCQ_Section (QuizID, Points) VALUES (@QUIZ_LAST_INSERT_ID, 20);

INSERT IGNORE INTO MCQ_Question (Question, QuizID) VALUES ('1 option:', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('1', 'Correct', @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;


INSERT IGNORE INTO MCQ_Question (Question, QuizID) VALUES ('2 option', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('1', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('2', 'Correct', @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;

INSERT IGNORE INTO MCQ_Question (Question, QuizID) VALUES ('3 option', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('1', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('2', 'Correct', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('3', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;

INSERT IGNORE INTO MCQ_Question (Question, QuizID) VALUES ('4 option', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('1', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('2', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('3', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('4', 'Correct', @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;

INSERT IGNORE INTO MCQ_Question (Question, QuizID) VALUES ('5 option', @QUIZ_LAST_INSERT_ID);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('1', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('2', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('3', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('4', 'Wrong', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option` (Content, Explanation, MCQID) VALUES ('5', 'Correct', @MCQ_QUESTION_LAST_INSERT_ID);
SET @MCQ_QUESTION_CORRECT_CHOICE_ID = LAST_INSERT_ID();
UPDATE `isnap2changedb`.`MCQ_Question`
SET `CorrectChoice` = @MCQ_QUESTION_CORRECT_CHOICE_ID
WHERE `MCQID` = @MCQ_QUESTION_LAST_INSERT_ID;

# [Example] insert a poster task into Poster_Section
INSERT INTO `isnap2changedb`.`Poster_Section` (`QuizID`, `Title`, `Description`, `Points`) VALUES
  (9, 'Create a Future Board',
   'What would you linke to achieve this school term? Make board with pictures of what you would like to achieve and the people and things that inspire you and whtat you aspire to be. You can also put down things about yourself that you would like to improve on. If you would feel more comvortable using words or pictures that only you know what they mean, you can . After all, some goals are personal.',
   20);

# [Example] insert a learning material for a Poster task with QuizID = 9
INSERT INTO `isnap2changedb`.`Learning_Material` (`Content`, `QuizID`)
VALUES ('<p>Learning material for this quiz has not been added.</p>', '9');

# [Example] insert one more learning material
INSERT INTO `isnap2changedb`.`Learning_Material` (`Content`, `QuizID`, Excluded)
VALUES ('<p>Learning material for this quiz has not been added.</p>', '10', 1);

# [Example] change a class's (classID = 1) unlocked progress to 3
UPDATE `isnap2changedb`.`Class`
SET `UnlockedProgress` = '3'
WHERE `ClassID` = '1';

# [Example] insert a standard drinking tool task into Quiz
INSERT INTO `isnap2changedb`.`Quiz` (`Week`, `QuizType`, `TopicID`) VALUES ('2', 'Misc', '3');

# [Example] insert a learning material for a standard drinking tool task with QuizID = 11
INSERT INTO `isnap2changedb`.`Learning_Material` (`Content`, `QuizID`) VALUES (
  '<p>Do you know what a standard drink is? (If no, go to the SNAP Facts page)</p><p>What is the standard amount of alcohol recommended by the National Health and Medical Research Council (NHMRC) to drink in a day? (You need to go to the iSNAPs facts page for this)</p><p>Alcoholic beverages are sold and served in many different sized containers. Different types of beverages contain different amounts of alcohol, and glass sizes are often not the same. A glass or container can hold more than one standard drink of alcohol. This can make it difficult to know how many standard drinks you consume.</p><p>Using standard drinks to measure your alcohol consumption is more accurate than counting the number of glasses or other containers you have consumed. If you are drinking packaged liquor the number of standard drinks should be written on the side of the beverage container.</p>',
  '11');

# [Example] insert a standard drinking tool task into Misc Quiz
INSERT INTO `isnap2changedb`.`Misc_Section` (`QuizID`, `QuizSubType`, `Points`) VALUES ('11', 'DrinkingTool', '30');

# [Example] set some quizzes as extra activities
UPDATE `isnap2changedb`.`Quiz`
SET `ExtraQuiz` = '1'
WHERE `QuizID` = '3';
UPDATE `isnap2changedb`.`Quiz`
SET `ExtraQuiz` = '1'
WHERE `QuizID` = '10';
UPDATE `isnap2changedb`.`Quiz`
SET `ExtraQuiz` = '1'
WHERE `QuizID` = '6';

# [Example] update some mockup data in the matching
UPDATE `isnap2changedb`.`Matching_Option`
SET `Content` = 'Meat'
WHERE `OptionID` = '7';
UPDATE `isnap2changedb`.`Matching_Option`
SET `Content` = 'Lamb'
WHERE `OptionID` = '8';
UPDATE `isnap2changedb`.`Matching_Option`
SET `Content` = 'Pork'
WHERE `OptionID` = '9';
UPDATE `isnap2changedb`.`Matching_Option`
SET `Content` = 'Nuts'
WHERE `OptionID` = '11';
UPDATE `isnap2changedb`.`Matching_Option`
SET `Content` = 'Cookie'
WHERE `OptionID` = '12';
UPDATE `isnap2changedb`.`Matching_Option`
SET `Content` = 'Apple'
WHERE `OptionID` = '14';
UPDATE `isnap2changedb`.`Matching_Option`
SET `Content` = 'Cake'
WHERE `OptionID` = '16';

# [Example] insert a poster task into Quiz
INSERT INTO `isnap2changedb`.`Quiz` (`Week`, `QuizType`, `TopicID`) VALUES ('4', 'Poster', '3');
# [Example] insert a poster task into Poster_Section
INSERT INTO `isnap2changedb`.`Poster_Section` (`QuizID`, `Title`, `Description`, `Points`) VALUES
  (12, 'Create a Future Board',
   'What would you linke to achieve this school term? Make board with pictures of what you would like to achieve and the people and things that inspire you and whtat you aspire to be. You can also put down things about yourself that you would like to improve on. If you would feel more comvortable using words or pictures that only you know what they mean, you can . After all, some goals are personal.',
   20);

# [Example] add poster record
# run unit_test/poster-generator.php

# [Example] add recipe
INSERT INTO `isnap2changedb`.`Recipe` (`RecipeName`, `Source`, `MealType`,`PreparationTime`,`CookingTime`,`Serves`) VALUES ('Eggplant Parmesan Pizza', 'http://www.eatingwell.com/recipes_menus/recipe_slideshows/vegetarian_pizza_recipes?slide=1#leaderboardad', 'Main Meal', 15,20,4);
SET @RECIPE_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT INTO `isnap2changedb`.`Recipe_Ingredient` (`Content`, `RecipeID`) VALUES ('1 small eggplant, (about 12 ounces)', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Ingredient` (`Content`, `RecipeID`) VALUES ('Yellow cornmeal, for dusting', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Ingredient` (`Content`, `RecipeID`) VALUES ('1 pound Easy Whole-Wheat Pizza Dough, or other prepared dough (recipe follows)', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Ingredient` (`Content`, `RecipeID`) VALUES ('3/4 cup prepared marinara sauce', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Ingredient` (`Content`, `RecipeID`) VALUES ('2 tablespoons chopped fresh basil', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Ingredient` (`Content`, `RecipeID`) VALUES ('1 medium clove garlic, minced medium clove garlic, minced', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Ingredient` (`Content`, `RecipeID`) VALUES ('3/4 cup thinly shaved Parmigiano-Reggiano cheese, (see Tip)', @RECIPE_LAST_INSERT_ID);

INSERT INTO `isnap2changedb`.`Recipe_Step` (`Description`, `RecipeID`) VALUES ('Preheat grill to medium-high. (For charcoal grilling or an oven variation, see below.)', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Step` (`Description`, `RecipeID`) VALUES ('Cut eggplant into 1/2-inch thick rounds. Grill, turning once, until marked and softened, 4 to 6 minutes. Let cool slightly, then thinly slice into strips. Reduce heat to low.', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Step` (`Description`, `RecipeID`) VALUES ('Sprinkle cornmeal onto a pizza peel or large baking sheet. Roll out the dough (see Tip) and transfer it to the prepared peel or baking sheet, making sure the underside of the dough is completely coated with cornmeal.', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Step` (`Description`, `RecipeID`) VALUES ('Slide the crust onto the grill rack; close the lid. Cook until lightly browned, 3 to 4 minutes.', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Step` (`Description`, `RecipeID`) VALUES ('Using a large spatula, flip the crust. Spread marinara sauce on the crust, leaving a 1-inch border. Quickly top with the eggplant, basil and garlic. Lay the Parmigiano-Reggiano shavings on top.', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Step` (`Description`, `RecipeID`) VALUES ('Close the lid again and grill until the cheese has melted and the bottom of the crust has browned, about 8 minutes.', @RECIPE_LAST_INSERT_ID);

INSERT INTO `isnap2changedb`.`Recipe_Nutrition` (`MeasurementUnit`,`NutritionName`, `RecipeID`) VALUES ('359','calories', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Nutrition` (`MeasurementUnit`,`NutritionName`, `RecipeID`) VALUES ('7 g','fat', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Nutrition` (`MeasurementUnit`,`NutritionName`, `RecipeID`) VALUES ('12 mg','cholesterol', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Nutrition` (`MeasurementUnit`,`NutritionName`, `RecipeID`) VALUES ('59 g','carbohydrates', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Nutrition` (`MeasurementUnit`,`NutritionName`, `RecipeID`) VALUES ('16 g','protein', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Nutrition` (`MeasurementUnit`,`NutritionName`, `RecipeID`) VALUES ('9 g','fiber', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Nutrition` (`MeasurementUnit`,`NutritionName`, `RecipeID`) VALUES ('713 mg','sodium', @RECIPE_LAST_INSERT_ID);
INSERT INTO `isnap2changedb`.`Recipe_Nutrition` (`MeasurementUnit`,`NutritionName`, `RecipeID`) VALUES ('416 mg','potassium', @RECIPE_LAST_INSERT_ID);


/*
#TEST

#TEST 1[PASSED]: ON DELETE CASCADE
#DELETE FROM Student WHERE StudentID = 1;

#TEST 2[PASSED]: ON DELETE CASCADE IN MULTIPLE TABLE;
#DELETE FROM MCQ_Section WHERE QuizID = 1;

#TEST 3[PASSED]: INSERT MCQ_Section QUESTION
START TRANSACTION;
INSERT IGNORE INTO MCQ_Question(Question, CorrectChoice, QuizID) VALUES('this is a test question for insert new question', 'A', 1);
SET @MCQ_QUESTION_LAST_INSERT_ID = LAST_INSERT_ID();
INSERT IGNORE INTO `MCQ_Option`(Content, Explanation, MCQID) VALUES('answeroftest1', @MCQ_QUESTION_LAST_INSERT_ID);
INSERT IGNORE INTO `MCQ_Option`(Content, Explanation, MCQID) VALUES('answeroftest2', @MCQ_QUESTION_LAST_INSERT_ID);
COMMIT;
#SELECT LAST_INSERT_ID();

#QUERY GET UNFINISHED QUIZZES
SELECT 
    QuizID, QuizType
FROM
    Quiz
WHERE
    Week = 1
        AND NOT EXISTS( SELECT 
            QuizID, QuizType
        FROM
            Quiz_Record
                NATURAL JOIN
            Quiz
        WHERE
            StudentID = 1 AND Week = 1);

SELECT 
    (SELECT 
            COUNT(*)
        FROM
            Quiz
        WHERE
            Week = 1) - COUNT(*)
FROM
    Quiz_Record
        NATURAL JOIN
    Quiz
WHERE
    StudentID = 1 AND Week = 1;
*/

