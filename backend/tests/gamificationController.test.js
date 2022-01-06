const assignPoints = require('./../components/gamificationController').assignPoints;
const checkBadge = require('./../components/gamificationController').checkNewBadgesAfterRide;
const getBestPlayer = require('./../components/gamificationController').getBestPlayerIndividualEvent;
const assignPrizeIndividual = require('./../components/gamificationController').assignPrizeIndividualEvent;
const assignPrizeTeam = require('./../components/gamificationController').assignPrizeTeamEvent;
const computeScoreboard = require('./../components/gamificationController').computeTeamScoreboard;
const update = require('./../components/profileController').updateUserStatistics;
const User = require('../schemas.js').User;
const Ride = require('../schemas.js').Ride;
const Event = require('../schemas.js').Event;
const app = require('./../../server');
const mongoose = require('mongoose');

jest.setTimeout(30000);

beforeAll(async () => {
    await mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
})

afterAll(async () => {
    await mongoose.connection.close();
})

const today = new Date()
const tomorrow = new Date(today)
const yesterday = new Date(today)
tomorrow.setDate(today.getDate() + 1)
yesterday.setDate(today.getDate() - 1)

var event_public_win= {
    name: 'prova_ind',
    description: 'descrizione',
    startDate: yesterday,
    endDate: tomorrow,
    type: 'individual',
    visibility: 'public',
    scoreboard: [
        {userId: 'shabbyUser', points: 0},
        {userId: 'strongUser', points: 1000}
    ],
    prize: 100
}

var event_public_ind = {
    name: 'prova_ind',
    description: 'descrizione',
    startDate: yesterday,
    endDate: tomorrow,
    type: 'individual',
    visibility: 'public',
    scoreboard: [
        {userId: 'username', points: 0}
    ]
}
var event_private_team = {
    name: 'prova_team',
    description: 'descrizione',
    startDate: yesterday,
    endDate: tomorrow,
    type: 'team',
    visibility: 'private',
    guestTeam: 'guestTeam',
    scoreboard: [
        {userId: 'username', points: 0}
    ]
}

var ride = Ride({
    "userId": "username",
    "name": "test_ride",
    "durationInSeconds": 3500,
    "pace": 18.5,
    "totalKm": 18,
    "date": today,
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
    test("The points of the user should be increased depending on ride data (no events)", async () => {
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
        assignPoints(user, ride, []);
        expect(user.points).toBe((ride.totalKm * 100) + (oldPoints + ride.elevationGain * 10));

    })
    test("The points of the user should be increased depending on ride data and events", async () => {
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
        var events = [event_public_ind, event_private_team]
        assignPoints(user, ride, events);
        const points = ((ride.totalKm * 100) + (oldPoints + ride.elevationGain * 10))/(events.length+1);
        expect(user.points).toBe(points);
        events.forEach(event => {
            expect(event.scoreboard[0].points).toBe(points);
        });
    })
})

describe("Testing checkNewBadgesAfterRide function", () => {
    test("Checking ride type badges unlocking", async () => {
        var user1 = User({
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

describe("Testing assignPrizeIndividualEvent function", () => {
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
    assignPrizeIndividual(user, event_public_win);
    expect(user.points).toBe(event_public_win.prize);
})

describe("Testing getBestPlayerIndividualEvent function", () => {
    test("Without prize", () =>{
        var bestUser = getBestPlayer(event_public_ind);
        expect(bestUser).toBe(null);
    })
    test("With prize", () =>{
        var bestUser = getBestPlayer(event_public_win);
        expect(bestUser.userId).toBe("strongUser");
    })
})