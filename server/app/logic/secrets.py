from dotenv import load_dotenv
import os

def load_secrets() -> tuple[int, str, str, str, str]:
    api_id = int(os.environ["API_ID"])
    api_hash = os.environ["API_HASH"]
    phone_number = os.environ["PHONE_NUMBER"]
    login = os.environ["LOGIN"]
    password = os.environ["PASSWORD"]
    return api_id, api_hash, phone_number, login, password
