from ubuntu:18.04

# Declare some ARGuments
ARG PYTHON_VERSION=2.7
ARG CONDA_VERSION=3
ARG CONDA_PY_VERSION=4.6.14
ARG OPENCV_VERSION=3.4.0
ARG CONDA_ENV_NAME=alprEnv

COPY environment.yml /tmp/environment.yml

# Install prerequisites
run apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    apt-utils \
    build-essential \
    cmake \
    curl \
    git \
    libcurl3-dev \
    libleptonica-dev \
    liblog4cplus-dev \
    wget

# Installation of general & Miniconda system dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python-pip \
    python-dev \
    python3-pip \
    python3-dev \
    python-lxml \
    bzip2 \
    libopenblas-dev \
    pbzip2 \
    libgl1-mesa-glx \
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

#Install MINICONDA
##################
WORKDIR /usr/local/src/
WORKDIR /usr/local/src/

RUN wget -q https://repo.continuum.io/miniconda/Miniconda$CONDA_VERSION-$CONDA_PY_VERSION-Linux-x86_64.sh -O Miniconda.sh && \
	       /bin/bash Miniconda.sh -b -p /opt/conda && \
         rm Miniconda.sh

ENV PATH /opt/conda/bin:$PATH

SHELL ["/bin/bash", "-c"]

# Create the conda environment
RUN conda update -n base -c defaults conda && \
    conda env create -f /tmp/environment.yml --name=$CONDA_ENV_NAME

# Install Tesseract OCR

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y automake libtool libleptonica-dev

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y libleptonica-dev

WORKDIR /usr/local/src/
RUN git clone https://github.com/tesseract-ocr/tesseract.git
WORKDIR tesseract

RUN ./autogen.sh && \
    ./configure && \
    make -j4 && \
    make install && \
    ldconfig

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

RUN conda install numpy

RUN echo "source activate $CONDA_ENV_NAME" > ~/.bashrc && \
    export PATH=/opt/conda/envs/$CONDA_ENV_NAME/bin:$PATH && \
    conda install hdf5 protobuf && \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D INSTALL_PYTHON_EXAMPLES=ON \
    -D INSTALL_C_EXAMPLES=OFF \
    -D OPENCV_EXTRA_MODULES_PATH=/usr/local/src/opencv_contrib-${OPENCV_VERSION}/modules \
    -D PYTHON2_EXECUTABLE=/opt/conda/envs/$CONDA_ENV_NAME/bin/python \
    -D PYTHON3_EXECUTABLE=/opt/conda/bin/python3 \
    -D PYTHON_LIBRARY=/opt/conda/envs/$CONDA_ENV_NAME/lib/python${PYTHON_VERSION} \
    -D PYTHON_INCLUDE_DIR2=/opt/conda/envs/$CONDA_ENV_NAME/include/python${PYTHON_VERSION}m \
    -D PYTHON_INCLUDE_DIR3=/opt/conda/include/python3.7m \
    -D ENABLE_PRECOMPILED_HEADERS=OFF \
    -D BUILD_opencv_python3=OFF \
    -D BUILD_EXAMPLES=OFF ..

RUN make -j6
RUN make install
RUN ldconfig

# Make cv2 visible in the conda environment
workdir /opt/conda/envs/$CONDA_ENV_NAME/lib/python$PYTHON_VERSION/site-packages/
RUN ln -s /usr/local/lib/python$PYTHON_VERSION/site-packages/cv2.so cv2.so

# Fix the opencv libfontconfig dependency issue
RUN rm /opt/conda/envs/$CONDA_ENV_NAME/lib/libfontconfig.so.1 \
       /opt/conda/envs/$CONDA_ENV_NAME/lib/libfontconfig.so \
       /opt/conda/envs/$CONDA_ENV_NAME/lib/libfontconfig.so.1.11.1


# A trick to get the conda spyder working, installs some mystical dependencies
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y spyder alsa


# Install alpr-unconstrained
############################

WORKDIR /usr/local/src
RUN git clone https://github.com/sergiomsilva/alpr-unconstrained.git

# Install darknet
WORKDIR /usr/local/src/alpr-unconstrained/darknet
RUN make -j6

WORKDIR /usr/local/src/alpr-unconstrained/
RUN bash get-networks.sh
