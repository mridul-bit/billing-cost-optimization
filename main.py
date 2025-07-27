import os
import json
import gzip
import boto3
from datetime import datetime, timedelta
from azure.cosmos import CosmosClient

# env variables and clients
COSMOS_ENDPOINT = os.environ["COSMOSDB_ENDPOINT"]
COSMOS_KEY = os.environ["COSMOSDB_KEY"]
COSMOS_DB = os.environ["COSMOSDB_DB"]
COSMOS_CONTAINER = os.environ["COSMOSDB_CONTAINER"]
DYNAMO_TABLE = os.environ.get("DYNAMO_TABLE", "billing-records-metadata")
S3_BUCKET = os.environ.get("S3_BUCKET", "cold-billing-archive-data")

dynamodb = boto3.client("dynamodb")
s3 = boto3.client("s3")


cosmos_client = CosmosClient(COSMOS_ENDPOINT, COSMOS_KEY)
container = cosmos_client.get_database_client(COSMOS_DB).get_container_client(COSMOS_CONTAINER)

# 90  days
cutoff_date = datetime.utcnow() - timedelta(days=90)

def handler(event, context):
    print(f"Starting archival for records older than {cutoff_date.isoformat()}")

    # Cosmos DB SQL query to fetch old records
    query = f"SELECT * FROM c WHERE c.timestamp < '{cutoff_date.isoformat()}'"
    archived = 0

    # Loop through matching records
    for record in container.query_items(query=query, enable_cross_partition_query=True):
        try:
            billing_id = record["id"]

            # Format S3 key by year/month/id
            s3_key = f"{billing_id}.json.gz"

            # Compress data using gzip
            compressed_data = gzip.compress(json.dumps(record).encode("utf-8"))

            # Upload compressed data to S3
            s3.put_object(
                Bucket=S3_BUCKET,
                Key=s3_key,
                Body=compressed_data,
                ContentType="application/json",
                ContentEncoding="gzip"
            )

            # Add metadata to DynamoDB 
            dynamodb.put_item(
                TableName=DYNAMO_TABLE,
                Item={
                    "billing_id": {"S": billing_id},
                    "s3_key": {"S": s3_key}
                }
            )

            archived += 1

        except Exception as e:
            print(f"Error processing record {record.get('id')}: {e}")

    print(f"Archived {archived} records.")
    return {"archived": archived}

