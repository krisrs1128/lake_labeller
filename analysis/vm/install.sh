
conda create -n glaciers

conda activate glaciers
conda install -c conda-forge -y gdal rasterio pyproj shapely
conda install -c conda-forge -y numpy scipy
conda install -c pytorch -y pytorch torchvision
conda install -c conda-forge -y torchgeo
