# DE Zoomcamp 2024 - Project1 

This repository contains a brief description of my DE Zoomcamp 2024 Project 1

## Problem statement

This project is part of the requirements for the Data Engineering Zoomcamp 2024 course. The chosen topic focuses on Retailrocket E-commerce.

Retailrocket has collected a large dataset of e-commerce data, which includes:

A file with behavioral data (events.csv),
A file with item properties (item_properties.csv), and
A file describing the category tree (category_tree.csv).
The dataset was gathered from a real-world e-commerce website and remains in its raw form, meaning no content transformations have been applied. However, all values have been hashed to address confidentiality concerns.

The purpose of publishing this dataset is to motivate research in the field of recommender systems with implicit feedback.

The goal of this project is to create a streamlined and efficient process for ingesting and analyzing e-commerce data in the Cloud by applying Data Engineering concepts.


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
- Batch processing : spark SQL
- IDE : VS Code, Jupyter Notebook
- Language : Python
- Visualisation : Google Looker Studio

## Project Architecture

The end-to-end data pipeline includes the below steps:
- Kaggle dataset is downloaded into the Google VM.
- The downloaded CSV files (raw) are then uploaded to a folder in Google Cloud bucket (parquet) as Data Lake.
- Next, the data will be stored in BigQuery with format and values same as the GCP bucket files.
- Last new tables are created from those original tables by using Spark SQL with correct data types as well as partitioned by Month and Clustered for optimised performance. These tables would be Data Warehouse tables. 
- Spin up a dataproc clusters (master and worker) and execute the pyspark jobs for procusts analys purposes
- Configure Google Looker Studio to power dashboards from BigQuery Data Warehouse tables

You can find the detailed Architecture on the diagram below:

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/9f7acc61-df73-4484-bf66-ecbcfb5fe4f4)


## Reproducing from Scratch

### Setup GCP
- Create GCP Account.
- Setup New Project and write down your Project ID.
- Configure Service Account to get access to the project and download auth-keys (.json). Change auth-keys name if required.
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
  ```
  1. Identity and Access Management (IAM) API
  2. IAM service account credentials API
  3. Cloud Dataproc API
  4. Compute Engine API (if you are going to use VM instance)
  ```
  

### Terraform as Internet as Code (IaC) to build infrastructure
- Download Terraform from here: [https://www.terraform.io/downloads](https://www.terraform.io/downloads)
- Under terraform folder, create files **main.tf** (required) and **variables.tf** (optional) to store terraform variables. 
- main.td containt the following resources want to be applied:
  ```
  1. Google Provider Versions
  2. resource "google_service_account"
  3. resource "google_project_iam_member"
  4. resource "google_compute_firewall"
  5. resource "google_storage_bucket"
  6. resource "google_storage_bucket_iam_member"
  7. resource "google_bigquery_dataset"
  8. resource "google_dataproc_cluster" (cluster_config : master_config, worker_config, software_config : image_version = "2.2.10-debian12"
      optional_components   = ["DOCKER", "JUPYTER"])
  ```
- **terraform init** or **terraform init -upgrade**: command initializes the directory, downloads, teh necesary plugins for the cinfigured provider, and prepares for use.
- **terraform plan** : too see execution plan
- **terraform apply** : to apply the changes
  
If you would like to remove your stack from the Cloud, use the **terraform destroy** command.


### Reproducibility

#### Assign External IP Address

After terraform apply complete succeesfully, assign External IP Address for Master and Workers instances using Console.

From VM Instance (Compute Engine) --> SSH
    
![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/2d4ff3e3-a28a-4739-a17c-39d64ae4683e)
  
![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/b67244eb-3b31-4f7d-ada6-76f261ba1887)
    
![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b0b4c8b8-84bb-40fa-bdde-cd1a517ba399)
    
![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b2ab4aaf-24db-49cc-9d35-c828777bb4e3)
    
![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/096daaa8-c50d-44bf-8dcb-c6f0b9e30b9b)
  
  
#### Setting up Mage-ai, PostgreSQL and pgAdmin through the Master VM Instance SSH.

Copy **repositories.sh** into VM. The repositories.sh is script for installing docker network and bring up docker containers of Mage-ai, postgresql and pgAdmin.
  ```
  #############Install Docker network#############
  #create a network most containers will use
  sudo docker network create dockernet >> /root/dockernet.log
  sudo docker network ls >> /root/dockernet.log
  
  #############Bring up docker containers############
  cat > /root/docker-compose.yml <<- "SCRIPT"
  
  version: '3'
  services:
    magic:
      image: mageai/mageai:latest
      command: mage start dezoomcamp
      container_name: dezoomcamp-mage
      build:
        context: .
        dockerfile: Dockerfile
      environment:
        USER_CODE_PATH: /home/src/dezoomcamp
        POSTGRES_DBNAME: dezoomcampdb
        POSTGRES_SCHEMA: public
        POSTGRES_USER: postgres
        POSTGRES_PASSWORD: <password>
        POSTGRES_HOST: vm-ikg-dezoomcamp
        POSTGRES_PORT: 5432
      ports:
        - 6789:6789
      volumes:
        - .:/home/src/
      restart: on-failure:5
    postgres:
      image: postgres:14
      restart: on-failure
      container_name: dezoomcamp-postgres
      environment:
        POSTGRES_DB: dezoomcampdb
        POSTGRES_USER: postgres
        POSTGRES_PASSWORD: <password>
      ports:
        - 5432:5432
    pgadmin:
      image: dpage/pgadmin4
      container_name: dezoomcamp-pgadmin
      environment:
        - PGADMIN_DEFAULT_EMAIL=admin@admin.com
        - PGADMIN_DEFAULT_PASSWORD=<password>
      ports:
        - 8080:80
        
  SCRIPT
  
  sudo docker compose -f /root/docker-compose.yml up -d
  ```

  *Note : provide password in repositories.sh file above*
  
  ```
  chmod +x repositories.sh
  sudo ./repositories.sh
  ```

  ==> *Mage-ai, postgresql and pgAdmin would be installed and up running.*

  Check mage-ai:
  
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b3906b1d-0b46-4166-af52-525f86b60a0c)
  
  Check pgadmin :
  
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/03991861-af32-4840-9d9d-d06f476da686)

  
  #### Restart Juypyer Notebook

  Stop :
  
  ```
  sudo systemctl stop jupyter
  ```
    
  Start by using port 8888 :
  
  ```
  jupyter-notebook  --port=8888 --ip=0.0.0.0 --no-browser
  ```
  
  Note: we use 0.0.0.0 just for demo purpose. Don't use this in production!
  
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/e78fc04d-9055-4aeb-ac27-5b877a99e1ec)

  Increase memory size for cluster if required, and then restart Jupyter Notebook

  ```
  jupyter notebook --generate-config
  ```

  Open /home/<some_folder>/.jupyter/jupyter_notebook_config.py 

  Edit file and modify parameter: **c.NotebookApp.max_buffer_size**

  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/2464f7a3-aad7-4514-add2-412e36321bff)

  Delete # character

