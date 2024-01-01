from ukrainian_tts.tts import TTS, Voices, Stress


# def play(audio_data: bytes) -> None:
#     import io
#     from pydub import AudioSegment
#     from pydub.playback import play
#
#     audio = AudioSegment.from_wav(io.BytesIO(audio_data))
#     play(audio)


def read_message(s: str, tts: TTS) -> bytes:
    return tts.tts(s, Voices.Dmytro.value, Stress.Dictionary.value)[0].getvalue()
