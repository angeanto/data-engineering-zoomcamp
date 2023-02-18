
-- insert 2019 and 2020 yellow data from gcs to bq
LOAD DATA OVERWRITE `dezoomcamp.rides_yellow_all`
FROM FILES (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_adept-storm-375515/data/yellow/yellow_tripdata_20*.csv.gz']);

-- insert 2019 and 2020 green data from gcs to bq
LOAD DATA OVERWRITE `dezoomcamp.rides_green_all`
FROM FILES (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_adept-storm-375515/data/green/green_tripdata_20*.csv.gz']);

--insert fhv data from gcs to bq
LOAD DATA OVERWRITE `dezoomcamp.fhv_tripdata_all`
FROM FILES (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_adept-storm-375515/data/fhv/fhv_tripdata_201*.csv.gz']);


dbt run --var 'is_test_run: false'

--count
SELECT COUNT(*) FROM `dezoomcamp.rides_yellow_all`
--109.047.518

SELECT COUNT(*) FROM `dezoomcamp.rides_green_all`
--7.778.101

SELECT COUNT(*) FROM `dezoomcamp.fhv_tripdata_all`

-- Question 1
SELECT COUNT(*) FROM adept-storm-375515.dbt_aangelakis.fact_trips
WHERE pickup_datetime >= '2019-01-01' AND pickup_datetime < '2021-01-01'
--61.648.442

-- Question 2
SELECT
service_type,
COUNT(*)
FROM adept-storm-375515.dbt_aangelakis.fact_trips
WHERE pickup_datetime >= '2019-01-01' AND pickup_datetime < '2021-01-01'
GROUP BY service_type

-- Question 3
SELECT COUNT(*) FROM`dezoomcamp.fhv_tripdata_all`
WHERE pickup_datetime >= '2019-01-01' AND pickup_datetime < '2020-01-01'
--43.244.696

-- Question 4 (Enhanced model with INNER JOINS for known zones)
SELECT COUNT(*) FROM`adept-storm-375515.dbt_aangelakis.fact_fhv_trips`
WHERE pickup_datetime >= '2019-01-01' AND pickup_datetime < '2020-01-01'
--22.998.722

-- Question 5 (Validate with SQL)
SELECT 
EXTRACT(MONTH FROM pickup_datetime),
COUNT(*) AS total_rides
FROM`adept-storm-375515.dbt_aangelakis.fact_fhv_trips`
GROUP BY  EXTRACT(MONTH FROM pickup_datetime)
ORDER BY total_rides DESC


