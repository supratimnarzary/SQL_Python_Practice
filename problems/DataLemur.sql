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

-- Q12
-- Assume you're given the tables containing completed trade orders and user details in a Robinhood trading system.

-- Write a query to retrieve the top three cities that have the highest number of completed trade orders listed in descending order. Output the city name and the corresponding number of completed trade orders.
-- trades Table:
-- Column Name	Type
-- order_id	integer
-- user_id	integer
-- quantity	integer
-- status	string ('Completed', 'Cancelled')
-- date	timestamp
-- price	decimal (5, 2)
-- trades Example Input:
-- order_id	user_id	quantity	status	date	price
-- 100101	111	10	Cancelled	08/17/2022 12:00:00	9.80
-- 100102	111	10	Completed	08/17/2022 12:00:00	10.00
-- 100259	148	35	Completed	08/25/2022 12:00:00	5.10
-- 100264	148	40	Completed	08/26/2022 12:00:00	4.80
-- 100305	300	15	Completed	09/05/2022 12:00:00	10.00
-- 100400	178	32	Completed	09/17/2022 12:00:00	12.00
-- 100565	265	2	Completed	09/27/2022 12:00:00	8.70
-- users Table:
-- Column Name	Type
-- user_id	integer
-- city	string
-- email	string
-- signup_date	datetime
-- users Example Input:
-- user_id	city	email	signup_date
-- 111	San Francisco	rrok10@gmail.com	08/03/2021 12:00:00
-- 148	Boston	sailor9820@gmail.com	08/20/2021 12:00:00
-- 178	San Francisco	harrypotterfan182@gmail.com	01/05/2022 12:00:00
-- 265	Denver	shadower_@hotmail.com	02/26/2022 12:00:00
-- 300	San Francisco	houstoncowboy1122@hotmail.com	06/30/2022 12:00:00
-- Example Output:
-- city	total_orders
-- San Francisco	3
-- Boston	2
-- Denver	1

-- In the given dataset, San Francisco has the highest number of completed trade orders with 3 orders. Boston holds the second position with 2 orders, and Denver ranks third with 1 order.

-- Solution:

with cte as (Select user_id, count(order_id) as total_orders from trades
where status = 'Completed'
group by user_id)

SELECT u.city, sum(cte.total_orders) as total_orders FROM users u 
inner join cte
on u.user_id = cte.user_id
group by u.city
order by total_orders Desc limit 3

-- Question 13

-- Given the reviews table, write a query to retrieve the average star rating for each product, grouped by month. The output should display the month as a numerical value, product ID, and average star rating rounded to two decimal places. Sort the output first by month and then by product ID.

-- P.S. If you've read the Ace the Data Science Interview, and liked it, consider writing us a review?
-- reviews Table:
-- Column Name	Type
-- review_id	integer
-- user_id	integer
-- submit_date	datetime
-- product_id	integer
-- stars	integer (1-5)
-- reviews Example Input:
-- review_id	user_id	submit_date	product_id	stars
-- 6171	123	06/08/2022 00:00:00	50001	4
-- 7802	265	06/10/2022 00:00:00	69852	4
-- 5293	362	06/18/2022 00:00:00	50001	3
-- 6352	192	07/26/2022 00:00:00	69852	3
-- 4517	981	07/05/2022 00:00:00	69852	2
-- Example Output:
-- mth	product	avg_stars
-- 6	50001	3.50
-- 6	69852	4.00
-- 7	69852	2.50
-- Explanation

-- Product 50001 received two ratings of 4 and 3 in the month of June (6th month), resulting in an average star rating of 3.5.

-- Solution:

SELECT EXTRACT(Month from submit_date) as mth, product_id, round(avg(stars),2) as avg_stars FROM reviews
group by mth, product_id
order by mth, product_id;

-- Question 14

-- Companies often perform salary analyses to ensure fair compensation practices. One useful analysis is to check if there are any employees earning more than their direct managers.

