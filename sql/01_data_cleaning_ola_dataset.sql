#Database Creation
create database if not exists ola_bookings;
use ola_bookings;

#Table Creation
CREATE TABLE staging_bookings (
    Booking_Date              VARCHAR(20),
    Booking_Time              VARCHAR(20),
    Booking_ID                VARCHAR(20),
    Booking_Status            VARCHAR(30),
    Customer_ID                VARCHAR(20),
    Vehicle_Type               VARCHAR(50),
    Pickup_Location             VARCHAR(100),
    Drop_Location                VARCHAR(100),
    V_TAT                       VARCHAR(20),
    C_TAT                       VARCHAR(20),
    Canceled_Rides_by_Customer  VARCHAR(150),
    Canceled_Rides_by_Driver    VARCHAR(150),
    Incomplete_Rides            VARCHAR(10),
    Incomplete_Rides_Reason     VARCHAR(100),
    Booking_Value                VARCHAR(20),
    Payment_Method               VARCHAR(30),
    Ride_Distance                 VARCHAR(20),
    Driver_Ratings                VARCHAR(10),
    Customer_Rating               VARCHAR(10)
);
select * from staging_bookings;
#Data Cleaning
USE ola_bookings;

-- How many 'null' text values are in each column?
SELECT
  SUM(V_TAT = 'null') AS null_vtat,
  SUM(C_TAT = 'null') AS null_ctat,
  SUM(Payment_Method = 'null') AS null_payment,
  SUM(Driver_Ratings = 'null') AS null_driver_rating,
  SUM(Customer_Rating = 'null') AS null_customer_rating,
  SUM(Canceled_Rides_by_Customer = 'null') AS null_cancel_cust,
  SUM(Canceled_Rides_by_Driver = 'null') AS null_cancel_driver,
  SUM(Incomplete_Rides = 'null') AS null_incomplete,
  SUM(Incomplete_Rides_Reason = 'null') AS null_incomplete_reason
FROM staging_bookings;
SELECT
  SUM(V_TAT IS NULL) AS null_vtat,
  SUM(C_TAT IS NULL) AS null_ctat,
  SUM(Payment_Method IS NULL) AS null_payment,
  SUM(Driver_Ratings IS NULL) AS null_driver_rating,
  SUM(Customer_Rating IS NULL) AS null_customer_rating,
  SUM(Canceled_Rides_by_Customer IS NULL) AS null_cancel_cust,
  SUM(Canceled_Rides_by_Driver IS NULL) AS null_cancel_driver,
  SUM(Incomplete_Rides IS NULL) AS null_incomplete,
  SUM(Incomplete_Rides_Reason IS NULL) AS null_incomplete_reason
FROM staging_bookings;

SELECT
  SUM(V_TAT = '') AS empty_vtat,
  SUM(C_TAT = '') AS empty_ctat,
  SUM(Payment_Method = '') AS empty_payment,
  SUM(Driver_Ratings = '') AS empty_driver_rating,
  SUM(Customer_Rating = '') AS empty_customer_rating,
  SUM(Canceled_Rides_by_Customer = '') AS empty_cancel_cust,
  SUM(Canceled_Rides_by_Driver = '') AS empty_cancel_driver,
  SUM(Incomplete_Rides = '') AS empty_incomplete,
  SUM(Incomplete_Rides_Reason = '') AS empty_incomplete_reason
FROM staging_bookings;

#updating 
set sql_safe_updates=0;
UPDATE staging_bookings
SET V_TAT = NULLIF(V_TAT, ''),
    C_TAT = NULLIF(C_TAT, ''),
    Payment_Method = NULLIF(Payment_Method, ''),
    Driver_Ratings = NULLIF(Driver_Ratings, ''),
    Customer_Rating = NULLIF(Customer_Rating, ''),
    Canceled_Rides_by_Customer = NULLIF(Canceled_Rides_by_Customer, ''),
    Canceled_Rides_by_Driver = NULLIF(Canceled_Rides_by_Driver, ''),
    Incomplete_Rides = NULLIF(Incomplete_Rides, ''),
    Incomplete_Rides_Reason = NULLIF(Incomplete_Rides_Reason, '');
    
    #checking for whitespace/casing issues
    SELECT DISTINCT Vehicle_Type FROM staging_bookings;
SELECT DISTINCT Payment_Method FROM staging_bookings;
SELECT DISTINCT Booking_Status FROM staging_bookings;
SELECT DISTINCT Incomplete_Rides FROM staging_bookings;

UPDATE staging_bookings
SET Vehicle_Type = TRIM(Vehicle_Type),
    Payment_Method = TRIM(Payment_Method),
    Booking_Status = TRIM(Booking_Status),
    Pickup_Location = TRIM(Pickup_Location),
    Drop_Location = TRIM(Drop_Location),
    Customer_ID = TRIM(Customer_ID),
    Booking_ID = TRIM(Booking_ID);
    
    #checking for duplicate booking_ids
    SELECT Booking_ID, COUNT(*)
FROM staging_bookings
GROUP BY Booking_ID
HAVING COUNT(*) > 1;


    

