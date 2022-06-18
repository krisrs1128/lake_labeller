#!/usr/bin/env bash

export id=$((id + 1))
git clone https://github.com/krisrs1128/lake_labeller
cd lake_labeller/analysis
Rscript -e "devtools::install('../lakes')"
Rscript -e "rmarkdown::render('download.Rmd', params = list(download_set = $id))"
cd ../
mkdir glaciers_${id}
mv analysis/*.tif glaciers_${id}
mv analysis/*.csv glaciers_${id}
tar -zcvf glaciers_${id}.tar.gz glaciers_${id}
mv *.tar.gz /staging/ksankaran/glaciers/