-- As a HR Analyst, you're asked to identify all employees who earn more than their direct managers. The result should include the employee's ID and name.
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
-- 3	Olivia Smith	7000	1	8
-- 4	Noah Johnson	6800	2	9
-- 5	Sophia Martinez	1750	1	11
-- 6	Liam Brown	13000	3	NULL
-- 7	Ava Garcia	12500	3	NULL
-- 8	William Davis	6800	2	NULL
-- Example Output:
-- employee_id	employee_name
-- 3	Olivia Smith

-- The output shows that Olivia Smith earns $7,000, surpassing her manager, William David who earns $6,800.

-- Solution:
with manager as (SELECT employee_id, name, salary FROM employee
where manager_id ISNULL)

select e.employee_id, e.name from employee e
inner join manager m
on e.manager_id = m.employee_id
where e.salary > m.salary

-- Question 15
-- Given a table containing information about bank deposits and withdrawals made using Paypal, write a query to retrieve the final account balance for each account, taking into account all the transactions recorded in the table with the assumption that there are no missing transactions.
-- transactions Table:
-- Column Name	Type
-- transaction_id	integer
-- account_id	integer
-- amount	decimal
-- transaction_type	varchar
-- transactions Example Input:
-- transaction_id	account_id	amount	transaction_type
-- 123	101	10.00	Deposit
-- 124	101	20.00	Deposit
-- 125	101	5.00	Withdrawal
-- 126	201	20.00	Deposit
-- 128	201	10.00	Withdrawal
-- Example Output:
-- account_id	final_balance
-- 101	25.00
-- 201	10.00

-- Using account ID 101 as an example, $30.00 was deposited into this account, while $5.00 was withdrawn. Therefore, the final account balance can be calculated as the difference between the total deposits and withdrawals which is $30.00 - $5.00, resulting in a final balance of $25.00.

-- Solution:

SELECT account_id,
sum(Case when transaction_type = 'Withdrawal' then (amount)*(-1) else amount END) as final_balance FROM transactions
group by account_id

-- Question 16

-- Assume you have an events table on Facebook app analytics. Write a query to calculate the click-through rate (CTR) for the app in 2022 and round the results to 2 decimal places.

-- Definition and note:

--     Percentage of click-through rate (CTR) = 100.0 * Number of clicks / Number of impressions
--     To avoid integer division, multiply the CTR by 100.0, not 100.

-- events Table:
-- Column Name	Type
-- app_id	integer
-- event_type	string
-- timestamp	datetime
-- events Example Input:
-- app_id	event_type	timestamp
-- 123	impression	07/18/2022 11:36:12
-- 123	impression	07/18/2022 11:37:12
-- 123	click	07/18/2022 11:37:42
-- 234	impression	07/18/2022 14:15:12
-- 234	click	07/18/2022 14:16:12
-- Example Output:
-- app_id	ctr
-- 123	50.00
-- 234	100.00
-- Explanation

-- Let's consider an example of App 123. This app has a click-through rate (CTR) of 50.00% because out of the 2 impressions it received, it got 1 click.

-- To calculate the CTR, we divide the number of clicks by the number of impressions, and then multiply the result by 100.0 to express it as a percentage. In this case, 1 divided by 2 equals 0.5, and when multiplied by 100.0, it becomes 50.00%. So, the CTR of App 123 is 50.00%.

-- Solution:

SELECT
app_id,
round(sum(case when event_type = 'click' then 1 else 0 end)*100.0/
sum(case when event_type ='impression' then 1 else 0 end),2) as ctr
FROM events
where EXTRACT(year from timestamp) =2022
group by app_id;

-- Question 17

-- Assume you're given tables with information about TikTok user sign-ups and confirmations through email and text. New users on TikTok sign up using their email addresses, and upon sign-up, each user receives a text message confirmation to activate their account.

-- Write a query to display the user IDs of those who did not confirm their sign-up on the first day, but confirmed on the second day.

-- Definition:

