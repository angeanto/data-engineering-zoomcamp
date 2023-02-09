--inserted native data manually and 
--imsert data after loading them to gcs
CREATE OR REPLACE EXTERNAL TABLE `ny_rides_3.fhv_tripdata`
OPTIONS (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_adept-storm-375515/data/fhv/fhv_tripdata_2019-*.csv.gz']
);

--imsert data after loading them to gcs
CREATE OR REPLACE TABLE `ny_rides_3.fhv_tripdata_not_external`
OPTIONS (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_adept-storm-375515/data/fhv/fhv_tripdata_2019-*.csv.gz']
);

-- Validate the min and max date
SELECT MIN(pickup_datetime),MAX(pickup_datetime)  FROM `ny_rides_3.fhv_tripdata`

-- Question 1
SELECT COUNT(*) FROM `ny_rides_3.fhv_tripdata`

-- Question 2
SELECT COUNT(DISTINCT(Affiliated_base_number)) FROM ny_rides_3.fhv_tripdata
--2.52.GB

-- Question 2
SELECT COUNT(DISTINCT(Affiliated_base_number)) FROM adept-storm-375515.ny_rides_3.fhv_tripdata_normal_table
--2.52.GB

-- Question 3
SELECT COUNT(*) FROM adept-storm-375515.ny_rides_3.fhv_tripdata_normal_table
WHERE DOlocationID IS NULL AND PUlocationID IS NULL

-- Question 4
--partition by and cluster by since we filter by date

-- Question 5
SELECT COUNT(DISTINCT(Affiliated_base_number)) FROM  adept-storm-375515.ny_rides_3.fhv_tripdata_normal_table
WHERE pickup_datetime BETWEEN '2019-03-01' AND '2019-03-31'
--647.87

CREATE OR REPLACE TABLE adept-storm-375515.ny_rides_3.fhv_tripdata_normal_table_partitioned
PARTITION BY DATE(pickup_datetime)
CLUSTER BY dispatching_base_num AS (
  SELECT * FROM adept-storm-375515.ny_rides_3.fhv_tripdata_normal_table
);

SELECT COUNT(DISTINCT(Affiliated_base_number)) FROM  adept-storm-375515.ny_rides_3.fhv_tripdata_normal_table_partitioned
WHERE pickup_datetime BETWEEN '2019-03-01' AND '2019-03-31'
--647.87

-- Question 6
-- Data is stored in the GCS bucket