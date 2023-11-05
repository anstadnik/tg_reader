from ukrainian_tts.tts import TTS, Voices, Stress
import io
from pydub import AudioSegment
from pydub.playback import play
import warnings

warnings.filterwarnings(
    "ignore", category=UserWarning, message="TypedStorage is deprecated"
)


# tts = TTS(device="cpu")
tts = None

def read_message(s: str) -> bytes:
    global tts
    if tts is None:
        tts = TTS(device="cpu")
    with io.BytesIO() as b:
        _, output_text = tts.tts(s, Voices.Dmytro.value, Stress.Dictionary.value, b)
        audio_data = b.getvalue()

    # Play audio
    # return s
    return audio_data
    # audio = AudioSegment.from_wav(io.BytesIO(audio_data))
    # play(audio)
