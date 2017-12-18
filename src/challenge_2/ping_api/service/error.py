#!/usr/bin/python3

from ping_api.service import *


@app.errorhandler(400)
def invalid_input(error):
    response = jsonify({'code': 400,
                        'message': 'Input is not valid'})
    response.status_code = 400
    return response


@app.errorhandler(404)
def not_found(error):
    response = jsonify({'code': 404,
                        'message': 'Not found'})
    response.status_code = 404
    return response


@app.errorhandler(405)
def method_not_allowed(error):
    response = jsonify({'code': 405,
                        'message': 'Method not allowed'})
    response.status_code = 405
    return response


@app.errorhandler(500)
def internal_error(error):
    response = jsonify({'code': 500,
                        'message': "Something's wrong here"})
    response.status_code = 500
    return response


class JSONHTTPException(HTTPException):
    def __init__(self, description=None, code=None):
        Exception.__init__(self)
        self.response = None
        self.description = description
        self.code = code

    def get_body(self, environ=None):
        return dumps({'message': self.description,
                      'code': self.code})

    def get_headers(self, environ=None):
        return [('Content-Type', 'application/json')]


def abort(code, message):
    raise JSONHTTPException(message, code)
