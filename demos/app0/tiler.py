"""
Run using,

uvicorn tiler:app
"""
from titiler.core.factory import TilerFactory
from titiler.core.errors import DEFAULT_STATUS_CODES, add_exception_handlers
from fastapi import FastAPI

app = FastAPI()
cog = TilerFactory(router_prefix="cog")
app.include_router(cog.router, prefix="/cog")
add_exception_handlers(app, DEFAULT_STATUS_CODES)
