from scipy import interpolate
import numpy as np
import rasterio
import rasterio.windows as windows

def read_windows(links, bbox):
  result = []
  for link in links:
    im = rasterio.open(link)
    window = windows.from_bounds(*bbox, transform=im.meta["transform"])
    result.append(im.read(window=window)[0,:, :])

  return interpolate_arrays(result)

def interpolate_arrays(arrays):
  interpolators = []
  for a in arrays:
    y = np.linspace(0, 1, num=a.shape[0])
    x = np.linspace(0, 1, num=a.shape[1])
    interpolators.append(interpolate.interp2d(x, y, a))

  max_y = max([x.shape[0] for x in arrays])
  max_x = max([x.shape[1] for x in arrays])
  xx, yy = np.linspace(0, 1, num=max_x), np.linspace(0, 1, num=max_y)
  result = []
  for i, a in enumerate(arrays):
    result.append(interpolators[i](xx, yy))

  return np.stack(result, axis=2)
