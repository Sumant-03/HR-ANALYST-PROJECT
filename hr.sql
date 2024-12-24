
create database hr_analytics;

create table hr 
(Age tinyint,
Attrition varchar(3),
BusinessTravel varchar(25),
DailyRate int,
Department varchar(50),
DistanceFromHome int,
Education tinyint,
EducationField varchar(50),
EmployeeCount tinyint,
EmployeeNumber int primary key,
EnvironmentSatisfaction tinyint,
Gender varchar(6),
HourlyRate int,
JobInvolvement tinyint,
JobLevel tinyint,
JobRole varchar(50),
JobSatisfaction tinyint,
MaritalStatus varchar(10));

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/HR_2.csv'
INTO TABLE hr_2
FIELDS TERMINATED BY ','
ENCLOSED BY '\"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE "secure_file_priv";

create table hr_2
(`Employee ID` int primary key,	
MonthlyIncome int,
MonthlyRate	int,
NumCompaniesWorked tinyint,
Over18 char(1),
OverTime varchar(3),
PercentSalaryHike int,
PerformanceRating tinyint,
RelationshipSatisfaction tinyint,
StandardHours int,
StockOptionLevel tinyint,
TotalWorkingYears tinyint,
TrainingTimesLastYear tinyint,
WorkLifeBalance	tinyint,
YearsAtCompany	tinyint,
YearsInCurrentRole	tinyint,
YearsSinceLastPromotion	tinyint,
YearsWithCurrManager tinyint
)

-- avg attrtion rate for all departments

select round(avg(ct),2) "avg attrition rate" from (
select Department, sum(EmployeeCount)*100/tot_ct ct from(
select Department,EmployeeCount,Attrition, sum(EmployeeCount) over(partition by Department) tot_ct
from hr) as T1
where Attrition like "Yes"
group by Department, tot_ct) as T2;


-- avg hourly rate of male research scientists

select avg(HourlyRate)
from hr
where Gender like "Male" and JobRole like "Research Scientist";

-- attrition rate vs monthly income stats


select count(*)*100/ct attrition_rate, income_levels from 
(select EmployeeNumber, Attrition from hr) as h1 join (
select *, count(*) over(partition by income_levels) ct from (
select `Employee ID` as EID,
case
when MonthlyIncome <=10000 then "Level 1: <=10k"
when MonthlyIncome <=20000 then "Level 2: <=20k"
when MonthlyIncome <=30000 then "Level 3: <=30k"
when MonthlyIncome <=40000 then "Level 4: <=40k"
when MonthlyIncome <=50000 then "Level 5: <=50k"
else "Level 6: <=60k"
end income_levels
from hr_2) as T1) as h2 on h1.EmployeeNumber=h2.EID 
where Attrition like "Yes"
group by income_levels, ct;


-- avg working years for each department

select Department, avg(YearsAtCompany) "working years"
from hr join hr_2 on EmployeeNumber=`Employee ID`
group by Department;

-- job role vs work life balance

with ratings as 
(select JobRole, WorkLifeBalance, EmployeeNumber
from hr join hr_2 on EmployeeNumber=`Employee ID`)
select r1.JobRole, `rate:1`,`rate:2`,`rate:3`,`rate:4`
from 
(select JobRole, count(EmployeeNumber) "rate:1" from ratings where WorkLifeBalance=1 group by JobRole) as r1 
join 
(select JobRole, count(EmployeeNumber) "rate:2" from ratings where WorkLifeBalance=2 group by JobRole) as r2
join
(select JobRole, count(EmployeeNumber) "rate:3" from ratings where WorkLifeBalance=3 group by JobRole) as r3
join
(select JobRole, count(EmployeeNumber) "rate:4" from ratings where WorkLifeBalance=4 group by JobRole) as r4
on r1.JobRole=r2.JobRole and r2.JobRole=r3.JobRole and r3.JobRole=r4.JobRole;

-- attrition rate vs year since last promotion

with att_rate as(
select * from (
(select EmployeeNumber,
case
when Attrition like "Yes" then 1
else 0
end attrition
 from hr) as T1
join 
(select `Employee ID`,YearsSinceLastPromotion from hr_2) T2 on EmployeeNumber=`Employee ID`))
select YearsSinceLastPromotion, sum(Attrition)*100/tot_ct attrition_rate
from (
select *, count(EmployeeNumber) over (partition by YearsSinceLastPromotion) tot_ct from att_rate
) as T1
group by YearsSinceLastPromotion, tot_ct;





