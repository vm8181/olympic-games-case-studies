# Case-study Olympic Games 1896-2016


![image](https://user-images.githubusercontent.com/92555446/187437164-b0bbad30-97d4-4ce5-a835-2de27a39bedf.png)

#### A complete SQL-based case study on the Olympic Games from 1896 to 2016. This dataset analyzes athletes, sports, nations, and medals using SQL queries.

## 📂 Dataset Tables Used
- `OLYMPICS_HISTORY`: Contains athlete-level Olympic participation and performance data.
- `OLYMPICS_HISTORY_NOC_REGIONS`: Maps NOC codes to country names (regions).

:red_circle: **How many olympics games have been held?**

**SQL Query**

```sql
select count(distinct Games) Total_games from OLYMPICS_HISTORY;
```
**Sample Output:**
| Total_games |
|-------------|
| 51          |


:red_circle: **List down all Olympics games held so far.**

**SQL Query**
```sql
select distinct
Games as Olympic_Games
from OLYMPICS_HISTORY
order by Olympic_Games asc;
```
**Sample Output:**
| Olympic_Games |
|---------------|
| 1896 Summer   |
| 1900 Summer   |
| 1904 Summer   |
| 1906 Summer   |
| 1908 Summer   |
| 1912 Summer   |
| 1920 Summer   |
| 1924 Summer   |
| 1924 Winter   |
| 1928 Summer   |
| 1928 Winter   |


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
**Sample Output:**
| Games       | total_nations |
|-------------|---------------|
| 1896 Summer | 12            |
| 1900 Summer | 31            |
| 1904 Summer | 14            |
| 1906 Summer | 20            |
| 1908 Summer | 22            |
| 1912 Summer | 29            |
| 1920 Summer | 29            |
| 1924 Summer | 45            |
| 1924 Winter | 19            |
| 1928 Summer | 46            |
| 1928 Winter | 25            |


:red_circle: **Which year saw the highest and lowest no of countries participating in olympics?**

**SQL Query**
```sql
select distinct
concat(first_value(games) over (order by total_nations),'-',first_value(total_nations) over (order by total_nations)) lowest_no_of_countries,
concat(first_value(games) over(order by total_nations desc),'-',first_value(total_nations) over(order by total_nations desc)) highest_no_of_countries
from
(select games,
count(region) total_nations
from
(select distinct games, region from OLYMPICS_HISTORY_NOC_REGIONS n
join OLYMPICS_HISTORY o on n.NOC = o.NOC) all_nations
group by Games
) total_nations;

```
**Sample Output:**
| lowest_no_of_countries | highest_no_of_countries |
|------------------------|-------------------------|
| 1896 Summer-12         | 2016 Summer-204         |

:red_circle: **Which nation has participated in all of the olympic games?**

**SQL Query**
```sql
with c as (
select nr.region as Nations, count(distinct oh.Games) Total_participated_games,
dense_rank() over (order by count(distinct oh.Games) desc) ranking
from OLYMPICS_HISTORY_NOC_REGIONS nr
join OLYMPICS_HISTORY oh on oh.NOC = nr.NOC
group by region)
select c.Nations, c.Total_participated_games from c
where ranking = 1

```
**Sample Output:**
| Nations     | Total_participated_games |
|-------------|--------------------------|
| France      | 51                       |
| Italy       | 51                       |
| Switzerland | 51                       |
| UK          | 51                       |

:red_circle: **Identify the sport which was played in all summer olympics.**

**SQL Query**
```sql
select Sport, no_of_games
from ( select Sport, count(1) as no_of_games, DENSE_RANK() over (order by count(Sport) desc) as 'rank'
from( select distinct Games, Sport from OLYMPICS_HISTORY
where Season = 'Summer') t1
group by Sport) t2
where rank = 1;

```
**Sample Output:**
| Sport      | no_of_games |
|------------|-------------|
| Gymnastics | 29          |
| Swimming   | 29          |
| Fencing    | 29          |
| Cycling    | 29          |
| Athletics  | 29          |


:red_circle: **Which Sports were just played only once in the olympics?**

**SQL Query**
```sql
select distinct a.Sport, no_of_sport, oh.games
from ( select sport, count(sport) no_of_sport
from (select  distinct games, sport from OLYMPICS_HISTORY) t
group by sport
having count(sport) = 1) a
join OLYMPICS_HISTORY oh
on a.Sport = oh.Sport;

```
**Sample Output:**
| Sport               | no_of_sport | games       |
|---------------------|-------------|-------------|
| Cricket             | 1           | 1900 Summer |
| Croquet             | 1           | 1900 Summer |
| Military Ski Patrol | 1           | 1924 Winter |
| Motorboating        | 1           | 1908 Summer |
| Jeu De Paume        | 1           | 1908 Summer |
| Aeronautics         | 1           | 1936 Summer |
| Roque               | 1           | 1904 Summer |
| Basque Pelota       | 1           | 1900 Summer |
| Rugby Sevens        | 1           | 2016 Summer |
| Racquets            | 1           | 1908 Summer |

:red_circle: **Fetch the total no of sports played in each olympic games.**

**SQL Query**
```sql
select Games, count(distinct sport) no_of_sports 
from OLYMPICS_HISTORY 
group by games 
order by no_of_sports desc;

```
**Sample Output:**
| Games       | no_of_sports |
|-------------|--------------|
| 2016 Summer | 34           |
| 2008 Summer | 34           |
| 2004 Summer | 34           |
| 2000 Summer | 34           |
| 2012 Summer | 32           |
| 1996 Summer | 31           |
| 1992 Summer | 29           |
| 1988 Summer | 27           |
| 1984 Summer | 25           |
| 1920 Summer | 25           |
| 1908 Summer | 24           |
| 1936 Summer | 24           |
| 1976 Summer | 23           |


:red_circle: **Fetch details of the oldest athletes to win a gold medal.**

**SQL Query**
```sql
with t1 as (
select max(cast(case when age = 'NA' then 0 else age end as int)) max_age_gold_winner
from OLYMPICS_HISTORY
where Medal = 'Gold'),
t2 as (
select oh.Name, oh.Sex, cast(case when age = 'NA' then 0 else age end as int) as Aged,
oh.Team, oh.Games, oh.City, oh.Sport, oh.Event, oh.Medal
from OLYMPICS_HISTORY oh)
select t2.* from t2
join t1 on t2.Aged = t1.max_age_gold_winner
where Medal = 'gold';

```
**Sample Output:**
| Name              | Sex | Aged | Team          | Games       | City      | Sport    | Event                                            | Medal |
|-------------------|-----|------|---------------|-------------|-----------|----------|--------------------------------------------------|-------|
| Charles Jacobus   | M   | 64   | United States | 1904 Summer | St. Louis | Roque    | Roque Men's Singles                              | Gold  |
| Oscar Gomer Swahn | M   | 64   | Sweden        | 1912 Summer | Stockholm | Shooting | Shooting Men's Running Target, Single Shot, Team | Gold  |


:red_circle: **Find the Ratio of male and female athletes participated in all olympic games.**

**SQL Query**
```sql
select  concat(Female / Female,' : ',round(Male/Female,2)) Ratio_of_FemaleMale
from (Select cast(count(case when Sex = 'M' then 1 end) as float) as Male,
	count(case when Sex = 'F' then 1 end as Female from OLYMPICS_HISTORY) a

```
**Sample Output:**
| Ratio_of_FemaleMale |      |
|---------------------|------|
| 1                   | 2.64 |

:red_circle: **Fetch the athletes who have won the most gold medals.**
```sql
with t1 as (
select [name], count(medal) total_gold_medals 
from OLYMPICS_HISTORY 
where Medal = 'gold' 
group by [name] )
select distinct t1.[name], oh.team, t1.total_gold_medals 
from t1, OLYMPICS_HISTORY oh 
where oh.Name = t1.Name 
order by total_gold_medals desc
```
**Sample Output:**
| name                                              | team          | total_gold_medals |
|---------------------------------------------------|---------------|-------------------|
| Michael Fred Phelps, II                           | United States | 23                |
| Raymond Clarence "Ray" Ewry                       | United States | 10                |
| Frederick Carlton "Carl" Lewis                    | United States | 9                 |
| Larysa Semenivna Latynina (Diriy-)                | Soviet Union  | 9                 |
| Mark Andrew Spitz                                 | United States | 9                 |
| Paavo Johannes Nurmi                              | Finland       | 9                 |
| Birgit Fischer-Schmidt                            | East Germany  | 8                 |
| Birgit Fischer-Schmidt                            | Germany       | 8                 |
| Jennifer Elisabeth "Jenny"   Thompson (-Cumpelik) | United States | 8                 |
| Matthew Nicholas "Matt" Biondi                    | United States | 8                 |

:red_circle: **Fetch the top 5 athletes who have won the most gold medals.**

**SQL Query**
```sql
with t1 as (
select [name], count(medal) total_gold_medals 
from OLYMPICS_HISTORY
where Medal = 'gold' 
group by [name] )
select distinct top 5 t1.[name], oh.team, t1.total_gold_medals 
from t1, OLYMPICS_HISTORY oh 
where oh.Name = t1.Name 
order by total_gold_medals desc
```
**Sample Output:**
| name                               | team          | total_gold_medals |
|------------------------------------|---------------|-------------------|
| Michael Fred Phelps, II            | United States | 23                |
| Raymond Clarence "Ray" Ewry        | United States | 10                |
| Frederick Carlton "Carl" Lewis     | United States | 9                 |
| Larysa Semenivna Latynina (Diriy-) | Soviet Union  | 9                 |
| Mark Andrew Spitz                  | United States | 9                 |

:red_circle: **Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).**

