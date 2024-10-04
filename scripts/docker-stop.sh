#!/bin/bash

# Nome do container
CONTAINER_NAME=geoserver-gdal-ewc

# Verificar se o container está rodando
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Parando o container $CONTAINER_NAME..."
    docker stop $CONTAINER_NAME
    docker rm $CONTAINER_NAME
else
    echo "O container $CONTAINER_NAME não está rodando."
fi
