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

-- Q24
-- UnitedHealth Group (UHG) has a program called Advocate4Me, which allows policy holders (or, members) to call an advocate and receive support for their health care needs – whether that's claims and benefits support, drug coverage, pre- and post-authorisation, medical records, emergency assistance, or member portal services.

-- Write a query to find how many UHG policy holders made three, or more calls, assuming each call is identified by the case_id column.

-- If you like this question, try out Patient Support Analysis (Part 2)!
-- callers Table:
-- Column Name	Type
-- policy_holder_id	integer
-- case_id	varchar
-- call_category	varchar
-- call_date	timestamp
-- call_duration_secs	integer
-- callers Example Input:
-- policy_holder_id	case_id	call_category	call_date	call_duration_secs
-- 1	f1d012f9-9d02-4966-a968-bf6c5bc9a9fe	emergency assistance	2023-04-13T19:16:53Z	144
-- 1	41ce8fb6-1ddd-4f50-ac31-07bfcce6aaab	authorisation	2023-05-25T09:09:30Z	815
-- 2	9b1af84b-eedb-4c21-9730-6f099cc2cc5e	claims assistance	2023-01-26T01:21:27Z	992
-- 2	8471a3d4-6fc7-4bb2-9fc7-4583e3638a9e	emergency assistance	2023-03-09T10:58:54Z	128
-- 2	38208fae-bad0-49bf-99aa-7842ba2e37bc	benefits	2023-06-05T07:35:43Z	619
-- Example Output:
-- policy_holder_count
-- 1
-- Explanation:

-- The only caller who made three, or more calls is policy holder ID 2.

-- Solution:

with cte as (SELECT policy_holder_id, count(case_id) as count_case FROM callers
group by policy_holder_id
HAVING count(case_id) >=3)

select count(policy_holder_id) as policy_holder_count from cte

-- Q25
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

-- The dataset you are querying against may have different input & output - this is just an example!

-- Solution:

with cte as (SELECT user_id, spend, transaction_date,
row_number() over (PARTITION BY user_id order by transaction_date) as rnk
FROM transactions)

SELECT user_id, spend, transaction_date
from cte
where rnk = 3

-- Q26

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

-- Solution:

select min(salary) as second_highest_salary from 
(SELECT salary from employee
order by salary desc limit 2) salary_table

-- Q27

-- This is the same question as problem #25 in the SQL Chapter of Ace the Data Science Interview!

-- Assume you're given tables with information on Snapchat users, including their ages and time spent sending and opening snaps.

-- Write a query to obtain a breakdown of the time spent sending vs. opening snaps as a percentage of total time spent on these activities grouped by age group. Round the percentage to 2 decimal places in the output.

-- Notes:

--     Calculate the following percentages:
--         time spent sending / (Time spent sending + Time spent opening)
--         Time spent opening / (Time spent sending + Time spent opening)
--     To avoid integer division in percentages, multiply by 100.0 and not 100.

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

-- Solution:

with cte as (SELECT
  user_id,
  round(sum(case when activity_type = 'send' then time_spent ELSE 0 END)*100.0/
  sum(case when activity_type != 'chat' then time_spent else 0 end),2) as send_perc,
  round(sum(case when activity_type = 'open' then time_spent ELSE 0 END)*100.0/
  sum(case when activity_type <> 'chat' then time_spent else 0 end),2) as open_perc
from activities
group by user_id)

SELECT a.age_bucket, c.send_perc, c.open_perc
from age_breakdown a
inner join cte c
on a.user_id = c.user_id
order by a.age_bucket

-- Q28

-- Assume there are three Spotify tables: artists, songs, and global_song_rank, which contain information about the artists, songs, and music charts, respectively.

-- Write a query to find the top 5 artists whose songs appear most frequently in the Top 10 of the global_song_rank table. Display the top 5 artist names in ascending order, along with their song appearance ranking.