#### Spark master and worker clusters

Edit ~/.bashrc file and add lines below:
  
 ```
export SPARK_HOME=/usr/lib/spark
export PATH=$SPARK_HOME/bin:$SPARK_HOME/sbin:$PATH
```

source ~/.bashrc

which start-all.sh
  
Start master and worker clusters
  
```
start-all.sh
```

Try run spark by using dataset on hdfs
  
Copy dataset folder into /user/<some_folder>
  
```
hdfs dfs -mkdir /user/<some_folder>
hdfs dfs -copyFromLocal ecommerce-dataset/ /user/<some_folder>
```

Login to Master Cluster web

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/cc931295-eca6-4bd7-8e20-b39bb5ef1213)

Login to Worker Cluster web

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/b9ac3c09-8016-47ac-a854-243a5d1d2f72)


## Mage-ai orchestration pipelines

Create two runtime variables: bucket_name and dataset. These variables used by all pipeline blocks.

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/6b1e3ff7-c0dd-4dd1-ba8a-f242e9a075ae)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/68e003cb-3c92-4535-b31f-b493578e3666)

Pipeline and its blocks available in mage-project1.tar files.
- Put mage-project1.tar into VM. You must have file copy authority to the master VM.

  ```
  gcloud auth login
  gcloud config set project <project_name>
  ```

  *allow to access of your google account*
  
  ```
  gcloud compute scp mage-project1.tar <username>@<project_name>:/home/<username>
  ```
  
- Open SSH on Master instance
- Copy mage-project1.tar into mage container (in this project named: dezoomcamp-mage)

  ```
  docker cp mage-project1.tar <mage_container>:/home/src/dezoomcamp 
  ```
  
- Go to mage container

  ```
  docker exec -it <mage_container> bash
  ```
  
- Extract (untar) mage-project.tar file

  ```
  cd /home/src/dezoomcamp
  tar -xvf mage-project1.tar
  ```
  
- Open Mage application website : http://<master_external_ip_address>:6789 

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/780553c9-a6af-4c34-b9f5-7559947b4fd1)

Because there is a limited memory size on the VM instance (only 8 GB), I load data one block per table.

