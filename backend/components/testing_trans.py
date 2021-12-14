import requests
import os

join_url = "http://localhost:8000/teams/join"
leave_url = "http://localhost:8000/teams/leave"

remote_join_url = "https://pedalami.herokuapp.com/teams/join"
remote_leave_url = "https://pedalami.herokuapp.com/teams/leave"

remote = False

#remote = True

if remote:
    join_url = remote_join_url
    leave_url = remote_leave_url

payload = {
    "userId": "15MkgTwMyOST77sinqjCzBhaPyE3",
    "teamId": "61b7a6d7d13fcf04e9955329"
}

def join_team():
    r = requests.post(join_url, json=payload)
    return r

def leave_team():
    r = requests.post(leave_url, json=payload)
    return r

for i in range(1000):
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

print("SUCCESS")