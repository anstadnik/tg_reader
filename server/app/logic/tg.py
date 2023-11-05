import asyncio
import logging
import os

from telethon import TelegramClient, events
from telethon.events.newmessage import NewMessage

from app.logic.singleton import SingletonMeta

from .broadcast import BROADCAST, CHANNEL

chat_patterns: dict[int, set[str]] = {}


async def handler(event: NewMessage.Event):
    logging.info(f"Got message from {event.chat_id}")
    logging.info(f"Message: {event.message.text}")
    chat = event.chat_id
    assert chat is not None
    patterns = chat_patterns.get(chat)
    if not patterns or any(p in event.message.text.lower() for p in patterns):
        # read_message(event.message.text)

        # TODO: Send .wav files instead
        logging.info(f"Sending {event.message.text} to {CHANNEL}")
        await BROADCAST.publish(channel=CHANNEL, message=event.message.text)
        logging.info(f"Sent {event.message.text} to {CHANNEL}")


class TG(metaclass=SingletonMeta):
    def __init__(
        self,
        phone_number: str | None = None,
        api_id: str | None = None,
        api_hash: str | None = None,
    ):
        logging.info("Initializing TG")

        phone_number = phone_number or os.getenv("PHONE_NUMBER")
        api_id = api_id or os.getenv("API_ID")
        api_hash = api_hash or os.getenv("API_HASH")
        assert phone_number and api_id and api_hash

        self.client = TelegramClient(phone_number, int(api_id), api_hash)
        self.lock = asyncio.Lock()

    async def add_handler(self, chat: str):
        logging.info(f"Adding handler for {chat}")
        async with self.lock:
            self.client.add_event_handler(handler, events.NewMessage(chats=chat))

    async def remove_handler(self, chat: str):
        logging.info(f"Removing handler for {chat}")
        async with self.lock:
            self.client.remove_event_handler(handler, events.NewMessage(chats=chat))

    async def loop(self):
        logging.info("Starting loop")
        await self.client.start()  # pyright: ignore
        await self.client.run_until_disconnected()  # pyright: ignore
