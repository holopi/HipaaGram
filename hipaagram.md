#HipaaGram
##Setup
* Create an org
* Create an app and record the appId (put in app delegate)
* Create an api key and record it (put in app delegate)
* Create a custom class for conversations

```
{
"name":"conversations",
"schema":{
"sender":"string",
"recipient":"string",
"sender_id":"string",
"recipient_id":"string"
},
"phi":false
}
```

* Create a custom class for messages

```
{
"name":"messages",
"schema":{
"msgContent":"string",
"toPhone":"string",
"fromPhone":"string",
"timestamp":"string",
"isPhi":"boolean",
"fileId":"string",
"conversationsId":"string"
},
"phi":false
}
```

* Create a custom class for contacts

```
{
"name":"contacts",
"schema":{
"user_username":"string",
"user_usersId":"string"
},
"phi":false
}
```

* Give default WRITE permission to all of the above 3 custom classes. You will also need retrieve permissions for contacts.

```
POST /v2/acl/custom/{conversations,messages}/{appId}
["create"]
```

```
POST /v2/acl/custom/contacts/{appId}
["create", "retrieve"]
```

##Alternate Setup
* Run `python setup.py` in the root of the HipaaGram project folder. This will print out appId and apiKey for you.

##Final Steps
1. code
2. send texts
3. profit