--     action_date refers to the date when users activated their accounts and confirmed their sign-up through text messages.

-- emails Table:
-- Column Name	Type
-- email_id	integer
-- user_id	integer
-- signup_date	datetime
-- emails Example Input:
-- email_id	user_id	signup_date
-- 125	7771	06/14/2022 00:00:00
-- 433	1052	07/09/2022 00:00:00
-- texts Table:
-- Column Name	Type
-- text_id	integer
-- email_id	integer
-- signup_action	string ('Confirmed', 'Not confirmed')
-- action_date	datetime
-- texts Example Input:
-- text_id	email_id	signup_action	action_date
-- 6878	125	Confirmed	06/14/2022 00:00:00
-- 6997	433	Not Confirmed	07/09/2022 00:00:00
-- 7000	433	Confirmed	07/10/2022 00:00:00
-- Example Output:
-- user_id
-- 1052
-- Explanation:

-- Only User 1052 confirmed their sign-up on the second day.

-- Solution:

select s.user_id from
(SELECT e.email_id, e.user_id, e.signup_date, t.action_date, t.signup_action
FROM emails e inner join texts t
on e.email_id = t.email_id) s
where s.signup_action = 'Confirmed'
and EXTRACT(Day from s.signup_date)+1 = EXTRACT(day from s.action_date)
group by s.user_id;

-- Q18

-- IBM is analyzing how their employees are utilizing the Db2 database by tracking the SQL queries executed by their employees. The objective is to generate data to populate a histogram that shows the number of unique queries run by employees during the third quarter of 2023 (July to September). Additionally, it should count the number of employees who did not run any queries during this period.

-- Display the number of unique queries as histogram categories, along with the count of employees who executed that number of unique queries.
-- queries Schema:
-- Column Name	Type	Description
-- employee_id	integer	The ID of the employee who executed the query.
-- query_id	integer	The unique identifier for each query (Primary Key).
-- query_starttime	datetime	The timestamp when the query started.
-- execution_time	integer	The duration of the query execution in seconds.
-- queries Example Input:

-- Assume that the table below displays all queries made from July 1, 2023 to 31 July, 2023:
-- employee_id	query_id	query_starttime	execution_time
-- 226	856987	07/01/2023 01:04:43	2698
-- 132	286115	07/01/2023 03:25:12	2705
-- 221	33683	07/01/2023 04:34:38	91
-- 240	17745	07/01/2023 14:33:47	2093
-- 110	413477	07/02/2023 10:55:14	470
-- employees Schema:

-- Assume that the table below displays all employees in the table:
-- Column Name	Type	Description
-- employee_id	integer	The ID of the employee who executed the query.
-- full_name	string	The full name of the employee.
-- gender	string	The gender of the employee.
-- employees Example Input:
-- employee_id	full_name	gender
-- 1	Judas Beardon	Male
-- 2	Lainey Franciotti	Female
-- 3	Ashbey Strahan	Male
-- Example Output:
-- unique_queries	employee_count
-- 0	191
-- 1	46
-- 2	12
-- 3	1

-- The output indicates that 191 employees did not run any queries, 46 employees ran exactly 1 unique queries, 12 employees ran 2 unique queries, and so on.

-- Solution:
select 
c.unique_queries, count(c.employee_id) as employee_count
from 
    (select e.employee_id, count(DISTINCT q.query_id) as unique_queries from employees e LEFT JOIN queries q
    on e.employee_id = q.employee_id
    and q.query_starttime >= '2023-07-01'
    and q.query_starttime < '2023-10-01'
    group by e.employee_id) as c
group by unique_queries
order by unique_queries;

-- Q19
Your team at JPMorgan Chase is preparing to launch a new credit card, and to gain some insights, you're analyzing how many credit cards were issued each month.

