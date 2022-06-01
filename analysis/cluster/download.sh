#!/usr/bin/env bash

git clone https://github.com/krisrs1128/lake_labeller
cd lake_labeller/analysis

start
Rscript -e "rmarkdown::render('donwload.Rmd', params = list(year = 2019, month = 8, n_months = 4))"

year: 2019
month: 8
n_months: 4
lake_ids: [1, 10]
