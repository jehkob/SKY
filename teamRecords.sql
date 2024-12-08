
drop table "SKY".home_temp;
-- GET HOME STATS --
create table "SKY".home_temp as 
	select 
	home_team as TEAM,
	EXTRACT(year from date::DATE) as yr_col,
	SUM(case when runs1 > runs0 THEN 1 
            ELSE 0 
        end) AS home_wins,
        SUM(CASE 
            WHEN runs1 < runs0 THEN 1 
            ELSE 0 
        end) AS home_losses,
        SUM(runs1) as homeRunsFor,
        SUM(runs0) as homeRunsAgainst
    from "SKY".gamehist g 
    where game_type = 0
    group by team, yr_col
    order by team, yr_col ;
    

drop table "SKY".away_temp;
-- GET AWAY STATS --
create table "SKY".away_temp as 
	select 
	away_team as TEAM,
	EXTRACT(year from date::DATE) as yr_col,
	SUM(case when runs0 > runs1 THEN 1 
            ELSE 0 
        end) AS away_wins,
        SUM(CASE 
            WHEN runs0 < runs1 THEN 1 
            ELSE 0 
        end) AS away_losses,
        SUM(runs0) as awayRunsFor,
        sum(runs1) as awayRunsAgainst
    from "SKY".gamehist g 
    where game_type=0
    group by team, yr_col
    order by team, yr_col ;
   
  select * from "SKY".home_temp limit 10;  
    select * from "SKY".away_temp limit 10;
    
  -- AGGREGATE WITH NAMES -- 
  drop table "SKY".teamRecords ;
   create table "SKY".teamRecords as 
   select 
	  t.city,
	  t.nickname,
	   h.yr_col as year,
	   (h.home_wins+a.away_wins) as W,
	   (h.home_losses+a.away_losses) as L,
	   (h.homeRunsFor+a.awayRunsFor) as RunsScored,
	   (h.homeRunsAgainst+a.awayRunsAgainst) as RunsAgainst,
	   h.home_wins,
	   h.home_losses, 
	   a.away_wins,
	   a.away_losses,
	   h.homeRunsFor,
	   h.homeRunsAgainst,
	   a.awayRunsFor,
	   a.awayRunsAgainst
	   from "SKY".team_lu t, "SKY".home_temp h, "SKY".away_temp a
   where t.ID=h.team
   and t.ID=a.team
   and h.team=a.team
   and h.yr_col=a.yr_col; 
  
 select * from "SKY".teamRecords limit 100; 

grant select on "SKY".teamRECORDS to postgres; 
COPY "SKY".teamRecords TO 'C:\Users\Public\SKY_RECORDS.csv' DELIMITER ',' CSV HEADER;

\copy (SELECT * FROM "SKY".teamRecords) to 'C:/Users/Public/Downloads/SKY_RECORDS.csv' with csv;


--- GET SCS PARTICIPANTS --- 

CREATE TABLE "SKY".SCS AS
SELECT 
    EXTRACT(YEAR FROM g.date::DATE) AS year,
    CONCAT(tl_away.city, ' ', tl_away.nickname) AS away_team_name,
    CONCAT(tl_home.city, ' ', tl_home.nickname) AS home_team_name,
    g.date AS game_date
FROM "SKY".gamehist g
INNER JOIN (
    SELECT 
        EXTRACT(YEAR FROM date::DATE) AS year,
        MAX(date) AS max_date
    FROM "SKY".gamehist
    WHERE game_type = 3
    GROUP BY EXTRACT(YEAR FROM date::DATE)
) latest_games
    ON EXTRACT(YEAR FROM g.date::DATE) = latest_games.year 
   AND g.date = latest_games.max_date
LEFT JOIN "SKY".team_lu tl_away
    ON g.away_team = tl_away.ID
LEFT JOIN "SKY".team_lu tl_home
    ON g.home_team = tl_home.ID
WHERE g.game_type = 3
ORDER BY year;
select * from "SKY".SCS limit 100;


