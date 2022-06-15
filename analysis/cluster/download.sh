#!/usr/bin/env bash

git clone https://github.com/krisrs1128/lake_labeller
cd lake_labeller/analysis
Rscript -e "rmarkdown::render('download.Rmd', params = list(download_set = $id))"
cd ../
mkdir data_${id}
mv analysis/*.tif data_${id}
mv analysis/*.csv data_${id}
tar -zcvf data_${id}.tar.gz data_${id}
