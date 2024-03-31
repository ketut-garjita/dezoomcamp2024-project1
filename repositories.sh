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
    command: mage start <some_folder>
    container_name: <some_folder>-mage
    build:
      context: .
      dockerfile: Dockerfile
    environment:
      USER_CODE_PATH: /home/src/<some_folder>
      POSTGRES_DBNAME: <some_folder>db
      POSTGRES_SCHEMA: public
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres316
      POSTGRES_HOST: vm-ikg-<some_folder>
      POSTGRES_PORT: 5432
    ports:
      - 6789:6789
    volumes:
      - .:/home/src/
      - /root/.google/credentials/key-ikg-<some_folder>-2024.json
    restart: on-failure:5
  postgres:
    image: postgres:14
    restart: on-failure
    container_name: <some_folder>-postgres
    environment:
      POSTGRES_DB: <some_folder>db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres316
    ports:
      - 5432:5432
  pgadmin:
    image: dpage/pgadmin4
    container_name: <some_folder>-pgadmin
    environment:
      - PGADMIN_DEFAULT_EMAIL=admin@admin.com
      - PGADMIN_DEFAULT_PASSWORD=root
    ports:
      - 8080:80
      
SCRIPT

sudo docker compose -f /root/docker-compose.yml up -d
