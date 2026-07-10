# DAX Measures

All measures used across the 5-page Power BI dashboard, grouped by the page(s) they
appear on. Table/column references use the actual table names from the model
(`'ola_bookings fact_bookings'`, `dim_vehicle_type`, `dim_date`, etc.).

## Core measures (used across multiple pages)

```dax
Total Bookings =
COUNTROWS(fact_bookings)
```

```dax
Total Revenue =
SUM(fact_bookings[Booking_Value])
```

```dax
Successful Bookings =
CALCULATE(
    [Total Bookings],
    fact_bookings[Booking_Status] = "Success"
)
```

```dax
Cancelled Bookings =
CALCULATE(
    [Total Bookings],
    fact_bookings[Booking_Status] IN {"Canceled by Customer", "Canceled by Driver"}
)
```

```dax
Cancellation Rate =
DIVIDE([Cancelled Bookings], [Total Bookings])
```

```dax
Avg Driver Rating =
AVERAGE(fact_bookings[Driver_Ratings])
```

```dax
Avg Customer Rating =
AVERAGE(fact_bookings[Customer_Rating])
```

## Vehicle Type page

```dax
Avg Distance Travelled =
AVERAGE(fact_bookings[Ride_Distance])
```

```dax
Total Distance Travelled =
SUM(fact_bookings[Ride_Distance])
```

```dax
Success Booking Value =
CALCULATE(
    [Total Revenue],
    fact_bookings[Booking_Status] = "Success"
)
```
> Note: in this dataset, `Booking_Value` is only ever populated for successful rides,
> so `Success Booking Value` and `Total Revenue` are numerically identical. Kept here
> for documentation, but not used as a separate KPI card on the dashboard for that reason.

## Revenue page

```dax
Avg Booking Value =
AVERAGE(fact_bookings[Booking_Value])
```

## Cancellation page

```dax
Cancelled by Customer =
CALCULATE(
    COUNTROWS(fact_bookings),
    fact_bookings[Booking_Status] = "Canceled by Customer"
)
```

```dax
Cancelled by Driver =
CALCULATE(
    [Total Bookings],
    fact_bookings[Booking_Status] = "Canceled by Driver"
)
```

## Calculated column (not a measure)

Used to sort `dim_date[Weekday]` in correct Monday→Sunday order instead of Power BI's
default alphabetical sort (created in Power Query):

```
Weekday_Number = Date.DayOfWeek([Booking_Date], Day.Monday) + 1
```
Applied via **Column tools → Sort by column** on `Weekday`, sorted by `Weekday_Number`.

## Relationship note

`fact_bookings` has two foreign keys into `dim_location` (`Pickup_Location_ID` and
`Drop_Location_ID`). Only one relationship can be active at a time between the same
two tables, so `Drop_Location_ID` is active and `Pickup_Location_ID` is inactive.
To build a pickup-based measure, use `USERELATIONSHIP()`, e.g.:

```dax
Bookings by Pickup Location =
CALCULATE(
    [Total Bookings],
    USERELATIONSHIP(fact_bookings[Pickup_Location_ID], dim_location[Location_ID])
)
```