-- If two or more artists have the same number of song appearances, they should be assigned the same ranking, and the rank numbers should be continuous (i.e. 1, 2, 2, 3, 4, 5). If you've never seen a rank order like this before, do the rank window function tutorial.
-- artists Table:
-- Column Name	Type
-- artist_id	integer
-- artist_name	varchar
-- label_owner	varchar
-- artists Example Input:
-- artist_id	artist_name	label_owner
-- 101	Ed Sheeran	Warner Music Group
-- 120	Drake	Warner Music Group
-- 125	Bad Bunny	Rimas Entertainment
-- songs Table:
-- Column Name	Type
-- song_id	integer
-- artist_id	integer
-- name	varchar
-- songs Example Input:
-- song_id	artist_id	name
-- 55511	101	Perfect
-- 45202	101	Shape of You
-- 22222	120	One Dance
-- 19960	120	Hotline Bling
-- global_song_rank Table:
-- Column Name	Type
-- day	integer (1-52)
-- song_id	integer
-- rank	integer (1-1,000,000)
-- global_song_rank Example Input:
-- day	song_id	rank
-- 1	45202	5
-- 3	45202	2
-- 1	19960	3
-- 9	19960	15
-- Example Output:
-- artist_name	artist_rank
-- Ed Sheeran	1
-- Drake	2
-- Explanation:

-- Ed Sheeran's song appeared twice in the Top 10 list of global song rank while Drake's song is only listed once. Therefore, Ed is ranked #1 and Drake is ranked #2.

-- Solution:

with cte as

(select a.artist_name, count(a.artist_name) as frequency from artists a
inner JOIN songs s
on a. artist_id = s.artist_id
INNER JOIN global_song_rank g
on s.song_id = g.song_id
where g.rank <=10
group by a.artist_name
order by frequency DESC)

SELECT f.artist_name, f.artist_rank from 
(SELECT artist_name,
dense_rank() over (order by frequency DESC) as artist_rank
FROM cte) f
where f.artist_rank <6

-- Q29:
-- Assume you're given a table on Walmart user transactions. Based on their most recent transaction date, write a query that retrieve the users along with the number of products they bought.

-- Output the user's most recent transaction date, user ID, and the number of products, sorted in chronological order by the transaction date.
-- user_transactions Table:
-- Column Name	Type
-- product_id	integer
-- user_id	integer
-- spend	decimal
-- transaction_date	timestamp
-- user_transactions Example Input:
-- product_id	user_id	spend	transaction_date
-- 3673	123	68.90	07/08/2022 12:00:00
-- 9623	123	274.10	07/08/2022 12:00:00
-- 1467	115	19.90	07/08/2022 12:00:00
-- 2513	159	25.00	07/08/2022 12:00:00
-- 1452	159	74.50	07/10/2022 12:00:00
-- Example Output:
-- transaction_date	user_id	purchase_count
-- 07/08/2022 12:00:00	115	1
-- 07/08/2022 12:00:000	123	2
-- 07/10/2022 12:00:00	159	1

-- Solution:
with cte as
(SELECT transaction_date, user_id, count(product_id) as purchase_count,
dense_rank() over(partition by user_id order by transaction_date desc) as rnk
FROM user_transactions
group by transaction_date, user_id)

select transaction_date, user_id, purchase_count
from cte
where rnk =1
order by transaction_date;

-- Q30

-- This is the same question as problem #28 in the SQL Chapter of Ace the Data Science Interview!

-- Assume you're given a table with measurement values obtained from a Google sensor over multiple days with measurements taken multiple times within each day.

-- Write a query to calculate the sum of odd-numbered and even-numbered measurements separately for a particular day and display the results in two different columns. Refer to the Example Output below for the desired format.

-- Definition:

--     Within a day, measurements taken at 1st, 3rd, and 5th times are considered odd-numbered measurements, and measurements taken at 2nd, 4th, and 6th times are considered even-numbered measurements.

-- Effective April 15th, 2023, the question and solution for this question have been revised.
-- measurements Table:
-- Column Name	Type
-- measurement_id	integer
-- measurement_value	decimal
-- measurement_time	datetime
-- measurements Example Input:
-- measurement_id	measurement_value	measurement_time
-- 131233	1109.51	07/10/2022 09:00:00
-- 135211	1662.74	07/10/2022 11:00:00
-- 523542	1246.24	07/10/2022 13:15:00
-- 143562	1124.50	07/11/2022 15:00:00
-- 346462	1234.14	07/11/2022 16:45:00
-- Example Output:
-- measurement_day	odd_sum	even_sum
-- 07/10/2022 00:00:00	2355.75	1662.74
-- 07/11/2022 00:00:00	1124.50	1234.14
-- Explanation

