/* Pet Health & Welfare Database - queries.sql
   Includes:
   - Core analysis / reporting queries (for use cases)
   - UI / demo queries (simple read + CRUD)
   NOTE: Some queries INSERT/UPDATE/DELETE data.
         Run those on a copy of the database if you
         don’t want to modify your main data. */

/* 1. Core Analysis / Reporting Queries
   (These support the “SQL Query Statements” + use cases.) */

/* 1.1 Recent outcomes per animal (Animal + Outcome)
   - Shows animals with their outcomes, ordered by date.
   - Used for “review recent outcomes” scenario. */
SELECT
    a.AnimalID,
    a.Species,
    a.Sex,
    a.AgeMonths,
    o.OutcomeType,
    o.OutcomeDateTime
FROM Animal a
JOIN Outcome o ON a.AnimalID = o.AnimalID
ORDER BY o.OutcomeDateTime DESC;


/* 1.2 Adoption counts by state and species
   - Supports: "What is the number of adoption counts
     of each species by state?" */
SELECT
    l.State,
    a.Species,
    COUNT(*) AS AdoptionCount
FROM Adoption ad
JOIN Outcome o   ON ad.OutcomeID   = o.OutcomeID
JOIN Animal a    ON o.AnimalID     = a.AnimalID
JOIN Adopter d   ON ad.AdopterSsn  = d.Ssn
JOIN Location l  ON d.LocationID   = l.LocationID
GROUP BY l.State, a.Species
ORDER BY l.State, a.Species;


/* 1.3 Live vs total outcomes by species
   - Supports: "What are the total live outcomes by
     state and species?" (species piece here; state
     can be added by joining Location if needed.) */
SELECT
    a.Species,
    SUM(CASE WHEN o.IsLive = TRUE THEN 1 ELSE 0 END) AS LiveOutcomes,
    COUNT(*) AS TotalOutcomes
FROM Outcome o
JOIN Animal a ON o.AnimalID = a.AnimalID
GROUP BY a.Species
ORDER BY a.Species;


/* 1.4 Animals that have at least one adoption outcome
   - Nested query example; supports “which animals
     have been successfully adopted?” */
SELECT
    a.AnimalID,
    a.Species
FROM Animal a
WHERE a.AnimalID IN (
    SELECT o.AnimalID
    FROM Outcome o
    WHERE o.OutcomeType = 'Adopted'
)
ORDER BY a.AnimalID;


/* 1.5 Example search queries for animals
   - These are concrete versions of the parameterized
     query in the report.
   - In the report you had:
       WHERE Species = ? AND (OrgID = ? OR ? IS NULL)
   - Here we provide testable versions:

   Example A: All dogs in Org 1
*/
SELECT
    AnimalID,
    OrgID,
    Species,
    Sex,
    AgeMonths,
    Microchip,
    Notes
FROM Animal
WHERE Species = 'Dog'
  AND OrgID = 1
ORDER BY AnimalID;

/* Example B: All cats across all organizations */
SELECT
    AnimalID,
    OrgID,
    Species,
    Sex,
    AgeMonths,
    Microchip,
    Notes
FROM Animal
WHERE Species = 'Cat'
ORDER BY OrgID, AnimalID;


/* 1.6 Total intakes per year, per state and species
   - Supports: "total feline and canine intakes per
     year by state." */
SELECT
    l.State,
    YEAR(i.IntakeDateTime) AS IntakeYear,
    a.Species,
    COUNT(*) AS TotalIntakes
FROM Intake i
JOIN Animal a   ON i.AnimalID   = a.AnimalID
JOIN Location l ON i.LocationID = l.LocationID
GROUP BY l.State, YEAR(i.IntakeDateTime), a.Species
ORDER BY IntakeYear, l.State, a.Species;


/* 1.7 Outcome breakdown (adoption vs euthanasia) by
   species and year
   - Supports: "year-by-year adoption and euthanasia
     rate by species of all states." */
SELECT
    a.Species,
    YEAR(o.OutcomeDateTime) AS OutcomeYear,
    SUM(CASE WHEN o.OutcomeType = 'Adopted'    THEN 1 ELSE 0 END) AS NumAdopted,
    SUM(CASE WHEN o.OutcomeType = 'Euthanized' THEN 1 ELSE 0 END) AS NumEuthanized,
    COUNT(*) AS TotalOutcomes
