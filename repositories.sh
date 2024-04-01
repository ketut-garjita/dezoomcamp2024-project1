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
      POSTGRES_HOST: <hostname>
      POSTGRES_PORT: 5432
    ports:
      - 6789:6789
    volumes:
      - .:/home/src/
      - /root/.google/credentials/gcp-key.json
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
