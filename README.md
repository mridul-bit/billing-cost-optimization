# 🧊 Cold Data Cost Optimization for Azure CosmosDB using AWS
 > **Use Case:** Reduce cost of rarely accessed billing records stored in Azure CosmosDB using a fully serverless, automated AWS services.

---

## 📌 Problem Statement

A service currently stores billing records (up to 300 KB each) in **Azure Cosmos DB**. The system is **read-heavy**, but:
- Records **older than 90 days** are **rarely accessed**
- Over **2 million records** now reside in CosmosDB
- This leads to **high storage and read costs** in Azure

- You **CANNOT modify** existing APIs or core app logic

- You **MUST** ensure:  
  - No downtime ✅  
  - No data loss ✅  
  - High availability ✅  
  - API compatibility ✅  
  - Full automation ✅  

---

## ✅ Solution

We’ve implemented a **serverless data archival solution** using AWS that:
- **Extracts and compresses** cold billing records from Azure CosmosDB
- **Stores them in S3 (Intelligent-Tiering)** with encryption and versioning
- **Indexes metadata** in DynamoDB for fast lookups
- **Fully automates ETL using Lambda + EventBridge**
- Ensures **low cost, high durability, and on-demand access** without changing API contracts

---
                        +---------------------+
                        |  Azure Cosmos DB    |
                        +----------+----------+
                                   |
                                   | (90-day filter)
                                   v
   +-----------------+    +--------+--------+     +-------------------------+
   | EventBridge     +--> |  AWS Lambda     +---> |  S3 (Intelligent Tier)  |
   | (Daily Trigger) |    |  Archival Logic |     |  + gzip compressed JSON |
   +-----------------+    +--------+--------+     +-------------------------+
                                   |
                                   v
                         +---------+--------+
                         | DynamoDB Metadata|
                         | (billing_id→s3)  |
                         +------------------+


---

## 🧠 Steps to Achieve the Solution

### 1. **S3 Intelligent tier bucket Bucket**
- Stores old CosmosDB records in **gzip-compressed JSON**
- Configured with:
  - Server-side encryption (AES256)
  - Intelligent Tiering for automatic cost savings
  - Public access fully blocked
  - Versioning enabled

### 2. **DynamoDB Metadata Index**
- Stores:
  - `billing_id`
  - `s3_key`
- Enables fast lookup and retrieval of cold records

### 3. **Lambda Worker**
- Written in Python (`main.py`)
- Runs every day (via EventBridge)
- Logic:
  - Connect to CosmosDB
  - Query records older than 90 days
  - Gzip + upload to S3
  - Save `billing_id → s3_key` mapping to DynamoDB

### 4. **EventBridge Schedule**
- Triggers the Lambda **once daily**
- No manual runs or cron jobs needed

### 5. **IAM Role & Policy**
- Lambda execution role has **minimum required permissions**:
  - DynamoDB: `GetItem`, `PutItem`, `Query`, `UpdateItem`
  - S3: `GetObject`, `PutObject`, `ListBucket`
  - CloudWatch Logs: for logging and monitoring

---

## 🔐 Security & Best Practices

- ✅ S3 bucket is **private, encrypted, and versioned**
- ✅ DynamoDB uses **on-demand billing** to reduce idle cost
- ✅ Lambda is scoped to minimum required IAM privileges
- ✅ No hardcoded credentials — all CosmosDB details injected via environment variables at deploy time
- ✅ `terraform apply` injects secrets using `-var` flags

---

## 🚀 How to Use This Repo

### 1. ✅ Prerequisites

- AWS CLI configured with permissions
- Terraform v1.6.6+ installed
- Python 3.12
- Azure CosmosDB read-only access credentials
-  The `lambda.zip` is already included in this repo. You only need to re-zip if you change the Lambda code. lambda.zip contains the handler functions.

### 2. ✅ Set-up
- clone repo using git clone

### 3. ✅ Prerequisites


terraform init

terraform apply \
  -var="cosmosdb_endpoint=YOUR_ENDPOINT" \
  -var="cosmosdb_key=YOUR_KEY" \
  -var="cosmosdb_db=YOUR_DB" \
  -var="cosmosdb_container=YOUR_CONTAINER"


