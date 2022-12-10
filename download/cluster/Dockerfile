FROM pytorch/pytorch:1.13.0-cuda11.6-cudnn8-runtime

# root packages
RUN apt-get -y autoclean; apt-get update -y
RUN apt-get install -y wget sudo

# install miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh
RUN bash Miniconda3-py39_4.12.0-Linux-x86_64.sh -b
RUN rm Miniconda3-py39_4.12.0-Linux-x86_64.sh
ENV PATH /opt/conda/bin:$PATH
RUN conda init bash

# create user
RUN useradd --shell /bin/bash --create-home --home-dir /home/glaciers glaciers
USER glaciers
WORKDIR /home/glaciers
ENV PATH=${PATH}:/home/glaciers/miniconda3/bin

# install needed python packages
RUN conda init bash \
  && conda create -y -n glaciers \
  && conda install -c conda-forge -n glaciers -y mamba \
  && /home/glaciers/.conda/envs/glaciers/bin/mamba install -c conda-forge -n glaciers -y numpy scipy \
  && /home/glaciers/.conda/envs/glaciers/bin/mamba install -c conda-forge -n glaciers -y gdal rasterio pyproj shapely \
  && /home/glaciers/.conda/envs/glaciers/bin/mamba install -c conda-forge -n glaciers -y geopandas pystac-client planetary-computer python-dotenv \
  && /home/glaciers/.conda/envs/glaciers/bin/mamba install -c pytorch -n glaciers -y torchvision \
  && /home/glaciers/.conda/envs/glaciers/bin/mamba install -c conda-forge -n glaciers -y torchgeo