**SQL Query**
```sql
with t1 as (
select top 5 [name], count(medal) total_medals 
from OLYMPICS_HISTORY 
where Medal <> 'NA' 
group by [Name]
order by total_medals desc)
select distinct t1.[name], oh.team, t1.total_medals 
from t1, OLYMPICS_HISTORY oh 
where oh.[Name] = t1.[Name] 
order by total_medals desc

```
**Sample Output:**
| name                               | team          | total_medals |
|------------------------------------|---------------|--------------|
| Michael Fred Phelps, II            | United States | 28           |
| Larysa Semenivna Latynina (Diriy-) | Soviet Union  | 18           |
| Nikolay Yefimovich Andrianov       | Soviet Union  | 15           |
| Borys Anfiyanovych Shakhlin        | Soviet Union  | 13           |
| Edoardo Mangiarotti                | Italy         | 13           |

:red_circle: **Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.**

**SQL Query**
```sql
select top 5 team, count(medal) total_medals, DENSE_RANK() over(order by count(medal) desc) Ranking  
from OLYMPICS_HISTORY 
where medal <> 'NA' 
group by team 
order by total_medals desc;

```
**Sample Output:**
| team          | total_medals | Ranking |
|---------------|--------------|---------|
| United States | 5219         | 1       |
| Soviet Union  | 2451         | 2       |
| Germany       | 1984         | 3       |
| Great Britain | 1673         | 4       |
| France        | 1550         | 5       |

