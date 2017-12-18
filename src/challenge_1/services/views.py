#!/usr/bin/python3

from ping_api.service import *
from ping_api.service.auth import authentication, get_role


@app.route('/', methods=['GET'])
def index():
    response = {
        'endpoints': {
            'get_token': '/token',
            'dashboard': '/dashboard'
        }
    }
    return jsonify(response)


@app.route('/dashboard', methods=['GET'])
@authentication
def dashboard():
    try:
        token = request.headers['Authorization']
        role = get_role(token)
        if role == 'admin':
            return jsonify({'message': open(FLAG_PATH, 'r').read()})
        elif role == 'user':
            return jsonify({'message': 'Nothing Here But Love'})
        else:
            return jsonify({'message': 'Nothing Here But Thieves'})
    except:
        return jsonify({'message': 'Nothing Here But Thieves'})


@app.route('/token', methods=['GET'])
def token():
    end_date = datetime.now() + timedelta(minutes=10)
    expired_time = int(mktime(end_date.timetuple()))
    header = {"alg": "SHA1", "typ": "PING_TOKEN"}
    payload = '{"role": "user", "expired_time":%d, "unique":"%s"}' % (expired_time, str(uuid4()))

    msg = payload.encode()
    signature = oracle.sign(msg)
    token = "%s.%s.%s" % (
        base64_encode(header), base64_encode(payload), base64_encode(signature, non_encode=True))
    return jsonify({'token': str(token)})
