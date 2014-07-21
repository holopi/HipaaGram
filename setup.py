#!/usr/bin/python
import requests
import json
from requests.adapters import HTTPAdapter
from requests.packages.urllib3.poolmanager import PoolManager
import ssl

class MyAdapter(HTTPAdapter):
    def init_poolmanager(self, connections, maxsize, block=False):
        self.poolmanager = PoolManager(num_pools=connections,
                                       maxsize=maxsize,
                                       block=block,
                                       ssl_version=ssl.PROTOCOL_TLSv1)

# Script to setup an org, app, and custom classes for HipaaGram

base_url = "https://localhost:8443"

headers = {'X-Api-Key': 'browser developer.catalyze.io 32a384f5-5d11-4214-812e-b35ced9af4d7', 'Content-Type': 'application/json'}

s = requests.Session()
s.mount('https://', MyAdapter())

# sign into the dashboard
route = '{}/v2/auth/signin'.format(base_url)
data = {'username':'josh@catalyze.io', 'password':'test123'}
r = s.post(route, data=json.dumps(data), headers=headers, verify=False)
resp = r.json()
r.raise_for_status()

headers['Authorization'] = 'Bearer {}'.format(resp['sessionToken'])

# create an org
route = '{}/v2/org'.format(base_url)
data = {'name':'joshsOrg', 'description':'org for HipaaGram'}
r = s.post(route, data=json.dumps(data), headers=headers, verify=False)
resp = r.json()
r.raise_for_status()

# create an app
route = '{}/v2/app'.format(base_url)
data = {'orgId':resp['orgId'], 'name':'HipaaGram', 'description':'HIPAA compliant messaging'}
r = s.post(route, data=json.dumps(data), headers=headers, verify=False)
resp = r.json()
r.raise_for_status()
app_id = resp['appId']
print 'appId: {}'.format(app_id)

# create an api key
route = '{}/v2/apiKey/{}'.format(base_url, app_id)
data = {'type':'ios', 'identifier':'io.catalyze.HipaaGram'}
r = s.post(route, data=json.dumps(data), headers=headers, verify=False)
resp = r.json()
r.raise_for_status()
print 'apiKey: {}'.format(resp['apiKey'])

# login to the new app
headers['X-Api-Key'] = resp['apiKey']

route = '{}/v2/auth/signin'.format(base_url)
data = {'username':'josh@catalyze.io', 'password':'test123'}
r = s.post(route, data=json.dumps(data), headers=headers, verify=False)
resp = r.json()
r.raise_for_status()

headers['Authorization'] = 'Bearer {}'.format(resp['sessionToken'])

# create the contacts custom class
route = '{}/v2/classes'.format(base_url)
data = {'name':'contacts','schema':{'user_username':'string','user_usersId':'string'},'phi':False}
r = s.post(route, data=json.dumps(data), headers=headers, verify=False)
resp = r.json()
r.raise_for_status()

# create the conversations custom class
route = '{}/v2/classes'.format(base_url)
data = {'name':'conversations','schema':{'sender':'string','recipient':'string','sender_id':'string','recipient_id':'string'},'phi':True}
r = s.post(route, data=json.dumps(data), headers=headers, verify=False)
resp = r.json()
r.raise_for_status()

# create the messages custom class
route = '{}/v2/classes'.format(base_url)
data = {'name':'messages','schema':{'conversationsId':'string','msgContent':'string','toPhone':'string','fromPhone':'string','timestamp':'string','isPhi':'boolean','fileId':'string'},'phi':True}
r = s.post(route, data=json.dumps(data), headers=headers, verify=False)
resp = r.json()
r.raise_for_status()

# set create permissions for contacts class for the app
route = '{}/v2/acl/custom/contacts/{}'.format(base_url, app_id)
data = ['create', 'retrieve']
r = s.post(route, data=json.dumps(data), headers=headers, verify=False)
resp = r.json()
r.raise_for_status()

# set create permissions for conversations class for the app
route = '{}/v2/acl/custom/conversations/{}'.format(base_url, app_id)
data = ['create']
r = s.post(route, data=json.dumps(data), headers=headers, verify=False)
resp = r.json()
r.raise_for_status()

# set create permissions for messages class for the app
route = '{}/v2/acl/custom/messages/{}'.format(base_url, app_id)
data = ['create']
r = s.post(route, data=json.dumps(data), headers=headers, verify=False)
resp = r.json()
r.raise_for_status()
