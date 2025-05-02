# case-studies Olympic Games 1896-2016

![image](https://user-images.githubusercontent.com/92555446/187437164-b0bbad30-97d4-4ce5-a835-2de27a39bedf.png)

## Dataset: 

https://techtfq.com/blog/practice-writing-sql-queries-using-real-dataset

## Requirement:
**We have dataset in the CSV format we need to import it into database and have to extract important information to get the idea about games and sportsperson, countries participants in each session. The below is problem statements which we need to solve using structure query language.**

:red_circle: **How many olympics games have been held?**
**SQL Query**
```sql
select 
	count(distinct Games) Total_games 
from 
	OLYMPICS_HISTORY;
```

:red_circle: **List down all Olympics games held so far.**
**SQL Query**
```sql
select distinct
    Games as Olympic_Games
from OLYMPICS_HISTORY
order by Olympic_Games asc;
```


:red_circle: **Mention the total no of nations who participated in each olympics game?**

**SQL Query**
```sql
select o.Games,
       count(distinct n.region) total_nations
from OLYMPICS_HISTORY_NOC_REGIONS n
    join OLYMPICS_HISTORY o
        on n.NOC = o.NOC
group by Games;
```

:red_circle: **Which year saw the highest and lowest no of countries participating in olympics?**

**SQL Query**
```sql
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

```
:red_circle: **Which nation has participated in all of the olympic games?**

**SQL Query**
```sql
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

```
:red_circle: **Identify the sport which was played in all summer olympics.**

**SQL Query**
```sql
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

```

:red_circle: **Which Sports were just played only once in the olympics?**

**SQL Query**
```sql
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

```
:red_circle: **Fetch the total no of sports played in each olympic games.**

**SQL Query**
```sql
select  
	Games, 
	count(distinct sport) no_of_sports 
from OLYMPICS_HISTORY 
group by games 
order by no_of_sports desc;

```

:red_circle: **Fetch details of the oldest athletes to win a gold medal.**

**SQL Query**
```sql
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

```

:red_circle: **Find the Ratio of male and female athletes participated in all olympic games.**

**SQL Query**
```sql
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

```
:red_circle: **Fetch the athletes who have won the most gold medals.**
```sql
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
```

:red_circle: **Fetch the top 5 athletes who have won the most gold medals.**

**SQL Query**
```sql
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
```
:red_circle: **Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).**

**SQL Query**
```sql
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

```

:red_circle: **Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.**

**SQL Query**
```sql
select 
	top 5 team, 
	count(medal) total_medals, 
	DENSE_RANK() over(order by count(medal) desc) Ranking  
from OLYMPICS_HISTORY 
where medal <> 'NA' 
group by team 
order by total_medals desc;

```

:red_circle: **List down total gold, silver and broze medals won by each country.**

**SQL Query**
```sql
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

```

:red_circle: **List down total gold, silver and broze medals won by each country corresponding to each olympic games.**

**SQL Query**
```sql
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

```

:red_circle: **Identify which country won the most gold, most silver and most bronze medals in each olympic games.**

**SQL Query**
```sql
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

```

:red_circle: **Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.**

**SQL Query**
```sql
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

```

:red_circle: **Which countries have never won gold medal but have won silver/bronze medals?**

**SQL Query**
```sql
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

```

:red_circle: **In which Sport/event, India has won highest medals.**

**SQL Query**
```sql
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

```

:red_circle: **Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.**

**SQL Query**
```sql
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
```

## Tool Used:
- Microsoft Excel 
- SQL 
- SQL Server RDBMS

