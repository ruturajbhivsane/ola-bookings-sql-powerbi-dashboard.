USE ola_bookings;

CREATE TABLE dim_date (
    Date_ID       INT AUTO_INCREMENT PRIMARY KEY,
    Booking_Date  DATE NOT NULL,
    Day           INT,
    Month         VARCHAR(20),
    Year          INT,
    Weekday       VARCHAR(20),
    Is_Weekend    BOOLEAN
);

CREATE TABLE dim_customer (
    Customer_ID   VARCHAR(20) PRIMARY KEY
);

CREATE TABLE dim_vehicle_type (
    Vehicle_Type_ID INT AUTO_INCREMENT PRIMARY KEY,
    Vehicle_Type    VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE dim_location (
    Location_ID   INT AUTO_INCREMENT PRIMARY KEY,
    Location_Name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dim_payment_method (
    Payment_Method_ID INT AUTO_INCREMENT PRIMARY KEY,
    Payment_Method    VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE fact_bookings (
    Booking_ID              VARCHAR(20) PRIMARY KEY,
    Date_ID                 INT NOT NULL,
    Booking_Time            TIME,
    Customer_ID             VARCHAR(20) NOT NULL,
    Vehicle_Type_ID         INT NOT NULL,
    Pickup_Location_ID      INT NOT NULL,
    Drop_Location_ID        INT NOT NULL,
    Payment_Method_ID       INT NULL,
    Booking_Status          VARCHAR(30) NOT NULL,
    V_TAT                   DECIMAL(10,2) NULL,
    C_TAT                   DECIMAL(10,2) NULL,
    Cancel_Reason_Customer  VARCHAR(150) NULL,
    Cancel_Reason_Driver    VARCHAR(150) NULL,
    Is_Incomplete           TINYINT NULL,
    Incomplete_Rides_Reason VARCHAR(100) NULL,
    Booking_Value           DECIMAL(10,2) NOT NULL,
    Ride_Distance           DECIMAL(10,2) NOT NULL,
    Driver_Ratings          DECIMAL(3,2) NULL,
    Customer_Rating         DECIMAL(3,2) NULL,

    FOREIGN KEY (Date_ID) REFERENCES dim_date(Date_ID),
    FOREIGN KEY (Customer_ID) REFERENCES dim_customer(Customer_ID),
    FOREIGN KEY (Vehicle_Type_ID) REFERENCES dim_vehicle_type(Vehicle_Type_ID),
    FOREIGN KEY (Pickup_Location_ID) REFERENCES dim_location(Location_ID),
    FOREIGN KEY (Drop_Location_ID) REFERENCES dim_location(Location_ID),
    FOREIGN KEY (Payment_Method_ID) REFERENCES dim_payment_method(Payment_Method_ID)
);

-- dim_customer
INSERT INTO dim_customer (Customer_ID)
SELECT DISTINCT Customer_ID FROM staging_bookings;

-- dim_vehicle_type
INSERT INTO dim_vehicle_type (Vehicle_Type)
SELECT DISTINCT Vehicle_Type FROM staging_bookings;

-- dim_location (pickup + drop combined)
INSERT INTO dim_location (Location_Name)
SELECT DISTINCT Pickup_Location FROM staging_bookings
UNION
SELECT DISTINCT Drop_Location FROM staging_bookings;

-- dim_payment_method
INSERT INTO dim_payment_method (Payment_Method)
SELECT DISTINCT Payment_Method FROM staging_bookings
WHERE Payment_Method IS NOT NULL;

INSERT INTO dim_date (Booking_Date, Day, Month, Year, Weekday, Is_Weekend)
SELECT DISTINCT
    DATE(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')) AS Booking_Date,
    DAY(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')),
    MONTHNAME(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')),
    YEAR(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')),
    DAYNAME(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')),
    DAYOFWEEK(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')) IN (1,7)
FROM staging_bookings;

SELECT * FROM dim_vehicle_type;


SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE fact_bookings;
TRUNCATE TABLE dim_date;
TRUNCATE TABLE dim_customer;
TRUNCATE TABLE dim_vehicle_type;
TRUNCATE TABLE dim_location;
TRUNCATE TABLE dim_payment_method;

SET FOREIGN_KEY_CHECKS = 1;

-- dim_vehicle_type
INSERT INTO dim_vehicle_type (Vehicle_Type)
SELECT DISTINCT Vehicle_Type FROM staging_bookings;

-- dim_location
INSERT INTO dim_location (Location_Name)
SELECT DISTINCT Pickup_Location FROM staging_bookings
UNION
SELECT DISTINCT Drop_Location FROM staging_bookings;

-- dim_payment_method
INSERT INTO dim_payment_method (Payment_Method)
SELECT DISTINCT Payment_Method FROM staging_bookings
WHERE Payment_Method IS NOT NULL;

-- dim_customer
INSERT INTO dim_customer (Customer_ID)
SELECT DISTINCT Customer_ID FROM staging_bookings;

-- dim_date
INSERT INTO dim_date (Booking_Date, Day, Month, Year, Weekday, Is_Weekend)
SELECT DISTINCT
    DATE(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')) AS Booking_Date,
    DAY(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')),
    MONTHNAME(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')),
    YEAR(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')),
    DAYNAME(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')),
    DAYOFWEEK(STR_TO_DATE(Booking_Date, '%Y-%m-%d %H:%i:%s')) IN (1,7)
FROM staging_bookings;
SELECT COUNT(*) FROM dim_date;
SELECT COUNT(*) FROM dim_customer;
SELECT COUNT(*) FROM dim_vehicle_type;
SELECT COUNT(*) FROM dim_location;
SELECT COUNT(*) FROM dim_payment_method;

INSERT INTO fact_bookings (
    Booking_ID, Date_ID, Booking_Time, Customer_ID, Vehicle_Type_ID,
    Pickup_Location_ID, Drop_Location_ID, Payment_Method_ID,
    Booking_Status, V_TAT, C_TAT, Cancel_Reason_Customer, Cancel_Reason_Driver,
    Is_Incomplete, Incomplete_Rides_Reason, Booking_Value, Ride_Distance,
    Driver_Ratings, Customer_Rating
)
SELECT
    s.Booking_ID,
    d.Date_ID,
    STR_TO_DATE(s.Booking_Time, '%H:%i:%s') AS Booking_Time,
    s.Customer_ID,
    v.Vehicle_Type_ID,
    pl.Location_ID AS Pickup_Location_ID,
    dl.Location_ID AS Drop_Location_ID,
    pm.Payment_Method_ID,
    s.Booking_Status,
    CAST(NULLIF(s.V_TAT, '') AS DECIMAL(10,2)),
    CAST(NULLIF(s.C_TAT, '') AS DECIMAL(10,2)),
    s.Canceled_Rides_by_Customer,
    s.Canceled_Rides_by_Driver,
    CASE WHEN s.Incomplete_Rides = 'Yes' THEN 1
         WHEN s.Incomplete_Rides = 'No' THEN 0
         ELSE NULL END,
    s.Incomplete_Rides_Reason,
    CAST(s.Booking_Value AS DECIMAL(10,2)),
    CAST(s.Ride_Distance AS DECIMAL(10,2)),
    CAST(NULLIF(s.Driver_Ratings, '') AS DECIMAL(3,2)),
    CAST(NULLIF(s.Customer_Rating, '') AS DECIMAL(3,2))
FROM staging_bookings s
JOIN dim_date d
    ON d.Booking_Date = DATE(STR_TO_DATE(s.Booking_Date, '%Y-%m-%d %H:%i:%s'))
JOIN dim_vehicle_type v
    ON v.Vehicle_Type = s.Vehicle_Type
JOIN dim_location pl
    ON pl.Location_Name = s.Pickup_Location
JOIN dim_location dl
    ON dl.Location_Name = s.Drop_Location
LEFT JOIN dim_payment_method pm
    ON pm.Payment_Method = s.Payment_Method;
    
    SELECT COUNT(*) FROM fact_bookings;