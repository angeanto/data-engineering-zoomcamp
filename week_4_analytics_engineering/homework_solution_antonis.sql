LOAD DATA OVERWRITE `ny_rides_3.fhv_tripdata_2019`
FROM FILES (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_adept-storm-375515/data/fhv/fhv_tripdata_2019-*.csv.gz']);

LOAD DATA OVERWRITE `ny_rides_3.fhv_tripdata_2020`
FROM FILES (
  format = 'CSV',
  uris = ['gs://dtc_data_lake_adept-storm-375515/data/fhv/fhv_tripdata_2020-*.csv.gz']);

SELECT MIN(lpep_pickup_datetime),MAX(lpep_pickup_datetime)  FROM adept-storm-375515.dezoomcamp.rides_green
SELECT MIN(tpep_pickup_datetime),MAX(tpep_pickup_datetime)  FROM adept-storm-375515.dezoomcamp.rides_yellow