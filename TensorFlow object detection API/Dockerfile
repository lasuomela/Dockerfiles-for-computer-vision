FROM nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04

# Declare some ARGuments
ARG PYTHON_VERSION=3.6
ARG CONDA_VERSION=3
ARG CONDA_PY_VERSION=4.6.14
ARG OPENCV_VERSION=4.1.0
ARG CONDA_ENV_NAME=trackerEnv

COPY environment.yml /tmp/environment.yml

# Installation of general & Miniconda system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends python-pip \
    python-dev \
    python3-pip \
    python3-dev \
    python-lxml \
    wget \
    bzip2 \
    libopenblas-dev \
    pbzip2 \
    libgl1-mesa-glx \
    build-essential \
    cmake \
    git \
    unzip \
    pkg-config

# Installation of OpenCv system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends protobuf-compiler \
    libjpeg8-dev \
    libtiff5-dev \
    libpng-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libv4l-dev \
    libxvidcore-dev \
    libx264-dev \
    libgtk-3-dev \
    libatlas-base-dev \
    gfortran && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Installation of Openconnect system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends libxml2-dev \
    zlib1g-dev \
    gnutls-dev \
    libtool \
    m4 \
    gettext \
    autotools-dev \
    automake \
    net-tools \
    vpnc


#Install MINICONDA
##################

RUN wget -q https://repo.continuum.io/miniconda/Miniconda$CONDA_VERSION-$CONDA_PY_VERSION-Linux-x86_64.sh -O Miniconda.sh && \
	       /bin/bash Miniconda.sh -b -p /opt/conda && \
         rm Miniconda.sh

ENV PATH /opt/conda/bin:$PATH

SHELL ["/bin/bash", "-c"]

# Create the conda environment from the requirements in environment.yml
RUN conda update -n base -c defaults conda && \
    conda env create -f /tmp/environment.yml --name=$CONDA_ENV_NAME


# Install OpenCv from source
############################

# Installing from source enables the codecs like ffmpeg needed for ip streaming

WORKDIR /usr/local/src/

RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/$OPENCV_VERSION.zip && \
    wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/$OPENCV_VERSION.zip

RUN unzip opencv.zip && rm opencv.zip && \
    unzip opencv_contrib.zip && rm opencv_contrib.zip

RUN mkdir /usr/local/src/opencv-$OPENCV_VERSION/build
WORKDIR /usr/local/src/opencv-$OPENCV_VERSION/build/

RUN echo "source activate $CONDA_ENV_NAME" > ~/.bashrc && \
    export PATH=/opt/conda/envs/$CONDA_ENV_NAME/bin:$PATH && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib-${OPENCV_VERSION}/modules \
    -D PYTHON_EXECUTABLE=/opt/conda/envs/$CONDA_ENV_NAME/bin/python \
    -D PYTHON_LIBRARY=/opt/conda/envs/$CONDA_ENV_NAME/lib/python${PYTHON_VERSION} \
    -D PYTHON_INCLUDE_DIR=/opt/conda/envs/$CONDA_ENV_NAME/include/python${PYTHON_VERSION}m \
    -D BUILD_EXAMPLES=OFF ..

RUN make -j6
RUN make install
RUN ldconfig

# Make cv2 visible in the conda environment
ENV PYTHONPATH /usr/local/src/opencv-$OPENCV_VERSION/build/python_loader:$PYTHONPATH


# Install the Tensorflow object detection API
#############################################

WORKDIR /usr/local/src/
RUN git clone https://github.com/tensorflow/tensorflow
WORKDIR /usr/local/src/tensorflow
RUN git clone https://github.com/tensorflow/models
WORKDIR /usr/local/src/tensorflow/models/research
RUN protoc object_detection/protos/*.proto --python_out=.
ENV PYTHONPATH=$PYTHONPATH:/usr/local/src/tensorflow/models/research/object_detection:/usr/local/src/tensorflow/models/research/:/usr/local/src/tensorflow/models/research/slim

# Fix the opencv libfontconfig dependency issue
RUN rm /opt/conda/envs/$CONDA_ENV_NAME/lib/libfontconfig.so.1 \
       /opt/conda/envs/$CONDA_ENV_NAME/lib/libfontconfig.so \
       /opt/conda/envs/$CONDA_ENV_NAME/lib/libfontconfig.so.1.11.1


# Install Openconnect from source to get the newest version with PulseVpn support
#################################################################################

# Running the vpn inside the container enables normal internet use for applications
# not running inside the container

WORKDIR /usr/local/src/

RUN mkdir -p /etc/vpnc/ && \
    wget -O /etc/vpnc/vpnc-script http://git.infradead.org/users/dwmw2/vpnc-scripts.git/blob_plain/HEAD:/vpnc-script && \
    chmod +x /etc/vpnc/vpnc-script

RUN git clone https://gitlab.com/openconnect/openconnect.git
WORKDIR /usr/local/src/openconnect

RUN ./autogen.sh && \
    ./configure && \
    make -j6 && \
    make install && \
    sed -i '/$IPROUTE route flush cache/d' /etc/vpnc/vpnc-script
