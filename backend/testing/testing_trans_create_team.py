import requests
import os
import random
import string
import json
from time import sleep

MODIFIED_DB = False

if not MODIFIED_DB:
    print('\033[93m' + "BEFORE RUNNING THIS TEST, YOU HAVE TO MODIFY THE DB\nTO DO SO, OPEN THE FILE schemas.js ")
    print('\033[93m' + "AND MODIFY THE LINE exports.Team = mongoose.model(\"TEAM\", TeamSchema); INTO exports.Team = mongoose.model(\"TestTeam\", TeamSchema);")
    print('\033[93m' +"THEN OPEN THE FILE profileController.js AND MODIFY THE LINE { $lookup: { from: \"teams\" TO { $lookup: {from: \"testteams\"")
    print('\033[93m' + "THEN, RUN THIS SCRIPT AGAIN SETTING MODIFIED_DB = True")
    print('\033[91m' + "BE VERY CAREFUL, OTHERWISE YOU WILL MESS UP WITH THE DB")
    os._exit(1)

create_url = "http://localhost:8000/teams/create"
get_teams_url = "http://localhost:8000/users/initUser"
get_members_url = "http://localhost:8000/teams/getTeam"

remote_create_url= "https://pedalami.herokuapp.com/teams/create"
remote_get_teams_url = "https://pedalami.herokuapp.com/users/initUser"
remote_get_members_url = "https://pedalami.herokuapp.com/teams/getTeam"

remote = False

#remote = True

if remote:
    create_url = remote_create_url
    get_teams_url = remote_get_teams_url
    get_members_url = remote_get_members_url

payload_init = {
    "userId": "transactionTest",
}

payload_get_teams = {
    "userId": "transactionTest",
}

payload_get_members = {
    "teamId": "to_insert"
}

def create_team():
    payload_create = {
    "adminId": "transactionTest",
    "name": "createTransactionTest_rand:" + ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(10))
    }
    r = requests.post(create_url, json=payload_create)
    return json.loads(r.text)['teamId']

def get_team(teamId):
    r = requests.post(get_teams_url, json=payload_get_teams)
    for team in json.loads(r.text)['teams'] :
        if team['_id'] == teamId:
            return team
    return None

def get_members(teamId):
    r = requests.get(get_members_url, params={'teamId': teamId})
    return json.loads(r.text)['members']

for i in range (5000):
    found = False
    team_id = create_team()
    result_team = get_team(team_id)
    if result_team and result_team["adminId"] == "transactionTest":
        members = get_members(team_id)
        for user in members:
            if user["userId"] == "transactionTest":
                print("SUCCESS " + str(i))
                found = True
                break
        if not found:
            print("ERROR: user not found in members")
            os._exit(1)
    else:
        print("ERROR: team not found")
        os._exit(1)


"""for i in range(5000):
    print(i)
    r1 = join_team()
    if r1.status_code == 200:
        r2 = join_team()
        if r2.status_code == 200:
            print("SUPER ERROR IN JOIN")
            os._exit(1)
    else:
        print("ERROR IN JOIN: "+r1.text)
        os._exit(1)
    r1 = leave_team()
    if r1.status_code == 200:
        r2 = leave_team()
        if r2.status_code == 200:
            print("SUPER ERROR IN LEAVE")
            os._exit(1)
    else:
        print("ERROR IN LEAVE: "+r1.text)
        os._exit(1)

print("SUCCESS")"""