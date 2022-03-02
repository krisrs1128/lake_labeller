import dash
from dash.dependencies import Input, Output, State
from dash import html
from dash import dcc
import dash_bootstrap_components as dbc
from dash_extensions.javascript import arrow_function
import dash_leaflet as dl
import PIL.Image
import geopandas as gpd

app = dash.Dash(__name__)
server = app.server
app.title = "Download lake labels"

# build some UI components based on a geopandas dataframe
labels_path = "../data/GL_3basins_2015.shp"
filter_fields = ["Sub_Basin", "GL_ID"]
labels = gpd.read_file(labels_path)

# some fixed styling elements
basemap_url = 'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark/{z}/{x}/{y}{r}.png'
titiler_url = "http://127.0.0.1:8000/cog/tiles/{z}/{x}/{y}.png?scale=1&format=png&TileMatrixSetId=WebMercatorQuad&url=..%2Fdata%2Fderived_data%2Fcogs%2Flakes.vrt&resampling_method=nearest&return_mask=true"

map = dl.Map(
    children=[
        dl.TileLayer(url=basemap_url, maxZoom=20),
        dl.TileLayer(url=titiler_url),
        dl.GeoJSON(data=labels[:10].to_json(), id="labels", hoverStyle=arrow_function(dict(weight=5, color='#666', dashArray='')))
    ],
    style={'width': '100%', 'height': '50vh', 'margin': "auto", "display": "block"},
    id="map",
    center=(30.3680988015709, 81.2868118286133),
    zoom=8
)

# define the overall layout
dropdowns = [dcc.Dropdown(labels[s].unique(), id=f"dropdown-{s}") for s in filter_fields]

app.layout = html.Div(
    [
        dbc.Row([
        ]),
        dbc.Container(
            [
                dbc.Row("This is the lake labelling app."),
                dbc.Row([
                    dbc.Input("latitude", placeholder="Lat", type="number"),
                    dbc.Input("longitude", placeholder="Long", type="number"),
                ]),
                *dropdowns,
                map
            ],
            fluid=True,
        ),
    ]
)

@app.callback(
    Input(component_id="latitude", component_property='value'),
    Input(component_id="longitude", component_property='value'),
    Input(component_id="map", component_property='value')
)
def update_center(latitude, longitude):
    print(map)
    map.panTo(40.737, -73.923)

if __name__ == "__main__":
    app.run_server()
