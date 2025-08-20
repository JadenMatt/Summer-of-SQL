select *
from person
where address_street_name = 'Northwestern Dr'
order by address_number desc
limit 1;

select *
from person
where name like 'Annabel%'
  and address_street_name = 'Franklin Ave';
