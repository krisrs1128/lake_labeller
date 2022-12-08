FROM nvidia/cuda:11.4.0-base-ubuntu20.04

RUN apt-get autoclean
RUN apt-get clean && apt-get update -y
RUN apt-get install -y wget git build-essential libblas-dev

# install miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-py39_4.12.0-Linux-x86_64.sh
RUN bash Miniconda3-py39_4.12.0-Linux-x86_64.sh -b
RUN rm Miniconda3-py39_4.12.0-Linux-x86_64.sh
ENV PATH=$PATH:/root/miniconda3/bin/

# install needed python packages
RUN conda install -c conda-forge -y mamba
#RUN mamba install -c conda-forge -y rasterio
#RUN mamba install -c conda-forge -y gdal rasterio pyproj shapely
#RUN mamba install -c conda-forge -y geopandas pystac-client planetary-computer python-dotenv
#RUN mamba install -c conda-forge -y numpy scipy
RUN mamba install -c pytorch -c nvidia -y pytorch-cuda=11.6
RUN mamba install -c pytorch -c nvidia -y pytorch=1.13 torchvision
RUN mamba install -c conda-forge -y torchgeo
