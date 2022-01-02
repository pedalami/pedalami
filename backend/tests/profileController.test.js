const request = require('supertest');
const app = require('./../../server');
const update = require('./../components/profileController').updateUserStatistics
const getEvents = require('./../components/profileController').getEvents
const getActiveEvents = require('./../components/profileController').getActiveEvents
const User = require('../schemas.js').User;
const Ride = require('../schemas.js').Ride;
const Event = require('../schemas.js').Event;
const ObjectId = require('../schemas.js').ObjectId;
const mongoose = require('mongoose');

jest.setTimeout(30000);

beforeAll(async () => {
  await mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
})

afterAll(async () => {
  await mongoose.connection.close();
})

const event_indiv = {
  'name': 'prova',
  'description': 'descrizione',
  'startDate': new Date(),
  'endDate': new Date(),
  'type': 'individual',
  'visibility': 'public'
}

const ride = Ride({
  "userId": "username",
  "name": "test_ride",
  "durationInSeconds": 200,
  "totalKm": 12,
  "pace": 10,
  "date": "2021-12-03",
  "path": [
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

describe("POST /initUser", ()=>{
  test("The response should be 400 if no userId is sent", async () =>{
    const response = await request(app).post('/users/initUser').send({});
    expect(response.status).toBe(400);
    expect(response.text).toBe('Missing userId parameter');
  })

  test("If user is already signed return 200", async () =>{
    const userId = "user_id";
    await request(app).post('/users/initUser').send({userId: userId});
    const response = await request(app).post('/users/initUser').send({
      userId: userId
    });
    expect(response.status).toBe(200);
    expect(response.body.userId).toBe(userId);
    await User.deleteOne({userId: userId});
  })

  test("Sending a request with userId should return 200 and the User", async () => {
    const userId = "user_id";
    const response = await request(app).post('/users/initUser').send({
      userId: userId
    });
    //Chiamare firbase dal backend per controllare che le uid sia di un utente
    expect(response.status).toBe(200);
    expect(response.body.userId).toBe(userId);
    await User.deleteMany({userId: userId});
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
    const oldElevation = user.statistics.totalElevationGain;
    await update(user, ride);
    expect(user.statistics.totalElevationGain).toBe(oldElevation + ride.elevationGain);
  })


})

describe("function getEvents", () =>{
  test("", async () =>{
    await request(app).post('/events/createIndividual').send(event_indiv);
    const new_event = await Event.findOne({'name': 'prova'})
    var user = User({
      "userId": "username",
      "badges": [],
      "teams": [],
      "points": 0,
      "joinedEvents": [
        new_event._id
      ],
      "statistics": {
        "numberOfRides": 0,
        "totalDuration": 0,
        "totalKm": 0,
        "averageSpeed": 0,
        "totalElevationGain": 0,
        "averageKm": 0,
        "averageDuration": 0,
        "averageElevationGain": 0,
      }
    });
    user_events = await getEvents(user);
    expect(user_events.length).toBe(1);
    expect(user_events[0]._id).toStrictEqual(ObjectId(new_event._id))
    await Event.deleteOne({'name': 'prova'})
  })
})

describe("function getActiveEvents", () =>{
  test("", async () =>{
    const today = new Date()
    const tomorrow = new Date(today)
    const yesterday = new Date(today)
    tomorrow.setDate(today.getDate() + 1)
    yesterday.setDate(today.getDate() - 1)
    const active_event = {
      'name': 'prova_active',
      'description': 'descrizione',
      'startDate': yesterday,
      'endDate': tomorrow,
      'type': 'individual',
      'visibility': 'public'
    }
    await request(app).post('/events/createIndividual').send(active_event);
    const new_event = await Event.findOne({'name': 'prova_active'})
    var user = User({
      "userId": "username",
      "badges": [],
      "teams": [],
      "points": 0,
      "joinedEvents": [
        new_event._id
      ],
      "statistics": {
        "numberOfRides": 0,
        "totalDuration": 0,
        "totalKm": 0,
        "averageSpeed": 0,
        "totalElevationGain": 0,
        "averageKm": 0,
        "averageDuration": 0,
        "averageElevationGain": 0,
      }
    });
    user_events = await getActiveEvents(user);
    expect(user_events.length).toBe(1);
    expect(user_events[0]._id).toStrictEqual(ObjectId(new_event._id))
    await Event.deleteOne({'name': 'prova_active'})
  })
})