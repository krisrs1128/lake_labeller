import pystac_client
import planetary_computer as pc
import geopandas as gpd
import rasterio
from rasterio import warp, windows, crs
from scipy import interpolate
from shapely.geometry import Point, box
from shapely.geometry.polygon import Polygon
import pyproj
import rasterio.windows as windows
from shapely.ops import transform
import numpy as np


def interpolation(arrays, dim0=5000):
    """
    Interpolate a list of 2D arrays

    This is needed because the sentinel bands have different resolutions. To
    save them into a single raster, we need to interpolate them to a shared
    pixel x-y dimension.
    """
    result = []
    dim1 = dim0 * arrays[0].shape[1] / arrays[0].shape[0]

    for a in arrays:
        x = np.linspace(0, 1, a.shape[1])
        y = np.linspace(0, 1, a.shape[0])
        f = interpolate.interp2d(x, y, a, kind="linear")
        result.append(f(np.linspace(0, 1, int(dim0)),np.linspace(0, 1, int(dim1))))
    return np.stack(result)


def update_profile(reader, count, window):
    """
    Define profile for writing

    Anytime we write a rasterio object, we have to pass in a profile. This defines
    a profile to fit in the window subregion that we care to save.
    """
    profile = reader.profile
    profile.update({ 
        "count": count, 
        "width": window.width,
        "height": window.height,
        "transform": windows.transform(window, reader.transform)
    })
    return profile


def search_catalog(bounds, date_range, constraints, collection="sentinel-2-l2a"):
    """
    Search a Collection

    This looks through a planetary computer collection (sentinel 2 by default) for
    scenes that match a query.
    """
    catalog = pystac_client.Client.open(
        "https://planetarycomputer.microsoft.com/api/stac/v1",
        modifier=pc.sign_inplace
    )
    return catalog.search(
        collections=collection,
        intersects=bounds, 
        datetime=date_range, 
        query=constraints
    )


def download_items(search_results, channels, bbox, out_dir=".", max_items=1):
    """
    Download Scenes

    This downloads from a set of planetary computer scenes. It will look for all
    assets within the channels list argument (e.g., 'B01' or 'B02' for sentinel).
    If the different assets have different dimension, they will be interpolated.
    """
    items = search_results.item_collection()
    ix = 0
    wgs84 = pyproj.CRS("EPSG:4326")
    bbox = box(*bbox)

    for item in items:
        print(f"Processing {item.id}")
        band_data = []
        for channel in channels:
             with rasterio.open(item.assets[channel].href) as reader:
                cur_crs = pyproj.CRS(reader.meta["crs"])
                project = pyproj.Transformer.from_crs(wgs84, cur_crs, always_xy=True).transform
                bbox_ = transform(project, bbox)
                print(box(*reader.bounds).contains(bbox_))
                if not box(*reader.bounds).contains(bbox_):
                    continue

                window = windows.from_bounds(*bbox_.bounds, transform=reader.meta["transform"])
                band_data.append(reader.read(window=window)[0])
                profile = update_profile(reader, len(channels), window)

        if len(band_data) > 0:
            ix += 1
            dim0 = max([b.shape[0] for b in band_data])
            band_data = interpolation(band_data, dim0)
            with rasterio.open(f"{out_dir}/{item.id}.tiff", "w", **profile) as writer:
                writer.write(np.stack(band_data))

            if ix == max_items: break


def download_scene(scene, constraints, channels, collection="sentinel-2-l2a"):
    point = Point(scene["lon"], scene["lat"]).buffer(0.05)
    date_range = f"{scene['start']}/{scene['end']}"
    search_results = search_catalog(point, date_range, constraints, collection)
    download_items(search_results, channels, point.bounds)


def download_range(scenes, start_ix, end_ix, constraints, channels, collection="sentinel-2-l2a"):
    for ix in range(start_ix, end_ix):
        download_scene(scenes[ix], constraints, channels, collection)
