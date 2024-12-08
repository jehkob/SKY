CREATE TABLE "SKY".final_table AS
WITH latest_games AS (
    SELECT 
        EXTRACT(YEAR FROM g.date::DATE) AS year,
        MAX(g.date) AS max_date
    FROM "SKY".gamehist g
    WHERE g.game_type = 3
    GROUP BY EXTRACT(YEAR FROM g.date::DATE)
),
game_results AS (
    SELECT 
        lg.year,
        g.date,
        -- Winning Team
        CASE 
            WHEN g.runs1 > g.runs0 THEN g.home_team 
            ELSE g.away_team 
        END AS winning_team_id,
        CASE 
            WHEN g.runs1 > g.runs0 THEN CONCAT(tl_home.city, ' ', tl_home.nickname)
            ELSE CONCAT(tl_away.city, ' ', tl_away.nickname)
        END AS winning_team_name,
        -- Losing Team
        CASE 
            WHEN g.runs1 > g.runs0 THEN g.away_team
            ELSE g.home_team
        END AS losing_team_id,
        CASE 
            WHEN g.runs1 > g.runs0 THEN CONCAT(tl_away.city, ' ', tl_away.nickname)
            ELSE CONCAT(tl_home.city, ' ', tl_home.nickname)
        END AS losing_team_name,
        g.runs1 AS home_team_runs,
        g.runs0 AS away_team_runs
    FROM "SKY".gamehist g
    INNER JOIN latest_games lg 
        ON EXTRACT(YEAR FROM g.date::DATE) = lg.year AND g.date = lg.max_date
    LEFT JOIN "SKY".team_lu tl_home ON g.home_team = tl_home.ID
    LEFT JOIN "SKY".team_lu tl_away ON g.away_team = tl_away.ID
    WHERE g.game_type = 3
),
team_metrics AS (
    SELECT 
        gr.year,
        gr.winning_team_name AS team_name,
        'winning' AS result,
        tr.W,
        tr.L,
        tr.runsScored,
        tr.runsAgainst,
        tr.home_wins,
        tr.home_losses,
        tr.away_wins,
        tr.away_losses,
        tr.homeRunsFor,
        tr.homeRunsAgainst,
        tr.awayRunsFor,
        tr.awayRunsAgainst,
        -- Calculated Metrics
        ROUND(tr.home_wins::DECIMAL / NULLIF(tr.home_wins + tr.home_losses, 0), 4) AS home_win_percentage,
        ROUND(tr.away_wins::DECIMAL / NULLIF(tr.away_wins + tr.away_losses, 0), 4) AS away_win_percentage,
        (tr.homeRunsFor - tr.homeRunsAgainst) AS home_run_diff,
        (tr.awayRunsFor - tr.awayRunsAgainst) AS away_run_diff
    FROM game_results gr
    LEFT JOIN "SKY".teamRecords tr 
        ON gr.year = tr.Year AND gr.winning_team_name = CONCAT(tr.City, ' ', tr.Nickname)
    UNION ALL
    SELECT 
        gr.year,
        gr.losing_team_name AS team_name,
        'losing' AS result,
        tr.W,
        tr.L,
        tr.runsScored,
        tr.runsAgainst,
        tr.home_wins,
        tr.home_losses,
        tr.away_wins,
        tr.away_losses,
        tr.homeRunsFor,
        tr.homeRunsAgainst,
        tr.awayRunsFor,
        tr.awayRunsAgainst,
        -- Calculated Metrics
        ROUND(tr.home_wins::DECIMAL / NULLIF(tr.home_wins + tr.home_losses, 0), 4) AS home_win_percentage,
        ROUND(tr.away_wins::DECIMAL / NULLIF(tr.away_wins + tr.away_losses, 0), 4) AS away_win_percentage,
        (tr.homeRunsFor - tr.homeRunsAgainst) AS home_run_diff,
        (tr.awayRunsFor - tr.awayRunsAgainst) AS away_run_diff
    FROM game_results gr
    LEFT JOIN "SKY".teamRecords tr 
        ON gr.year = tr.Year AND gr.losing_team_name = CONCAT(tr.City, ' ', tr.Nickname)
)
SELECT *
FROM team_metrics
ORDER BY year, team_name, result;

select * from "SKY".final_table limit 100;

COPY "SKY".final_table TO 'C:\Users\Public\SCS.csv' DELIMITER ',' CSV HEADER;

select * from "SKY".teamRecords where year=2001 and city in('Montreal','Milwaukee')