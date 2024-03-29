use `bank analysis`;
select * from finance_1;
select * from finance_2;

desc finance_1;
desc finance_2;
show tables;
select * from finance_1;
select * from finance_2;
ALTER TABLE finance_1 ADD COLUMN issue_d_temp VARCHAR(10);

UPDATE finance_1
SET issue_d_temp = 
    CASE
        WHEN CHAR_LENGTH(issue_d) = 6 THEN STR_TO_DATE(CONCAT(issue_d, '-01'), '%b-%y-%d')
        WHEN CHAR_LENGTH(issue_d) = 5 THEN STR_TO_DATE(CONCAT(issue_d, '-01'), '%b-%y-%d')
        ELSE STR_TO_DATE(issue_d, '%b-%y-%d')
    END;

ALTER TABLE finance_1 DROP COLUMN issue_d;
ALTER TABLE finance_1 CHANGE COLUMN issue_d_temp issue_d DATE;

# KPI 1 Year wise loan amount Stats
select distinct year(issue_d) as Year, sum(loan_amnt) as Total_amount
from finance_1
group by Year
order by Year;

#KPI 2 Grade and sub grade wise revol_bal
select f1.grade, f1.sub_grade, sum(f2.revol_bal) as revolving_balance from
finance_1 as f1
inner join
finance_2 as f2
on f1.id = f2.id
group by f1.grade, f1.sub_grade;

#KPI 3 Total Payment for Verified Status Vs Total Payment for Non Verified Status
select f1.verification_status, round(sum(f2.total_pymnt),0) as Total_payment
from
finance_1 as f1
inner join
finance_2 as f2
on f1.id = f2.id
group by f1.verification_status;

# KPI 4 State wise and month wise loan status
select distinct f1.addr_state, f1.loan_status, count(loan_status)
from finance_1 as f1
inner join
finance_2 as f2
on f1.id = f2.id
group by f1.addr_state, f1.loan_status;


ALTER TABLE finance_2 ADD COLUMN last_pymnt_temp VARCHAR(10);
SET SQL_SAFE_UPDATES = 0;

UPDATE finance_2
SET last_pymnt_temp = 
    CASE
        WHEN CHAR_LENGTH(last_pymnt_d) = 6 AND last_pymnt_d IS NOT NULL AND last_pymnt_d != '' THEN STR_TO_DATE(CONCAT(last_pymnt_d, '-01'), '%b-%y-%d')
        WHEN CHAR_LENGTH(last_pymnt_d) = 5 AND last_pymnt_d IS NOT NULL AND last_pymnt_d != '' THEN STR_TO_DATE(CONCAT(last_pymnt_d, '-01'), '%b-%y-%d')
        WHEN last_pymnt_d IS NOT NULL AND last_pymnt_d != '' THEN STR_TO_DATE(last_pymnt_d, '%b-%y-%d')
    END;

ALTER TABLE finance_2 DROP COLUMN last_pymnt_d;
ALTER TABLE finance_2 CHANGE COLUMN last_pymnt_temp last_pymnt_d DATE;

# KPI 5 Home ownership Vs last payment date stats
select year(f2.last_pymnt_d) as Year, f1.home_ownership, count(f1.home_ownership) home_ownership
from finance_1 as f1 inner join finance_2 as f2
on f1.id = f2.id
group by Year, f1.home_ownership
order by Year;

