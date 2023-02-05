from pathlib import Path
import pandas as pd
from prefect import flow, task
from prefect_gcp.cloud_storage import GcsBucket
from prefect_gcp import GcpCredentials


@task(retries=3)
def extract_from_gcs(color: str, year: int, month: int) -> Path:
    """Download trip data from GCS"""
    gcs_path = f"data/{color}/{color}_tripdata_{year}-{month:02}.parquet"
    gcs_block = GcsBucket.load("zoom-gcs")
    gcs_block.get_directory(from_path=gcs_path, local_path=f"../data/")
    return Path(f"../data/{gcs_path}")


@task()
def transform(path: Path) -> pd.DataFrame:
    """Data cleaning example"""
    df = pd.read_parquet(path)
    print(f"pre: missing passenger count: {df['passenger_count'].isna().sum()}")
    return df


@task()
def write_bq(df: pd.DataFrame,color: str) -> None:
    """Write DataFrame to BiqQuery"""

    gcp_credentials_block = GcpCredentials.load("zoom-gcp-creds")

    df.to_gbq(
        destination_table= f"dezoomcamp.rides_{color}",
        project_id="adept-storm-375515",
        credentials=gcp_credentials_block.get_credentials_from_service_account(),
        chunksize=500_000,
        if_exists="append",
    )


@flow()
def etl_gcs_to_bq():
    """Main ETL flow to load data into Big Query"""
    color = ["yellow","green"]
    total_rows_green = 0
    total_rows_yellow = 0 
    for x in color: 
        if x == "green":
            year = 2020
            month = 1
            path = extract_from_gcs(x, year, month)
            df = transform(path)
            write_bq(df,x)
            total_rows_green = total_rows_green + len(df)
        elif x == "yellow":
            year = 2019
            month = [2,3]
            for y in month:
                path = extract_from_gcs(x, year, y)
                df = transform(path)
                write_bq(df,x)
                total_rows_yellow = total_rows_yellow + len(df)
        else:
            raise Exception("Sorry, there's no such file")

    print('Total processed rows for yellow:', total_rows_yellow)
    print('Total processed rows for green:', total_rows_green)

if __name__ == "__main__":
    etl_gcs_to_bq()