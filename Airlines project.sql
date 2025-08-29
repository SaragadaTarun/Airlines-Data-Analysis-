/*select * from tickets;
select * from passengers;
select * from flights;
select * from airlines;
select * from airports;*/
use flight;
-- 1) Find the busiest airport by number of flights takeoff
select b.name as airport_name,count(*) as total_flights from flights as a inner join airports as b 
on a.origin = b.airportid group by b.name order by total_flights desc ;
-- 2) find the total number of tickets sold per airline
select a.name,count(*) as tickets from tickets as t 
join flights as f on t.flightid = f.flightid
join airlines as a on a.airlineid = f.airlineid group by a.name order by tickets desc;
-- 3) list all flights operated by indigo with airport names (origin and destination)
select f.flightid,a.name as origin,a1.name as destination from flights as f 
join airlines as al on f.airlineid = al.airlineid
join airports as a on f.origin = a.airportid
join airports as a1 on f.destination = a1.airportid
where al.name = "indigo";
-- 4) for each flight,show time taken in hours and categorize it as a short(<2h),medium(2-5),or long(>5)
select *,timestampdiff(hour,departuretime,arrivaltime) as flight_time,
case
	when timestampdiff(hour,departuretime,arrivaltime) < 2 then "short"
    when timestampdiff(hour,departuretime,arrivaltime) >=2 and 
    timestampdiff(hour,departuretime,arrivaltime) <5 then "medium"
    else "high"
end as flightcategorize
 from flights order by flight_time desc;
 -- 5) show each passenger's first and last flight dates and number of flights
select t.passengerid,p.name,min(f.departuretime)as first_flight,max(f.departuretime)as last_flight,count(*) total_flights
from flights as f join tickets as t on f.flightid = t.flightid
				  join passengers AS p ON t.passengerid = p.passengerid
group by t.passengerid,p.name order by total_flights desc;
-- 6)find flight tickets with height price ticket sold for each route(origin -> destination)
-- used subquery for this question 
select  ticketid,origin,destination,price from(select t.ticketid,a.name as origin,a1.name as destination,t.price as price,
rank()over(partition by f.origin,f.destination order by price desc ) as rank1
 from flights as f 
join tickets as t on f.flightid = t.flightid
join airports as a on a.airportid = f.origin
join airports as a1 on a1.airportid = f.destination) ranked
where rank1 = 1  order by price desc;
-- 7)find the higest spending passenger in each frequent flyer status group
-- used subquery
select passengerid,name,frequentflyerstatus,spent from
(select p.passengerid,p.name,p.frequentflyerstatus,sum(t.price) as spent
, rank() over(partition by frequentflyerstatus order by sum(t.price) desc) as rn from passengers as p 
join tickets as t on p.passengerid = t.passengerid
group by p.passengerid,p.name,p.frequentflyerstatus) ranked
where rn =1;

-- or
with tarun as(
select p.passengerid,p.name,p.frequentflyerstatus,sum(t.price) as spent
, rank() over(partition by frequentflyerstatus order by sum(t.price) desc) as rn from passengers as p 
join tickets as t on p.passengerid = t.passengerid
group by p.passengerid,p.name,p.frequentflyerstatus)
select passengerid,name,frequentflyerstatus,spent from 
tarun where rn =1;
