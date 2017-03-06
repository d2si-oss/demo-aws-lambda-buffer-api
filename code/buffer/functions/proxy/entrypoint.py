# -*- coding: utf-8 -*-
from __future__ import print_function

import boot

import json
import logging
import requests
import os
import boto3
import random
import time

print('Loading entrypoint...')

logging.basicConfig()
log = logging.getLogger()
log.setLevel(logging.DEBUG)

# Load environment variables
from os.path import join, dirname
from dotenv import load_dotenv
dotenv_path = join(dirname(__file__), '.env')
load_dotenv(dotenv_path)

def log_event(event):
    log.debug('body: ' + str(event.get('body', '')))
    log.debug('method: ' + str(event.get('method', '')))
    log.debug('params: ' + str(event.get('params', '')))
    log.debug('query: '+ str(event.get('query', '')))

def query(url, method, headers, data, params):
    if method == 'get' or method == 'post':
        response = requests.__getattribute__(method)(url, headers=headers, data=data, params=params)
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
        event['params']
    ).text
    scheme = 'https://'
    text = text.replace(base_api, scheme + event['headers']['Host'] + '/' + event['stage'])
    return json.loads(text)
