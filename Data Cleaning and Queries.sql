CREATE DATABASE fifa;

USE fifa;

SELECT * FROM players_15;

-- creating table of top 100 players
CREATE TABLE top_players AS 
SELECT * FROM players_15
ORDER BY overall DESC
LIMIT 100;

SELECT * FROM top_players;
DESCRIBE top_players;

-- data cleaning 

-- converting dates from TEXT to DATE

SET SQL_SAFE_UPDATES = 0;
ALTER TABLE top_players MODIFY dob DATE;
UPDATE top_players SET club_joined = NULL WHERE club_joined = ""; -- to account for missing values (loan players)
ALTER TABLE top_players MODIFY club_joined DATE;

-- cleaning positions column

ALTER TABLE top_players ADD COLUMN position VARCHAR(255);

UPDATE top_players 
SET position = CASE
	WHEN player_positions LIKE '%GK%' THEN 'goalkeeper'
    WHEN player_positions LIKE '%CF%' 
        OR player_positions LIKE '%ST%'
        OR player_positions LIKE '%RW%'
        OR player_positions LIKE '%LW%'
        OR player_positions LIKE '%RF%'
        OR player_positions LIKE '%LF%' THEN 'attacker'
    WHEN player_positions LIKE '%CM%' 
        OR player_positions LIKE '%RM%'
        OR player_positions LIKE '%LM%'
        OR player_positions LIKE '%CDM%'
        OR player_positions LIKE '%CAM%'
        OR player_positions LIKE '%RAM%'
        OR player_positions LIKE '%LAM%' THEN 'midfielder'
    WHEN player_positions LIKE '%CB%' 
        OR player_positions LIKE '%RB%'
        OR player_positions LIKE '%LB%'
        OR player_positions LIKE '%RCB%'
        OR player_positions LIKE '%LCB%'
        OR player_positions LIKE '%RLB%'
        OR player_positions LIKE '%LLB%' THEN 'defender'
    ELSE 'other'
END;


-- writing queries to analyze dataset 

-- question 1: how correlated is a players wage to his overall fifa rating?
SELECT overall, AVG(wage_eur) AS avg_wage_eur
FROM top_players
GROUP BY overall
ORDER BY overall;

-- question 2: what is the distribution of different nationalities among the top 100 players in the world? I'm sure they are mostly from Singapore!
SELECT nationality_name, COUNT(*) AS number_of_players
FROM top_players
GROUP BY nationality_name
ORDER BY number_of_players DESC;

-- question 3: which trait is most important for an attacker - pace, shooting, passing or dribbling
SELECT overall, pace, shooting, passing, dribbling FROM top_players WHERE position = 'attacker';

-- question 4: which positions are most common in top 100 players
SELECT position, COUNT(*) AS number_of_players
FROM top_players
GROUP BY POSITION
ORDER BY number_of_players DESC;

-- question 5: does height affect the position you play?

SELECT position, AVG(height_cm) AS average_height
FROM top_players
GROUP BY POSITION
ORDER BY average_height DESC;


-- question 6: which players have improved the most from Fifa 15 to Fifa 22??

SELECT a.short_name, (b.overall - a.overall) as improvement
FROM players_15 a
INNER JOIN players_22 b ON a.sofifa_id = b.sofifa_id
ORDER BY improvement DESC
LIMIT 10;



-- question 7: Are there any players who were in the top 10 in both 2015 and 2022?

WITH 
top_10_15 AS (
  SELECT sofifa_id, short_name, overall
  FROM players_15
  ORDER BY overall DESC
  LIMIT 10
),
top_10_22 AS (
  SELECT sofifa_id, short_name, overall
  FROM players_22
  ORDER BY overall DESC
  LIMIT 10
)

SELECT a.short_name, a.overall as overall_15, b.overall as overall_22
FROM top_10_15 a
JOIN top_10_22 b ON a.sofifa_id = b.sofifa_id
ORDER BY a.overall DESC, b.overall DESC;


