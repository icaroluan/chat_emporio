import os
import sys
from dotenv import load_dotenv

if getattr(sys, 'frozen', False):
    BASE_DIR = sys._MEIPASS
else:
    BASE_DIR = os.path.dirname(os.path.abspath(__file__))

ENV_PATH = os.path.join(BASE_DIR, ".env")

load_dotenv(ENV_PATH)

class Config:
    
    GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")

