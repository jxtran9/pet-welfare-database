-- This script is intended to be run top-to-bottom.
-- Table creation order follows foreign key dependencies.
-- INSERT statements assume all tables have already been created.

CREATE DATABASE pet_welfare_test;
USE pet_welfare_test;

-- 1. ORGANIZATION
CREATE TABLE Organization (
    OrgID      INT           NOT NULL,
    OrgName    VARCHAR(100)  NOT NULL,
    Type       VARCHAR(100)  NOT NULL,
    CONSTRAINT PK_Organization PRIMARY KEY (OrgID),
    CONSTRAINT UQ_Organization_OrgName UNIQUE (OrgName),
    CONSTRAINT CK_Organization_OrgID CHECK (OrgID >= 1)
);

-- 2. LOCATION
CREATE TABLE Location (
    LocationID  INT           NOT NULL,
    City        VARCHAR(50)   NOT NULL,
    State       CHAR(2)       NOT NULL,
    Description VARCHAR(500)  NULL,
    OrgID       INT           NOT NULL,
    CONSTRAINT PK_Location PRIMARY KEY (LocationID),
    CONSTRAINT FK_Location_Org
        FOREIGN KEY (OrgID) REFERENCES Organization (OrgID),
    CONSTRAINT CK_Location_LocationID CHECK (LocationID >= 1)
);

-- 3. ANIMAL
CREATE TABLE Animal (
    AnimalID   INT           NOT NULL,
    OrgID      INT           NOT NULL,
    Species    VARCHAR(30)   NOT NULL,
    Sex        CHAR(1)       NOT NULL,
    AgeMonths  INT           NOT NULL,
    Microchip  VARCHAR(20)   NULL,
    Notes      VARCHAR(500)  NULL,
    CONSTRAINT PK_Animal PRIMARY KEY (AnimalID),
    CONSTRAINT FK_Animal_Org
        FOREIGN KEY (OrgID) REFERENCES Organization (OrgID),
    CONSTRAINT UQ_Animal_Microchip UNIQUE (Microchip),
    CONSTRAINT CK_Animal_AnimalID CHECK (AnimalID >= 1),
    CONSTRAINT CK_Animal_Sex CHECK (Sex IN ('M','F','U')),
    CONSTRAINT CK_Animal_AgeMonths CHECK (AgeMonths BETWEEN 0 AND 1000)
);

-- 4. INTAKE  (weak entity under Animal; composite PK)
CREATE TABLE Intake (
    IntakeNo        INT           NOT NULL,
    AnimalID        INT           NOT NULL,
    IntakeType      VARCHAR(100)  NOT NULL, 
    IntakeDateTime  TIMESTAMP     NOT NULL,
    SourceText      VARCHAR(500)  NULL,
    LocationID      INT           NOT NULL,
    CONSTRAINT PK_Intake PRIMARY KEY (IntakeNo, AnimalID),
    CONSTRAINT FK_Intake_Animal
        FOREIGN KEY (AnimalID)   REFERENCES Animal (AnimalID),
    CONSTRAINT FK_Intake_Location
        FOREIGN KEY (LocationID) REFERENCES Location (LocationID),
    CONSTRAINT CK_Intake_IntakeNo CHECK (IntakeNo >= 1)
);

-- 5. OUTCOME
CREATE TABLE Outcome (
    OutcomeID       INT           NOT NULL,
    AnimalID        INT           NOT NULL,
    OutcomeType     VARCHAR(100)  NOT NULL,
    OutcomeDateTime TIMESTAMP     NOT NULL,
    Returned        BOOLEAN       NOT NULL DEFAULT FALSE,
    IsLive          BOOLEAN       NOT NULL,
    CONSTRAINT PK_Outcome PRIMARY KEY (OutcomeID),
    CONSTRAINT FK_Outcome_Animal
        FOREIGN KEY (AnimalID) REFERENCES Animal (AnimalID),
    CONSTRAINT CK_Outcome_OutcomeID CHECK (OutcomeID >= 1)
);

