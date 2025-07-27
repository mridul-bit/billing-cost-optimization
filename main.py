import os
import json
import gzip
import boto3
from datetime import datetime, timedelta
from azure.cosmos import CosmosClient

COSMOS_ENDPOINT = os.environ["COSMOSDB_ENDPOINT"]
COSMOS_KEY = os.environ["COSMOSDB_KEY"]
COSMOS_DB = os.environ["COSMOSDB_DB"]
COSMOS_CONTAINER = os.environ["COSMOSDB_CONTAINER"]
DYNAMO_TABLE = os.environ.get("DYNAMO_TABLE", "billing-records-metadata")
S3_BUCKET = os.environ.get("S3_BUCKET", "cold-billing-archive-data")

dynamodb = boto3.client("dynamodb")
s3 = boto3.client("s3")


COSMOS_CUTOFF_DAYS = 90

def is_uploaded(billing_id):
    response = dynamodb.get_item(
        TableName=DYNAMO_TABLE,
        Key={"billing_id": {"S": billing_id}}
    )
    return "Item" in response

def upload(record):
    billing_id = record["billing_id"]
    billing_key = f"{billing_id}.json.gz"

    compressed_data = gzip.compress(json.dumps(record).encode("utf-8"))

    s3.put_object(
        Bucket=S3_BUCKET,
        Key=billing_key,
        Body=compressed_data,
        ContentEncoding="gzip",
        ContentType="application/json"
    )

    dynamodb.put_item(
        TableName=DYNAMO_TABLE,
        Item={
            "billing_id": {"S": billing_id},
            "billing_key": {"S": billing_key},
            "archived_at": {"S": datetime.utcnow().isoformat()}
        }
    )
    container.delete_item(item=record, partition_key=record["billing_id"])



cosmos_client = CosmosClient(COSMOS_ENDPOINT, COSMOS_KEY)
database = cosmos_client.get_database_client(COSMOS_DB)
container = database.get_container_client(COSMOS_CONTAINER)



def handler(event, context):
    cutoff_date = datetime.utcnow() - timedelta(days=COSMOS_CUTOFF_DAYS)
    query = f"SELECT * FROM c WHERE c.timestamp < '{cutoff_date.isoformat()}'"

    result = container.query_items(
        query=query,
        enable_cross_partition_query=True,
        max_item_count=100
    )

    total_uploaded = 0

    for record in result:
        billing_id = record["billing_id"]

        if is_uploaded(billing_id):
            print(f"[SKIP] {billing_id} already uploaded")
            continue

        try:
            upload(record)
            print(f"[OK] {billing_id} uploaded")
            total_uploaded += 1
        except Exception as e:
            print(f"[FAIL] Upload failed for {billing_id}: {e}")
            break

    print(f"Total records uploaded: {total_uploaded}")

