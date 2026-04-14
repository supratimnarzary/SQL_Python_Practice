-- Question 1 Histogram of Tweets
-- Assume you're given a table Twitter tweet data, write a query to obtain a histogram of tweets posted per user in 2022. Output the tweet count per user as the bucket and the number of Twitter users who fall into that bucket.

-- In other words, group the users by the number of tweets they posted in 2022 and count the number of users in each group.

-- tweets Table:
-- Column Name	Type
-- tweet_id	integer
-- user_id	integer
-- msg	string
-- tweet_date	timestamp
-- tweets Example Input:
-- tweet_id	user_id	msg	tweet_date
-- 214252	111	Am considering taking Tesla private at $420. Funding secured.	12/30/2021 00:00:00
-- 739252	111	Despite the constant negative press covfefe	01/01/2022 00:00:00
-- 846402	111	Following @NickSinghTech on Twitter changed my life!	02/14/2022 00:00:00
-- 241425	254	If the salary is so competitive why won’t you tell me what it is?	03/01/2022 00:00:00
-- 231574	148	I no longer have a manager. I can't be managed	03/23/2022 00:00:00
-- Example Output:
-- tweet_bucket	users_num
-- 1	2
-- 2	1
-- Explanation:
-- Based on the example output, there are two users who posted only one tweet in 2022, and one user who posted two tweets in 2022. The query groups the users by the number of tweets they posted and displays the number of users in each group.

-- Solution1:
with bucket as (SELECT count(tweet_id) as tweet_bucket, user_id
FROM tweets
where Year(tweet_date) = 2022
Group By user_id)

SELECT tweet_bucket, count(user_id) as users_num from bucket
group by tweet_bucket;

-- Solution2:
select b.tweet_bucket, count(b.user_id) as users_num 
  FROM(SELECT count(tweet_id) as tweet_bucket, user_id , tweet_date
  FROM tweets
  where Year(tweet_date) = 2022
  Group By user_id) b
GROUP by b.tweet_bucket;


-- Question 2 Candidates with Required Skills
-- Given a table of candidates and their skills, you're tasked with finding the candidates best suited for an open Data Science job. You want to find candidates who are proficient in Python, Tableau, and PostgreSQL.

-- Write a query to list the candidates who possess all of the required skills for the job. Sort the output by candidate ID in ascending order.

-- Assumption:

-- There are no duplicates in the candidates table.
-- candidates Table:
-- Column Name	Type
-- candidate_id	integer
-- skill	varchar
-- candidates Example Input:
-- candidate_id	skill
-- 123	Python
-- 123	Tableau
-- 123	PostgreSQL
-- 234	R
-- 234	PowerBI
-- 234	SQL Server
-- 345	Python
-- 345	Tableau
-- Example Output:
-- candidate_id
-- 123
-- Explanation
-- Candidate 123 is displayed because they have Python, Tableau, and PostgreSQL skills. 345 isn't included in the output because they're missing one of the required skills: PostgreSQL.

SELECT candidate_id FROM candidates
where skill in ("Python" , "Tableau", "PostgreSQL")
group by candidate_id
having count(skill) = 3;

-- Question 3 Page With No Likes

-- Assume you're given two tables containing data about Facebook Pages and their respective likes (as in "Like a Facebook Page").

-- Write a query to return the IDs of the Facebook pages that have zero likes. The output should be sorted in ascending order based on the page IDs.

-- pages Table:
-- Column Name	Type
-- page_id	integer
-- page_name	varchar
-- pages Example Input:
-- page_id	page_name
-- 20001	SQL Solutions
-- 20045	Brain Exercises
-- 20701	Tips for Data Analysts
-- page_likes Table:
-- Column Name	Type
-- user_id	integer
-- page_id	integer
-- liked_date	datetime
-- page_likes Example Input:
-- user_id	page_id	liked_date
-- 111	20001	04/08/2022 00:00:00
-- 121	20045	03/12/2022 00:00:00
-- 156	20001	07/25/2022 00:00:00
-- Example Output:
-- page_id
-- 20701

-- solution:

SELECT p.page_id from pages p
left join
(SELECT page_id, count(liked_date) as like_cnt FROM page_likes
group by page_id) a
on p.page_id = a.page_id
where like_cnt is NULL
order by p.page_id;


