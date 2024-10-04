#!/bin/bash

# Nome do container
CONTAINER_NAME="geoserver-gdal-ewc"

# Caminho para o log dentro do container
LOG_FILE="/usr/local/tomcat/logs/localhost.$(date +'%Y-%m-%d').log"

# Verifique se o container está rodando
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Lendo o arquivo de log $LOG_FILE dentro do container $CONTAINER_NAME..."
    docker exec -it $CONTAINER_NAME cat $LOG_FILE
else
    echo "O container $CONTAINER_NAME não está rodando."
fi
