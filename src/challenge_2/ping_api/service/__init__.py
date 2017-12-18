#!/usr/bin/python3

from flask import jsonify, request, Flask
from datetime import datetime, timedelta
from time import mktime, time
from ping_api.crypto.oracle import oracle
from uuid import uuid4
from werkzeug.exceptions import HTTPException
from functools import wraps
from json import loads, dumps
from ping_api.utils import base64_decode, base64_encode, FLAG_PATH

app = Flask(__name__)
app.config.update(
    DEBUG=False,
)
