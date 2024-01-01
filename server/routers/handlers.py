import logging

from fastapi import APIRouter, Depends, Request

from dependencies import verify_credentials
from logic.tg import TG
from logic.handler import Handler

router = APIRouter()


@router.post("/handler/", dependencies=[Depends(verify_credentials)])
async def add_handler(chat: str, request: Request):
    tg: TG = request.app.state.tg
    handler: Handler = request.app.state.handler
    await tg.add_handler(chat, handler)
    logging.info(f"Adding {chat} to chat_patterns")
    logging.info(
        f"chat_patterns: {[p.chats for _, p in tg.client.list_event_handlers()]}"
    )
    return {"status": "success"}


@router.delete("/handler/", dependencies=[Depends(verify_credentials)])
async def remove_handler(chat: str, request: Request):
    tg: TG = request.app.state.tg
    handler: Handler = request.app.state.handler
    await tg.remove_handler(chat, handler)
    logging.info(f"Removing {chat} from chat_patterns")
    logging.info(
        f"chat_patterns: {[p.chats for _, p in tg.client.list_event_handlers()]}"
    )
    return {"status": "success"}


@router.get("/handler/")
async def list_handlers(request: Request):
    tg: TG = request.app.state.tg
    return {"handlers": [p for _, p in tg.client.list_event_handlers()]}
