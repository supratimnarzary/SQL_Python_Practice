# Code Review Issues Log

A reference log of correctness bugs, portability issues, and efficiency
improvements found during review. The "passes the example" trap applies to
several of these: DataLemur grades against a larger hidden dataset, so matching
the small example shown does **not** mean the query is correct.

---

## Correctness bugs (produce wrong results on some data)

### Q14 — "employees who earn more than their manager"
**File:** `problems/DataLemur.sql`

**Bug:** The CTE restricts managers to `WHERE manager_id IS NULL`, i.e. only
**top-level** managers (people with no boss of their own). Employees whose
manager is mid-level are silently dropped from the join.

**Why it passed the example:** The only qualifying employee (Olivia Smith) has a
manager (William Davis) who happens to be top-level (`manager_id = NULL`), so the
comparison fires.

**Where it breaks:**
| id | name     | salary | manager_id |
|----|----------|--------|-----------|
| 10 | Worker   | 9000   | 11        |
| 11 | TeamLead | 8000   | 6         |
| 6  | Director | 13000  | NULL      |

Worker (9000) > TeamLead (8000) should be returned, but TeamLead has
`manager_id = 6` (not NULL), so TeamLead is excluded from the manager CTE and
Worker is dropped.

**Fix idea:** Any employee can be a manager — don't filter the manager side.
```sql
SELECT e.employee_id, e.name AS employee_name
FROM employee e
JOIN employee m ON e.manager_id = m.employee_id
WHERE e.salary > m.salary;
```
Also: `ISNULL` is SQLite-only; standard SQL is `IS NULL`.

---

### Q17 — "confirmed sign-up on the second day"
**File:** `problems/DataLemur.sql`

**Bug:** Filter uses `EXTRACT(DAY FROM signup_date) + 1 = EXTRACT(DAY FROM action_date)`.
`EXTRACT(DAY ...)` returns only the **day-of-month number** (1–31), discarding
month and year.

**Why it passed the example:** Sample dates are `07/09` → `07/10`, same month,
mid-month, so day-number arithmetic happens to work.

**Where it breaks:**
1. Month boundary: `01/31` → `02/01` is 1 day apart, but `31 + 1 = 32 ≠ 1`. Missed.
2. Same day numbers, different months: `01/09` → `02/10` is a month apart, but
   `9 + 1 = 10`. **Falsely matched.**
3. Year boundary: `12/31` → `01/01`. Same problem as (1).

**Fix idea:** Compare actual calendar dates, not day numbers.
```sql
WHERE signup_action = 'Confirmed'
  AND action_date::date = signup_date::date + INTERVAL '1 day'
```

---

### Q20 — "mean items per order"
**File:** `problems/DataLemur.sql`

**Bug:** `ROUND(CAST(SUM(total_orders) / SUM(order_occurrences) AS NUMERIC), 1)`.
Both sums are integers, so the division runs in **integer arithmetic first** and
truncates; the `CAST` to NUMERIC happens *after* the truncation, too late.

**Why it might pass:** Engine-dependent. MySQL's `/` always returns a decimal
(`8900/3300 = 2.6969… → 2.7`, correct). Postgres/SQL Server truncate integer
division (`8900/3300 = 2 → 2.0`, wrong; expected 2.7).

**Fix idea:** Cast an operand to numeric **before** dividing.
```sql
SELECT ROUND(SUM(item_count * order_occurrences)::numeric / SUM(order_occurrences), 1) AS mean
FROM items_per_order;
```
(The CTE and its `GROUP BY` are also unnecessary — rows are already unique.)

---

### Q1 Solution 2 — non-aggregated column
**File:** `problems/DataLemur.sql`
Inner query selects `tweet_date` while grouping only by `user_id`. That column
is not aggregated and not in `GROUP BY` — errors under standard/strict SQL, and
it's unused anyway. Drop it.

---

### Q11 — can overcount companies
**File:** `problems/DataLemur.sql`
Grouping by `company_id, title` then `count(company_id)` counts a company once
**per duplicated title**, so a company with two distinct duplicated postings is
counted twice. Use `count(DISTINCT company_id)`. Also `description` is selected
but not grouped, and the dedup should key on **title AND description** per the
problem statement.

---

## Portability issues

### Double-quoted string literals
**File:** `problems/DataLemur.sql` (Q2, Q5, Q8)
`"Python"`, `"laptop"`, etc. Standard SQL / Postgres treat double quotes as
**identifiers** (column names), so these error. Use single quotes `'Python'`.
MySQL tolerates double quotes, which is why it slipped through.

---

## Efficiency improvements

### Function-on-column prevents index use
**Files:** `problems/DataLemur.sql` (Q1, Q6, Q10, Q13, Q16), `problems/problems03_branch_performance.sql`
`YEAR(date) = 2022`, `EXTRACT(year FROM ts) = 2022`, etc. force a full scan.
Use half-open ranges instead:
```sql
WHERE tweet_date >= '2022-01-01' AND tweet_date < '2023-01-01'
```
**Good reference:** Q18 already does this correctly — copy that pattern.

### Hardcoded year vs. "current year"
**File:** `problems/problems03_branch_performance.sql`
Uses `year(...) = 2024` though the prompt says "current year." Prefer
`transaction_date >= date_trunc('year', CURRENT_DATE)`.

### Pointless ORDER BY inside subqueries
**File:** `problems/DataLemur.sql` (Q8 Second Highest Salary, Q22)
Ordering inside a derived table isn't guaranteed to survive the outer query and
just adds a sort. Remove it; keep the outer `ORDER BY`.

### Q20 redundant CTE
Covered above — the `GROUP BY item_count, order_occurrences` over already-unique
rows does nothing; collapse to a single aggregate query.

### Q5 (Laptop vs Mobile) — prefer single-pass version
**File:** `problems/DataLemur.sql`
The first solution recomputes a full-table subquery for `mobile_views`. The
conditional-`SUM(CASE WHEN ...)` alternative right below it does it in one pass —
prefer that one.

---

## Key takeaway
"Matches the example output" ≠ correct. The example data is deliberately small
and avoids edge cases: a mid-level manager (Q14), a month/year boundary (Q17),
and integer truncation that only surfaces on certain engines (Q20). Always
reason about edge cases the example omits.
