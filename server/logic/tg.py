import asyncio
import logging
import os

from telethon import TelegramClient, events

from logic.handler import Handler


class TG:
    def __init__(self, api_id: str | None = None, api_hash: str | None = None):
        logging.info("Initializing TG")

        # phone_number = phone_number or os.getenv("PHONE_NUMBER")
        session_name = "tg_reader"
        api_id = api_id or os.getenv("API_ID")
        api_hash = api_hash or os.getenv("API_HASH")
        assert api_id and api_hash

        self.client = TelegramClient(session_name, int(api_id), api_hash)
        self.lock = asyncio.Lock()

    async def add_handler(self, chat: str, handler: Handler):
        logging.info(f"Adding handler for {chat}")
        async with self.lock:
            self.client.add_event_handler(handler, events.NewMessage(chats=chat))

    async def remove_handler(self, chat: str, handler: Handler):
        logging.info(f"Removing handler for {chat}")
        async with self.lock:
            self.client.remove_event_handler(handler, events.NewMessage(chats=chat))

    async def loop(self):
        logging.info("Starting loop")
        await self.client.start()  # pyright: ignore
        await self.client.run_until_disconnected()  # pyright: ignore
