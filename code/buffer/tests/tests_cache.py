import boot

import sys
import unittest
import json
import os

import cache
print "---- Loading from ---"
print cache.__file__

from cache import Cache

AWS_DEFAULT_REGION = 'eu-west-1'
TABLE_NAME = 'dev-buffer-api-proxy'

class TestCache(unittest.TestCase):
    def setUp(self):
        self.cache = Cache(AWS_DEFAULT_REGION, TABLE_NAME)

    def testTrue(self):
        assert True

    def testGetCacheKey(self):
        key = self.cache.get_cache_key('/profile', 89078977)
        self.assertEqual(len(key), Cache.MAX_DIGITS)

    def testSetDoc(self):
        self.cache.set_doc('/check', 69097, { 'hello': 'world' } )
        doc = self.cache.get_doc('/check', 69097)

    def testGetDoc(self):
        dico = { 'hello': 'world' }
        self.cache.set_doc('/check', 69987, dico)
        doc = self.cache.get_doc('/check', 69987)
        assert doc is not None
        self.assertEqual(doc, dico)

    def testBase62(self):
        o = self.cache.base62_encode(0)
        self.assertEqual(o,'a')

    def testDocExist(self):
        doc = self.cache.get_doc('/my-way', 45345369987)
        assert doc is None

if __name__ == "__main__":
    unittest.main()
