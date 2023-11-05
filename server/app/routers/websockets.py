from fastapi import APIRouter
import logging
from fastapi import WebSocket

from app.logic.broadcast import BROADCAST, CHANNEL


router = APIRouter()


@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    logging.info(f"Accepting websocket {websocket.client}")
    await websocket.accept()
    logging.info(f"Accepted websocket {websocket.client}")
    async with BROADCAST.subscribe(channel=CHANNEL) as subscriber:
        logging.info(f"Subscribed to {CHANNEL} in websocket {websocket.client}")
        async for event in subscriber:
            logging.info(
                f"Sending {len(event.message)} bytes to websocket {websocket.client}"
            )
            await websocket.send_bytes(event.message)
            logging.info(
                f"Sent {len(event.message)} bytes to websocket {websocket.client}"
            )
