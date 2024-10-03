#!/bin/bash

# Nome da imagem
IMAGE_NAME="geoserver"

# Caminho para o Dockerfile (pode ser alterado se necessário)
DOCKERFILE_PATH="."

# Verificar se há uma imagem existente com o mesmo nome e removê-la (opcional)
if [ "$(docker images -q $IMAGE_NAME)" ]; then
    echo "Removendo imagem antiga do GeoServer..."
    docker rmi $IMAGE_NAME
fi

# Construir a nova imagem com o nome 'geoserver'
echo "Construindo a nova imagem Docker do GeoServer..."
docker build -t $IMAGE_NAME $DOCKERFILE_PATH

# Verificar se a imagem foi construída com sucesso
if [ "$(docker images -q $IMAGE_NAME)" ]; then
    echo "Imagem do GeoServer criada com sucesso: $IMAGE_NAME"
else
    echo "Erro ao criar a imagem do GeoServer."
fi