:red_circle: **List down total gold, silver and broze medals won by each country.**

**SQL Query**
```sql
select nr.region as nation, count( case when medal = 'Gold' then 1 end) gold_medals,
count( case when medal = 'Silver' then 1 end) silver_medals,
count( case when medal = 'Bronze' then 1 end) bronze_medals
from OLYMPICS_HISTORY_NOC_REGIONS nr,
OLYMPICS_HISTORY oh
where oh.NOC = nr.NOC and medal <> 'NA'
group by region
order by gold_medals desc, silver_medals desc, bronze_medals desc ;     

```
**Sample Output:**
| nation  | gold_medals | silver_medals | bronze_medals |
|---------|-------------|---------------|---------------|
| USA     | 2638        | 1641          | 1358          |
| Russia  | 1599        | 1170          | 1178          |
| Germany | 1301        | 1195          | 1260          |
| UK      | 678         | 739           | 651           |
| Italy   | 575         | 531           | 531           |
| France  | 501         | 610           | 666           |
| Sweden  | 479         | 522           | 535           |
| Canada  | 463         | 438           | 451           |
| Hungary | 432         | 332           | 371           |
| Norway  | 378         | 361           | 294           |

:red_circle: **List down total gold, silver and broze medals won by each country corresponding to each olympic games.**

