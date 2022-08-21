use Olympic
select * from OLYMPICS_HISTORY
select * from OLYMPICS_HISTORY_NOC_REGIONS
--How many olympics games have been held?
select 
	count(distinct Games) Total_games 
from 
	OLYMPICS_HISTORY;

--List down all Olympics games held so far.
select distinct
    Games as Olympic_Games
from OLYMPICS_HISTORY
order by Olympic_Games asc;

--Mention the total no of nations who participated in each olympics game?
select o.Games,
       count(distinct n.region) total_nations
from OLYMPICS_HISTORY_NOC_REGIONS n
    join OLYMPICS_HISTORY o
        on n.NOC = o.NOC
group by Games;

--Which year saw the highest and lowest no of countries participating in olympics?
--The FIRST_VALUE() function is a window function that returns the first value in an ordered partition of a result set.
select distinct
    concat(
              first_value(games) over (order by total_nations),
              '-',
              first_value(total_nations) over (order by total_nations)
          ) lowest_no_of_countries,
	concat(
				first_value(games) over(order by total_nations desc),
				'-',
				first_value(total_nations) over(order by total_nations desc)
				) highest_no_of_countries
from
(
    select games,
           count(region) total_nations
    from
    (
        select distinct
            games,
            region
        from OLYMPICS_HISTORY_NOC_REGIONS n
            join OLYMPICS_HISTORY o
                on n.NOC = o.NOC
    ) all_nations
    group by Games
) total_nations;

--Method2
with all_nations
as (select distinct
        games,
        region
    from OLYMPICS_HISTORY_NOC_REGIONS n
        join OLYMPICS_HISTORY o
            on n.NOC = o.NOC
   ),
     total_nations
as (select games,
           count(region) total_nations
    from all_nations
    group by games
   )
select distinct
    concat(
              first_value(games) over (order by total_nations),
              '-',
              first_value(total_nations) over (order by total_nations)
          ) lowest_no_of_countries,
    concat(
              first_value(games) over (order by total_nations desc),
              '-',
              first_value(total_nations) over (order by total_nations desc)
          ) highest_no_of_countries
from total_nations;

--Which nation has participated in all of the olympic games?
with c
as (select nr.region as Nations,
           count(distinct oh.Games) Total_participated_games,
           dense_rank() over (order by count(distinct oh.Games) desc) ranking
    from OLYMPICS_HISTORY_NOC_REGIONS nr
        join OLYMPICS_HISTORY oh
            on oh.NOC = nr.NOC
    group by region
   )
select c.Nations,
       c.Total_participated_games
from c
where ranking = 1
--method2
with total_events
as (select count(distinct games) total_games
    from OLYMPICS_HISTORY oh
   ),
     nations
as (select games,
           nr.region as nation
    from olympics_history oh
        join olympics_history_noc_regions nr
            ON nr.noc = oh.noc
    group by games,
             nr.region
   ),
     country_participated
as (select nation,
           count(1) total_participation
    from nations
    group by nation
   )
select cp.*
from country_participated cp
    join total_events te
        on te.total_games = cp.total_participation
		
--Identify the sport which was played in all summer olympics.
select Sport,
       no_of_games
from
(
    select Sport,
           count(1) as no_of_games,
           DENSE_RANK() over (order by count(Sport) desc) as 'rank'
    from
    (
        select distinct
            Games,
            Sport
        from OLYMPICS_HISTORY
        where Season = 'Summer'
    ) t1
    group by Sport
) t2
where rank = 1;
--Method2
with t1
as (select count(distinct Games) total_sports
    from OLYMPICS_HISTORY
    where Season = 'Summer'
   ),
     t2
as (select distinct
        games,
        sport
    from OLYMPICS_HISTORY
    where Season = 'Summer'
   ),
     t3
as (select sport,
           count(1) no_of_games
    from t2
    group by Sport
   )
select t.*
from t3 t
    join t1
        on t1.total_sports = t.no_of_games;

--Which Sports were just played only once in the olympics?
select distinct
    a.Sport,
    no_of_sport,
    oh.games
from
(
    select sport,
           count(sport) no_of_sport
    from
    (select  distinct games, sport from OLYMPICS_HISTORY) t
    group by sport
    having count(sport) = 1
) a
    join OLYMPICS_HISTORY oh
        on a.Sport = oh.Sport;
		select * from OLYMPICS_HISTORY;
--Method2
with a1
as (select distinct
        games,
        sport
    from OLYMPICS_HISTORY
   ),
     a2
as (select sport,
           count(sport) no_of_games
    from a1
    group by sport
   )
select distinct
    a2.Sport,
    a2.no_of_games,
    a1.Games
from a2
    join a1
        on a2.Sport = a1.Sport
where no_of_games = 1;

--Fetch the total no of sports played in each olympic games.
select  
	Games, 
	count(distinct sport) no_of_sports 
