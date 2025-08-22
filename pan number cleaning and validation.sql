SET search_path TO practice;

create table Pan_verification(
pan_number text
);

select * from pan_verification;

-- identify and handle missing data

select * from pan_verification where 
pan_number is null;

-- check for duplicates

select pan_number,count(1) from 
pan_verification 
group by pan_number 
having count(1)>1

-- spaces handling

select pan_number from pan_verification
where length(pan_number)!=10

select pan_number from pan_verification
where pan_number<>trim(pan_number)

-- correct lettercase

select pan_number from pan_verification
where pan_number<>upper(pan_number)

-- WHOLE QUERY TOGRTHER
select distinct upper(trim(pan_number)) from pan_verification where 
pan_number is not null
and trim(pan_number)<>'';

-- Function to check if adjecent characters are the same

create or replace function check_the_num(str text)
returns boolean
language plpgsql
as $$
begin
 for i in 1 .. length(str)-1
 loop
 	if substring(str,i,1)=substring(str,i+1,1)
	then 
	return True;
	end if;
 end loop;
 return False;
end;
$$


-- function to check if there is sequence of characters

create or replace function check_seq(str text)
returns boolean
language plpgsql
as $$
begin
 for i in 1 .. length(str)-1
 loop
 	if ascii(substring(str,i+1,1))-ascii(substring(str,i,1))=1
	then 
	return True;
	end if;
 end loop;
 return False;
end;
$$



-- regular expression to validate the patterns

-- select * from pan_verification
-- where pan_number~ '^[A-Z]{5}[0-9]{4}[A-Z]$'

-- valid and  invalid categorization

create or replace view valid_invalid_pan as
with cleaned_data as(
select distinct upper(trim(pan_number)) as pan_number from pan_verification where 
pan_number is not null
and trim(pan_number)<>''
),


valid_num as(
select * from cleaned_data
where check_the_num(pan_number)=false
and 
check_seq(substring(pan_number,1,5))=false
and
check_seq(substring(pan_number,6,4))=false
and
pan_number~ '^[A-Z]{5}[0-9]{4}[A-Z]$'
)

select c.pan_number,
case when v.pan_number is null then 'invalid'
else 'valid' end as status from cleaned_data c
left join 
valid_num v
on c.pan_number=v.pan_number



select (select count(*) from pan_verification) as total_processed,
sum(case when status='invalid' then 1 else 0 end) as invalid_count
,sum(case when status='valid'  then 1 else 0 end) as valid_Count
from valid_invalid_pan;

select * from valid_invalid_pan

