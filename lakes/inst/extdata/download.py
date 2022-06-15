from scipy import interpolate
import numpy as np
import pyproj
import rasterio
import rasterio.windows as windows
from shapely.geometry import box
from shapely.ops import transform

def read_windows(links, bbox):
  wgs84 = pyproj.CRS("EPSG:4326")
  bbox = box(*bbox)
  
  result = []
  for link in links:
    im = rasterio.open(link)
    cur_crs = pyproj.CRS(im.meta["crs"])
    project = pyproj.Transformer.from_crs(wgs84, cur_crs, always_xy=True).transform
    bbox_tuple = transform(project, bbox).bounds

    window = windows.from_bounds(*bbox_tuple, transform=im.meta["transform"])
    result.append(im.read(window=window)[0])

  if any([min(r.shape) < 20 for r in result]):
    return []
  return interpolate_arrays(result)

def interpolate_arrays(arrays):
  interpolators = []
  for a in arrays:
    y = np.linspace(0, 1, num=a.shape[0])
    x = np.linspace(0, 1, num=a.shape[1])
    interpolators.append(interpolate.interp2d(x, y, a, kind="linear"))

  max_y = max([x.shape[0] for x in arrays])
  max_x = max([x.shape[1] for x in arrays])
  xx, yy = np.linspace(0, 1, num=max_x), np.linspace(0, 1, num=max_y)
  result = []
  for i, a in enumerate(arrays):
    result.append(interpolators[i](xx, yy))

  return np.stack(result, axis=2)
