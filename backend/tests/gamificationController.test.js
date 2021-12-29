const assign = require('./../components/gamificationController').assignPoints;
const checkBadge = require('./../components/gamificationController').checkNewBadgesAfterRide;
const update = require('./../components/profileController').updateUserStatistics;
const User = require('../schemas.js').User;
const Ride = require('../schemas.js').Ride;
const app = require('./../../server');
const mongoose = require('mongoose');

jest.setTimeout(30000);

beforeAll(async () => {
    await mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
})

afterAll(async () => {
    await mongoose.connection.close();
})

var ride = Ride({
    "userId": "user_id",
    "name": "test_ride",
    "durationInSeconds": 3500,
    "pace": 18.5,
    "totalKm": 18,
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
    "elevationGain": 102
});

describe("Testing assignPoints function", () => {
    test("The points of the user should be increased depending on ride data", async () => {
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
        const oldPoints = user.points;
        assign(user, ride, []);
        expect(user.points).toBe((ride.totalKm * 100) + (oldPoints + ride.elevationGain * 10));
    })
})

describe("Testing checkNewBadgesAfterRide function", () => {
    test("Checking ride type badges unlocking", async () => {
        var user1 = User({
            "userId": "user_id",
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
        await checkBadge(user1, ride);

        // should unlock: pace 10, totalKm 1, totalKm 10, elevationGain 10, elevationGain 100, DurationInSeconds 1800
        expect(user1.badges.length).toBe(6);
    })

    test("Checking userStat and ride type badges unlocking", async () => {
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

        update(user, ride);
        await checkBadge(user, ride);

        // should unlock:
        // ride - pace 10, totalKm 1, totalKm 10, elevationGain 10, elevationGain 100, DurationInSeconds 1800
        // userStat - numberOfRides 1, totalKm 10
        expect(user.badges.length).toBe(8);
    })
})
