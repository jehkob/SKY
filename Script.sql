
drop table "SKY".ho_temp;
create table SKY.home_temp as 
	select 
	home_team as TEAM,
	EXTRACT(year from date::DATE) as yr_col,
	SUM(case when runs1 > runs0 THEN 1 
            ELSE 0 
        end) AS home_wins,
        SUM(CASE 
            WHEN runs1 < runs0 THEN 1 
            ELSE 0 
        end) AS home_losses
    from "SKY".gamehist g 
    group by team, yr_col
    order by team, yr_col ;
    

drop table "SKY".away_temp;

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
        end) AS away_losses
    from "SKY".gamehist g 
    group by team, yr_col
    order by team, yr_col ;
   
  select * from SKY.home_temp limit 10;  
    select * from SKY.away_temp limit 10