-- Write a query that outputs the name of each credit card and the difference in the number of issued cards between the month with the highest issuance cards and the lowest issuance. Arrange the results based on the largest disparity.
-- monthly_cards_issued Table:
-- Column Name	Type
-- card_name	string
-- issued_amount	integer
-- issue_month	integer
-- issue_year	integer
-- monthly_cards_issued Example Input:
-- card_name	issued_amount	issue_month	issue_year
-- Chase Freedom Flex	55000	1	2021
-- Chase Freedom Flex	60000	2	2021
-- Chase Freedom Flex	65000	3	2021
-- Chase Freedom Flex	70000	4	2021
-- Chase Sapphire Reserve	170000	1	2021
-- Chase Sapphire Reserve	175000	2	2021
-- Chase Sapphire Reserve	180000	3	2021
-- Example Output:
-- card_name	difference
-- Chase Freedom Flex	15000
-- Chase Sapphire Reserve	10000

-- Chase Freedom Flex's best month was 70k cards issued and the worst month was 55k cards, so the difference is 15k cards.

-- Chase Sapphire Reserve’s best month was 180k cards issued and the worst month was 170k cards, so the difference is 10k cards.

-- Solution:
SELECT card_name, (max(issued_amount) - min(issued_amount)) as difference
FROM monthly_cards_issued
group by card_name
order by difference desc;

--Q20

-- You're trying to find the mean number of items per order on Alibaba, rounded to 1 decimal place using tables which includes information on the count of items in each order (item_count table) and the corresponding number of orders for each item count (order_occurrences table).
-- items_per_order Table:
-- Column Name	Type
-- item_count	integer
-- order_occurrences	integer
-- items_per_order Example Input:
-- item_count	order_occurrences
-- 1	500
-- 2	1000
-- 3	800
-- 4	1000

-- There are a total of 500 orders with one item per order, 1000 orders with two items per order, and 800 orders with three items per order."
-- Example Output:
-- mean
-- 2.7
-- Explanation

-- Let's calculate the arithmetic average:

-- Total items = (1*500) + (2*1000) + (3*800) + (4*1000) = 8900

-- Total orders = 500 + 1000 + 800 + 1000 = 3300

-- Mean = 8900 / 3300 = 2.7

-- Solution:
with cte as
  (SELECT item_count, (item_count * order_occurrences) as total_orders, order_occurrences
   from items_per_order
   group by item_count, order_occurrences)

SELECT round(cast(sum(total_orders)/sum(order_occurrences) as NUMERIC),1) as mean
FROM cte;

-- Q21
-- CVS Health is trying to better understand its pharmacy sales, and how well different products are selling. Each drug can only be produced by one manufacturer.

-- Write a query to find the top 3 most profitable drugs sold, and how much profit they made. Assume that there are no ties in the profits. Display the result from the highest to the lowest total profit.

-- Definition:

--     cogs stands for Cost of Goods Sold which is the direct cost associated with producing the drug.
--     Total Profit = Total Sales - Cost of Goods Sold

-- If you like this question, try out Pharmacy Analytics (Part 2)!
-- pharmacy_sales Table:
-- Column Name	Type
-- product_id	integer
-- units_sold	integer
-- total_sales	decimal
-- cogs	decimal
-- manufacturer	varchar
-- drug	varchar
-- pharmacy_sales Example Input:
-- product_id	units_sold	total_sales	cogs	manufacturer	drug
-- 9	37410	293452.54	208876.01	Eli Lilly	Zyprexa
-- 34	94698	600997.19	521182.16	AstraZeneca	Surmontil
-- 61	77023	500101.61	419174.97	Biogen	Varicose Relief
-- 136	144814	1084258	1006447.73	Biogen	Burkhart
-- Example Output:
-- drug	total_profit
-- Zyprexa	84576.53
-- Varicose Relief	80926.64
-- Surmontil	79815.03
-- Explanation:

-- Zyprexa made the most profit (of $84,576.53) followed by Varicose Relief (of $80,926.64) and Surmontil (of $79,815.3).