from OLYMPICS_HISTORY 
group by games 
order by no_of_sports desc;

--Fetch details of the oldest athletes to win a gold medal.
with t1
as (select max(   cast(case
                           when age = 'NA' then
                               0
                           else
                               age
                       end as int)
              ) max_age_gold_winner
    from OLYMPICS_HISTORY
    where Medal = 'Gold'
   ),
     t2
as (select oh.Name,
           oh.Sex,
           cast(case
                    when age = 'NA' then
                        0
                    else
                        age
                end as int) as Aged,
           oh.Team,
           oh.Games,
           oh.City,
           oh.Sport,
           oh.Event,
           oh.Medal
    from OLYMPICS_HISTORY oh
   )
select t2.*
from t2
    join t1
        on t2.Aged = t1.max_age_gold_winner
where Medal = 'gold';
--Method2
with t1
as (select name,
           sex,
           cast(case
                    when age = 'NA' then
                        0
                    else
                        age
                end as int) as age,
           team,
           games,
           city,
           sport,
           event,
           medal
    from olympics_history
   ),
     ranking
as (select *,
           rank() over (order by age desc) as ranking
    from t1
    where medal = 'Gold'
   )
select *
from ranking
where ranking = 1;
	
--Find the Ratio of male and female athletes participated in all olympic games.
select  concat(Female / Female,' : ',round(Male/Female,2)) Ratio_of_FemaleMale
from
(
    select cast(count(   case
                        when Sex = 'M' then
                            1
                    end
                ) as float) as Male,
           count(   case
                        when Sex = 'F' then
                            1
                    end
                )as Female
    from OLYMPICS_HISTORY
) a
--Method2
with cte as (
	select cast(count(   case
                        when Sex = 'M' then
                            1
                    end
                ) as float) as Male,
           count(   case
                        when Sex = 'F' then
                            1
                    end
                )as Female
    from OLYMPICS_HISTORY
	)
select  concat(Female / Female,' : ',round(Male/Female,2)) Ratio_of_FemaleMale
from cte
use Olympic

--Fetch the athletes who have won the most gold medals.
with t1 as (
	select 
		[name], 
		count(medal) total_gold_medals 
	from OLYMPICS_HISTORY 
	where Medal = 'gold' 
	group by [name] 
	)
select distinct 
	t1.[name], 
	oh.team, 
	t1.total_gold_medals 
from 
	t1, OLYMPICS_HISTORY oh 
where oh.Name = t1.Name 
order by total_gold_medals desc
--Top 5
with t1 as (
	select 
		[name], 
		count(medal) total_gold_medals 
	from OLYMPICS_HISTORY 
	where Medal = 'gold' 
	group by [name] 
	)
select distinct top 5   
	t1.[name], 
	oh.team, 
	t1.total_gold_medals 
from 
	t1, OLYMPICS_HISTORY oh 
where oh.Name = t1.Name 
order by total_gold_medals desc
--Method2
 with t1 as
            (select name, team, count(1) as total_gold_medals
            from olympics_history
            where medal = 'Gold'
            group by name, team 
            ),
        t2 as
            (select *, row_number() over (order by total_gold_medals desc) as rnk
            from t1)
    select name, team, total_gold_medals
    from t2
    where rnk <= 5 ;

--Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
with t1 as (
	select 
		top 5 [name], 
		count(medal) total_medals 
from OLYMPICS_HISTORY 
where Medal <> 'NA' 
group by [Name]
order by total_medals desc
)
select distinct
	t1.[name], 
	oh.team, 
	t1.total_medals 
from t1, OLYMPICS_HISTORY oh 
where oh.[Name] = t1.[Name] 
order by total_medals desc

--Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.
select 
	top 5 team, 
	count(medal) total_medals, 
	DENSE_RANK() over(order by count(medal) desc) Ranking  
from OLYMPICS_HISTORY 
where medal <> 'NA' 
group by team 
order by total_medals desc;
--List down total gold, silver and broze medals won by each country.
select nr.region as nation,
       count(   case
                    when medal = 'Gold' then
                        1
                end
            ) gold_medals,
       count(   case
                    when medal = 'Silver' then
                        1
                end
            ) silver_medals,
       count(   case
                    when medal = 'Bronze' then
                        1
                end
            ) bronze_medals
from OLYMPICS_HISTORY_NOC_REGIONS nr,
     OLYMPICS_HISTORY oh
where oh.NOC = nr.NOC
      and medal <> 'NA'
group by region
order by gold_medals desc,
         silver_medals desc,
         bronze_medals desc ;     
 --Method2
select nation,
       coalesce([gold], 0) as gold_medals,
       coalesce([silver], 0) as silver_medals,
       coalesce([bronze], 0) as bronze_medals
