import numpy as np
from rio_cogeo.cogeo import cog_translate
from rio_cogeo.profiles import cog_profiles
from pathlib import Path

input_dir = Path("../data/raw_data/imgs/")
output_dir = Path("../data/derived_data/cogs/")
output_dir.mkdir(exist_ok=True, parents = True)

for p in input_dir.glob("*tif*"):
    output_path = output_dir / p.name
    cog_translate(p, output_path, cog_profiles.get("deflate"))

## then run
## gdalbuildvrt -srcnodata 0 lakes.vrt *.tif
