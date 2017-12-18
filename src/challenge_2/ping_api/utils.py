#!/usr/bin/python3

import math
from base64 import b64encode, b64decode
from json import dumps, loads
from os.path import join, dirname, realpath

KEY_PATH = join((dirname(realpath(__file__))), 'private', 'key.pem')
FLAG_PATH = join((dirname(realpath(__file__))), 'private', 'flag')


def int_to_bytes(n):
    byte_length = math.ceil(n.bit_length() / 8.0)
    return n.to_bytes(byte_length, 'big')


def base64_encode(msg, non_encode=False):
    if non_encode:
        return b64encode(msg).decode()
    if isinstance(msg, str):
        return b64encode(msg.encode()).decode()
    return b64encode(dumps(msg).encode()).decode()


def base64_decode(msg, to_json=False):
    try:
        if to_json:
            return loads(b64decode(msg, validate=True).decode())
        else:
            return b64decode(msg, validate=True)
    except:
        return None