from
(
    select nr.region as nation,
           oh.medal as medals,
           count(oh.medal) total_medals
    from OLYMPICS_HISTORY_NOC_REGIONS nr,
         OLYMPICS_HISTORY oh
    where oh.NOC = nr.NOC
          and medal <> 'NA'
    group by region,
             Medal
) as pivot_table
pivot
(
    max(total_medals)
    for medals in ([gold], [silver], [bronze])
) as pivot_table
order by gold_medals desc,
         silver_medals desc,
         bronze_medals desc;
--List down total gold, silver and broze medals won by each country corresponding to each olympic games.
select oh.Games as games,
	   nr.region as nation,
       count(   case
                    when medal = 'Gold' then
                        1
                end
            ) gold_medals,
       count(   case
                    when medal = 'Silver' then
                        1
                end
            ) silver_medals,
       count(   case
                    when medal = 'Bronze' then
                        1
                end
            ) bronze_medals
from OLYMPICS_HISTORY_NOC_REGIONS nr,
     OLYMPICS_HISTORY oh
where oh.NOC = nr.NOC
      and medal <> 'NA'
group by region, Games
order by games

--Identify which country won the most gold, most silver and most bronze medals in each olympic games.
select
    games,
    [gold] max_gold_medals,
    [silver] max_silver_medals,
    [bronze] max_bronze_medals
from
(
    select games,
           medal,
           concat(nation, '-', total_medals) as n_tm
    from
    (
        select oh.games,
               nr.region as nation,
               oh.medal,
               count(oh.medal) as total_medals,
               DENSE_RANK() over (partition by medal, games order by count(medal) desc) ranking
        from OLYMPICS_HISTORY oh
            join OLYMPICS_HISTORY_NOC_REGIONS nr
                on oh.NOC = nr.NOC
        where Medal <> 'NA'
        group by Games,
                 region,
                 Medal
    ) t1
    where ranking = 1
) as source_table
pivot
(
    max(n_tm)
    for medal in ([gold], [silver], [bronze])
) as pivot_table
order by Games 

--Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
with t1 as (select 
	oh.games,
	nr.region as nations,
	sum(case when medal = 'gold' then 1 else 0 end) as gold_medals,
	sum(case when medal = 'silver' then 1 else 0 end) as silver_medals,
	sum(case when medal = 'bronze' then 1 else 0 end) as bronze_medals,
	sum(case when medal <> 'NA' then 1 else 0 end) as total_medals
from OLYMPICS_HISTORY oh 
	join OLYMPICS_HISTORY_NOC_REGIONS nr 
		on oh.NOC = nr.NOC
group by Games, region)
select distinct 
	games,
	concat(first_value(nations) over(partition by games order by gold_medals desc),
	'-',
	first_value(gold_medals) over(partition by games order by gold_medals desc)) max_gold_medals,
	concat(first_value(nations) over(partition by games order by silver_medals desc),
	'-',
	first_value(silver_medals) over(partition by games order by silver_medals desc)) max_silver_medals,
	concat(first_value(nations) over(partition by games order by bronze_medals desc),
	'-',
	first_value(bronze_medals) over(partition by games order by bronze_medals desc)) max_bronze_medals,
	concat(first_value(nations) over(partition by games order by total_medals desc),
	'-',
	first_value(total_medals) over(partition by games order by total_medals desc)) max_total_medals
from t1;

--Which countries have never won gold medal but have won silver/bronze medals?
with t1 as (
	select distinct 
		
		nr.region as nations,
		sum(case when medal = 'gold' then 1 else 0 end) as gold_medals,
		sum(case when medal = 'silver' then 1 else 0 end) as silver_medals,
		sum(case when medal = 'bronze' then 1 else 0 end) as bronze_medals
	from 
		OLYMPICS_HISTORY oh, OLYMPICS_HISTORY_NOC_REGIONS nr 
	where oh.NOC = nr.NOC
	group by region
)
select distinct
	nations, 
	gold_medals, 
	silver_medals, 
	bronze_medals 
from 
	t1 
where gold_medals = 0 and (silver_medals > 0 or bronze_medals > 0)
order by silver_medals desc;

--In which Sport/event, India has won highest medals.
select top 1
    sport,
    count(medal) total_medals
from OLYMPICS_HISTORY_NOC_REGIONS nr
    join OLYMPICS_HISTORY oh
        on nr.NOC = oh.NOC
where medal <> 'NA'
      and region = 'India'
group by Sport
order by total_medals desc;

--Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
select nr.region country,
       oh.sport,
       oh.games,
       count(medal) total_medals
from OLYMPICS_HISTORY_NOC_REGIONS nr
    join OLYMPICS_HISTORY oh
        on nr.NOC = oh.NOC
where region = 'India'
      and Medal <> 'NA'
      and Sport = 'Hockey'
group by region,
         Sport,
         Games
order by total_medals desc