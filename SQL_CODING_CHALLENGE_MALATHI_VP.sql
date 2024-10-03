--Creating database

CREATE DATABASE CrimeSchemaNewdb;

use CrimeSchemaNewdb;

-- Create tables

-- Creating table Crime

CREATE TABLE Crime (
CrimeID INT PRIMARY KEY,
IncidentType VARCHAR(255),
IncidentDate DATE,
Location VARCHAR(255),
Description TEXT,
Status VARCHAR(20)
); 

-- Creating table Victim

CREATE TABLE Victim (
VictimID INT PRIMARY KEY,
CrimeID INT,
Name VARCHAR(255),
ContactInfo VARCHAR(255),
Injuries VARCHAR(255),
FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
); 

-- Creating table Suspect

CREATE TABLE Suspect (
SuspectID INT PRIMARY KEY,
CrimeID INT,
Name VARCHAR(255),
Description TEXT,
CriminalHistory TEXT,
FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
); 
 
-- Insert sample data 

--Inserting datas into Crime table
 
INSERT INTO Crime (CrimeID, IncidentType, IncidentDate, Location, Description, Status)
VALUES
(1, 'Robbery', '2023-09-15', '123 Main St, Cityville', 'Armed robbery at a convenience store', 'Open'),
(2, 'Homicide', '2023-09-20', '456 Elm St, Townsville', 'Investigation into a murder case', 'Under Investigation'),
(3, 'Theft', '2023-09-10', '789 Oak St, Villagetown', 'Shoplifting incident at a mall', 'Closed'); 
 
 --Inserting datas into Victim table

INSERT INTO Victim (VictimID, CrimeID, Name, ContactInfo, Injuries)
VALUES
(1, 1, 'John Doe', 'johndoe@example.com', 'Minor injuries'),
(2, 2, 'Jane Smith', 'janesmith@example.com', 'Deceased'),
(3, 3, 'Alice Johnson', 'alicejohnson@example.com', 'None'); 

--Inserting datas into Suspect table

INSERT INTO Suspect (SuspectID, CrimeID, Name, Description, CriminalHistory)
VALUES
(1, 1, 'Robber 1', 'Armed and masked robber', 'Previous robbery convictions'),
(2, 2, 'Unknown', 'Investigation ongoing', NULL),
(3, 3, 'Suspect 1', 'Shoplifting suspect', 'Prior shoplifting arrests'); 

-- Printing all the tables

SELECT * FROM Crime;
SELECT * FROM Victim;
SELECT * FROM Suspect;

-- 1. Select all open incidents

SELECT * FROM Crime
WHERE Status = 'Open';

-- 2. Find the total number of incidents

SELECT COUNT(*) AS TotalIncidents FROM Crime;

-- 3. List all unique incident types

SELECT DISTINCT IncidentType FROM Crime;

-- 4. Retrieve incidents that occurred between '2023-09-01' and '2023-09-10'

SELECT * FROM Crime
WHERE IncidentDate BETWEEN '2023-09-01' AND '2023-09-10';

--ASSUMPTIONS
-- Since we're asked queries related to age, so we are creating a column 'Age' in both victim and suspect table

ALTER TABLE Victim
ADD Age INT;

UPDATE Victim
SET Age = 30
WHERE VictimID = 1;

UPDATE Victim
SET Age = 32
WHERE VictimID = 2;

UPDATE Victim
SET Age = 27
WHERE VictimID = 3;

ALTER TABLE Suspect
ADD Age INT;

UPDATE Suspect
SET Age = 29
WHERE SuspectID = 1;

UPDATE Suspect
SET Age = 35
WHERE SuspectID = 2;

UPDATE Suspect
SET Age = 40
WHERE SuspectID = 3;

-- 5. List persons involved in incidents in descending order of age

SELECT Name, Age FROM Victim
UNION
SELECT Name, Age FROM Suspect
ORDER BY Age DESC;

-- 6. Find the average age of persons involved in incidents

SELECT AVG(Age) AS AverageAge FROM (
  SELECT Age FROM Victim
  UNION
  SELECT Age FROM Suspect
) AS Persons;

-- 7. List incident types and their counts, only for open cases

