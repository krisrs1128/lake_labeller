
#export PC_SDK_SUBSCRIPTION_KEY=
python3 download_scenes.py --start_ix $((10 * Process)) --end_ix $((10 * Process + 9))
mv *.tiff /staging/ksankaran/glaciers/