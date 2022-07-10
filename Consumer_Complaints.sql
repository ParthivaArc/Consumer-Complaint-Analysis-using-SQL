create database customer_Complaint;
use customer_complaint;

								/* DDL */

select * from complaints;
select * from company_response;

create table complaints
(Complaint_ID int,
Date_Received char(20),	
Product_Name varchar(100),
Sub_Product varchar(100),
Issue text,
Sub_Issue	text,
Consumer_Complaint_Narrative	text,
Company_Public_Response	text,
Company	char(100),
State_Name char(10)	,
Zip_Code char(20),	
Tags	char(20),
Consumer_Consent_Provided	char(20),
Submitted_via	char(20),
Date_Sent_to_Company char(20),
constraint complaint_pk primary key (complaint_id)
);


create table company_response
(complaint_id int,
Company_Response_to_Consumer char(100),
Timely_Response char(20),
Consumer_Disputed char(20),
constraint response_fk foreign key(complaint_id) references complaints(complaint_id)
);

alter table company_response
modify column Company_Response_to_Consumer varchar(100);

select * from complaints;
select * from company_response;

/* Changing Recieving date column to MySQL date format*/
select Date_Received, str_to_date(left(Date_Received,10), "%d-%m-%Y") as Updated_RecieveDate
from complaints;

Alter table complaints 
add column Complaint_RecieveDate date;

Update complaints
Set Complaint_RecieveDate = str_to_date(left(Date_Received,10), '%d-%m-%Y');

select * from complaints;

Alter table complaints
Drop column Date_Received;

Alter table complaints
Rename column Updated_recieveDate to Complaint_RecieveDate;

/* Changing Date of complaint sent to Company column to MySQL date format*/
select Date_Sent_to_Company, str_to_date(left(Date_Sent_to_Company,10), "%d-%m-%Y") as Date_ComplaintDispatched_toCompany
from complaints;

Alter table complaints 
add column Date_ComplaintDispatched_toCompany date;

Update complaints
Set Date_ComplaintDispatched_toCompany = str_to_date(left(Date_Sent_to_Company,10), '%d-%m-%Y');

select * from complaints;

Alter table complaints
Drop column Date_Sent_to_Company;

								/*** DML ***/
/* Firstly let us see a very basic sql queries to get acquainted with basic stuffs and then move on eventually*/
#first and foremost is understanding how to define things like select from and then applying condition as per que

/*1. How many complaints were received and sent off the same day*/
select complaint_id, Product_Name
from complaints 
where Complaint_RecieveDate = Date_ComplaintDispatched_toCompany;

						/* manipulations using between and in , not in */
/*2. Complaints received in the states of New York (NY) and California (CA) for the same day*/
#multiple condition
select Complaint_ID, Product_Name, State_Name
from complaints
where Complaint_RecieveDate = Date_ComplaintDispatched_toCompany and State_Name in ("NY", "CA");

						/* Joins, Group by, order by */
/* Now after we see about how complaints were dispatched on time now we will se from the company side how many were resolved on time*/
/* 2concepts to learn- along with applying condition we will learn joins and group by, order by*/

/*3. #State wise# find the number of consumer disputes were made */
select state_name, count(*) as Consumer_Disputes_Count
from company_response cr inner join complaints c on c.complaint_id = cr.COMPLAINT_ID
where consumer_disputed = "Yes"
group by state_name
order by 2 desc;

/*4. Did company provide timely response*/
select company, count(c.Complaint_ID)  as No_timely_responseCount
from company_response cr inner join complaints c on c.complaint_id = cr.CoMPlAiNt_ID
where timely_response = "no"
group by company
order by 2 desc;

						/* Pattern Matching- Like and Regexp */
/*5. Find the complaints which was as a result of theft or fraud.*/

select Issue, complaint_id,  company
from complaints
where  Issue like "%theft%" or Issue like "%fraud%" or Issue like "%scam%";

select Issue, complaint_id,  company
from complaints
where  Issue regexp "theft | fraud | scam";
 

							/* Logical Operator, CTE */
/* advance level of work where multi concepts are used
here it is important since for scams, frauds and thefts these are utmost important to be resolved the moment it is received
as else there can be mis use of it specially in financial services eg- theft of ATM card*/                           

/*6. Check if complaints which was as a result of theft or fraud dispatched on same day */
select complaint_id, company, if (Complaint_RecieveDate = Date_ComplaintDispatched_toCompany, "Dispatched same day","NIL")
from (select c.complaint_id, Issue, company, Complaint_RecieveDate, Date_ComplaintDispatched_toCompany
from company_response cr inner join complaints c on c.complaint_id = cr.complaint_id
where  Issue like "%theft%" or Issue like "%fraud%" or Issue like "%fraud%") as temptable
order by 2;

select * from complaints;

						/*** Data visualization queries ***/

/** Find statewise number of complaints lodged **/
select state_name, count(*) as Number_of_Complaints
from complaints
where state_name is not Null
group by state_name
order by 1 desc;

select state_name, issue, max(Number_of_Complaints)
from (select state_name, issue, count(*) as Number_of_Complaints
from complaints
where state_name is not Null
group by state_name, 2
order by 1) as temptable
group by 1, 2
order by 3 desc;


/** Timely response ratio of each company **/
select company, sum(if(Timely_Response="yes",1,0))/count(*) as `Timely Response Ratio`
from company_response cr inner join complaints c on c.complaint_id = cr.complaint_id
group by company;

select avg(`Timely Response Ratio`), min(`Timely Response Ratio`), max(`Timely Response Ratio`)
from (select company, sum(if(Timely_Response="yes",1,0))/count(*) as `Timely Response Ratio`
from company_response cr inner join complaints c on c.complaint_id = cr.complaint_id
group by company) as t;

/* Company response to  consumer*/
select Company_Response_to_Consumer, count(*)
from company_response
group by Company_Response_to_Consumer; 

/* How did the consumers submit complaint to CFCB*/
select Submitted_via, count(*)
from complaints
group by Submitted_via;

/* Product by highest complaint volume */
/* distribution of various types of product recieving complaints*/
select product_name, count(*)
from complaints
group by product_name
order by 2 desc;

select state_name, count(*)
from complaints
group by state_name;