#sql questions
-- 1. Retrieve all successful bookings
create view vw_succesful_bookings as
select * from
fact_bookings
where Booking_Status="Success";

-- 2. Average ride distance for each vehicle type
CREATE OR REPLACE VIEW vw_avg_distance_by_vehicle AS
SELECT v.Vehicle_Type,
       ROUND(AVG(f.Ride_Distance), 2) AS Avg_Ride_Distance
FROM fact_bookings f
JOIN dim_vehicle_type v ON f.Vehicle_Type_ID = v.Vehicle_Type_ID
GROUP BY v.Vehicle_Type;

select * from vw_avg_distance_by_vehicle;

-- 3. Total cancelled rides by customer
CREATE OR REPLACE VIEW vw_total_cancelled_by_customer AS
SELECT COUNT(*) AS Total_Cancelled_By_Customer
FROM fact_bookings
WHERE Booking_Status = 'Canceled by Customer';

-- 4. Top 5 customers by ride count
CREATE OR REPLACE VIEW vw_top5_customers AS
SELECT Customer_ID, 
COUNT(Booking_ID) AS Total_Rides
FROM fact_bookings
GROUP BY Customer_ID
ORDER BY Total_Rides DESC
LIMIT 5;

-- 5. Rides cancelled by driver - personal & car issue
CREATE OR REPLACE VIEW vw_cancelled_driver_personal_car AS
SELECT COUNT(*) AS Cancelled_By_Driver_Personal_Car_Issue
FROM fact_bookings
WHERE Cancel_Reason_Driver = 'Personal & Car related issue';
  select * from fact_bookings;
  
  select * from vw_cancelled_driver_personal_car;	
  
  -- 6. Max/min driver ratings for Prime Sedan
CREATE OR REPLACE VIEW vw_prime_sedan_driver_ratings AS
SELECT MAX(f.Driver_Ratings) AS Max_Driver_Rating,
       MIN(f.Driver_Ratings) AS Min_Driver_Rating
FROM fact_bookings f
JOIN dim_vehicle_type v ON f.Vehicle_Type_ID = v.Vehicle_Type_ID
WHERE v.Vehicle_Type = 'Prime Sedan';
SELECT * FROM vw_prime_sedan_driver_ratings;

-- 7. Rides paid via UPI
CREATE OR REPLACE VIEW vw_upi_rides AS
SELECT f.*
FROM fact_bookings f
JOIN dim_payment_method p ON f.Payment_Method_ID = p.Payment_Method_ID
WHERE p.Payment_Method = 'UPI';
SELECT * FROM vw_upi_rides;

-- 8. Average customer rating per vehicle type
CREATE OR REPLACE VIEW vw_avg_customer_rating_by_vehicle AS
SELECT v.Vehicle_Type,
       ROUND(AVG(f.Customer_Rating), 2) AS Avg_Customer_Rating
FROM fact_bookings f
JOIN dim_vehicle_type v ON f.Vehicle_Type_ID = v.Vehicle_Type_ID
GROUP BY v.Vehicle_Type;

-- 9. Total booking value of successful rides
CREATE OR REPLACE VIEW vw_total_successful_booking_value AS
SELECT SUM(Booking_Value) AS Total_Successful_Booking_Value
FROM fact_bookings
WHERE Booking_Status = 'Success';

-- 10. Incomplete rides with reason
CREATE OR REPLACE VIEW vw_incomplete_rides AS
SELECT Booking_ID, Incomplete_Rides_Reason
FROM fact_bookings
WHERE Is_Incomplete = 1;
select * from vw_incomplete_rides;


select * from fact_bookings;
select sum(ride_distance) from fact_bookings;
select avg(customer_rating) from fact_bookings;




USE ola_bookings;

UPDATE fact_bookings f
JOIN dim_vehicle_type v ON f.Vehicle_Type_ID = v.Vehicle_Type_ID
SET f.Driver_Ratings = ROUND(
    CASE v.Vehicle_Type
        WHEN 'Prime SUV'   THEN 4.3 + (RAND() * 0.6 - 0.3)
        WHEN 'Prime Sedan' THEN 4.2 + (RAND() * 0.6 - 0.3)
        WHEN 'Prime Plus'  THEN 4.1 + (RAND() * 0.6 - 0.3)
        WHEN 'Mini'        THEN 3.9 + (RAND() * 0.6 - 0.3)
        WHEN 'Auto'        THEN 3.7 + (RAND() * 0.6 - 0.3)
        WHEN 'Bike'        THEN 3.6 + (RAND() * 0.6 - 0.3)
        WHEN 'E-Bike'      THEN 3.8 + (RAND() * 0.6 - 0.3)
    END, 2)
WHERE f.Driver_Ratings IS NOT NULL;

UPDATE fact_bookings f
JOIN dim_vehicle_type v ON f.Vehicle_Type_ID = v.Vehicle_Type_ID
SET f.Customer_Rating = ROUND(
    CASE v.Vehicle_Type
        WHEN 'Prime SUV'   THEN 4.2 + (RAND() * 0.6 - 0.3)
        WHEN 'Prime Sedan' THEN 4.1 + (RAND() * 0.6 - 0.3)
        WHEN 'Prime Plus'  THEN 4.0 + (RAND() * 0.6 - 0.3)
        WHEN 'Mini'        THEN 3.8 + (RAND() * 0.6 - 0.3)
        WHEN 'Auto'        THEN 3.6 + (RAND() * 0.6 - 0.3)
        WHEN 'Bike'        THEN 3.5 + (RAND() * 0.6 - 0.3)
        WHEN 'E-Bike'      THEN 3.7 + (RAND() * 0.6 - 0.3)
    END, 2)
WHERE f.Customer_Rating IS NOT NULL;


USE ola_bookings;

UPDATE fact_bookings f
JOIN dim_vehicle_type v ON f.Vehicle_Type_ID = v.Vehicle_Type_ID
SET f.Booking_Value = ROUND(
    f.Ride_Distance *
    CASE v.Vehicle_Type
        WHEN 'Prime SUV'   THEN 18 + (RAND() * 4 - 2)
        WHEN 'Prime Sedan' THEN 15 + (RAND() * 4 - 2)
        WHEN 'Prime Plus'  THEN 13 + (RAND() * 4 - 2)
        WHEN 'Mini'        THEN 10 + (RAND() * 3 - 1.5)
        WHEN 'Auto'        THEN 8  + (RAND() * 3 - 1.5)
        WHEN 'Bike'        THEN 5  + (RAND() * 2 - 1)
        WHEN 'E-Bike'      THEN 6  + (RAND() * 2 - 1)
        ELSE 10
    END
, 2)
WHERE f.Booking_Value IS NOT NULL AND f.Ride_Distance IS NOT NULL;




SELECT DISTINCT Booking_Status FROM fact_bookings;

SELECT Booking_Status, COUNT(*) AS total_rows, COUNT(Booking_Value) AS non_null_values
FROM fact_bookings
GROUP BY Booking_Status;

SELECT 
    SUM(Booking_Value) AS total_revenue_all,
    SUM(CASE WHEN Booking_Status = 'Success' THEN Booking_Value ELSE 0 END) AS success_revenue_only
FROM fact_bookings;
set sql_safe_updates=0;
UPDATE fact_bookings 
SET Cancel_Reason_Customer = 'Driver not approaching'
WHERE Cancel_Reason_Customer = 'Driver is not moving towards pickup location';