-- Solution:
SELECT drug, sum(total_sales-cogs) as total_profit
FROM pharmacy_sales
group by drug
order by total_profit desc limit 3;

--Q22
-- CVS Health is analyzing its pharmacy sales data, and how well different products are selling in the market. Each drug is exclusively manufactured by a single manufacturer.

-- Write a query to identify the manufacturers associated with the drugs that resulted in losses for CVS Health and calculate the total amount of losses incurred.

-- Output the manufacturer's name, the number of drugs associated with losses, and the total losses in absolute value. Display the results sorted in descending order with the highest losses displayed at the top.

-- If you like this question, try out Pharmacy Analytics (Part 3)!
-- pharmacy_sales Table:
-- Column Name	Type
-- product_id	integer
-- units_sold	integer
-- total_sales	decimal
-- cogs	decimal
-- manufacturer	varchar
-- drug	varchar
-- pharmacy_sales Example Input:
-- product_id	units_sold	total_sales	cogs	manufacturer	drug
-- 156	89514	3130097.00	3427421.73	Biogen	Acyclovir
-- 25	222331	2753546.00	2974975.36	AbbVie	Lamivudine and Zidovudine
-- 50	90484	2521023.73	2742445.90	Eli Lilly	Dermasorb TA Complete Kit
-- 98	110746	813188.82	140422.87	Biogen	Medi-Chord
-- Example Output:
-- manufacturer	drug_count	total_loss
-- Biogen	1	297324.73
-- AbbVie	1	221429.36
-- Eli Lilly	1	221422.17
-- Explanation:

-- The first three rows indicate that some drugs resulted in losses. Among these, Biogen had the highest losses, followed by AbbVie and Eli Lilly. However, the Medi-Chord drug manufactured by Biogen reported a profit and was excluded from the result.

-- Solution:
select p.manufacturer, sum(p.drug_count), sum(p.total_loss) as total_loss
  FROM 
  (SELECT manufacturer, count(drug) as drug_count, sum(total_sales - cogs)*-1 as total_loss
  from pharmacy_sales
  GROUP BY manufacturer, drug
  order by total_loss ASC) p
where total_loss >0
group by manufacturer
order by total_loss DESC;

-- Q23
-- CVS Health wants to gain a clearer understanding of its pharmacy sales and the performance of various products.

-- Write a query to calculate the total drug sales for each manufacturer. Round the answer to the nearest million and report your results in descending order of total sales. In case of any duplicates, sort them alphabetically by the manufacturer name.

-- Since this data will be displayed on a dashboard viewed by business stakeholders, please format your results as follows: "$36 million".

-- If you like this question, try out Pharmacy Analytics (Part 4)!
-- pharmacy_sales Table:
-- Column Name	Type
-- product_id	integer
-- units_sold	integer
-- total_sales	decimal
-- cogs	decimal
-- manufacturer	varchar
-- drug	varchar
-- pharmacy_sales Example Input:
-- product_id	units_sold	total_sales	cogs	manufacturer	drug
-- 94	132362	2041758.41	1373721.70	Biogen	UP and UP
-- 9	37410	293452.54	208876.01	Eli Lilly	Zyprexa
-- 50	90484	2521023.73	2742445.9	Eli Lilly	Dermasorb
-- 61	77023	500101.61	419174.97	Biogen	Varicose Relief
-- 136	144814	1084258.00	1006447.73	Biogen	Burkhart
-- Example Output:
-- manufacturer	sale
-- Biogen	$4 million
-- Eli Lilly	$3 million
-- Explanation

-- The total sales for Biogen is $4 million ($2,041,758.41 + $500,101.61 + $1,084,258.00 = $3,626,118.02) and for Eli Lilly is $3 million ($293,452.54 + $2,521,023.73 = $2,814,476.27).

--Solution:

SELECT manufacturer, Concat('$',round(sum(total_sales)/1000000), ' million') as sale FROM pharmacy_sales
group by manufacturer
order by sum(total_sales) DESC, manufacturer;