Memory used for hadoop dfs, hadoop yarn, spark, hive, docker containers, jupyter-notebook services. 

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/61b8da66-962c-40e8-91b8-b01fd8246bdd)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/278928b2-9fea-4814-8fe7-c5ab8385a900)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/b1b6ef82-babb-41b8-9cad-db1b61464d30)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/540aaf85-6d86-4e96-88f8-a8bba47d8939)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/87ab35b1-bee4-4774-9caa-62f9d410c41f)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/ead83ef3-993f-4892-8786-637208b9aba1)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/301645ce-82a6-4f62-934d-06cb8b208d0c)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/b43880ee-cdc4-41f6-a6a9-254a9c203a18)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/01cbbf9a-1f74-422d-96c4-a803a04651af)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/54a06a8a-192b-4029-882e-feee61b5fb6b)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/e9db7e2e-6282-499b-bb96-b6252035d0f8)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/35b761b9-2377-4312-b43e-d37bca75dc43)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/a6f1a529-cbf2-42db-88ee-5ab21923a8b0)

- Running the Mage pipeline

  Because my VM instance memory has limited memory (only 8 GB), to get more free memory, the services below will be stopped to allow the running pipeline process to run smoothly:
    - sudo systemctl stop mysql
    - sudo systemctl stop jupyter
    - sudo systemctl stop spark-history-server.service
    - sudo systemctl stop hive-metastore.service hive-server2.service
    - sudo systemctl stop hadoop-mapreduce-historyserver.service
    - sudo systemctl stop hadoop-yarn-resourcemanager.service 
    - sudo systemctl stop	hadoop-yarn-timelineserver.service
    - sudo systemctl stop hadoop-hdfs-secondarynamenode.service
    - sudo systemctl stop hadoop-hdfs-namenode.service

    ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/9d2c075f-90f5-49c0-9223-690d6d67055c)

Now we have more free memory available.
  
These services would start automaticcaly when Cluster and VM Instances started.

To run a Mage pipeline once, you can do so by setting up a trigger with the schedule type set to "@once". This can be achieved by navigating to the pipeline’s trigger page in the Mage UI, and selecting the [Run @once] option in the page’s subheader. This action creates a trigger that executes the pipeline a single time immediately.

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/867a1e99-25b7-434a-a40a-5328e66b5910)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/049d47c8-917a-4f87-8dd3-c74479b743d3)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/897c6e4c-6210-4712-85ab-86b54b7c469b)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/2c48afda-f091-4a13-8fb9-8c249aaaf204)


## Check Outputs

- Files in VM instance

  ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/7d5fb69e-cf99-40fe-b6b1-403a9e7ee537)

- Files in GCS bucket

  ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/7b571e9b-8f80-40e6-a807-40259837d8f5)

  ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/e2644476-3161-4c5b-bac6-0ae8f3b0b2aa)

- BigQuery Tables

  ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/ffee0f9c-d474-4711-8a0c-10fcb1bf3ef5)

  *category_tree*

  ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/8f2de205-6e36-4787-9119-b14b336092c0)

  *events preview*

  ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/4504b276-41de-4281-bb8d-9e80f7eea1b8)

  *item_properties preview*

  ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/e3709b62-e099-4a65-b137-cf521f134aa5)

