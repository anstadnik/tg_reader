from fastapi import APIRouter, Request
import logging
from fastapi import WebSocket


router = APIRouter()


@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    broadcast = websocket.app.state.broadcast
    channel = websocket.app.state.channel
    logging.info(f"Accepting websocket {websocket.client}")
    await websocket.accept()
    logging.info(f"Accepted websocket {websocket.client}")
    # async with BROADCAST.subscribe(channel=CHANNEL) as subscriber:
    async with broadcast.subscribe(channel=channel) as subscriber:
        logging.info(f"Subscribed to {channel} in websocket {websocket.client}")
        async for event in subscriber:
            logging.info(
                f"Sending {len(event.message)} bytes to websocket {websocket.client}"
            )
            await websocket.send_bytes(event.message)
            logging.info(
                f"Sent {len(event.message)} bytes to websocket {websocket.client}"
            )
