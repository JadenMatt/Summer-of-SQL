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