- Convert unix timestamp of timestamp column to datetime 'yyyy-MM-dd hh:mm:dd' format on events and item_properties tables

  - Start Cluster on Console
  - Stop and Start VM Instances (Master and Workers)
  - Open Master SSH
  
    Restart jupyter-notebook

    ```
    sudo systemctl stop jupyter
    jupyter-notebook --port=8888 --ip=0.0.0.0 --no-browser
    ```

  - Run script below on Jupyter-Notebook editor
 
    Script link:
    https://github.com/garjita63/dezoomcamp2024-project1/blob/main/trasnform_dwh_tables.ipynb

    *Make sure you have free enough disk space on VM*
    
    ```
    # Transform events table into events_dwh
    # from_unixtime --> datetime (yyyy-MM-DD HH:mm:ss)
    # Run in Cloud Jupyter Notebook
    
    import pyspark
    from pyspark.sql import SparkSession
    from pyspark.conf import SparkConf
    from pyspark.context import SparkContext
    
    # credentials_location = '/root/.google/credentials/google-creds.json'
    
    
    conf = SparkConf() \
        .setAppName('events') \
        .set("spark.jars", "/usr/lib/spark/jars/gcs-connector-hadoop3-latest.jar") \
        .set("spark.hadoop.google.cloud.auth.service.account.enable", "true") 
    #    .set("spark.hadoop.google.cloud.auth.service.account.json.keyfile", credentials_location)
    
    spark = SparkSession.builder.config(conf=conf).getOrCreate()
    
    project_id = "<project_name>"
    dataset_id = "project1"
    table_source = "events"
    
    df = spark.read.format('bigquery') \
        .option("temporaryGcsBucket","dataproc-temp-asia-southeast2-212352110204-1oi7hped") \
        .option("project", project_id) \
        .option("dataset", dataset_id) \
        .load(table_source)
        
    df.createOrReplaceTempView("temp_events")
    
    events_transform = spark.sql("""
    select from_unixtime((timestamp / 1000), "yyyy-MM-dd HH:mm:ss") as timestamp, 
        visitorid, event, itemid, transactionid
    from temp_events
    """)
    
    events_transform.show()
    
    project_id = "<project_name>"
    dataset_id = "project1"
    table_target = "events_dwh"
    parttition_column = "DATE_FORMAT(timestamp, 'yyyy-MM')"
    cluster_column = "event"
    
    events_transform.write \
        .format("bigquery") \
        .option("temporaryGcsBucket","dataproc-temp-asia-southeast2-212352110204-1oi7hped") \
        .option("table", f"{project_id}.{dataset_id}.{table_target}") \
        .option("PARTITION BY",  parttition_column) \
        .option("CLUSTER BY", cluster_column) \
        .mode('Overwrite') \
        .save()
    
    # Stop Spark session
    spark.stop()
    ```
  
    ```
    # Transform item_properties table into item_properties_dwh
    # from_unixtime --> datetime (yyyy-MM-DD HH:mm:ss)
    # Run in Cloud Jupyter Notebook
    
    import pyspark
    from pyspark.sql import SparkSession
    from pyspark.conf import SparkConf
    from pyspark.context import SparkContext
    
    # credentials_location = '/root/.google/credentials/google-creds.json'
    
    
    conf = SparkConf() \
        .setAppName('item_properties') \
        .set("spark.jars", "/usr/lib/spark/jars/gcs-connector-hadoop3-latest.jar") \
        .set("spark.hadoop.google.cloud.auth.service.account.enable", "true") 
    #    .set("spark.hadoop.google.cloud.auth.service.account.json.keyfile", credentials_location)
    
    spark = SparkSession.builder.config(conf=conf).getOrCreate()
    
    project_id = "<project_name>"
    dataset_id = "project1"
    table_source = "item_properties"
    
    df = spark.read.format('bigquery') \
        .option("temporaryGcsBucket","dataproc-temp-asia-southeast2-212352110204-1oi7hped") \
        .option("project", project_id) \
        .option("dataset", dataset_id) \
        .load(table_source)
        
    df.createOrReplaceTempView("temp_item_properties")
    
    item_properties_transform = spark.sql("""
    select from_unixtime((timestamp / 1000), "yyyy-MM-dd HH:mm:ss") as timestamp, 
        itemid, property, value
    from temp_item_properties
    """)
    
    item_properties_transform.show()
    
    project_id = "<projet_name>"
    dataset_id = "project1"
    table_target = "item_properties_dwh"
    parttition_column = "DATE_FORMAT(timestamp, 'yyyy-MM')"
    cluster_column = "property"
    
    item_properties_transform.write \
        .format("bigquery") \
        .option("temporaryGcsBucket","dataproc-temp-asia-southeast2-212352110204-1oi7hped") \
        .option("table", f"{project_id}.{dataset_id}.{table_target}") \
        .option("PARTITION BY",  parttition_column) \
        .option("CLUSTER BY", cluster_column) \
        .mode('Overwrite') \
        .save()
    
    # Stop Spark session
    spark.stop()
    ```

  - Check again tables in BigQuert

    ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/dfe7e900-b835-45c8-83fe-dfc41d7d66ee)

    ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/cac2a5b9-e3e6-4bb6-822f-ae0230b435b9)

    ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/2a8b36e3-803d-449a-b918-79733b290fba)

 
## Dashboard

- BigQuery --> Google Looker Studio

[The 10 Sold Items](https://lookerstudio.google.com/reporting/1d41fc0d-7470-4e45-9951-9a9e20dc1102)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/2427675e-edd8-447c-b3de-1fbecb28e06a)

[Percentage of Events](https://lookerstudio.google.com/reporting/c12cc383-bcb3-4b84-8298-a027277382d9)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/82524f06-e24d-4147-9c41-096960ff0539)

[Number of categoryid by parentid](https://lookerstudio.google.com/s/rykyVybnLkU)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/9d74dace-e7ba-40e1-a9cf-2e09bd3a76a8)


- BigQuery --> Pyspark SQL --> Pandas
  
  https://github.com/garjita63/dezoomcamp2024-project1/blob/main/EDA%20-%20Dashboard.ipynb

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/e49aa80a-cc74-47bd-aae4-d7d2ffb2b450)