-- Based on the results,

--     On 07/10/2022, the sum of the odd-numbered measurements is 2355.75, while the sum of the even-numbered measurements is 1662.74.
--     On 07/11/2022, there are only two measurements available. The sum of the odd-numbered measurements is 1124.50, and the sum of the even-numbered measurements is 1234.14.

-- Solution:
with rank_table as
(SELECT CAST(measurement_time as date) as measurement_day, measurement_value,
row_number() over(PARTITION by extract(day from measurement_time) order by measurement_time asc) as rnk
FROM measurements)

select
measurement_day,
sum(case when rnk%2 != 0 then measurement_value else 0 end) as odd_sum,
sum(case when rnk%2 = 0 then measurement_value else 0 end) as even_sum
from rank_table
group by measurement_day
order by measurement_day;

-- Q31:
-- This is the same question as problem #32 in the SQL Chapter of Ace the Data Science Interview!

-- Assume you're given a table containing information about Wayfair user transactions for different products. Write a query to calculate the year-on-year growth rate for the total spend of each product, grouping the results by product ID.

-- The output should include the year in ascending order, product ID, current year's spend, previous year's spend and year-on-year growth percentage, rounded to 2 decimal places.
-- user_transactions Table:
-- Column Name	Type
-- transaction_id	integer
-- product_id	integer
-- spend	decimal
-- transaction_date	datetime
-- user_transactions Example Input:
-- transaction_id	product_id	spend	transaction_date
-- 1341	123424	1500.60	12/31/2019 12:00:00
-- 1423	123424	1000.20	12/31/2020 12:00:00
-- 1623	123424	1246.44	12/31/2021 12:00:00
-- 1322	123424	2145.32	12/31/2022 12:00:00
-- Example Output:
-- year	product_id	curr_year_spend	prev_year_spend	yoy_rate
-- 2019	123424	1500.60	NULL	NULL
-- 2020	123424	1000.20	1500.60	-33.35
-- 2021	123424	1246.44	1000.20	24.62
-- 2022	123424	2145.32	1246.44	72.12
-- Explanation:

-- Product ID 123424 is analyzed for multiple years: 2019, 2020, 2021, and 2022.

--     In the year 2020, the current year's spend is 1000.20, and there is no previous year's spend recorded (indicated by an empty cell).
--     In the year 2021, the current year's spend is 1246.44, and the previous year's spend is 1000.20.
--     In the year 2022, the current year's spend is 2145.32, and the previous year's spend is 1246.44.

-- To calculate the year-on-year growth rate, we compare the current year's spend with the previous year's spend.For instance, the spend grew by 24.62% from 2020 to 2021, indicating a positive growth rate.

SELECT
EXTRACT (Year FROM transaction_date) as year,
  product_id, spend as curr_year_spend,
  lag(spend) over(partition by product_id
  order by transaction_date) as prev_year_spend,
  round((spend - lag(spend) over(partition by product_id
  order by transaction_date))*100.0/
  lag(spend) over(partition by product_id
  order by transaction_date),2) as yoy_rate
FROM user_transactions
group by transaction_date, product_id,spend;

-- Q32:

-- Amazon wants to maximize the storage capacity of its 500,000 square-foot warehouse by prioritizing a specific batch of prime items. The specific prime product batch detailed in the inventory table must be maintained.

-- So, if the prime product batch specified in the item_category column included 1 laptop and 1 side table, that would be the base batch. We could not add another laptop without also adding a side table; they come all together as a batch set.

-- After prioritizing the maximum number of prime batches, any remaining square footage will be utilized to stock non-prime batches, which also come in batch sets and cannot be separated into individual items.

-- Write a query to find the maximum number of prime and non-prime batches that can be stored in the 500,000 square feet warehouse based on the following criteria:

--     Prioritize stocking prime batches
--     After accommodating prime items, allocate any remaining space to non-prime batches