-- Q4 Unfinished Parts
-- Tesla is investigating production bottlenecks and they need your help to extract the relevant data. Write a query to determine which parts have begun the assembly process but are not yet finished.

-- Assumptions:

-- parts_assembly table contains all parts currently in production, each at varying stages of the assembly process.
-- An unfinished part is one that lacks a finish_date.
-- This question is straightforward, so let's approach it with simplicity in both thinking and solution.

-- Effective April 11th 2023, the problem statement and assumptions were updated to enhance clarity.

-- parts_assembly Table
-- Column Name	Type
-- part	string
-- finish_date	datetime
-- assembly_step	integer
-- parts_assembly Example Input
-- part	finish_date	assembly_step
-- battery	01/22/2022 00:00:00	1
-- battery	02/22/2022 00:00:00	2
-- battery	03/22/2022 00:00:00	3
-- bumper	01/22/2022 00:00:00	1
-- bumper	02/22/2022 00:00:00	2
-- bumper		3
-- bumper		4
-- Example Output
-- part	assembly_step
-- bumper	3
-- bumper	4

-- Solution:

SELECT part, assembly_step FROM parts_assembly
where finish_date is Null;

-- Q5 Laptop vs. Mobile Viewership

-- Assume you're given the table on user viewership categorised by device type where the three types are laptop, tablet, and phone.

-- Write a query that calculates the total viewership for laptops and mobile devices where mobile is defined as the sum of tablet and phone viewership. Output the total viewership for laptops as laptop_reviews and the total viewership for mobile devices as mobile_views.

-- Effective 15 April 2023, the solution has been updated with a more concise and easy-to-understand approach.

-- viewership Table
-- Column Name	Type
-- user_id	integer
-- device_type	string ('laptop', 'tablet', 'phone')
-- view_time	timestamp
-- viewership Example Input
-- user_id	device_type	view_time
-- 123	tablet	01/02/2022 00:00:00
-- 125	laptop	01/07/2022 00:00:00
-- 128	laptop	02/09/2022 00:00:00
-- 129	phone	02/09/2022 00:00:00
-- 145	tablet	02/24/2022 00:00:00
-- Example Output
-- laptop_views	mobile_views
-- 2	3

-- Solution:

SELECT count(device_type) as laptop_views,
(SELECT count(device_type) from viewership
where device_type in ("tablet", "phone")) as mobile_views
FROM viewership
WHERE device_type = "laptop";

-- Alternative Solution:

SELECT
sum(case WHEN device_type = "laptop" then 1 else 0 END) as laptop_views,
sum(case when device_type in ("tablet", "phone") then 1 else 0 END) as mobile_views
FROM viewership;

-- Q6 Average Post Hiatus (Part 1)

-- Given a table of Facebook posts, for each user who posted at least twice in 2021, write a query to find the number of days between each user’s first post of the year and last post of the year in the year 2021. Output the user and number of the days between each user's first and last post.

-- p.s. If you've read the Ace the Data Science Interview and liked it, consider writing us a review?

-- posts Table:
-- Column Name	Type
-- user_id	integer
-- post_id	integer
-- post_content	text
-- post_date	timestamp
-- posts Example Input:
-- user_id	post_id	post_content	post_date
-- 151652	599415	Need a hug	07/10/2021 12:00:00
-- 661093	624356	Bed. Class 8-12. Work 12-3. Gym 3-5 or 6. Then class 6-10. Another day that's gonna fly by. I miss my girlfriend	07/29/2021 13:00:00
-- 004239	784254	Happy 4th of July!	07/04/2021 11:00:00
-- 661093	442560	Just going to cry myself to sleep after watching Marley and Me.	07/08/2021 14:00:00
-- 151652	111766	I'm so done with covid - need travelling ASAP!	07/12/2021 19:00:00
-- Example Output:
-- user_id	days_between
-- 151652	2
-- 661093	21
-- The dataset you are querying against may have different input & output - this is just an example!

--Solution:
SELECT user_id, (Datediff(max(post_date), min(post_date))) as days_between from posts
where year(post_date) = 2021
group by user_id
HAVING count(user_id)>1

--Q7 User's Third Transaction

-- Assume you are given the table below on Uber transactions made by users. Write a query to obtain the third transaction of every user. Output the user id, spend and transaction date.

