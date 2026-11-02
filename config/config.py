import os
from pathlib import Path
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parents[1]
load_dotenv(BASE_DIR / '.env', override=False)


def project_path(value: str) -> Path:
    path = Path(value).expanduser()
    return path if path.is_absolute() else BASE_DIR / path


class Config:
    DATABASE_URL = os.getenv('DATABASE_URL')
    GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')
    GEMINI_MODEL = os.getenv('GEMINI_MODEL', 'gemini-3.5-flash-lite')
    CHAT_PROMPT_PATH = project_path(os.getenv('CHAT_PROMPT_PATH', 'src/prompts/system_prompt.md'))
    STORE_MANUAL_PATH = project_path(os.getenv('STORE_MANUAL_PATH', 'src/data/politicas_da_loja.pdf'))
