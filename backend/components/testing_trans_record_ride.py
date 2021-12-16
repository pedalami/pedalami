import requests
import os
import random
import string
import json

MODIFIED_DB = False

if not MODIFIED_DB:
    print('\033[93m' + "BEFORE RUNNING THIS TEST, YOU HAVE TO MODIFY THE DB\nTO DO SO, OPEN THE FILE schemas.js ")
    print('\033[93m' + "AND MODIFY THE LINE exports.Ride = mongoose.model(\"Ride\", RideSchema); INTO exports.Ride = mongoose.model(\"TestRide\", RideSchema);")
    print('\033[91m' + "BE VERY CAREFUL, OTHERWISE YOU WILL MESS UP WITH THE DB")
    os._exit(1)

record_ride_url = "http://localhost:8000/rides/record"
get_user_url = "http://localhost:8000/users/initUser"
get_rides_url = "http://localhost:8000/rides/getAllByUserId"

remote_record_ride_url = "https://pedalami.herokuapp.com/rides/record"
remote_get_user_url = "https://pedalami.herokuapp.com/users/initUser"
remote_get_rides_url = "https://pedalami.herokuapp.com/rides/getAllByUserId"

remote = False

#remote = True

if remote:
    record_ride_url = remote_record_ride_url
    get_user_url = remote_get_user_url
    get_rides_url = remote_get_rides_url
    
payload_ger_rides = {
    "userId": "transactionTest"
}

def record_ride(userId):
    payload_record_ride = {
    "userId": userId,
    "name": "transactionalRide:"+ ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(10)),
    "durationInSeconds": 50,
    "totalKm": 100,
    "date": "2021-11-29",
    "elevationGain": 10
    }
    r = requests.post(record_ride_url, json=payload_record_ride)
    return json.loads(r.text)['id']

def get_rides(userId):
    r = requests.get(get_rides_url, params={'userId': userId})
    return json.loads(r.text)['rides']

def get_user(userId):
    r = requests.post(get_user_url, json={'userId': userId})
    return json.loads(r.text)


userId = "transactionTestRides"
for i in range (5000):
    old_num_rides = get_user(userId)["statistics"]["numberOfRides"]
    rideId = record_ride(userId)
    new_num_of_rides = get_user(userId)["statistics"]["numberOfRides"]
    if new_num_of_rides == old_num_rides+1:
        print("SUCCESS" + " - " + str(i))
    else:
        print("ERROR - " + str(i))
        os._exit(1)
