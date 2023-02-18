{{ config(materialized='table') }}

WITH dim_zones as (
    select * from {{ ref('dim_zones') }}
    where borough != 'Unknown'
),

fhv_data as (
    select *, 
        'fhv' as service_type
    from {{ ref('stg_fhv_tripdata') }}
) 

SELECT fhv_data.*,
pickup_zone.borough as pickup_borough, 
pickup_zone.zone as pickup_zone, 
dropoff_zone.borough as dropoff_borough, 
dropoff_zone.zone as dropoff_zone
FROM  fhv_data
INNER JOIN dim_zones as pickup_zone
on fhv_data.PUlocationID = pickup_zone.locationid
INNER JOIN dim_zones as dropoff_zone
on fhv_data.DOlocationID = dropoff_zone.locationid