-- Output the item_type with prime_eligible first followed by not_prime, along with the maximum number of batches that can be stocked.

-- Assumptions:

--     Again, products must be stocked in batches, so we want to find the largest available quantity of prime batches, and then the largest available quantity of non-prime batches
--     Non-prime items must always be available in stock to meet customer demand, so the non-prime item count should never be zero.
--     Item count should be whole numbers (integers).

-- inventory table:
-- Column Name	Type
-- item_id	integer
-- item_type	string
-- item_category	string
-- square_footage	decimal
-- inventory Example Input:
-- item_id	item_type	item_category	square_footage
-- 1374	prime_eligible	mini refrigerator	68.00
-- 4245	not_prime	standing lamp	26.40
-- 2452	prime_eligible	television	85.00
-- 3255	not_prime	side table	22.60
-- 1672	prime_eligible	laptop	8.50
-- Example Output:
-- item_type	item_count
-- prime_eligible	9285
-- not_prime	6

-- The dataset you are querying against may have different input & output - this is just an example!

Solution:
with cte as (
select
  item_type,
  sum(square_footage) as total_footage,
  count(square_footage) as prime_item_cnt
from inventory
group by item_type
)

SELECT
  item_type,
  floor(500000/(SELECT total_footage from cte where item_type ='prime_eligible'))*
  (SELECT prime_item_cnt from cte where item_type = 'prime_eligible') as item_count
from inventory
where item_type = 'prime_eligible'
group by item_type

UNION

select
  item_type,
  floor((500000-floor(500000/(SELECT total_footage from cte where item_type ='prime_eligible'))*
  (SELECT total_footage from cte where item_type ='prime_eligible'))/
  (SELECT total_footage from cte where item_type ='not_prime'))*
  (SELECT prime_item_cnt from cte where item_type ='not_prime') as item_count
from inventory
where item_type = 'not_prime'
group by item_type

-- Q 33:
-- As part of an ongoing analysis of salary distribution within the company, your manager has requested a report identifying high earners in each department. A 'high earner' within a department is defined as an employee with a salary ranking among the top three salaries within that department.

-- You're tasked with identifying these high earners across all departments. Write a query to display the employee's name along with their department name and salary. In case of duplicates, sort the results of department name in ascending order, then by salary in descending order. If multiple employees have the same salary, then order them alphabetically.

-- Note: Ensure to utilize the appropriate ranking window function to handle duplicate salaries effectively.

-- As of June 18th, we have removed the requirement for unique salaries and revised the sorting order for the results.
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
-- 4	Noah Johnson	6800	2	9
-- 5	Sophia Martinez	1750	1	11
-- 6	Liam Brown	13000	3	
-- 7	Ava Garcia	12500	3	
-- 8	William Davis	6800	2	
-- 9	Isabella Wilson	11000	3	
-- 10	James Anderson	4000	1	11
-- department Schema:
-- column_name	type	description
-- department_id	integer	The department ID of the employee.
-- department_name	string	The name of the department.
-- department Example Input:
-- department_id	department_name
-- 1	Data Analytics
-- 2	Data Science
-- Example Output:
-- department_name	name	salary
-- Data Analytics	James Anderson	4000
-- Data Analytics	Emma Thompson	3800
-- Data Analytics	Daniel Rodriguez	2230
-- Data Science	Noah Johnson	6800
-- Data Science	William Davis	6800

-- The output displays the high earners in each department.

--     In the Data Analytics deaprtment, James Anderson leads with a salary of $4,000, followed by Emma Thompson earning $3,800, and Daniel Rodriguez with $2,230.
--     In the Data Science department, both Noah Johnson and William Davis earn $6,800, with Noah listed before William due to alphabetical ordering.


-- Solution:

With cte AS
(SELECT e.name,e.salary, e.department_id, d.department_name,
dense_rank() OVER (PARTITION BY d.department_id ORDER BY e.salary DESC) as rnk
FROM employee e JOIN department d
ON e.department_id = d.department_id)


SELECT department_name, name, salary from cte
WHERE rnk <=3
ORDER BY department_name ASC, salary DESC, name ASC;

