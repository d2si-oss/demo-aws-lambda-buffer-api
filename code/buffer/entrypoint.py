# -*- coding: utf-8 -*-
from __future__ import print_function
import settings
import json
import logging
import requests

print('Loading entrypoint...')

logging.basicConfig()
log = logging.getLogger()
log.setLevel(logging.DEBUG)

def log_event(event):
    log.debug('body: ' + str(event.get('body', '')))
    log.debug('method: ' + str(event.get('method', '')))
    log.debug('params: ' + str(event.get('params', '')))
    log.debug('query: '+ str(event.get('query', '')))

def query(query):
    headers = {}
    response = requests.get(query, headers=headers)
    if response.status_code != 200:
        raise Exception('Resource does not exist ' + str(response.status_code) + query )
    return response

def proxy_handler(event, context):
    """Call the base API with proxy params and return the response
    """
    log_event(event)
    scheme = 'https://'
    base_api = event['stageVariables']['BASE_API']
    text = query("{0}/{1}/".format(
        base_api,
        event['params']['proxy'])
    ).text.replace(base_api, scheme + event['headers']['Host'] + '/' + event['stage'])
    return json.loads(text)
