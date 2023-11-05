import asyncio
import logging
from contextlib import asynccontextmanager

from fastapi import FastAPI
from app.logic.broadcast import BROADCAST

from app.logic.tg import TG
from app.routers import handlers, websockets


@asynccontextmanager
async def lifespan(_: FastAPI):
    logging.basicConfig(
        format="[%(levelname) 5s/%(asctime)s] %(name)s: %(message)s",
        level=logging.INFO,
    )

    TG()
    await TG().add_handler("me")
    await BROADCAST.connect()
    asyncio.create_task(TG().loop())

    yield

    await BROADCAST.disconnect()


app = FastAPI(lifespan=lifespan)


app.include_router(handlers.router)
app.include_router(websockets.router)
