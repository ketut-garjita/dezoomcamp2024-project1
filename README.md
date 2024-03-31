# DE Zoomcamp 2024 - Project1 
retailrocket-ecommerce-batch
This repository contains a brief description of my DE Zoomcamp 2024 Project 1

## Problem statement

The Retailrocket t has collected a large dataset of E-commerce i.e  a file with behaviour data (events.csv), a file with item properties (item_properties.сsv) and a file, which describes category tree (category_tree.сsv). The data has been collected from a real-world ecommerce website. It is raw data, i.e. without any content transformations, however, all values are hashed due to confidential issues. The purpose of publishing is to motivate researches in the field of recommender systems with implicit feedback.  The goal of this project is to create a streamlined and efficient process for analyzing e-commerce by implementing Data Engineering process flows basics.

## About the Dataset
[Retailrocket recommender system](https://www.kaggle.com/datasets/retailrocket/ecommerce-dataset) 

The dataset consists of three context files i.e. : 
1. a file with behaviour data (events.csv)
2. a file, which describes category tree (category_tree.сsv).
3. a file with item properties (item_properties_part1.сsv & item_properties_part2.csv)

The data has been collected from a real-world ecommerce website. It is raw data, i.e. without any content transformations, however, all values are hashed due to confidential issues.

The behaviour data, i.e. events like clicks, add to carts, transactions, represent interactions that were collected over a period of 4.5 months. A visitor can make three types of events, namely **view**, **addtocart** or **transaction**. 

## Technologies / Tools
- Containerisation : Docker
- Cloud : GCP
- Infrastructure as code (IaC) : Terraform
- Workflow orchestration : Mage-ai
- Data Warehouse : BigQuery
- Batch processing : pyspark
- IDE : VS Code, Jupyter Notebook
- Language : Python
- Visualisation : Google Looker Studio

## Project Architecture

Kaggle dataset is downloaded into the Google VM, then ingested to Google Cloud Storage Buecket as Data Lake. Next, the data will be stored in BigQuery as a Data Warehouse. All data flows are executed using the Mage-ai workflow orchestration tool. A Spark job is run on the data stored in the Google Storage Buecket or in BigQuery.
The results are written to a dafaframe and/or table in Postgres. A dashboard is created from the Looker Studio.

The end-to-end data pipeline includes the below steps:
- Kaggle dataset is downloaded into the Google VM
- The downloaded CSV files (raw) are then uploaded to a folder in Google Cloud bucket (parquet) as Data Like
- Next, the data will be stored in BigQuery as a Data Warehouse
- A new table is created from this original table with correct data types as well as partitioned by Month and Clustered by type of event for optimised performance
- Spin up a dataproc clusters (amster and worker) and execute the pyspark jobs for procusts analys purposes
- Configure Google Looker Studio to power dashboards from BigQuery Data Warehouse tables

You can find the detailed Architecture on the diagram below:

![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/160d7dfe-0ef3-4cf9-9cf4-8d01684603bb)


## Reproducing from Scratch

### Setup GCP
- Create GCP Account.
- Setup New Project and write down your Project ID.
- Configure service account to get access to the project and download auth-keys (.json). Change auth-keys name if required.
  Please provide the service account the permissions below (*sorted by name*):
  ```
  1. BigQuery Admin
  2. Cloud SQL Client
  3. Compute Admin
  4. Compute Engine Service Agent
  5. Compute Network Admin
  6. Compute Storage Admin
  7. Dataproc Service Agent
  8. Editor
  9. Logs Bucket Writer
  10. Owner
  11. Storage Admin
  12. Storage Object Admin
  ```
      
- Enable the following options under the APIs and services section:
  1. Identity and Access Management (IAM) API
  2. IAM service account credentials API
  3. Compute Engine API (if you are going to use VM instance)

### Terraform as Internet as Code (IaC) to build infrastructure
- Download Terraform from here: [https://www.terraform.io/downloads](https://www.terraform.io/downloads)
- Under terraform folder, create files main.tf (required) and variables.tf (optional) to store terraform varaibels
- main.td contents
  1. Google Provider Versions
  2. resource "google_service_account"
  3. resource "google_project_iam_member"
  4. resource "google_compute_firewall"
  5. resource "google_storage_bucket"
  6. resource "google_storage_bucket_iam_member"
  7. resource "google_bigquery_dataset"
  8. resource "google_dataproc_cluster" (cluster_config : master_config, worker_config, software_config : image_version = "2.2.10-debian12"
      optional_components   = ["DOCKER", "JUPYTER"])
  

terraform init
terraform plan
terraform apply
If you would like to remove your stack from the Cloud, use the terraform destroy command.

## Dashboard

![locker-studio2](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/73839329-bb0a-426e-bb95-44da5718504c)

![locker-studio1](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/4ca8c142-1f90-4514-ab90-f5241f04f6ef)


## Reproducibility

After terrafor apply:

![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/328db997-ca2e-4589-be7b-55b91a3e5f9e)

![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b0b4c8b8-84bb-40fa-bdde-cd1a517ba399)

![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b2ab4aaf-24db-49cc-9d35-c828777bb4e3)

![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/096daaa8-c50d-44bf-8dcb-c6f0b9e30b9b)

Assign the new external IP address to the VM.
- gcloud compute instances add-access-config project1-dataproc-m --access-config-name="project1-dataproc-m-config"
- gcloud compute instances add-access-config project1-dataproc-w-0 --access-config-name="project1-dataproc-m-config"
- gcloud compute instances add-access-config project1-dataproc-w-1 --access-config-name="project1-dataproc-m-config"

  
Copy execute-shell.sh into bucket

Lohin via ssh of master vm:
![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/1c59d592-e8ed-45dd-9149-30327885463d)

gsutil cp repositories.sh gs://semar-bucket

gsutil cp gs://semar-bucket/repositories.sh .

chmod +x repositories.sh

sudo ./repositories.sh

Check mage :

![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b3906b1d-0b46-4166-af52-525f86b60a0c)

Check pgadmin :

![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/03991861-af32-4840-9d9d-d06f476da686)

 jupyter-notebook  --port=8888 --ip=0.0.0.0 --no-browser

 ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/e78fc04d-9055-4aeb-ac27-5b877a99e1ec)


jupyter notebook --generate-config

/home/smrhitam/.jupyter/jupyter_notebook_config.py

![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/2464f7a3-aad7-4514-add2-412e36321bff)

hdfs dfs -mkdir /user/smrhitam

hdfs dfs -copyFromLocal  ecommerce-dataset/ /user/smrhitam

kaggle key jason
```
import os
import json

# Define the content of the kaggle.json file
data = {
    "username": "ketutgarjita",
    "key": "105b7cfe0e35251e4f61267478ae09f3"
}

# Convert the data to a JSON string
json_string = json.dumps(data)

# Put the JSON string into the /home/src
file1 = open('/home/src/kaggle.json', 'w')
file1.write(json_string)
file1.close()

# Set appropriate permissions on the kaggle.json file
os.system("chmod 600 /home/src/kaggle.json")
```





/home/smrhitam/.jupyter/jupyter_notebook_config.py
