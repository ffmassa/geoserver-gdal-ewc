
# GeoServer with GDAL and ECW Support

This repository contains a custom Dockerfile to configure and run **GeoServer 2.26.0** with support for **GDAL 3.8.5** and the **ECW** library. GeoServer runs inside **Tomcat 9.0.80**, which is configured to run on port **8081**. The container is also configured to handle special characters in the filesystem using UTF-8.

## Introduction

This Dockerfile is designed to set up a complete environment for GeoServer with support for advanced raster formats such as ECW, using the Hexagon SDK. It installs **GDAL** with **Java JNI** support and the **ECW SDK**, integrates **GeoServer** into Tomcat, and includes the **GDAL plugin** for GeoServer. The installation is fully automated, with environment optimizations and locale settings.

## Prerequisites

You will need to obtain the file `ECWJP2SDKSetup_5.5.0.2268.bin`, which is required to add support for the ECW format in GDAL. This file can be downloaded directly from the [Hexagon Geospatial](https://www.hexagongeospatial.com/) website. The file is not included in the repository and must be placed in the root of the project before building the Docker image.

## How to Build the Docker Image

To build the Docker image, follow these steps:

1. Clone the repository to your local environment:

   ```bash
   git clone https://github.com/ffmassa/geoserver-gdal-ewc.git
   cd geoserver-gdal-ewc
   ```

2. Make sure the `ECWJP2SDKSetup_5.5.0.2268.bin` file has been downloaded and placed in the root of the project.

3. Build the Docker image using the Docker CLI:

   ```bash
   docker build -t geoserver-gdal-ecw:latest .
   ```

   This command will create a Docker image named `geoserver-gdal-ecw`, based on the Dockerfile instructions, including GeoServer, GDAL, and the ECW SDK installation.

## How to Run the Container

Once the Docker image has been created, you can start the container by running the following command:

```bash
docker run -d -p 8081:8081 -v /path/to/local/geoserver_data:/gsdata --name geoserver-container geoserver-gdal-ecw:latest
```

Here are the parameters explained:
- `-p 8081:8081`: Maps the internal port 8081 of the container to port 8081 on the host.
- `-v /path/to/local/geoserver_data:/gsdata`: Binds the GeoServer data directory to persist outside the container.
- `--name geoserver-container`: Name of the container.
- `geoserver-gdal-ecw:latest`: Name of the Docker image that was created.

## Accessing GeoServer

Once the container is running, you can access the GeoServer interface in your browser:

```
http://localhost:8081/geoserver
```

## Scripts Overview

In the `scripts` folder, you will find several Bash scripts designed to manage the Docker container lifecycle, image creation, and log retrieval for the GeoServer instance. Below is an explanation of each script:

1. **`docker-run.sh`**:  
   This script is responsible for starting the GeoServer container. It checks if a container named `geoserver-gdal-ewc` is already running. If the container is stopped, it will be started again, and if it doesn’t exist, a new container will be created. It binds the local `data_dir` folder to `/gsdata` inside the container, and logs are redirected to `geoserver.out`.

   Usage:
   ```bash
   ./scripts/docker-run.sh
   ```

2. **`docker-stop.sh`**:  
   This script stops and removes the running GeoServer container named `geoserver-gdal-ewc`. It first checks if the container is running before stopping and removing it.

   Usage:
   ```bash
   ./scripts/docker-stop.sh
   ```

3. **`docker-build.sh`**:  
   This script builds a new Docker image based on the `Dockerfile`. It first checks if an image with the name `geoserver-gdal-ewc` exists and removes it before building a new one.

   Usage:
   ```bash
   ./scripts/docker-build.sh
   ```

4. **`docker-bash.sh`**:  
   This script allows you to open a bash shell inside the running `geoserver-gdal-ewc` container. If the container is not running, it will prompt you to start the container first.

   Usage:
   ```bash
   ./scripts/docker-bash.sh
   ```

5. **`docker-log.sh`**:  
   This script retrieves the current day’s GeoServer logs from the `geoserver-gdal-ewc` container. It reads the log file located at `/usr/local/tomcat/logs/localhost.<current-date>.log` and outputs it to the terminal. If the container is not running, it will notify you to start the container first.

   Usage:
   ```bash
   ./scripts/docker-log.sh
   ```

## `data_dir` Overview

The `data_dir` folder contains initial test data for GeoServer, based on the default data directory provided in the GeoServer 2.26 download. This directory includes essential configuration files and sample layers that can be used to test the GeoServer installation and functionality. When you run the container, this folder is bound to the `/gsdata` directory inside the container, allowing GeoServer to use these initial configurations.

## Final Considerations

This project provides a complete GeoServer installation with advanced raster support and is ready for use in development and production environments. Be sure to adjust file and volume permissions as needed for your environment.

## Acknowledgments

Special thanks to the [docker-gdal-ecw project](https://github.com/elmoneto/docker-gdal-ecw/tree/main) for helping in setting up GDAL with ECW 5.5. Thanks to this project, I was able to set up the GeoServer 2.26.x environment using the latest version of the ECW library.

## License

This project is licensed under the **MIT License**. See the LICENSE file for more details.

## Contact

If you have any questions or need assistance, feel free to contact me:

**Fernando**  
Email: [fernando@winlogic.com.br](mailto:fernando@winlogic.com.br)