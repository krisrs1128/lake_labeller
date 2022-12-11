import argparse
import json
from helpers import download_range

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--start_ix", type=int)
parser.add_argument("-e", "--end_ix", type=int)
args = parser.parse_args()

# download the sentinel scenes
scenes = json.load(open("scenes.json", "r"))
constraints = {"eo:cloud_cover": {"lt": 20}, "s2:nodata_pixel_percentage": {"lt": 10}}
channels = ['B01', 'B02', 'B03', 'B04', 'B05', 'B06', 'B07', 'B08', 'B09', 'B11', 'B12']
#download_range(scenes, args.start_ix, args.end_ix, constraints, channels)

# download the corresponding SAR scenes
constraints = {}
channels = ['vv', 'vh'] # vertical and horizontal polarization
download_range(scenes, args.start_ix, args.end_ix, constraints, channels, collection="sentinel-1-rtc")