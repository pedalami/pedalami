const request = require('supertest');
const app = require('./../../server');
const update = require('./../components/profileController').updateUserStatistics
const User = require('../schemas.js').User;
const Ride = require('../schemas.js').Ride;

describe("POST /initUser", ()=>{
  test("The response should be 400 if no userId is sent", async () =>{
    const response = await request(app).post('/users/initUser').send({});
    expect(response.status).toBe(400);
    expect(response.text).toBe('Missing parameters');
  })

  test("Sending a request with userId should return 200 and the User", async () => {
    const userId = "user_id";
    const response = await request(app).post('/users/initUser').send({
      userId: userId
    });
    expect(response.status).toBe(200);
    expect(response.body.userId).toBe(userId);
  })
})

describe("updateUserStatistics", () => {
  test("After a ride a user should have one more numberOfRides", async () =>{
    var user = User({
      "userId": "username",
      "badges": [],
      "teams": [],
      "points": 0,
      "statistics": {
        "numberOfRides": 0,
        "totalDuration": 0,
        "totalKm": 0,
        "averageSpeed": 0,
        "totalElevationGain": 0,
        "averageKm": 0,
        "averageDuration": 0,
        "averageElevationGain": 0
      }
    });
    var ride = Ride({
      "userId": "username",
      "name": "test_ride",
      "durationInSeconds": 200,
      "totalKm": 12,
      "pace": 10,
      "date": "2021-12-03",
      "geoPoints": [
        {
          "latitude": 10,
          "longitude": 10
        },
        {
          "latitude": 20,
          "longitude": 10
        }
      ],
      "elevationGain": 102,
      "points": 100
    });
    const oldNum = user.statistics.numberOfRides;
    await update(user, ride);
    expect(user.statistics.numberOfRides).toBe(oldNum + 1);
  })
  test("After a ride a user should have increased his totalDuration", async () =>{
    var user = User({
      "userId": "username",
      "badges": [],
      "teams": [],
      "points": 0,
      "statistics": {
        "numberOfRides": 0,
        "totalDuration": 0,
        "totalKm": 0,
        "averageSpeed": 0,
        "totalElevationGain": 0,
        "averageKm": 0,
        "averageDuration": 0,
        "averageElevationGain": 0
      }
    });
    var ride = Ride({
      "userId": "username",
      "name": "test_ride",
      "durationInSeconds": 200,
      "totalKm": 12,
      "pace": 10,
      "date": "2021-12-03",
      "geoPoints": [
        {
          "latitude": 10,
          "longitude": 10
        },
        {
          "latitude": 20,
          "longitude": 10
        }
      ],
      "elevationGain": 102,
      "points": 100
    });
    var oldTotDuration = user.statistics.totalDuration;
    await update(user, ride);
    expect(user.statistics.totalDuration).toBe(oldTotDuration + ride.durationInSeconds);
  })

  test("After a ride a user should have increased his totalKm", async () =>{
    var user = User({
      "userId": "username",
      "badges": [],
      "teams": [],
      "points": 0,
      "statistics": {
        "numberOfRides": 0,
        "totalDuration": 0,
        "totalKm": 0,
        "averageSpeed": 0,
        "totalElevationGain": 0,
        "averageKm": 0,
        "averageDuration": 0,
        "averageElevationGain": 0
      }
    });
    var ride = Ride({
      "userId": "username",
      "name": "test_ride",
      "durationInSeconds": 200,
      "totalKm": 12,
      "pace": 10,
      "date": "2021-12-03",
      "geoPoints": [
        {
          "latitude": 10,
          "longitude": 10
        },
        {
          "latitude": 20,
          "longitude": 10
        }
      ],
      "elevationGain": 102,
      "points": 100
    });
    const oldTotKm = user.statistics.totalKm;
    await update(user, ride);
    expect(user.statistics.totalKm).toBe(oldTotKm + ride.totalKm);
  })

  test("After a ride a user should have increased his totalElevationGain", async () =>{
    var user = User({
      "userId": "username",
      "badges": [],
      "teams": [],
      "points": 0,
      "statistics": {
        "numberOfRides": 0,
        "totalDuration": 0,
        "totalKm": 0,
        "averageSpeed": 0,
        "totalElevationGain": 0,
        "averageKm": 0,
        "averageDuration": 0,
        "averageElevationGain": 0
      }
    });
    var ride = Ride({
      "userId": "username",
      "name": "test_ride",
      "durationInSeconds": 200,
      "totalKm": 12,
      "pace": 10,
      "date": "2021-12-03",
      "geoPoints": [
        {
          "latitude": 10,
          "longitude": 10
        },
        {
          "latitude": 20,
          "longitude": 10
        }
      ],
      "elevationGain": 102,
      "points": 100
    });
    const oldElevation = user.statistics.totalElevationGain;
    await update(user, ride);
    expect(user.statistics.totalElevationGain).toBe(oldElevation + ride.elevationGain);
  })


})