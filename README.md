# DE Zoomcamp 2024 - Project1 

This repository contains a brief description of my DE Zoomcamp 2024 Project 1

## Problem statement

The Retailrocket t has collected a large dataset of E-commerce i.e  a file with behaviour data (events.csv), a file with item properties (item_properties.сsv) and a file, which describes category tree (category_tree.сsv). The data has been collected from a real-world ecommerce website. It is raw data, i.e. without any content transformations, however, all values are hashed due to confidential issues. The purpose of publishing is to motivate researches in the field of recommender systems with implicit feedback.  The goal of this project is to create a streamlined and efficient process for analyzing e-commerce by implementing Data Engineering concepts.

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

Kaggle dataset is downloaded into the Google VM, then ingested to Google Cloud Storage Buecket as Data Lake. Next, the data will be stored in BigQuery as a Data Warehouse. All data flows are executed using the Mage-ai workflow orchestration tool. A Spark job is run on the data stored in the Google Storage Bucket or in BigQuery.
The results are written to a dafaframe and/or table in Postgres. A dashboard is created from the Looker Studio.

The end-to-end data pipeline includes the below steps:
- Kaggle dataset is downloaded into the Google VM.
- The downloaded CSV files (raw) are then uploaded to a folder in Google Cloud bucket (parquet) as Data Like.
- Next, the data will be stored in BigQuery with format and values same as the GCP bucket files.
- Last new tables are created from those original tables by using Spark SQL with correct data types as well as partitioned by Month and Clustered for optimised performance. These tables would be Data Warehouse tables. 
- Spin up a dataproc clusters (master and worker) and execute the pyspark jobs for procusts analys purposes
- Configure Google Looker Studio to power dashboards from BigQuery Data Warehouse tables

You can find the detailed Architecture on the diagram below:

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/ef363cea-67c7-4a10-9dc7-0516dab7008d)


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
  3. Compute Engine API (if you are going to use VM instance)
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

After terrafor apply done :

- Assign External IP Address for Master and Workers Clusters. You can use either Console or gcloud :

  **Console** :

  From VM Instance (Compute Engine) - SSH
  
  ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/2d4ff3e3-a28a-4739-a17c-39d64ae4683e)
  
  ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/b67244eb-3b31-4f7d-ada6-76f261ba1887)
  
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b0b4c8b8-84bb-40fa-bdde-cd1a517ba399)
  
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b2ab4aaf-24db-49cc-9d35-c828777bb4e3)
  
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/096daaa8-c50d-44bf-8dcb-c6f0b9e30b9b)
  
  **gloud shell** (local or cloud) :
  ```
  gcloud compute instances add-access-config <master_cluster> --access-config-name="<master_cluster>-config"
  gcloud compute instances add-access-config <worker_cluster_0> --access-config-name="<worker_cluster_0>-config"
  gcloud compute instances add-access-config <worker_cluster_1> --access-config-name="<worker_cluster_1>-config"
  ```
  
  *Provide master_cluster and worker_cluster names.*

