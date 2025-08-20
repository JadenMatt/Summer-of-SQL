# SQL Murder Mystery – Step-by-Step Solution

This document records my investigation into the SQL Murder Mystery challenge.  
Each section contains the SQL queries I ran, the outputs, and the reasoning behind how they contributed to solving the case.

---

## Step 1 – Retrieve the crime scene report
The detective mentioned a murder on **15th Jan 2018 in SQL City**.  
I started by filtering the `crime_scene_report` table:

```sql
select *
from crime_scene_report
where type = 'murder'
  and city = 'SQL City'
  and date = 20180115;
```

Output (summary):
A murder took place in SQL City on the specified date.

Security footage revealed there were two witnesses:

- One lives at the last house on Northwestern Dr.

- One is named Annabel and lives on Franklin Ave.
  

This gave me my first lead: find the two witnesses.

## Step 2 – Identify the two witnesses

First witness (last house on Northwestern Dr):


```sql
select *
from person
where address_street_name = 'Northwestern Dr'
order by address_number desc
limit 1;
```
Output:
- Person ID: 14887
- Name: Morty Schapiro


Second witness (Annabel on Franklin Ave):

```sql
select *
from person
where name like 'Annabel%'
  and address_street_name = 'Franklin Ave';
```
Output:
- Person ID: 16371
- Name: Annabel Miller


Now I had both witnesses’ IDs.

## Step 3 – Retrieve witness statements

```sql
select *
from interview
where person_id = '14887'
   or person_id = '16371';
```
Outputs:
- Annabel Miller:She saw the murder happen and recognised the killer from her gym on 9th Jan 2018.
- Morty Schapiro: He heard a gunshot and saw a man running away with a Get Fit Now Gym bag.
  - Details:
      - Membership number began with "48Z".
      - Only gold members have that bag.
      - The suspect drove away in a car with "H42W" in the plate.


Both statements pointed me straight to the gym database.

## Step 4 – Track Annabel’s gym activity

First I confirmed Annabel’s gym membership:

```sql
select *
from get_fit_now_member
where person_id = 16371;
```

Output:
- Membership ID: 90081
- Status: Gold
- Start Date: 2016-02-08


Next, I checked her visits:

```sql
select *
from get_fit_now_check_in
where membership_id = 90081;
```

Output:
- Annabel checked in on 2018-01-09, from 16:00 to 17:00.


This gave me a timeframe to search for suspects who were in the gym at the same time.

## Step 5 – Find suspects at the gym at the same time

```sql
select *
from get_fit_now_check_in
where check_in_date = 20180109;
```

Among the people present, I cross-checked memberships starting with "48Z" (gold bag owners):

```sql
select *
from get_fit_now_member
where id = '48Z55' or id = '48Z7A';
```

and got their personal information from the person table

```sql
select *
from person
where id = '67318' OR id = '28819';
```

Outputs:
- Membership 48Z55 → Person ID 28819 → Joe Germuska
- Membership 48Z7A → Person ID 67318 → Jeremy Bowers


So there were two main suspects.

## Step 6 – Match suspect cars

From the witness, I knew the killer’s car had "H42W" in the number plate.

 I checked their driver’s licences, getting the license number from the person table:

 ```sql
select *
from drivers_license
where id = '173289' or id = '423327';
```

Outputs:
- Joe Germuska → No relevant car.
- Jeremy Bowers → Plate: 0H42W2 ✅ (matches Morty’s description).


At this point, it was clear that Jeremy Bowers was the murderer.

## Step 7 – Interrogate Jeremy

```sql
select *
from interview
where person_id = '67318';
```

Output:
- Jeremy confessed he was hired by a woman. He gave details in his statement:
    - Red hair
    - Height 5’5”–5’7”
    - Drove a Tesla Model S
    - Attended the SQL Symphony Concert 3 times in Dec 2017


This shifted the focus: who was the mastermind?

## Step 8 – Find the mastermind (efficient solution)

The challenge suggests solving the mastermind in **no more than 2 queries**.  
Instead of filtering licences first and then checking concert attendance separately, I combined everything with `JOIN`s:

```sql
select p.name
      , count(f.date)
from person p
join drivers_license d
    on p.license_id = d.id
join facebook_event_checkin f
    on p.id = f.person_id
where car_make = 'Tesla' 
  and car_model = 'Model S'
  and gender = 'female'
  and hair_color = 'red'
  and event_name = 'SQL Symphony Concert'
  and f.date like '%201712%'
group by p.name;
```
Output:
- Miranda Priestly
- 3

This single query linked:
- person → identity,
- drivers_license → car + physical description,
- facebook_event_checkin → SQL Symphony Concert attendance in Dec 2017.

By grouping the results, I confirmed that only Miranda Priestly attended the concert three times in that month.

Final Answer

- Murderer: Jeremy Bowers
- Mastermind: Miranda Priestly

Case closed.