FROM Outcome o
JOIN Animal a ON o.AnimalID = a.AnimalID
GROUP BY a.Species, YEAR(o.OutcomeDateTime)
ORDER BY OutcomeYear, a.Species;


/* 1.8 Average number of animals handled per organization
   by state and year
   - Supports: "What is the average number of animals
     handled per organization by state and year?" */
SELECT
    l.State,
    YEAR(i.IntakeDateTime) AS IntakeYear,
    COUNT(DISTINCT a.AnimalID) / COUNT(DISTINCT o.OrgID) AS AvgAnimalsPerOrg
FROM Intake i
JOIN Animal a    ON i.AnimalID   = a.AnimalID
JOIN Location l  ON i.LocationID = l.LocationID
JOIN Organization o ON l.OrgID   = o.OrgID
GROUP BY l.State, YEAR(i.IntakeDateTime)
ORDER BY IntakeYear, l.State;


/* 2. UI / Demo Queries
   (These correspond to Appendix D + CRUD operations.) */

/* RUN MANUALLY (DO NOT RUN WHOLE FILE) */

/* 2.1 Simple read query for Animals page
   - Used by /animals-simple endpoint. */
SELECT
    AnimalID,
    OrgID,
    Species,
    Sex,
    AgeMonths,
    Microchip,
    Notes
FROM Animal
ORDER BY AnimalID
LIMIT 50;


/* 2.2 CREATE – Insert a new animal
   - Example values chosen to avoid conflicts with your
     existing data (AnimalID 1100, OrgID 1, Location 100).
   - Used by POST /add-animal in the UI demo. */
INSERT INTO Animal (
    AnimalID,
    OrgID,
    Species,
    Sex,
    AgeMonths,
    Microchip,
    Notes
) VALUES (
    1100,
    1,
    'Dog',
    'M',
    24,
    'MC1100Z',
    'Demo insert from queries.sql'
);


/* 2.3 CREATE – Insert an initial intake for that new animal
   - Uses composite PK (IntakeNo, AnimalID).
   - IntakeNo 99 chosen to avoid existing values. */
INSERT INTO Intake (
    IntakeNo,
    AnimalID,
    IntakeType,
    IntakeDateTime,
    SourceText,
    LocationID
) VALUES (
    99,
    1100,
    'Owner Surrender',
    '2025-03-20 10:30:00',
    'Owner moved out of state.',
    100
);


/* 2.4 UPDATE – Update adopter contact info
   - Demonstrates CRUD "Update".
   - Uses an existing adopter SSN from your inserts
     (e.g., '123456789'). */
UPDATE Adopter
SET
    Phone = '206-555-9999',
    Email = 'updated.email@example.com'
WHERE Ssn = '123456789';


/* 2.5 DELETE – Delete a specific adoption record
   - Demonstrates CRUD "Delete".
   - Uses an OutcomeID that exists in your Adoption table
     (e.g., 2032). Run on a copy if you don’t want to lose it. */
DELETE FROM Adoption
WHERE OutcomeID = 2032;


/* 2.6 Example: show all adoptions after a given date
   - Simple filter to show “recent adoptions” in UI/demo. */
SELECT
    ad.OutcomeID,
    ad.AdopterSsn,
    ad.AdoptionDate,
    ad.AdoptionFee,
    a.AnimalID,
    a.Species
FROM Adoption ad
JOIN Outcome o ON ad.OutcomeID = o.OutcomeID
JOIN Animal a  ON o.AnimalID   = a.AnimalID
WHERE ad.AdoptionDate >= '2025-02-01'
ORDER BY ad.AdoptionDate;


/* 2.7 Example: joined view used in screenshots
   - Similar to Figure 5 in the report: Animal + Outcome. */
SELECT
    a.AnimalID,
    a.Species,
    o.OutcomeType,
    o.OutcomeDateTime
FROM Animal a
JOIN Outcome o ON a.AnimalID = o.AnimalID
ORDER BY o.OutcomeDateTime DESC;