- Set up Mage-ai, PostgreSQL and pgAdmin through the Master VM Instance SSH.

  Copy repsistories.sh into VM. repsistories.sh is script for installing docker network and bring up docker containers of Mage-ai, postgresql and pgAdmin.
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
        POSTGRES_PASSWORD: postgres316
        POSTGRES_HOST: vm-ikg-dezoomcamp
        POSTGRES_PORT: 5432
      ports:
        - 6789:6789
      volumes:
        - .:/home/src/
        - /root/.google/credentials/key-ikg-dezoomcamp-2024.json
      restart: on-failure:5
    postgres:
      image: postgres:14
      restart: on-failure
      container_name: dezoomcamp-postgres
      environment:
        POSTGRES_DB: dezoomcampdb
        POSTGRES_USER: postgres
        POSTGRES_PASSWORD: postgres316
      ports:
        - 5432:5432
    pgadmin:
      image: dpage/pgadmin4
      container_name: dezoomcamp-pgadmin
      environment:
        - PGADMIN_DEFAULT_EMAIL=admin@admin.com
        - PGADMIN_DEFAULT_PASSWORD=root
      ports:
        - 8080:80
        
  SCRIPT
  
  sudo docker compose -f /root/docker-compose.yml up -d
  ```

  chmod +x repositories.sh

  sudo ./repositories.sh

  ==> *Mage-ai, postgresql and pgAdmin would be installed and up running.*


  Check mage :
  
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b3906b1d-0b46-4166-af52-525f86b60a0c)
  
  Check pgadmin :
  
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/03991861-af32-4840-9d9d-d06f476da686)


  Restart Juypyer Notebook

    Stop :
    ```
    sudo systemctl stop jupyter
    ```
    
    Start by using script below :
    ```
    jupyter-notebook  --port=8888 --ip=0.0.0.0 --no-browser
    ```
  
     ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/e78fc04d-9055-4aeb-ac27-5b877a99e1ec)

- Increase memory size for cluster if required, and then restart Jupyter Notebook

  ```
  jupyter notebook --generate-config
  ```

  Open /home/<some_folder>/.jupyter/jupyter_notebook_config.py 

  Modify the

  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/2464f7a3-aad7-4514-add2-412e36321bff)

- Spark master and worker clusters

    Edit ~/.bashrc fileand add lines below:
    ```
    export SPATH=$SPARK_HOME/bin:$SPARK/sbin:$PATH
    ```
  
    Start master and worker clusters
    ```
    start-all.sh
    ```

    Try run spark by using dataset on hdfs
  
    Copy dataset folder into /user/<some_folder>
    ```
    hdfs dfs -mkdir /user/<some_folder>
    hdfs dfs -copyFromLocal  ecommerce-dataset/ /user/s<some_folder>
    ```

    Login to Web Master Cluster

    ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/2a725a00-6ec0-4658-bb8e-73f6abbdfe64)

    Login to Web Worker Cluster

    ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/65c9db9b-58af-428f-97ad-8ad1de1b02cc)


## Mage-ai orchestration pipelines

All pipeline and its blocks available in mager-project1.tar files.
- Put mage-project1.tar into VM. You must have file copy authority to the master VM.
  ```
  gcloud auth login
  gcloud config set project <project_name>
  --> allow to access from your google account
  ```
  ```
  gcloud compute scp mage-project1.tar <username>@<project_name>:/home/<username>
  ```
- Open SSH on Master instance
- Copy mage-project1.tar into mage container (in this project named: dezoomcamp-mage)
  ```
  docker cp mager-project1.tar <mage_container>:/home/src/<some_folder>   # in this project is "dezoomcamp'
  ```
- Go to mage container
  ```
  docker exec -it <mage_container> bash
  ```
- Extract (untar) mage-project.tar file
  ```
  cd /home/src/<some_folder>
  tar -xvf mage-project1.tar
  ```
- Open Mage application website : http://<master_external_ip_address>:6789 

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/c3714049-6cdb-4f30-b92a-82c4cd4c7ca3)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/ce3c86ad-8ea1-4d4a-9ddc-408c699a274e)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/1c5ac741-fe18-4ee4-9549-88c7394283e7)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/bcfbb92a-b40c-428e-af62-b0111ea96d76)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/c157df89-d5e8-429a-855a-29c4c405ba97)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/029017d9-47bd-4d80-9e3f-150bba1940c6)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/47adf1f5-edde-4a62-bd77-e286cfea6627)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/80b44ef7-4d79-4248-87a2-88e5432683f1)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/3ed735e6-f0c0-466a-b96a-b3aa4babdefc)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/90178e95-4e8a-4d0c-86e2-5e121df462d0)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/dec77702-674a-4895-8413-77f3e490c637)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/0cf02751-3185-41eb-a33b-f7dd70677b31)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/38533740-1186-4294-9110-2718203ec87c)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/a2619916-42f3-4c6d-919b-69c7a652a718)


## Dashboard

![locker-studio2](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/73839329-bb0a-426e-bb95-44da5718504c)

![locker-studio1](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/4ca8c142-1f90-4514-ab90-f5241f04f6ef)