-- Q 34:
-- New TikTok users sign up with their emails. They confirmed their signup by replying to the text confirmation to activate their accounts. Users may receive multiple text messages for account confirmation until they have confirmed their new account.

-- A senior analyst is interested to know the activation rate of specified users in the emails table. Write a query to find the activation rate. Round the percentage to 2 decimal places.

-- Definitions:

--     emails table contain the information of user signup details.
--     texts table contains the users' activation information.

-- Assumptions:

--     The analyst is interested in the activation rate of specific users in the emails table, which may not include all users that could potentially be found in the texts table.
--     For example, user 123 in the emails table may not be in the texts table and vice versa.

-- Effective April 4th 2023, we added an assumption to the question to provide additional clarity.
-- emails Table:
-- Column Name	Type
-- email_id	integer
-- user_id	integer
-- signup_date	datetime
-- emails Example Input:
-- email_id	user_id	signup_date
-- 125	7771	06/14/2022 00:00:00
-- 236	6950	07/01/2022 00:00:00
-- 433	1052	07/09/2022 00:00:00
-- texts Table:
-- Column Name	Type
-- text_id	integer
-- email_id	integer
-- signup_action	varchar
-- texts Example Input:
-- text_id	email_id	signup_action
-- 6878	125	Confirmed
-- 6920	236	Not Confirmed
-- 6994	236	Confirmed

-- 'Confirmed' in signup_action means the user has activated their account and successfully completed the signup process.
-- Example Output:
-- confirm_rate
-- 0.67
-- Explanation:

-- 67% of users have successfully completed their signup and activated their accounts. The remaining 33% have not yet replied to the text to confirm their signup.

Solution:

-- SELECT
-- ROUND(COUNT(t.email_id)::DECIMAL
--   /COUNT(DISTINCT e.email_id),2) as activation_rate
-- FROM emails e
-- LEFT JOIN texts t
-- ON e.email_id = t.email_id
-- AND t.signup_action = 'Confirmed';

-- Q 35:
-- You're given two tables containing data on Spotify users' streaming activity: songs_history which has historical streaming data, and songs_weekly which has data from the current week.

-- Write a query that outputs the user ID, song ID, and cumulative count of song plays up to August 4th, 2022, sorted in descending order.

-- Assume that there may be new users or songs in the songs_weekly table that are not present in the songs_history table.

-- Definitions:

--     song_weeklytable only contains data for the week of August 1st to August 7th, 2022.
--     songs_history table contains data up to July 31st, 2022. The query should include historical data from this table.

-- songs_history Table:
-- Column Name	Type
-- history_id	integer
-- user_id	integer
-- song_id	integer
-- song_plays	integer
-- songs_history Example Input:
-- history_id	user_id	song_id	song_plays
-- 10011	777	1238	11
-- 12452	695	4520	1

-- song_plays field contains the historical data of the number of times a user has played a particular song.
-- songs_weekly Table:
-- Column Name	Type
-- user_id	integer
-- song_id	integer
-- listen_time	datetime
-- songs_weekly Example Input:
-- user_id	song_id	listen_time
-- 777	1238	08/01/2022 12:00:00
-- 695	4520	08/04/2022 08:00:00
-- 125	9630	08/04/2022 16:00:00
-- 695	9852	08/07/2022 12:00:00
-- Example Output:
-- user_id	song_id	song_plays
-- 777	1238	12
-- 695	4520	2
-- 125	9630	1

-- On 4 August 2022, the data shows that User 777 listened to the song with song ID 1238 for a total of 12 times, with 11 of those times occurring before the current week and 1 time occurring within the current week.

-- However, the streaming data for User 695 with the song ID 9852 are not included in the output because the streaming date for that record falls outside the date range specified in the question.

-- Solution:


WITH total_plays as
  ((SELECT DISTINCT user_id, song_id, sum(song_plays) as song_plays FROM songs_history
    GROUP BY user_id, song_id
    ORDER BY song_plays DESC)

UNION ALL

  (SELECT user_id, song_id, count(song_id) as song_plays from songs_weekly
    WHERE EXTRACT( DAY from listen_time)<=4
    GROUP BY user_id, song_id
    ORDER BY song_plays DESC))

