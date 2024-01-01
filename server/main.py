import asyncio
import logging
from contextlib import asynccontextmanager
from broadcaster import Broadcast

from dotenv import load_dotenv
from fastapi import FastAPI


load_dotenv()

from logic.tg import TG  # noqa
from logic.handler import Handler  # noqa
from routers import handlers, websockets  # noqa


@asynccontextmanager
async def lifespan(app: FastAPI):
    logging.basicConfig(
        format="[%(levelname) 5s/%(asctime)s] %(name)s: %(message)s",
        level=logging.INFO,
    )

    broadcast = Broadcast("memory://")
    channel = "messages"

    tg = TG()
    handler = Handler(broadcast, channel)
    await tg.add_handler("war_monitor", handler)
    await tg.add_handler("astadnik", handler)
    await broadcast.connect()
    asyncio.create_task(tg.loop())

    app.state.tg = tg
    app.state.handler = handler
    app.state.broadcast = broadcast
    app.state.channel = channel

    yield

    await broadcast.disconnect()


app = FastAPI(lifespan=lifespan)


app.include_router(handlers.router)
app.include_router(websockets.router)
