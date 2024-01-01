import logging

from broadcaster import Broadcast
from logic.tts import read_message
from telethon.events.newmessage import NewMessage
from ukrainian_tts.tts import TTS


class Handler:
    def __init__(self, broadcast: Broadcast, channel: str) -> None:
        self.chat_patterns: dict[int, set[str]] = {}
        self.tts = TTS(device="cpu")
        self.broadcast = broadcast
        self.channel = channel

    async def __call__(self, event: NewMessage.Event):
        logging.info(f"Got message from {event.chat_id}")
        logging.info(f"Message: {event.message.text}")
        chat = event.chat_id
        assert chat is not None
        patterns = self.chat_patterns.get(chat)
        if not patterns or any(p in event.message.text.lower() for p in patterns):
            wav_bytes = read_message(event.message.text, self.tts)

            logging.info(f"Sending {event.message.text} to {self.channel}")
            await self.broadcast.publish(channel=self.channel, message=wav_bytes)
            logging.info(f"Sent {event.message.text} to {self.channel}")