-- transactions Table:
-- Column Name	Type
-- user_id	integer
-- spend	decimal
-- transaction_date	timestamp
-- transactions Example Input:
-- user_id	spend	transaction_date
-- 111	100.50	01/08/2022 12:00:00
-- 111	55.00	01/10/2022 12:00:00
-- 121	36.00	01/18/2022 12:00:00
-- 145	24.99	01/26/2022 12:00:00
-- 111	89.60	02/05/2022 12:00:00
-- Example Output:
-- user_id	spend	transaction_date
-- 111	89.60	02/05/2022 12:00:00

-- Solution:

with cte as (SELECT user_id, spend, transaction_date, 
row_number()over(PARTITION by user_id order by transaction_date) as rnk FROM transactions)

SELECT user_id, spend, transaction_date from cte
where rnk =3;

-- Second Highest Salary

-- Imagine you're an HR analyst at a tech company tasked with analyzing employee salaries. Your manager is keen on understanding the pay distribution and asks you to determine the second highest salary among all employees.

-- It's possible that multiple employees may share the same second highest salary. In case of duplicate, display the salary only once.

-- employee Schema:
-- column_name	type	description
-- employee_id	integer	The unique ID of the employee.
-- name	string	The name of the employee.
-- salary	integer	The salary of the employee.
-- department_id	integer	The department ID of the employee.
-- manager_id	integer	The manager ID of the employee.
-- employee Example Input:
-- employee_id	name	salary	department_id	manager_id
-- 1	Emma Thompson	3800	1	6
-- 2	Daniel Rodriguez	2230	1	7
-- 3	Olivia Smith	2000	1	8
-- Example Output:
-- second_highest_salary
-- 2230
-- The output represents the second highest salary among all employees. In this case, the second highest salary is $2,230.

--Solution:

SELECT a.salary as second_highest_salary from (SELECT  department_id, salary, rank() over(order by salary DESC) as rnk
FROM employee
order by salary DESC) a
where rnk = 2;

-- Q8 Sending vs. Opening Snaps
-- Assume you're given tables with information on Snapchat users, including their ages and time spent sending and opening snaps.

-- Write a query to obtain a breakdown of the time spent sending vs. opening snaps as a percentage of total time spent on these activities grouped by age group. Round the percentage to 2 decimal places in the output.

-- Notes:

-- Calculate the following percentages:
-- time spent sending / (Time spent sending + Time spent opening)
-- Time spent opening / (Time spent sending + Time spent opening)
-- To avoid integer division in percentages, multiply by 100.0 and not 100.
-- Effective April 15th, 2023, the solution has been updated and optimised.

-- activities Table
-- Column Name	Type
-- activity_id	integer
-- user_id	integer
-- activity_type	string ('send', 'open', 'chat')
-- time_spent	float
-- activity_date	datetime
-- activities Example Input
-- activity_id	user_id	activity_type	time_spent	activity_date
-- 7274	123	open	4.50	06/22/2022 12:00:00
-- 2425	123	send	3.50	06/22/2022 12:00:00
-- 1413	456	send	5.67	06/23/2022 12:00:00
-- 1414	789	chat	11.00	06/25/2022 12:00:00
-- 2536	456	open	3.00	06/25/2022 12:00:00
-- age_breakdown Table
-- Column Name	Type
-- user_id	integer
-- age_bucket	string ('21-25', '26-30', '31-25')
-- age_breakdown Example Input
-- user_id	age_bucket
-- 123	31-35
-- 456	26-30
-- 789	21-25
-- Example Output
-- age_bucket	send_perc	open_perc
-- 26-30	65.40	34.60
-- 31-35	43.75	56.25
-- Explanation
-- Using the age bucket 26-30 as example, the time spent sending snaps was 5.67 and the time spent opening snaps was 3.

-- To calculate the percentage of time spent sending snaps, we divide the time spent sending snaps by the total time spent on sending and opening snaps, which is 5.67 + 3 = 8.67.

-- So, the percentage of time spent sending snaps is 5.67 / (5.67 + 3) = 65.4%, and the percentage of time spent opening snaps is 3 / (5.67 + 3) = 34.6%.

--Solution:

SELECT b.age_bucket,
round(sum(CASE WHEN a.activity_type = "send" THEN a.time_spent else 0 end)*100.0 /sum(time_spent),2)as send_perc,
round(sum(CASE WHEN a.activity_type = "open" THEN a.time_spent else 0 end)*100.0/sum(time_spent),2) as open_perc
FROM activities a
inner join age_breakdown b on
a.user_id=b.user_id
where a.activity_type in ("open","send")
group by b.age_bucket;