-- 6. ADOPTER
CREATE TABLE Adopter (
    Ssn         CHAR(9)        NOT NULL,
    Phone       VARCHAR(20)    NOT NULL,
    Email       VARCHAR(150)   NOT NULL,
    FirstName   VARCHAR(100)   NOT NULL,
    LastName    VARCHAR(100)   NOT NULL,
    LocationID  INT            NOT NULL,
    CONSTRAINT PK_Adopter PRIMARY KEY (Ssn),
    CONSTRAINT FK_Adopter_Location
        FOREIGN KEY (LocationID) REFERENCES Location (LocationID)
);

-- 7. ADOPTION (specialization of Outcome)
CREATE TABLE Adoption (
    OutcomeID     INT          NOT NULL,
    AdopterSsn    CHAR(9)      NOT NULL,
    AdoptionDate  DATE         NOT NULL,
    AdoptionFee   DECIMAL(8,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT PK_Adoption PRIMARY KEY (OutcomeID),
    CONSTRAINT FK_Adoption_Outcome
        FOREIGN KEY (OutcomeID)  REFERENCES Outcome (OutcomeID),
    CONSTRAINT FK_Adoption_Adopter
        FOREIGN KEY (AdopterSsn) REFERENCES Adopter (Ssn)
);

-- 8. WELFARE EXAM
CREATE TABLE WelfareExam (
    WelfareExamID INT           NOT NULL,
    Date          DATE          NOT NULL,
    Weight        DECIMAL(5,2)  NULL,
    HealthScore   INT           NULL,
    Notes         VARCHAR(500)  NULL,
    OrgID         INT           NOT NULL,
    AnimalID      INT           NOT NULL,
    CONSTRAINT PK_WelfareExam PRIMARY KEY (WelfareExamID),
    CONSTRAINT FK_WelfareExam_Org
        FOREIGN KEY (OrgID)   REFERENCES Organization (OrgID),
    CONSTRAINT FK_WelfareExam_Animal
        FOREIGN KEY (AnimalID) REFERENCES Animal (AnimalID),
    CONSTRAINT CK_WelfareExam_WelfareExamID CHECK (WelfareExamID >= 1),
    CONSTRAINT CK_WelfareExam_HealthScore
        CHECK (HealthScore IS NULL OR (HealthScore BETWEEN 1 AND 10))
);


------------------------------------------------------------
-- 1. ORGANIZATION
------------------------------------------------------------
INSERT INTO Organization (OrgID, OrgName, Type)
VALUES
  (1, 'Seattle Animal Rescue',        'Municipal Shelter'),
  (2, 'Evergreen Pet Haven',         'Nonprofit Rescue'),
  (3, 'Pawsitive Futures Rescue',    'Nonprofit Rescue'),
  (4, 'South Sound Animal Care',     'Municipal Shelter');

------------------------------------------------------------
-- 2. LOCATION
------------------------------------------------------------
INSERT INTO Location (LocationID, City, State, Description, OrgID)
VALUES
  (100, 'Seattle',   'WA', 'Main Shelter - Downtown',           1),
  (101, 'Seattle',   'WA', 'Foster Home - Northgate',           1),
  (102, 'Everett',   'WA', 'Everett City Park (found in bush)', 1),
  (103, 'Bellevue',  'WA', 'Adopter Home - Single Family',      2),
  (104, 'Tacoma',    'WA', 'Adopter Apartment Building',        2),

  (105, 'Tacoma',    'WA', 'Main Shelter - Tacoma',                  4),
  (106, 'Kent',      'WA', 'Satellite Clinic - Kent',                1),
  (107, 'Redmond',   'WA', 'Foster Home - Redmond',                  3),
  (108, 'Everett',   'WA', 'Shelter Annex - Everett',                3),
  (109, 'Olympia',   'WA', 'Adopter Home - Rural Property',          4),
  (110, 'Seattle',   'WA', 'Neighborhood foster home - Ballard',     1),
  (111, 'Renton',    'WA', 'Renton satellite shelter',               1),
  (112, 'Everett',   'WA', 'Evergreen Pet Haven main shelter',       2),
  (113, 'Lynnwood',  'WA', 'Partner vet clinic',                     2),
  (114, 'Kirkland',  'WA', 'Foster apartment',                       3),
  (115, 'Puyallup',  'WA', 'South Sound intake facility',            4),
  (116, 'Tacoma',    'WA', 'Offsite adoption event location',        4),
  (117, 'Shoreline', 'WA', 'Short-term foster home',                 1),
  (118, 'Bellevue',  'WA', 'High-volume adopter neighborhood',       2);

------------------------------------------------------------
-- 3. ANIMAL
------------------------------------------------------------
INSERT INTO Animal (AnimalID, OrgID, Species, Sex, AgeMonths, Microchip, Notes)
VALUES
  (1000, 1, 'Dog',   'F',  18, 'MC1000A', 'Friendly, came in as stray.'),
  (1001, 1, 'Cat',   'M',  60, 'MC1001B', 'Owner surrender; shy in kennel.'),
  (1002, 1, 'Dog',   'M',   6, NULL,      'Found in park with no collar.'),
  (1003, 2, 'Cat',   'F',  36, 'MC1003D', 'Transferred from another rescue.'),
  (1004, 2, 'Dog',   'U', 120, 'MC1004E', 'Senior dog with mobility issues.'),

  (1005, 1, 'Dog', 'F',  24, 'MC1005F',
     'High-energy dog; needs training and large yard.'),
  (1006, 1, 'Cat', 'F',   8, NULL,
     'Kitten with upper respiratory infection; on meds.'),
  (1007, 2, 'Dog', 'M',  36, 'MC1007G',
     'Good with other dogs; loves fetch.'),
  (1008, 3, 'Cat', 'M',  48, 'MC1008H',
     'Bonded pair with AnimalID 1009.'),
  (1009, 3, 'Cat', 'F',  48, 'MC1009I',
     'Bonded pair with AnimalID 1008.'),
  (1010, 4, 'Dog', 'F',   4, NULL,
     'Puppy surrendered from accidental litter.'),
  (1011, 4, 'Dog', 'M',  84, 'MC1011J',
     'Large-breed senior; heart murmur noted.'),
  (1012, 2, 'Cat', 'U',  18, NULL,
     'Semi-feral barn cat; prefers outdoor placement.'),

  (1013, 1, 'Dog', 'M',  30, 'MC1013K',
     'Medium mixed breed; dog-friendly and crate trained.'),
  (1014, 1, 'Cat', 'F',  72, 'MC1014L',
     'Declawed front paws; must be indoor only.'),
  (1015, 1, 'Dog', 'U',  10, NULL,
     'Shy puppy; still learning leash; scared of loud noises.'),
  (1016, 2, 'Cat', 'M',  24, 'MC1016M',
     'Young adult; black coat; tolerant of handling.'),
  (1017, 2, 'Dog', 'F',  60, 'MC1017N',
     'Bonded with AnimalID 1018; surrendered together.'),
  (1018, 2, 'Dog', 'M',  60, 'MC1018O',
     'Bonded with 1017; nervous around men.'),
  (1019, 3, 'Cat', 'F',  15, NULL,
     'Polydactyl kitten; very social; good candidate for family home.'),
  (1020, 3, 'Dog', 'M',  96, 'MC1020P',
     'Retired working dog; arthritis in hips; needs low-impact exercise.'),
  (1021, 3, 'Cat', 'U',   5, NULL,
     'Stray kitten; underweight; on bottle feeding initially.'),
  (1022, 4, 'Dog', 'F',  36, 'MC1022Q',
     'Behavior hold; resource guarding around food.'),
  (1023, 4, 'Dog', 'M',  20, NULL,
     'Recovered from parvo; currently on medical hold.'),
  (1024, 4, 'Cat', 'F',  84, 'MC1024R',
     'Senior cat; chronic kidney disease; special diet.'),
  (1025, 2, 'Cat', 'M',  40, NULL,
     'Barn cat candidate; prefers outdoor or semi-feral placement.'),
  (1026, 1, 'Dog', 'F',  14, 'MC1026S',
     'Small breed; brought in with puppies; very people focused.'),
  (1027, 1, 'Dog', 'M',   8, NULL,
     'Puppy from 1026''s litter; playful and mouthy.'),
  (1028, 1, 'Dog', 'F',   8, NULL,
     'Puppy from same litter as 1027; slightly more reserved.'),
  (1029, 3, 'Cat', 'M',  30, 'MC1029T',
     'Returned adoption; inappropriate urination reported in home.'),
  (1030, 4, 'Dog', 'M',  48, 'MC1030U',
     'Large hound; strong puller on leash; scent-driven.');

------------------------------------------------------------
-- 4. ADOPTER
------------------------------------------------------------
INSERT INTO Adopter (Ssn, Phone, Email, FirstName, LastName, LocationID)
VALUES
  ('123456789', '206-555-0101', 'alice.nguyen@example.com',  'Alice',   'Nguyen', 103),
  ('234567890', '425-555-0202', 'brian.lee@example.com',     'Brian',   'Lee',    104),
  ('345678901', '360-555-0303', 'carla.santos@example.com',  'Carla',   'Santos', 103),

  ('456789012', '425-555-0404', 'david.kim@example.com',     'David',  'Kim',     103),
  ('567890123', '509-555-0505', 'emily.chan@example.com',    'Emily',  'Chan',    104),
  ('678901234', '253-555-0606', 'frank.garcia@example.com',  'Frank',  'Garcia',  109),
  ('789012345', '206-555-0707', 'grace.wong@example.com',    'Grace',  'Wong',    103),
  ('890123456', '425-555-0808', 'hannah.ross@example.com',   'Hannah', 'Ross',    114),
  ('901234567', '360-555-0909', 'ian.miller@example.com',    'Ian',    'Miller',  118),
  ('012345678', '253-555-1010', 'julia.park@example.com',    'Julia',  'Park',    111),
  ('098765432', '206-555-1111', 'kevin.tran@example.com',    'Kevin',  'Tran',    117);

------------------------------------------------------------
-- 5. WELFARE EXAM
------------------------------------------------------------
INSERT INTO WelfareExam (WelfareExamID, Date, Weight, HealthScore, Notes, OrgID, AnimalID)
VALUES
  (3000, '2025-01-05', 45.20, 8, 'Initial intake exam; mild skin irritation.', 1, 1000),
  (3001, '2025-01-06',  9.10, 7, 'Dental tartar noted.',                        1, 1001),
  (3002, '2025-01-07', 12.30, 9, 'Puppy in good condition.',                    1, 1002),
  (3003, '2025-01-08',  7.80, 6, 'Chronic cough; scheduled follow up.',         2, 1003),
  (3004, '2025-01-09', 55.00, 5, 'Arthritis; started pain management.',         2, 1004),

  (3005, '2025-01-10', 52.00, 7,
     'Slight anxiety in kennel; overall healthy.',              1, 1005),
  (3006, '2025-01-11',  2.10, 8,
     'Kitten underweight but improving on treatment.',          1, 1006),
  (3007, '2025-01-12', 40.50, 9,
     'Fit and active; cleared for adoption events.',            2, 1007),
  (3008, '2025-01-13',  5.20, 8,
     'Bonded pair exam for 1008; mild dental tartar.',          3, 1008),
  (3009, '2025-01-13',  5.00, 8,
     'Bonded pair exam for 1009; body condition normal.',       3, 1009),
  (3010, '2025-01-14',  6.80, 9,
     'Puppy exam; vaccines started, no issues.',                4, 1010),
  (3011, '2025-01-15', 75.30, 6,
     'Senior dog; heart murmur and arthritis; meds prescribed.',4, 1011),
  (3012, '2025-01-16',  4.40, 7,
     'Semi-feral; stressy in kennel; good body weight.',        2, 1012),
  (3013, '2025-01-17', 28.40, 8,
     'Healthy; mild tartar; cleared for adoption events.',      1, 1013),
  (3014, '2025-01-18',  4.50, 7,
     'Senior cat; weight slightly low; kidney values monitored.',1, 1014),
  (3015, '2025-01-19',  9.20, 8,
     'Puppy exam; boosters started; slightly nervous.',         1, 1015),
  (3016, '2025-01-20',  5.10, 9,
     'Young cat; no major issues; vaccinated and microchipped.',2, 1016),
  (3017, '2025-01-21', 55.00, 7,
     'Bonded pair exam with 1018; moderate dental disease.',    2, 1017),
  (3018, '2025-01-21', 54.50, 7,
     'Bonded pair exam with 1017; nervous but handleable.',     2, 1018),
  (3019, '2025-01-22',  3.20, 8,
     'Kitten; dewormed; extra toes noted.',                     3, 1019),
  (3020, '2025-01-23', 68.00, 6,
     'Retired working dog; arthritis and hip discomfort.',      3, 1020),
  (3021, '2025-01-24',  1.80, 7,
     'Bottle baby; gaining weight slowly; needs frequent feeds.',3, 1021),
  (3022, '2025-01-25', 40.20, 6,
     'Behavior hold; resource guarding observed; behavior plan.',4, 1022),
  (3023, '2025-01-26', 22.50, 7,
     'Post-parvo recovery; GI signs resolved; recheck in 1 week.',4, 1023),
  (3024, '2025-01-27',  4.10, 6,
     'Senior with kidney disease; hydration and labs monitored.',4, 1024),
  (3025, '2025-01-28',  4.30, 8,
     'Barn cat candidate; healthy; minimal handling.',          2, 1025),
  (3026, '2025-01-29',  6.20, 9,
     'Postpartum dog; body condition good; puppies nursing.',   1, 1026),
  (3027, '2025-01-30',  2.50, 9,
     'Healthy puppy; growing well; dewormed.',                  1, 1027),
  (3028, '2025-01-30',  2.40, 9,
     'Littermate of 1027; healthy and social.',                 1, 1028),
  (3029, '2025-02-01',  4.90, 7,
     'Returned adoption; mild cystitis suspected.',             3, 1029),
  (3030, '2025-02-02', 70.00, 8,
     'Large hound; strong but otherwise healthy.',              4, 1030);

------------------------------------------------------------
-- 6. INTAKE  (PK = IntakeNo + AnimalID)
------------------------------------------------------------
INSERT INTO Intake (IntakeNo, AnimalID, IntakeType, IntakeDateTime, SourceText, LocationID)
VALUES
  (1, 1000, 'Stray',           '2025-01-04 15:32:00',
      'Found roaming near downtown shelter; brought in by AC officer.', 100),
  (1, 1001, 'Owner Surrender', '2025-01-04 10:05:00',
      'Owner moving and unable to keep cat.',                           100),
  (1, 1002, 'Stray',           '2025-01-05 13:20:00',
      'Good Samaritan found dog near playground.',                      102),
  (1, 1003, 'Transfer In',     '2025-01-06 09:45:00',
      'Transferred from partner rescue in Spokane.',                    100),
  (1, 1004, 'Public Assist',   '2025-01-06 16:10:00',
      'Owner requested help rehoming senior dog.',                      101),
  (2, 1000, 'Return from Adoption', '2025-02-10 11:15:00',
      'Adopter returned due to housing restrictions.',                  100),

  (1, 1005, 'Stray',           '2025-01-09 12:05:00',
     'Found running loose near dog park; no ID tags.',          106),
  (1, 1006, 'Stray',           '2025-01-10 09:40:00',
     'Found under parked car; sneezing and congested.',         100),
  (1, 1007, 'Owner Surrender', '2025-01-10 15:25:00',
     'Owner could not afford ongoing vet costs.',               104),
  (1, 1008, 'Seizure',         '2025-01-11 10:10:00',
     'Removed from neglect case; housed together with 1009.',   108),
  (1, 1009, 'Seizure',         '2025-01-11 10:10:00',
     'Removed from same neglect case as 1008; bonded pair.',    108),
  (1, 1010, 'Owner Surrender', '2025-01-12 14:22:00',
     'Accidental litter; owner surrendered 3 puppies, kept 1.', 105),
  (1, 1011, 'Public Assist',   '2025-01-13 17:05:00',
     'Neighbor reported elderly dog tied outside for long periods.', 105),
  (1, 1012, 'Stray',           '2025-01-14 08:30:00',
     'Trapped as part of barn cat relocation program.',         102),

  (1, 1013, 'Stray',           '2025-01-16 13:00:00',
     'Found loose near neighborhood park; no ID.',              110),
  (1, 1014, 'Owner Surrender', '2025-01-17 10:15:00',
     'Owner moving to assisted living; cannot keep cat.',       100),
  (1, 1015, 'Stray',           '2025-01-18 18:25:00',
     'Puppy found under porch; no microchip found.',            111),
  (1, 1016, 'Stray',           '2025-01-19 09:40:00',
     'Found near apartment complex; friendly with people.',     112),
  (1, 1017, 'Owner Surrender', '2025-01-20 14:05:00',
     'Bonded pair surrendered due to divorce.',                 112),
  (1, 1018, 'Owner Surrender', '2025-01-20 14:05:00',
     'Same bonded pair surrender; came in together with 1017.', 112),
  (1, 1019, 'Stray',           '2025-01-21 11:55:00',
     'Kitten brought in by Good Samaritan.',                    114),
  (1, 1020, 'Transfer In',     '2025-01-22 15:30:00',
     'Transfer from working dog program.',                      108),
  (1, 1021, 'Stray',           '2025-01-23 08:10:00',
     'Found in alley; very underweight.',                       114),
  (1, 1022, 'Seizure',         '2025-01-24 16:45:00',
     'Animal control seized dog from neglect case.',            115),
  (1, 1023, 'Owner Surrender', '2025-01-25 10:00:00',
     'Owner unable to afford treatment after parvo.',           115),
  (1, 1024, 'Owner Surrender', '2025-01-26 13:20:00',
     'Owner moving and cannot continue medical care.',          113),
  (1, 1025, 'Stray',           '2025-01-27 07:50:00',
     'Trapped on farm; part of barn cat program.',              113),
  (1, 1026, 'Owner Surrender', '2025-01-28 12:05:00',
     'Owner surrendered mom dog and litter.',                   111),
  (1, 1027, 'Litter Intake',   '2025-01-28 12:05:00',
     'Puppy from same litter as 1026; processed individually.', 111),
  (1, 1028, 'Litter Intake',   '2025-01-28 12:05:00',
     'Second puppy from same litter; processed individually.',  111),
  (1, 1029, 'Adoption Return', '2025-01-31 10:40:00',
     'Returned due to litter box issues.',                      110),
  (1, 1030, 'Stray',           '2025-02-01 17:30:00',
     'Found following jogger; extremely energetic.',            116),

  (2, 1002, 'Return from Adoption', '2025-03-01 11:45:00',
     'Returned due to mismatched energy level with adopter.',   100),
  (2, 1022, 'Return from Foster',  '2025-02-15 09:30:00',
     'Behavior concerns reported; returned from foster.',       115),
  (2, 1029, 'Stray',              '2025-03-05 13:15:00',
     'Seen again roaming neighborhood; readmitted.',            110);

------------------------------------------------------------
-- 7. OUTCOME
------------------------------------------------------------
INSERT INTO Outcome (OutcomeID, AnimalID, OutcomeType, OutcomeDateTime, Returned, IsLive)
VALUES
  (2000, 1000, 'Adopted',      '2025-01-20 14:00:00', FALSE, TRUE),
  (2001, 1001, 'Transferred',  '2025-01-18 09:30:00', FALSE, TRUE),
  (2002, 1002, 'Adopted',      '2025-01-25 16:45:00', FALSE, TRUE),
  (2003, 1003, 'Adopted',      '2025-02-01 11:00:00', FALSE, TRUE),
  (2004, 1004, 'Euthanized',   '2025-02-05 17:20:00', FALSE, FALSE),
  (2005, 1000, 'Returned to Shelter', '2025-02-10 11:00:00', TRUE, TRUE),

  (2006, 1005, 'Adopted',          '2025-02-01 13:10:00', FALSE, TRUE),
  (2007, 1006, 'Foster',           '2025-01-20 16:30:00', FALSE, TRUE),
  (2008, 1007, 'Adopted',          '2025-02-10 10:05:00', FALSE, TRUE),
  (2009, 1008, 'Adopted',          '2025-02-15 14:45:00', FALSE, TRUE),
  (2010, 1009, 'Adopted',          '2025-02-15 14:45:00', FALSE, TRUE),
  (2011, 1010, 'Adopted',          '2025-02-20 09:20:00', FALSE, TRUE),
  (2012, 1011, 'Transferred',      '2025-02-25 17:55:00', FALSE, TRUE),
  (2013, 1012, 'Relocated',        '2025-03-01 08:10:00', FALSE, TRUE),
  (2014, 1002, 'Adopted',          '2025-03-10 15:40:00', FALSE, TRUE),

  (2015, 1013, 'Adopted',          '2025-02-05 14:10:00', FALSE, TRUE),
  (2016, 1014, 'Transferred',      '2025-02-07 09:00:00', FALSE, TRUE),
  (2017, 1015, 'Foster',           '2025-02-08 16:20:00', FALSE, TRUE),
  (2018, 1016, 'Adopted',          '2025-02-10 11:05:00', FALSE, TRUE),
  (2019, 1017, 'Adopted',          '2025-02-12 13:45:00', FALSE, TRUE),
  (2020, 1018, 'Adopted',          '2025-02-12 13:45:00', FALSE, TRUE),
  (2021, 1019, 'Adopted',          '2025-02-14 10:25:00', FALSE, TRUE),
  (2022, 1020, 'Transferred',      '2025-02-16 15:30:00', FALSE, TRUE),
  (2023, 1021, 'Foster',           '2025-02-18 09:50:00', FALSE, TRUE),
  (2024, 1022, 'Behavior Hold',    '2025-02-20 17:05:00', FALSE, TRUE),
  (2025, 1023, 'Adopted',          '2025-02-22 14:40:00', FALSE, TRUE),
  (2026, 1024, 'Hospice Foster',   '2025-02-24 11:15:00', FALSE, TRUE),
  (2027, 1025, 'Relocated',        '2025-02-26 08:30:00', FALSE, TRUE),
  (2028, 1026, 'Adopted',          '2025-02-28 10:10:00', FALSE, TRUE),
  (2029, 1027, 'Adopted',          '2025-03-01 12:05:00', FALSE, TRUE),
  (2030, 1028, 'Adopted',          '2025-03-01 12:05:00', FALSE, TRUE),
  (2031, 1029, 'Adopted',          '2025-03-10 16:40:00', TRUE,  TRUE),
  (2032, 1030, 'Adopted',          '2025-03-12 15:20:00', FALSE, TRUE);

------------------------------------------------------------
-- 8. ADOPTION (only for OutcomeType = 'Adopted')
------------------------------------------------------------
INSERT INTO Adoption (OutcomeID, AdopterSsn, AdoptionDate, AdoptionFee)
VALUES
  (2000, '123456789', '2025-01-20', 150.00),
  (2002, '234567890', '2025-01-25', 200.00),
  (2003, '345678901', '2025-02-01',  75.00),

  (2006, '456789012', '2025-02-01', 175.00),  -- 1005
  (2008, '567890123', '2025-02-10', 225.00),  -- 1007
  (2009, '678901234', '2025-02-15', 120.00),  -- 1008
  (2010, '678901234', '2025-02-15', 120.00),  -- 1009 bonded pair
  (2011, '789012345', '2025-02-20', 250.00),  -- 1010
  (2014, '123456789', '2025-03-10', 200.00),  -- 1002 second adoption

  (2015, '890123456', '2025-02-05', 180.00),  -- 1013
  (2018, '901234567', '2025-02-10',  95.00),  -- 1016
  (2019, '456789012', '2025-02-12', 250.00),  -- 1017
  (2020, '456789012', '2025-02-12', 250.00),  -- 1018
  (2021, '098765432', '2025-02-14', 130.00),  -- 1019
  (2025, '012345678', '2025-02-22', 220.00),  -- 1023
  (2028, '123456789', '2025-02-28', 175.00),  -- 1026
  (2029, '234567890', '2025-03-01', 200.00),  -- 1027
  (2030, '234567890', '2025-03-01', 200.00),  -- 1028
  (2031, '678901234', '2025-03-10',  75.00),  -- 1029
  (2032, '789012345', '2025-03-12', 210.00);  -- 1030