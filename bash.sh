#!/bin/bash

# Nome do container
CONTAINER_NAME=geoserver

# Verificar se o container está rodando
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "Entrando no bash do container $CONTAINER_NAME..."
    docker exec -it $CONTAINER_NAME /bin/bash
else
    echo "O container $CONTAINER_NAME não está rodando. Inicie-o primeiro."
fi