--Q9
-- Given a table of tweet data over a specified time period, calculate the 3-day rolling average of tweets for each user. Output the user ID, tweet date, and rolling averages rounded to 2 decimal places.

-- Notes:

-- A rolling average, also known as a moving average or running mean is a time-series technique that examines trends in data over a specified period of time.
-- In this case, we want to determine how the tweet count for each user changes over a 3-day period.
-- Effective April 7th, 2023, the problem statement, solution and hints for this question have been revised.

-- tweets Table:
-- Column Name	Type
-- user_id	integer
-- tweet_date	timestamp
-- tweet_count	integer
-- tweets Example Input:
-- user_id	tweet_date	tweet_count
-- 111	06/01/2022 00:00:00	2
-- 111	06/02/2022 00:00:00	1
-- 111	06/03/2022 00:00:00	3
-- 111	06/04/2022 00:00:00	4
-- 111	06/05/2022 00:00:00	5
-- Example Output:
-- user_id	tweet_date	rolling_avg_3d
-- 111	06/01/2022 00:00:00	2.00
-- 111	06/02/2022 00:00:00	1.50
-- 111	06/03/2022 00:00:00	2.00
-- 111	06/04/2022 00:00:00	2.67
-- 111	06/05/2022 00:00:00	4.00

--Solution:
SELECT user_id, tweet_date,
round(avg(tweet_count)
over(partition by user_id order by tweet_date 
ROWS between 2 PRECEDING and CURRENT ROW),2) as rolling_avg_3d
FROM tweets;

-- Q10: Teams Power Users
-- Write a query to identify the top 2 Power Users who sent the highest number of messages on Microsoft Teams in August 2022. Display the IDs of these 2 users along with the total number of messages they sent. Output the results in descending order based on the count of the messages.

-- Assumption:

-- No two users have sent the same number of messages in August 2022.
-- messages Table:
-- Column Name	Type
-- message_id	integer
-- sender_id	integer
-- receiver_id	integer
-- content	varchar
-- sent_date	datetime
-- messages Example Input:
-- message_id	sender_id	receiver_id	content	sent_date
-- 901	3601	4500	You up?	08/03/2022 00:00:00
-- 902	4500	3601	Only if you're buying	08/03/2022 00:00:00
-- 743	3601	8752	Let's take this offline	06/14/2022 00:00:00
-- 922	3601	4500	Get on the call	08/10/2022 00:00:00
-- Example Output:
-- sender_id	message_count
-- 3601	2
-- 4500	1

--Solution:
SELECT sender_id, count(message_id) as message_count FROM messages
where EXTRACT(year from sent_date) = 2022 and EXTRACT(month from sent_date) = 8
group by sender_id
order by message_count desc limit 2;

-- Q11
-- Assume you're given a table containing job postings from various companies on the LinkedIn platform. Write a query to retrieve the count of companies that have posted duplicate job listings.

-- Definition:

-- Duplicate job listings are defined as two job listings within the same company that share identical titles and descriptions.
-- job_listings Table:
-- Column Name	Type
-- job_id	integer
-- company_id	integer
-- title	string
-- description	string
-- job_listings Example Input:
-- job_id	company_id	title	description
-- 248	827	Business Analyst	Business analyst evaluates past and current business data with the primary goal of improving decision-making processes within organizations.
-- 149	845	Business Analyst	Business analyst evaluates past and current business data with the primary goal of improving decision-making processes within organizations.
-- 945	345	Data Analyst	Data analyst reviews data to identify key insights into a business's customers and ways the data can be used to solve problems.
-- 164	345	Data Analyst	Data analyst reviews data to identify key insights into a business's customers and ways the data can be used to solve problems.
-- 172	244	Data Engineer	Data engineer works in a variety of settings to build systems that collect, manage, and convert raw data into usable information for data scientists and business analysts to interpret.
-- Example Output:
-- duplicate_companies
-- 1
-- Explanation:
-- There is one company ID 345 that posted duplicate job listings. The duplicate listings, IDs 945 and 164 have identical titles and descriptions.

-- Solution:

select count(a.company_id) as duplicate_companies from
(SELECT company_id, count(title) as cnt, description FROM job_listings
group by company_id, title
having cnt >1)a;
