# DE Zoomcamp 2024 - Project1 

This repository contains a brief description of my DE Zoomcamp 2024 Project 1

## Problem statement

The Retailrocket has collected a large dataset of E-commerce i.e  a file with behaviour data (events.csv), a file with item properties (item_properties.сsv) and a file, which describes category tree (category_tree.сsv). The data has been collected from a real-world ecommerce website. It is raw data, i.e. without any content transformations, however, all values are hashed due to confidential issues. The purpose of publishing is to motivate researches in the field of recommender systems with implicit feedback.  The goal of this project is to create a streamlined and efficient process for ingesting and analyzing e-commerce on Cloud by implementing Data Engineering concepts.

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
- Batch processing : pyspark SQL
- IDE : VS Code, Jupyter Notebook
- Language : Python
- Visualisation : Google Looker Studio

## Project Architecture

The end-to-end data pipeline includes the below steps:
- Kaggle dataset is downloaded into the Google VM.
- The downloaded CSV files (raw) are then uploaded to a folder in Google Cloud bucket (parquet) as Data Like.
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

- Assign External IP Address

  After terraform apply complete succeesfully, assign External IP Address for Master and Workers instances using Console.

  From VM Instance (Compute Engine) --> SSH
    
  ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/2d4ff3e3-a28a-4739-a17c-39d64ae4683e)
  
  ![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/b67244eb-3b31-4f7d-ada6-76f261ba1887)
    
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b0b4c8b8-84bb-40fa-bdde-cd1a517ba399)
    
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b2ab4aaf-24db-49cc-9d35-c828777bb4e3)
    
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/096daaa8-c50d-44bf-8dcb-c6f0b9e30b9b)
  
  
- Setting up Mage-ai, PostgreSQL and pgAdmin through the Master VM Instance SSH.

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
  
  chmod +x repositories.sh

  sudo ./repositories.sh

  ==> *Mage-ai, postgresql and pgAdmin would be installed and up running.*

  Check mage-ai:
  
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/b3906b1d-0b46-4166-af52-525f86b60a0c)
  
  Check pgadmin :
  
  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/03991861-af32-4840-9d9d-d06f476da686)

  Restart Juypyer Notebook

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

- Increase memory size for cluster if required, and then restart Jupyter Notebook

  ```
  jupyter notebook --generate-config
  ```

  Open /home/<some_folder>/.jupyter/jupyter_notebook_config.py 

  Edit file and modify parameter: **c.NotebookApp.max_buffer_size**

  ![image](https://github.com/garjita63/retailrocket-ecommerce-batch/assets/77673886/2464f7a3-aad7-4514-add2-412e36321bff)

  Delete # character

- Spark master and worker clusters

    Edit ~/.bashrc file and add lines below:
    ```
    export SPATH=$SPARK_HOME/bin:$SPARK/sbin:$PATH
    source ~/.bashrc
    which start-all.sh
    ```
    
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

    Login to Worker Cluster web



## Mage-ai orchestration pipelines

Create two runtime variables: bucket_name and dataset. These variables used by all pipeline blocks.

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/6b1e3ff7-c0dd-4dd1-ba8a-f242e9a075ae)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/68e003cb-3c92-4535-b31f-b493578e3666)

Pipeline and its blocks available in mage-project1.tar files.
- Put mage-project1.tar into VM. You must have file copy authority to the master VM.
  ```
  gcloud auth login
  gcloud config set project <project_name>
  --> allow to access of your google account
  ```
  ```
  gcloud compute scp mage-project1.tar <username>@<project_name>:/home/<username>
  ```
- Open SSH on Master instance
- Copy mage-project1.tar into mage container (in this project named: dezoomcamp-mage)
  ```
  docker cp mage-project1.tar <mage_container>:/home/src/<some_folder>   # in this project is "dezoomcamp'
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

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/780553c9-a6af-4c34-b9f5-7559947b4fd1)

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


## BigQuery Tables

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/56182c69-7fc1-4193-a69a-2a5fedfaa41f)


events preview

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/4504b276-41de-4281-bb8d-9e80f7eea1b8)

events_dwh preview

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/a8cf4106-79da-4a5f-b915-542b6f30d7a7)

item_properties preview

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/e3709b62-e099-4a65-b137-cf521f134aa5)

item_properties_dwh preview

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/9b30666d-8ab7-4e9b-b88a-f57c438b5aff)


## Dashboard

[The 10 Sold Items](https://lookerstudio.google.com/reporting/1d41fc0d-7470-4e45-9951-9a9e20dc1102)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/2427675e-edd8-447c-b3de-1fbecb28e06a)

[Percentage of Events](https://lookerstudio.google.com/reporting/c12cc383-bcb3-4b84-8298-a027277382d9)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/82524f06-e24d-4147-9c41-096960ff0539)

[Number of categoryid by parentid](https://lookerstudio.google.com/s/rykyVybnLkU)

![image](https://github.com/garjita63/dezoomcamp2024-project1/assets/77673886/9d74dace-e7ba-40e1-a9cf-2e09bd3a76a8)





