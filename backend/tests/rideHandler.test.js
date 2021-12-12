const request = require('supertest');
const app = require('./../../server');
const mongoose = require('mongoose');

jest.setTimeout(15000);

beforeAll(async () => {
    await mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
})

afterAll(async () => {
    await mongoose.connection.close();
})

var ride_json = {
    "userId": "user_id",
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
        const response = await request(app).post('/rides/record').send({});
        expect(response.status).toBe(400);
    })

    test("A request with a fake userId should return 500", async () => {
        const response = await request(app).post('/rides/record').send({userId: "n0t3x1st"});
        expect(response.status).toBe(500);
    })

    test("A request with a correct ride should saved it successfully", async () => {
        const response = await request(app).post('/rides/record').send(ride_json);
        expect(response.body.message).toBe("Ride saved successfully, user statistics and badges updated successfully");
    })
})

describe("GET /getAllByUserId", () => {
    test("A request without userId should return 400", async () => {
        const response = await request(app).get('/rides/getAllByUserId').send({});
        expect(response.status).toBe(400);
    })
    test("A request with a fake userId should return 0 rides", async () => {
        const response = await request(app).get('/rides/getAllByUserId').query({ userId: 'n0t3x1st' });
        expect(response.status).toBe(200);
        expect(response.body.length).toBe(0);
    })
    test("A request with a real userId should return a rides array", async () => {
        const response = await request(app).get('/rides/getAllByUserId').query({ userId: 'yTi9ZmJbK4Sy4yykwRvrDAcCFPB3' });
        expect(response.status).toBe(200);
        expect(response.body.length).toBeGreaterThan(0);
        expect(response.type).toBe("application/json");
    })

})