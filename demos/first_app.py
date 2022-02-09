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
print(labels.head())

# some fixed styling elements
SIDEBAR_STYLE = {
    "position": "fixed",
    "top": 0,
    "left": 0,
    "bottom": 0,
    "width": "16rem",
    "padding": "2rem 1rem",
    "background-color": "#f8f9fa",
}

map = dl.Map(
    children=[
        dl.TileLayer(),
        dl.GeoJSON(
            data=labels[:10].to_json(),
            id="labels",
            hoverStyle=arrow_function(dict(weight=5, color='#666', dashArray=''))
        )],
    style={'width': '100%', 'height': '50vh', 'margin': "auto", "display": "block"},
    id="map",
    center=(28.887046, 86.513408),
    zoom=9
)

# define the overall layout
dropdowns = [dcc.Dropdown(labels[s].unique(), id=f"dropdown-{s}") for s in filter_fields]

app.layout = html.Div(
    [
        dbc.Container(
            [
                dbc.Row("This is the lake labelling app."),
                *dropdowns,
                map
            ],
            fluid=True,
        ),
    ],
    style=SIDEBAR_STYLE,
)


if __name__ == "__main__":
    app.run_server()
