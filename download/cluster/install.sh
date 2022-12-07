
conda create -n glaciers

conda activate glaciers
conda install -c conda-forge -y gdal rasterio pyproj shapely
conda install -c conda-forge -y geopandas pystac-client planetary-computer python-dotenv
conda install -c conda-forge -y numpy scipy
conda install -c pytorch -y pytorch torchvision
conda install -c conda-forge -y torchgeo
conda install -c conda-forge -y jupyterlab

conda install -c conda-forge -y ipykernel
python -m ipykernel install --name glaciers
