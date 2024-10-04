#!/bin/bash

# Nome do container
CONTAINER_NAME=geoserver-gdal-ewc

# Porta exposta
PORT=8080

# Nome da imagem
IMAGE_NAME=geoserver-gdal-ewc

# Diretório local para bind (use caminho absoluto)
HOST_DATA_DIR=${HOST_DATA_DIR:-/home/fernando/winlogic/ffmassa/geoserver-gdal-ewc/data_dir}

# Diretório de dados no container
CONTAINER_DATA_DIR=/gsdata

# Arquivo de log
LOG_FILE="geoserver.out"

# Verificar se o container já está rodando
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo "O container $CONTAINER_NAME já está rodando."
elif [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    # O container existe mas está parado, então iniciá-lo
    echo "Iniciando o container $CONTAINER_NAME existente..."
    docker start $CONTAINER_NAME
else
    # Iniciar um novo container com bind mount
    echo "Iniciando um novo container $CONTAINER_NAME na porta $PORT com bind $HOST_DATA_DIR..."
    docker run -d -p $PORT:8081 --name $CONTAINER_NAME \
      -v $HOST_DATA_DIR:$CONTAINER_DATA_DIR \
      $IMAGE_NAME
fi

# Redirecionar os logs do container para um arquivo
echo "Redirecionando logs do container para $LOG_FILE..."
docker logs -f $CONTAINER_NAME &> $LOG_FILE &

# Monitorar o arquivo de log
echo "Monitorando logs do container. Pressione Ctrl+C para parar."
tail -f $LOG_FILE
