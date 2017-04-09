# -*- coding: utf-8 -*-
from __future__ import print_function

import boot

# vendor
import json
import logging
import requests
import os
import boto3
import random
import time

# libs
from cache import Cache

print('Loading entrypoint...')

logging.basicConfig()
log = logging.getLogger()
log.setLevel(logging.DEBUG)

# Load environment variables
from os.path import join, dirname
from dotenv import load_dotenv
dotenv_path = join(dirname(__file__), '.env')
load_dotenv(dotenv_path)

AWS_DEFAULT_REGION = 'eu-west-1'
TABLE_NAME_SUF = "-buffer-api-proxy"

def log_event(event):
    log.debug('body: ' + str(event.get('body', '')))
    log.debug('method: ' + str(event.get('method', '')))
    log.debug('params: ' + str(event.get('params', '')))
    log.debug('query: '+ str(event.get('query', '')))

def query(url, method, headers, data, params, stage):
    buffy = Cache(AWS_DEFAULT_REGION, stage + TABLE_NAME_SUF)
    payload = dict(data.items() + params.items())
    doc = buffy.get_doc(url, payload)
    if doc is None:
        doc = requests.request(method, url, headers=headers, data=data, params=params).text
        buffy.set_doc(url, payload, doc)
        return doc
    else:
        return doc

    if response.status_code != requests.codes.ok:
        response.raise_for_status()
    return response

def proxy_handler(event, context):
    """Call the base API with proxy params and return the response
    """
    log_event(event)
    base_api = os.environ['BASE_API']
    headers = {}
    text = query(
        "{0}/{1}/".format(base_api, event['params']['proxy']),
        event['httpMethod'].lower(),
        headers,
        event['body'],
        event['params'],
        event['stage']
    )
    scheme = 'https://'
    text = text.replace(base_api, scheme + event['headers']['Host'] + '/' + event['stage'])
    return json.loads(text)