**SQL Query**
```sql
select oh.Games as games, nr.region as nation,
count(case when medal = 'Gold' then 1 end) gold_medals,
count(case when medal = 'Silver' then 1 end) silver_medals,
count(case when medal = 'Bronze' then 1 end) bronze_medals
from OLYMPICS_HISTORY_NOC_REGIONS nr,
OLYMPICS_HISTORY oh
where oh.NOC = nr.NOC and medal <> 'NA'
group by region, Games
order by games

```
**Sample Output:**
| games       | nation      | gold_medals | silver_medals | bronze_medals |
|-------------|-------------|-------------|---------------|---------------|
| 1896 Summer | Greece      | 10          | 18            | 20            |
| 1896 Summer | Switzerland | 1           | 2             | 0             |
| 1896 Summer | Germany     | 25          | 5             | 2             |
| 1896 Summer | UK          | 3           | 3             | 3             |
| 1896 Summer | France      | 5           | 4             | 2             |
| 1896 Summer | Denmark     | 1           | 2             | 3             |
| 1896 Summer | Hungary     | 2           | 1             | 3             |
| 1896 Summer | Australia   | 2           | 0             | 1             |
| 1896 Summer | USA         | 11          | 7             | 2             |
| 1896 Summer | Austria     | 2           | 1             | 2             |

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
**Sample Output:**
| games       | max_gold_medals | max_silver_medals | max_bronze_medals |
|-------------|-----------------|-------------------|-------------------|
| 1896 Summer | Germany-25      | Greece-18         | Greece-20         |
| 1900 Summer | UK-59           | France-101        | France-82         |
| 1904 Summer | USA-128         | USA-141           | USA-125           |
| 1906 Summer | Greece-24       | Greece-48         | Greece-30         |
| 1908 Summer | UK-147          | UK-131            | UK-90             |
| 1912 Summer | Sweden-103      | UK-64             | UK-59             |
| 1920 Summer | USA-111         | France-71         | Belgium-66        |
| 1924 Summer | USA-97          | France-51         | USA-49            |
| 1924 Winter | UK-16           | USA-10            | UK-11             |
| 1928 Summer | USA-47          | Netherlands-29    | Germany-41        |

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
**Sample Output:**
| games       | max_gold_medals | max_silver_medals | max_bronze_medals | max_total_medals |
|-------------|-----------------|-------------------|-------------------|------------------|
| 1896 Summer | Germany-25      | Greece-18         | Greece-20         | Greece-48        |
| 1900 Summer | UK-59           | France-101        | France-82         | France-235       |
| 1904 Summer | USA-128         | USA-141           | USA-125           | USA-394          |
| 1906 Summer | Greece-24       | Greece-48         | Greece-30         | Greece-102       |
| 1908 Summer | UK-147          | UK-131            | UK-90             | UK-368           |
| 1912 Summer | Sweden-103      | UK-64             | UK-59             | Sweden-190       |
| 1920 Summer | USA-111         | France-71         | Belgium-66        | USA-194          |
| 1924 Summer | USA-97          | France-51         | USA-49            | USA-182          |
| 1924 Winter | UK-16           | USA-10            | UK-11             | UK-31            |
| 1928 Summer | USA-47          | Netherlands-29    | Germany-41        | USA-88           |
| 1928 Winter | Canada-12       | Sweden-13         | Switzerland-12    | Sweden-16        |
| 1932 Summer | USA-81          | USA-47            | USA-61            | USA-189          |
| 1932 Winter | Canada-14       | USA-21            | Germany-14        | USA-34           |
| 1936 Summer | Germany-93      | Germany-70        | Germany-61        | Germany-224      |
| 1936 Winter | UK-12           | Canada-13         | USA-14            | Norway-18        |

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
**Sample Output:**
| nations     | gold_medals | silver_medals | bronze_medals |
|-------------|-------------|---------------|---------------|
| Paraguay    | 0           | 17            | 0             |
| Iceland     | 0           | 15            | 2             |
| Montenegro  | 0           | 14            | 0             |
| Malaysia    | 0           | 11            | 5             |
| Namibia     | 0           | 4             | 0             |
| Moldova     | 0           | 3             | 5             |
| Philippines | 0           | 3             | 7             |
| Sri Lanka   | 0           | 2             | 0             |
| Tanzania    | 0           | 2             | 0             |
| Lebanon     | 0           | 2             | 2             |

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
**Sample Output:**
| sport  | total_medals |
|--------|--------------|
| Hockey | 173          |

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
**Sample Output:**
| country | sport  | games       | total_medals |
|---------|--------|-------------|--------------|
| India   | Hockey | 1948 Summer | 20           |
| India   | Hockey | 1936 Summer | 19           |
| India   | Hockey | 1956 Summer | 17           |
| India   | Hockey | 1968 Summer | 16           |
| India   | Hockey | 1980 Summer | 16           |
| India   | Hockey | 1964 Summer | 15           |
| India   | Hockey | 1932 Summer | 15           |
| India   | Hockey | 1928 Summer | 14           |
| India   | Hockey | 1952 Summer | 14           |
| India   | Hockey | 1972 Summer | 14           |
| India   | Hockey | 1960 Summer | 13           |

## Tool Used:
- Microsoft Excel 
- SQL 
- SQL Server RDBMS

