#!/usr/bin/python3

import re
from Crypto.Signature import PKCS1_v1_5
from Crypto.PublicKey import RSA
from Crypto.Hash import SHA as SHA
from Crypto.Util import asn1
from ping_api.utils import *
from binascii import hexlify, unhexlify


class Oracle:
    def __init__(self):
        self.key = RSA.importKey(open(KEY_PATH, 'rb').read())
        self.public_key = self.key.publickey()

    def verify(self, message, signature):
        n = self.public_key.n
        e = self.public_key.e
        c = int(hexlify(signature), 16)
        m = int_to_bytes(pow(c, e, n))

        r = re.match(br'01(ff)+00', hexlify(m))
        if not r:
            return False
        asn = unhexlify(hexlify(m)[r.end():])
        try:
            sequence = asn1.DerSequence()
            sequence.decode(asn)
            found_hash = sequence[1][2:]
        except (ValueError, IndexError) as e:
            return False

        expected_hash = SHA.new(message).digest()
        return expected_hash == found_hash

    @staticmethod
    def generate_key(destination):
        """
        This method only use for generating a Private key, not use for the Oracle
        """
        key = RSA.generate(1024, e=3)
        with open(destination, "wb") as key_file:
            key_file.write(key.exportKey())

    def sign(self, message):
        h = SHA.new(message)
        signer = PKCS1_v1_5.new(self.key)
        signature = signer.sign(h)
        return signature


oracle = Oracle()
# oracle.generate_key("key.pem")
