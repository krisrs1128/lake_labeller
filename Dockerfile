FROM rocker/tidyverse:latest

RUN Rscript -e "install.packages('reticulate')"
RUN Rscript -e "install.packages(c('sf', 'terra', 'lubridate', 'devtools'))"
RUN Rscript -e "install.packages(c('fastkmedoids', 'glue', 'rstac'))"
RUN Rscript -e "devtools::install_github('krisrs1128/lake_labeller/lakes')"

RUN Rscript -e "reticulate::install_miniconda()"
RUN Rscript -e "reticulate::conda_create('lakes_labeller')"
RUN Rscript -e "reticulate::conda_install('lakes_labeller', c('gdal', 'numpy', 'scipy', 'rasterio'))"
