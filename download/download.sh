
#export PC_SDK_SUBSCRIPTION_KEY=
python3 download_scenes.py --start_ix $((2 * Process)) --end_ix $((2 * Process + 1))
mv *.tiff /staging/ksankaran/glaciers/