SELECT user_id, song_id, sum(song_plays) as song_plays from total_plays
GROUP BY user_id, song_id
ORDER BY song_plays DESC;

-- Q 35:

-- A Microsoft Azure Supercloud customer is defined as a customer who has purchased at least one product from every product category listed in the products table.

-- Write a query that identifies the customer IDs of these Supercloud customers.
-- customer_contracts Table:
-- Column Name	Type
-- customer_id	integer
-- product_id	integer
-- amount	integer
-- customer_contracts Example Input:
-- customer_id	product_id	amount
-- 1	1	1000
-- 1	3	2000
-- 1	5	1500
-- 2	2	3000
-- 2	6	2000
-- products Table:
-- Column Name	Type
-- product_id	integer
-- product_category	string
-- product_name	string
-- products Example Input:
-- product_id	product_category	product_name
-- 1	Analytics	Azure Databricks
-- 2	Analytics	Azure Stream Analytics
-- 4	Containers	Azure Kubernetes Service
-- 5	Containers	Azure Service Fabric
-- 6	Compute	Virtual Machines
-- 7	Compute	Azure Functions
-- Example Output:
-- customer_id
-- 1
-- Explanation:

-- Customer 1 bought from Analytics, Containers, and Compute categories of Azure, and thus is a Supercloud customer. Customer 2 isn't a Supercloud customer, since they don't buy any container services from Azure.

-- Solution:
SELECT customer_id FROM
(SELECT c.customer_id, p.product_category FROM customer_contracts c
  JOIN products p
  ON c.product_id = p.product_id) cte
GROUP BY customer_id
HAVING count(DISTINCT product_category) =
  (SELECT count(DISTINCT product_category) FROM products )

-- Q 36:
-- Zomato is a leading online food delivery service that connects users with various restaurants and cuisines, allowing them to browse menus, place orders, and get meals delivered to their doorsteps.

-- Recently, Zomato encountered an issue with their delivery system. Due to an error in the delivery driver instructions, each item's order was swapped with the item in the subsequent row. As a data analyst, you're asked to correct this swapping error and return the proper pairing of order ID and item.

-- If the last item has an odd order ID, it should remain as the last item in the corrected data. For example, if the last item is Order ID 7 Tandoori Chicken, then it should remain as Order ID 7 in the corrected data.

-- In the results, return the correct pairs of order IDs and items.
-- orders Schema:
-- column_name	type	description
-- order_id	integer	The ID of each Zomato order.
-- item	string	The name of the food item in each order.
-- orders Example Input:

-- Here's a sample of the initial incorrect data:
-- order_id	item
-- 1	Chow Mein
-- 2	Pizza
-- 3	Pad Thai
-- 4	Butter Chicken
-- 5	Eggrolls
-- 6	Burger
-- 7	Tandoori Chicken
-- orders Example Output:

-- The corrected data should look like this:
-- corrected_order_id	item
-- 1	Pizza
-- 2	Chow Mein
-- 3	Butter Chicken
-- 4	Pad Thai
-- 5	Burger
-- 6	Eggrolls
-- 7	Tandoori Chicken

-- Order ID 1 is now associated with Pizza and Order ID 2 is paired with Chow Mein. This adjustment ensures that each order is correctly aligned with its respective item, addressing the initial swapping error.

-- Order ID 7 remains unchanged and is still associated with Tandoori Chicken. This preserves the order sequence ensuring that the last odd order ID remains unaltered.

-- Solution:
WITH totals AS

(SELECT count(order_id) as cnt
FROM orders)


SELECT

CASE
  WHEN order_id%2 != 0 AND order_id != cnt THEN order_id + 1
  WHEN order_id%2 != 0 AND order_id = cnt THEN order_id
ELSE order_id - 1 END AS corrected_order_id,
item

from orders
CROSS JOIN totals

ORDER BY corrected_order_id;

Q37:

-- The Bloomberg terminal is the go-to resource for financial professionals, offering convenient access to a wide array of financial datasets. As a Data Analyst at Bloomberg, you have access to historical data on stock performance.

-- Currently, you're analyzing the highest and lowest open prices for each FAANG stock by month over the years.