SELECT IncidentType, COUNT(*) AS IncidentCount FROM Crime
WHERE Status = 'Open'
GROUP BY IncidentType;

-- 8. Find persons with names containing 'Doe'

SELECT Name FROM Victim WHERE Name LIKE '%Doe%'
UNION
SELECT Name FROM Suspect WHERE Name LIKE '%Doe%';

-- 9. Retrieve the names of persons involved in open cases and closed cases

SELECT v.Name AS Victim, s.Name AS Suspect, c.Status 
FROM Crime c
LEFT JOIN Victim v ON c.CrimeID = v.CrimeID
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE c.Status IN ('Open', 'Closed');

-- 10. List incident types where there are persons aged 30 or 35 involved

SELECT DISTINCT c.IncidentType
FROM Crime c
JOIN Victim v ON c.CrimeID = v.CrimeID
WHERE v.Age IN (30, 35)
UNION
SELECT DISTINCT c.IncidentType
FROM Crime c
JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE s.Age IN (30, 35);

-- 11. Find persons involved in incidents of the same type as 'Robbery'

SELECT v.Name FROM Victim v
JOIN Crime c ON v.CrimeID = c.CrimeID
WHERE c.IncidentType = 'Robbery'
UNION
SELECT s.Name FROM Suspect s
JOIN Crime c ON s.CrimeID = c.CrimeID
WHERE c.IncidentType = 'Robbery';

-- 12. List incident types with more than one open case

SELECT IncidentType, COUNT(*) AS OpenCases
FROM Crime
WHERE Status = 'Open'
GROUP BY IncidentType
HAVING COUNT(*) > 1;

-- Since there are only one open case in the table, query 12 will not give the output

-- 13.  List all incidents with suspects whose names also appear as victims in other incidents

SELECT c.CrimeID, c.IncidentType, c.Status
FROM Crime c
JOIN Suspect s ON c.CrimeID = s.CrimeID
JOIN Victim v ON s.Name = v.Name
WHERE s.Name = v.Name;

--Since no suspect name match with the victim name, query 13 will not give output

-- 14. Retrieve all incidents along with victim and suspect details

SELECT c.CrimeID, c.IncidentType, c.Status, v.Name AS VictimName, s.Name AS SuspectName
FROM Crime c
LEFT JOIN Victim v ON c.CrimeID = v.CrimeID
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID;

-- 15. Find incidents where the suspect is older than any victim

SELECT c.CrimeID, c.IncidentType
FROM Crime c
JOIN Victim v ON c.CrimeID = v.CrimeID
JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE s.Age > v.Age;

-- 16. Find suspects involved in multiple incidents

SELECT Name, COUNT(*) AS IncidentCount
FROM Suspect
GROUP BY Name
HAVING COUNT(DISTINCT CrimeID) > 1;

-- Since no suspect is involved in multipe incident, query 16 will not give output

-- 17. List incidents with no suspects involved

SELECT c.CrimeID, c.IncidentType, c.Status
FROM Crime c
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID
WHERE s.SuspectID IS NULL;

-- Since all incidents have suspect, query 17 will not give output

-- 18. List all cases where at least one incident is of type 'Homicide' and all other incidents are of type 'Robbery'

SELECT c.*
FROM Crime c
WHERE EXISTS (SELECT 1 FROM Crime WHERE IncidentType = 'Homicide')
AND NOT EXISTS (SELECT 1 FROM Crime WHERE IncidentType NOT IN ('Homicide', 'Robbery'));

-- Since there is a incident 'theft' , query 18 will not give output

-- 19. Retrieve a list of all incidents and the associated suspects, showing suspects for each incident, or 'No Suspect' if there are none

SELECT c.CrimeID, c.IncidentType, COALESCE(s.Name, 'No Suspect') AS SuspectName
FROM Crime c
LEFT JOIN Suspect s ON c.CrimeID = s.CrimeID;

-- 20. List all suspects who have been involved in incidents with incident types 'Robbery' or 'Assault

SELECT s.Name 
FROM Suspect s
JOIN Crime c ON s.CrimeID = c.CrimeID
WHERE c.IncidentType IN ('Robbery', 'Assault');











