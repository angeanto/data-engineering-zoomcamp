{{ config(materialized='table') }}

SELECT * FROM 
 {{ source('staging','fhv_tripdata_all') }}

