# case-studies Olympic Games 1896-2016
https://techtfq.com/blog/practice-writing-sql-queries-using-real-dataset

**How many olympics games have been held?**

![image](https://user-images.githubusercontent.com/92555446/187253333-980354c9-ef31-4d83-bc80-6269372bb80f.png)

**List down all Olympics games held so far.**
![image](https://user-images.githubusercontent.com/92555446/187254051-bd90dc97-96b1-4ad1-bca6-b8002c39cb29.png)

**Mention the total no of nations who participated in each olympics game?**
![image](https://user-images.githubusercontent.com/92555446/187254174-157b1a49-09bb-4d88-99b5-7556ab31f0f7.png)

**Which year saw the highest and lowest no of countries participating in olympics?**
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
![image](https://user-images.githubusercontent.com/92555446/187254320-898f996f-ccac-4fc9-8021-2cb058d3a406.png)

**Which nation has participated in all of the olympic games?**
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
![image](https://user-images.githubusercontent.com/92555446/187254466-1f3d1d7c-ffc2-4808-8ecb-27f7d0eb41aa.png)

**Identify the sport which was played in all summer olympics.**
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
![image](https://user-images.githubusercontent.com/92555446/187254812-48e38ae0-1986-4bf3-94de-3d5a6e5f12a9.png)


Which Sports were just played only once in the olympics?

Fetch the total no of sports played in each olympic games.

Fetch details of the oldest athletes to win a gold medal.

Find the Ratio of male and female athletes participated in all olympic games.

Fetch the top 5 athletes who have won the most gold medals.

Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won.

List down total gold, silver and broze medals won by each country.

List down total gold, silver and broze medals won by each country corresponding to each olympic games.

Identify which country won the most gold, most silver and most bronze medals in each olympic games.

Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

Which countries have never won gold medal but have won silver/bronze medals?

In which Sport/event, India has won highest medals.

Break down all olympic games where india won medal for Hockey and how many medals in each olympic games.
