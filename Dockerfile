FROM ubuntu:latest

MAINTAINER Daniel Hardesty Lewis <dhl@tacc.utexas.edu>

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ America/Chicago
ENV TAUDEM_VERSION Develop
ENV MINICONDA3_VERSION latest
ENV HAND_TAUDEM_VERSION master
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8
ARG CONDA_ENV_HAND=hand-taudem
ARG CONDA_ENV_LIBGDAL=hand-libgdal
ARG CONDA_ENV_RASTERIO=hand-rasterio
ENV PATH /opt/conda/envs/${CONDA_ENV}/bin:/opt/conda/bin:/usr/local/taudem:$PATH

RUN apt-get update && \
    apt-get install -y \
        build-essential \
        gcc \
        g++ \
        gfortran \
        python3-all-dev \
        python3-pip \
        python3-numpy \
        libblas-dev \
        liblapack-dev \
        libgeos-dev \
        libproj-dev \
        libspatialite-dev \
        libspatialite7 \
        spatialite-bin \
        libibnetdisc-dev \
        wget \
        zip \
        gdal-bin \
        gdal-data \
        libgdal26 \
        libgdal-dev \
        python3-gdal \
        mpich \
        libmpich12 \
        libmpich-dev \
        cmake \
        bzip2 \
        ca-certificates \
        curl \
        parallel && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

## Download and build taudem
RUN wget -O /opt/TauDEM.tar.gz https://github.com/dtarb/TauDEM/archive/${TAUDEM_VERSION}.tar.gz && \
    tar -xvf /opt/TauDEM.tar.gz -C /opt && \
    mkdir /opt/TauDEM-Develop/src/build
WORKDIR "/opt/TauDEM-Develop/src/build"
RUN cmake .. && \
    make -j $(($(grep -c ^processor /proc/cpuinfo)-1)) && \
    make -j $(($(grep -c ^processor /proc/cpuinfo)-1)) install && \
    rm -Rf /opt/TauDEM*
WORKDIR "/"

RUN wget https://repo.anaconda.com/miniconda/Miniconda3-${MINICONDA3_VERSION}-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh && \
    /opt/conda/bin/conda clean -tipsy && \
    ln -s /opt/conda/etc/profile.d/conda.sh /etc/profile.d/conda.sh && \
    echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc && \
    echo "conda activate base" >> ~/.bashrc

RUN wget https://raw.githubusercontent.com/dhardestylewis/HAND-TauDEM/${HAND_TAUDEM_VERSION}/env/environment.yml -O /opt/${CONDA_ENV_HAND}.yml && \
    wget https://raw.githubusercontent.com/dhardestylewis/HAND-TauDEM/${HAND_TAUDEM_VERSION}/env/env-${CONDA_ENV_LIBGDAL}.yml -O /opt/${CONDA_ENV_LIBGDAL}.yml && \
    wget https://raw.githubusercontent.com/dhardestylewis/HAND-TauDEM/${HAND_TAUDEM_VERSION}/env/env-${CONDA_ENV_RASTERIO}.yml -O /opt/${CONDA_ENV_RASTERIO}.yml && \
    conda env create -f /opt/${CONDA_ENV_HAND}.yml && \
    conda env create -f /opt/${CONDA_ENV_LIBGDAL}.yml && \
    conda env create -f /opt/${CONDA_ENV_RASTERIO}.yml && \
    rm /opt/*.yml && \
    echo '. `which env_parallel.bash`' >> $HOME/.bashrc

