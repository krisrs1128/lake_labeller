FROM pytorch/pytorch:1.13.0-cuda11.6-cudnn8-runtime

RUN apt-get update -y \
  && apt-get install -y software-properties-common \
  && apt-get update -y

RUN apt-get install -y gnupg \
  && add-apt-repository ppa:ubuntugis/ppa \
  && apt-get update \
  && apt-get install -y libgdal-dev gdal-bin

RUN pip install --no-cache-dir rasterio geopandas torchvision pyproj shapely pystac-client planetary-computer python-dotenv torchgeo
RUN planetarycomputer configure --subscription_key a47b295458434389804c72ed1596b300