-- For each FAANG stock, display the ticker symbol, the month and year ('Mon-YYYY') with the corresponding highest and lowest open prices (refer to the Example Output format). Ensure that the results are sorted by ticker symbol.
-- stock_prices Schema:
-- Column Name	Type	Description
-- date	datetime	The specified date (mm/dd/yyyy) of the stock data.
-- ticker	varchar	The stock ticker symbol (e.g., AAPL) for the corresponding company.
-- open	decimal	The opening price of the stock at the start of the trading day.
-- high	decimal	The highest price reached by the stock during the trading day.
-- low	decimal	The lowest price reached by the stock during the trading day.
-- close	decimal	The closing price of the stock at the end of the trading day.
-- stock_prices Example Input:

-- Note that the table below displays randomly selected AAPL data.
-- date	ticker	open	high	low	close
-- 01/31/2023 00:00:00	AAPL	142.28	142.70	144.34	144.29
-- 02/28/2023 00:00:00	AAPL	146.83	147.05	149.08	147.41
-- 03/31/2023 00:00:00	AAPL	161.91	162.44	165.00	164.90
-- 04/30/2023 00:00:00	AAPL	167.88	168.49	169.85	169.68
-- 05/31/2023 00:00:00	AAPL	176.76	177.33	179.35	177.25
-- Example Output:
-- ticker	highest_mth	highest_open	lowest_mth	lowest_open
-- AAPL	May-2023	176.76	Jan-2023	142.28

-- Solution:

WITH highest as
  (SELECT
    ticker,
    MAX(open) as highest_open,
    TO_CHAR(date, 'Mon-YYYY') as highest_mth,
    ROW_NUMBER() OVER(PARTITION BY ticker ORDER BY open DESC) as rnk
    FROM stock_prices
  
  GROUP BY ticker,TO_CHAR(date, 'Mon-YYYY'), open),

lowest as

 (SELECT
    ticker,
    MIN(open) as lowest_open,
    TO_CHAR(date, 'Mon-YYYY') as lowest_mth,
    ROW_NUMBER() OVER(PARTITION BY ticker ORDER BY open ASC) as rnk
    FROM stock_prices
  
  GROUP BY ticker,TO_CHAR(date, 'Mon-YYYY'), open)

  
  
  SELECT h.ticker, h.highest_mth, h.highest_open, l.lowest_mth, l.lowest_open
  FROM highest h
  INNER JOIN lowest l
  ON h.ticker = l.ticker
  AND h.rnk =1
  AND l.rnk =1
  ORDER by h.ticker
  
-- Q38:
-- Write an SQL query to find the best-selling product in each product category. If there are two or more products with the same sales quantity, go by whichever product which has the higher review rating.

-- Return the category name and product name in alphabetical order of the category.
-- products Table:
-- Column Name	Type
-- product_id	integer
-- product_name	varchar
-- category_name	varchar
-- products Example Input:
-- product_id	product_name	category_name
-- 3690	Game of Thrones	Books
-- 5520	Refrigerator	Home Appliances
-- 5952	Dishwasher	Home Appliances
-- 3561	IKGAI	Books
-- product_sales Table:
-- Column Name	Type
-- product_id	integer
-- sales_quantity	integer
-- rating	decimal (1.0 - 5.0)
-- product_sales Example Input:
-- product_id	sales_quantity	rating
-- 3690	300	4.9
-- 5520	70	3.8
-- 5952	70	4.0
-- 3561	290	4.5
-- Example Output:
-- category_name	product_name
-- Books	Game of Thrones
-- Home Appliances	Dishwasher

-- Solution:

WITH cte AS
  (SELECT p.product_id, p.product_name, p.category_name, s.sales_quantity, s.rating,
    dense_rank()OVER(PARTITION BY p.category_name ORDER BY s.sales_quantity DESC, s.rating DESC) AS rnk
    FROM products p
    INNER JOIN product_sales s
    ON  p.product_id = s.product_id)

SELECT category_name, product_name FROM cte
WHERE rnk = 1;

-- Q39:
-- In an effort to identify high-value customers, Amazon asked for your help to obtain data about users who go on shopping sprees. A shopping spree occurs when a user makes purchases on 3 or more consecutive days.

