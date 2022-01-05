import requests
import os
import random
import string
import json


create_private_event_url = "http://localhost:8000/events/createPrivateTeam"

remote_create_private_event_url = "https://pedalami.herokuapp.com/events/createPrivateTeam"

remote = False

#remote = True

if remote:
    create_private_event_url = remote_create_private_event_url
    
payload = {
    "adminId": "yTi9ZmJbK4Sy4yykwRvrDAcCFPB3",
    "hostTeamId": "61d0c0d0d9e27a06939080c2",
    "invitedTeamId": "61b7e379f34ee1e97587502b",
    "name": "GIAN TEST",
    "description": "PROVA",
    "startDate": "2021-12-12T11:12:12.000Z",
    "endDate": "2021-12-12T11:12:12.000Z"
}

def create_evt():
    r = requests.post(create_private_event_url, json=payload)
    return json.loads(r.text)['name']


for i in range (5000):
    evt = create_evt()
    if evt == "GIAN TEST":
        print("SUCCESS" + " - " + str(i))
    else:
        print("ERROR - " + str(i))
        os._exit(1)
