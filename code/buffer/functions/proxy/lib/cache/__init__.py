# -- coding: utf-8 --

from __future__ import print_function
import boto3
import json
import decimal
import time
import datetime
import pytz
import hashlib
import dateutil.parser

# Helper class to convert a DynamoDB item to JSON.
class DecimalEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, decimal.Decimal):
            if o % 1 > 0:
                return float(o)
            else:
                return int(o)
        return super(DecimalEncoder, self).default(o)

class CacheBase(object):
    ALPHABET = list("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
    MAX_DIGITS = 10

    def get_cache_key(self, _type='default', identifier=None):
        key = str(identifier) + _type
        i = int(hashlib.sha1(key).hexdigest(), 16) % (len(CacheBase.ALPHABET) ** CacheBase.MAX_DIGITS)
        return self.base62_encode(i)

    def base62_encode(self, i):
        if i is 0:
            return CacheBase.ALPHABET[0]
        else:
                s = ''
                base = len(CacheBase.ALPHABET)
                while i > 0:
                    s += CacheBase.ALPHABET[i % base]
                    i /= base
                return s[::-1]

    def clear(self):
        print('should be Implemented')

    def get_doc(self, _type, identifier):
        print('should be Implemented')

    def set_doc(self, _type, identifier, data):
        print('should be Implemented')

# Cache class based on DynamoDB
class Cache(CacheBase):
    cache_lifetime = 24 * 3600 # db_cache = 24h;

    def __init__(self,
                 region_name,
                 table_name,
                 endpoint_url=None,
                 aws_access_key_id=None,
                 aws_secret_access_key=None):
        print('Cache will use ' + table_name)
        self.dynamodb = boto3.resource('dynamodb',
                                       region_name=region_name,
                                       endpoint_url=endpoint_url,
                                       aws_access_key_id=aws_access_key_id,
                                       aws_secret_access_key=aws_secret_access_key)
        self.table = self.dynamodb.Table(table_name)

    def get_doc(self, _type, identifier):
        try:
            response = self.table.get_item(
                Key={
                    'cache_key': self.get_cache_key(_type, identifier)
                }
            )
        except Exception as e:
            print(e)
            pass
        else:
            try:
                timestamp = dateutil.parser.parse(response['Item']['insert_timestamp'])
                now = datetime.datetime.now(tz=pytz.utc)
                delta = now - timestamp
                cache_insert = delta.total_seconds()
                if (cache_insert < self.cache_lifetime ):
                    return json.loads(response['Item']['data'])
                else:
                    pass
            except KeyError:
                pass

    def set_doc(self, _type, identifier, data):
        timestamp = datetime.datetime.now(tz=pytz.utc).isoformat()
        cache_key = self.get_cache_key(_type, identifier)
        try:
            response = self.table.put_item(
                Item={
                      'cache_key': cache_key,
                      'data': json.dumps(data),
                      'insert_timestamp': timestamp,
                      'identifier': json.dumps(identifier),
                      '_type': _type
                }
            )
            return response
        except Exception as e:
            print(e)
            pass
