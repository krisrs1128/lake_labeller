FROM rocker/tidyverse:latest

RUN Rscript -e "install.packages('reticulate')"
RUN Rscript -e "install.packages(c('sf', 'terra', 'lubridate', 'devtools'))"
RUN Rscript -e "devtools::install_github('krisrs1128/lake_labeller/lakes')"
