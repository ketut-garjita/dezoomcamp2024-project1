# retailrocket-ecommerce-batch
This repository contains a brief description of my DE Zoomcamp Project 1.

## Problem statement

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
- Data Wareshouse : BigQuery
- Batch processing : pyspark
- Visualisation : Google Data Studio

## About the Project

Github Archive data is ingested daily into the AWS S3 buckets from 1st of May.
A Spark job is run on the data stored in the S3 bucket using AWS ElasticMapReduce (EMR)
The results are written to a table defined in Redshift.
A dashboard is created from the Redshift tables.

## Dashboard

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

![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/160d7dfe-0ef3-4cf9-9cf4-8d01684603bb)



/home/smrhitam/.jupyter/jupyter_notebook_config.py
