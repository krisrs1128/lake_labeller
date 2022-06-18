FROM rocker/tidyverse

RUN apt-get update
RUN apt-get install -y libudunits2-dev gdal-bin libgdal-dev libgeos-dev libproj-dev python3.8-venv
RUN Rscript -e "install.packages('reticulate')"
RUN Rscript -e 'reticulate::install_miniconda()'
RUN Rscript -e "reticulate::py_install(c('gdal==3.0.4', 'numpy', 'scipy', 'rasterio', 'pyproj', 'shapely'))"
RUN Rscript -e "install.packages(c('sf', 'terra', 'lubridate', 'devtools'))"
RUN Rscript -e "install.packages(c('fastkmedoids', 'glue', 'rstac', 'stars'))"

RUN chmod -R 777 /usr/local/lib/
ENV HOME /root/
ENV USER root
RUN chmod -R 777 /root/
