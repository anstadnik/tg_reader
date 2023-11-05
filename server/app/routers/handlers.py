import logging

from fastapi import APIRouter, Depends

from app.dependencies import verify_credentials
from app.logic.tg import TG

router = APIRouter()


@router.post("/handler/", dependencies=[Depends(verify_credentials)])
async def add_handler(chat: str):
    await TG().add_handler(chat)
    logging.info(f"Adding {chat} to chat_patterns")
    logging.info(
        f"chat_patterns: {[p.chats for _, p in TG().client.list_event_handlers()]}"
    )
    return {"status": "success"}


@router.delete("/handler/", dependencies=[Depends(verify_credentials)])
async def remove_handler(chat: str):
    await TG().remove_handler(chat)
    logging.info(f"Removing {chat} from chat_patterns")
    logging.info(
        f"chat_patterns: {[p.chats for _, p in TG().client.list_event_handlers()]}"
    )
    return {"status": "success"}


@router.get("/handler/")
async def list_handlers():
    return {"handlers": [p for _, p in TG().client.list_event_handlers()]}
