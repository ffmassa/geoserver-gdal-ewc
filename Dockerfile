# Use a imagem base do Ubuntu Jammy (20.04 LTS) como ponto de partida para o ambiente.
FROM ubuntu:jammy

# Define variáveis de ambiente para controlar as versões do GDAL e GeoServer
ARG GDAL_VERSION=3.8.5
ARG GEOSERVER_VERSION=2.26.0

# Define variáveis de ambiente essenciais para o Tomcat, Java e para configurar o locale.
ENV CATALINA_HOME=/usr/local/tomcat
ENV PATH=$CATALINA_HOME/bin:$PATH
ENV TOMCAT_VERSION=9.0.80
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
ENV PATH="$JAVA_HOME/bin:$PATH"
ENV GEOSERVER_DATA_DIR=/gsdata
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Atualiza os pacotes e instala o OpenJDK, wget e outras dependências básicas que são essenciais para o sistema.
RUN apt-get update && \
    apt-get install -y openjdk-11-jdk wget swig ant bison curl expect ca-certificates && \
    apt-get clean

# Atualiza os pacotes novamente e instala dependências adicionais para compilar o GDAL.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
    wget \
    gnupg2 \
    build-essential \
    make \
    cmake \
    ca-certificates \
    libjpeg-dev \
    libpng-dev \
    unzip \
    expect && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata

# Aqui começamos a instalação do SDK ECW, que permite suporte ao formato ECW no GDAL.
# O arquivo 'install-ecw-sdk.exp' é um script expect para automatizar a instalação interativa do SDK ECW.
COPY ./install-ecw-sdk.exp ./install-ecw-sdk.exp
COPY ./ECWJP2SDKSetup_5.5.0.2268.bin ./install.bin
RUN chmod +x install.bin && \
    expect ./install-ecw-sdk.exp && \
    cp -r /root/hexagon/ERDAS-ECW_JPEG_2000_SDK-5.5.0/Desktop_Read-Only /usr/local/hexagon && \
    rm -r /usr/local/hexagon/lib/x64 && \
    mv /usr/local/hexagon/lib/cpp11abi/x64 /usr/local/hexagon/lib/x64 && \
    cp /usr/local/hexagon/lib/x64/release/libNCSEcw* /usr/local/lib && \
    ldconfig /usr/local/hexagon && \
    apt update && \
    apt upgrade -y && \
    apt install -y proj-bin libproj-dev proj-data libproj22 && \
    wget https://github.com/OSGeo/gdal/releases/download/v${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz && \
    tar -xf gdal-${GDAL_VERSION}.tar.gz && \
    mkdir ./gdal-${GDAL_VERSION}/build && \
    cd ./gdal-${GDAL_VERSION}/build && \
    cmake -DCMAKE_BUILD_TYPE=Release -DECW_ROOT=/usr/local/hexagon -DJAVA_HOME=$JAVA_HOME -DBUILD_JAVA_BINDINGS=ON -DBUILD_PYTHON_BINDINGS=OFF -DBUILD_SHARED_LIBS=ON .. && \
    make && \
    make install && \
    ln -s /usr/lib/libgdal.so /usr/lib/libgdal.so.1 && \
    /sbin/ldconfig && \
    cd ../../ && \
    rm gdal-${GDAL_VERSION}.tar.gz && \
    rm -r gdal-${GDAL_VERSION} && \
    rm -r /usr/local/hexagon && \
    rm /install.bin && \
    rm -r /root/hexagon/ERDAS-ECW_JPEG_2000_SDK-5.5.0

# Baixa e instala o Tomcat 9, necessário para executar o GeoServer.
# O Tomcat é um contêiner de servlets que serve como o servidor de aplicação do GeoServer.
RUN wget https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    tar xvf apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
    mv apache-tomcat-${TOMCAT_VERSION} $CATALINA_HOME && \
    rm apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Configura o LD_LIBRARY_PATH para incluir as bibliotecas JNI do GDAL.
RUN echo "export LD_LIBRARY_PATH=/usr/local/lib/jni:/usr/lib:$LD_LIBRARY_PATH" >> $CATALINA_HOME/bin/setenv.sh

# Baixa o GeoServer na versão especificada e instala ele no Tomcat.
RUN echo "Baixando o GeoServer versão ${GEOSERVER_VERSION}..." && \
    echo "URL: https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip/download" && \
    curl -L "https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/geoserver-${GEOSERVER_VERSION}-bin.zip/download" -o /tmp/geoserver.zip && \
    unzip /tmp/geoserver.zip -d /tmp && \
    mv /tmp/webapps/geoserver /usr/local/tomcat/webapps/ && \
    rm -rf /tmp/geoserver*

# Baixa o plugin GDAL para o GeoServer, que permite ao GeoServer lidar com formatos raster avançados como ECW.
RUN echo "Baixando o plugin GDAL para o GeoServer..." && \
    curl -L "https://sourceforge.net/projects/geoserver/files/GeoServer/${GEOSERVER_VERSION}/extensions/geoserver-${GEOSERVER_VERSION}-gdal-plugin.zip/download" -o /tmp/gdal-plugin.zip && \
    unzip -o /tmp/gdal-plugin.zip -d /usr/local/tomcat/webapps/geoserver/WEB-INF/lib && \
    rm /tmp/gdal-plugin.zip

# Cria o diretório de dados do GeoServer e configura as permissões necessárias.
RUN echo "Criando diretório de dados do GeoServer em ${GEOSERVER_DATA_DIR}..." && \
    mkdir -p ${GEOSERVER_DATA_DIR} && \
    chown -R $(id -u):$(id -g) ${GEOSERVER_DATA_DIR}

# Define o diretório de dados do GeoServer como um volume para que ele possa ser persistido fora do container.
VOLUME ["${GEOSERVER_DATA_DIR}"]

# Configurações de locale e otimizações para o Java.
RUN echo "export JAVA_OPTS=\"-Dfile.encoding=UTF-8 \$JAVA_OPTS\"" >> $CATALINA_HOME/bin/setenv.sh && \
    apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8

# Modifica a porta padrão do Tomcat de 8080 para 8081 no arquivo de configuração do server.xml.
RUN sed -i 's/port="8080"/port="8081"/' $CATALINA_HOME/conf/server.xml

# Expõe a porta 8081 para o acesso ao GeoServer.
EXPOSE 8081

# Define o comando padrão que será executado ao iniciar o container, iniciando o Tomcat.
CMD ["catalina.sh", "run"]
