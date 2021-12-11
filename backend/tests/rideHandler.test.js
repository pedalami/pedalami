const request = require('supertest');
const app = require('./../../server');
const Ride = require('../schemas.js').Ride;

var ride_json = {
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
};

describe("POST /record", () => {
    test("A request without userId should return 400", async () => {
        const response = await request(app).post('/ride/record').send({});
        expect(response.status).toBe(400);
    })

    test("A request with a fake userId should return 500", async () => {
        const response = await request(app).post('/ride/record').send({userId: "404error"});
        expect(response.status).toBe(500);
    })

    test("A request with a fake userId should return 500", async () => {
        const response = await request(app).post('/ride/record').send(ride_json);
        expect(response.body.text).toBe("Ride saved successfully, user statistics and badges updated successfully");
    })
})