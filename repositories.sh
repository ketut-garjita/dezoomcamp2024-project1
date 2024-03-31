#############Install Docker#############
# Update the apt package index and install packages to allow apt to use a repository over HTTPS
sudo apt update
sudo apt install apt-transport-https ca-certificates curl software-properties-common

# Add Docker’s official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 

# The following command is to set up the stable repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu `lsb_release -cs` stable" 

# Update the apt package index, and install the latest version of Docker Engine and containerd, or go to the next step to install a specific version
sudo apt update 
sudo apt install -y docker-ce


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


#############Install some packages############
sudo apt update
sudo apt install net-tools
sudo apt install vim
