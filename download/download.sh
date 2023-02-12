
#export PC_SDK_SUBSCRIPTION_KEY=
python3 download_scenes.py --start_ix $((10 * id)) --end_ix $((10 * id + 10))
mv *.tiff /staging/ksankaran/glaciers/