-- List the user IDs who have gone on at least 1 shopping spree in ascending order.
-- transactions Table:
-- Column Name	Type
-- user_id	integer
-- amount	float
-- transaction_date	timestamp
-- transactions Example Input:
-- user_id	amount	transaction_date
-- 1	9.99	08/01/2022 10:00:00
-- 1	55	08/17/2022 10:00:00
-- 2	149.5	08/05/2022 10:00:00
-- 2	4.89	08/06/2022 10:00:00
-- 2	34	08/07/2022 10:00:00
-- Example Output:
-- user_id
-- 2
-- Explanation

-- In this example, user_id 2 is the only one who has gone on a shopping spree.

-- Solution:

SELECT DISTINCT t1.user_id

  FROM transactions t1
  INNER JOIN transactions t2
  ON DATE(t2.transaction_date) = DATE(t1.transaction_date)+1
  INNER JOIN transactions t3
  ON DATE(t3.transaction_date) = DATE(t1.transaction_date)+2

ORDER BY t1.user_id

--Q40
-- You're given a table containing the item count for each order on Alibaba, along with the frequency of orders that have the same item count. Write a query to retrieve the mode of the order occurrences. Additionally, if there are multiple item counts with the same mode, the results should be sorted in ascending order.

-- Clarifications:

--     item_count: Represents the number of items sold in each order.
--     order_occurrences: Represents the frequency of orders with the corresponding number of items sold per order.
--     For example, if there are 800 orders with 3 items sold in each order, the record would have an item_count of 3 and an order_occurrences of 800.

-- Effective June 14th, 2023, the problem statement has been revised and additional clarification have been added for clarity.
-- items_per_order Table:
-- Column Name	Type
-- item_count	integer
-- order_occurrences	integer
-- items_per_order Example Input:
-- item_count	order_occurrences
-- 1	500
-- 2	1000
-- 3	800
-- Example Output:
-- mode
-- 2
-- Explanation:

-- Based on the example output, the order_occurrences value of 1000 corresponds to the highest frequency among all item counts. This means that item count of 2 has occurred 1000 times, making it the mode of order occurrences.

--Solution:

SELECT item_count as mode FROM
items_per_order
WHERE order_occurrences = (SELECT Max(order_occurrences) FROM items_per_order)

-- Q41:
-- Your team at JPMorgan Chase is soon launching a new credit card. You are asked to estimate how many cards you'll issue in the first month.

-- Before you can answer this question, you want to first get some perspective on how well new credit card launches typically do in their first month.

-- Write a query that outputs the name of the credit card, and how many cards were issued in its launch month. The launch month is the earliest record in the monthly_cards_issued table for a given card. Order the results starting from the biggest issued amount.
-- monthly_cards_issued Table:
-- Column Name	Type
-- issue_month	integer
-- issue_year	integer
-- card_name	string
-- issued_amount	integer
-- monthly_cards_issued Example Input:
-- issue_month	issue_year	card_name	issued_amount
-- 1	2021	Chase Sapphire Reserve	170000
-- 2	2021	Chase Sapphire Reserve	175000
-- 3	2021	Chase Sapphire Reserve	180000
-- 3	2021	Chase Freedom Flex	65000
-- 4	2021	Chase Freedom Flex	70000
-- Example Output:
-- card_name	issued_amount
-- Chase Sapphire Reserve	170000
-- Chase Freedom Flex	65000
-- Explanation

-- Chase Sapphire Reserve card was launched on 1/2021 with an issued amount of 170,000 cards and the Chase Freedom Flex card was launched on 3/2021 with an issued amount of 65,000 cards.

-- Solution:

WITH cte AS

(SELECT
a.card_name, a.issued_amount, issue_year, issue_month,
row_number() OVER(PARTITION BY a.card_name) as rnk

FROM

  (SELECT MIN(issue_year) as issue_year, card_name, issued_amount, issue_month
  FROM monthly_cards_issued
  GROUP BY card_name, issued_amount, issue_month
  ORDER BY card_name,issue_year, issue_month) a)
  
SELECT card_name, issued_amount
FROM cte
WHERE rnk = 1
ORDER BY issued_amount DESC;