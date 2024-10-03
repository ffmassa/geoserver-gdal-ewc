
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