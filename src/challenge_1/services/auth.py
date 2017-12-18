#!/usr/bin/python3

from ping_api.service import *

from ping_api.service.error import abort


def check_auth(token):
    try:
        header, payload, signature = token.split('.')
        header = base64_decode(header, to_json=True)
        payload = base64_decode(payload)
        signature = base64_decode(signature)
        msg = payload
        payload = loads(payload.decode())
        if header['alg'] != 'SHA1' or header['typ'] != 'PING_TOKEN' or payload['expired_time'] < int(
                time()) or oracle.verify(msg, signature) is False:
            return False
        return True
    except:
        return False


def get_role(token):
    try:
        payload = base64_decode(token.split('.')[1], to_json=True)
        if payload['role'] == "user" or payload['role'] == "admin":
            return payload['role']
        return None
    except:
        return None


def authentication(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if 'Authorization' not in request.headers:
            abort(401, "Missing authentication credentials")
            return None
        token = request.headers['Authorization']
        if not check_auth(token):
            abort(401, 'Incorrect authentication credentials')
            return None
        return f(*args, **kwargs)

    return decorated
