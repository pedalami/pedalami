const request = require('supertest');
const app = require('./../../server');
const User = require('../schemas.js').User;
const Reward = require('../schemas.js').Reward;
const Ride = require('../schemas.js').Ride;
const mongoose = require('mongoose');

jest.setTimeout(30000);

beforeAll(async () => {
    await mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
})

afterAll(async () => {
    await mongoose.connection.close();
})

const userId = "user_id";
const ride_json = {
    userId: userId,
    name: "test_ride",
    durationInSeconds: 200,
    totalKm: 12,
    pace: 10,
    date: "2021-12-03",
    path: [
        {
            "latitude": 10,
            "longitude": 10
        },
        {
            "latitude": 20,
            "longitude": 10
        }
    ],
    elevationGain: 102
};

describe("POST /redeem", () => {
    test("An empty request should return 400", async () => {
        const response = await request(app).post('/rewards/redeem').send({});
        expect(response.status).toBe(400);
    })
    test("A request without userId or rewardId should return 400", async () => {
        const response1 = await request(app).post('/rewards/redeem').send({'userId': 'user'});
        expect(response1.status).toBe(400);
        const response2 = await request(app).post('/rewards/redeem').send({'rewardId': 0});
        expect(response2.status).toBe(400);
    })
    test("A request with a fake rewardId should return 500", async () => {
        const response = await request(app).post('/rewards/redeem').send({'userId': 'user', 'rewardId': 'reward'});
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error in finding the selected reward.')
    })
    test("A request with a fake userId should return 404", async () => {
        const reward = await Reward.findOne();
        const response = await request(app).post('/rewards/redeem').send({'userId': 'user', 'rewardId': reward._id});
        expect(response.status).toBe(404);
        expect(response.text).toBe('User not found.')
    })

    test("Without enough points you cannot redeem rewards", async () => {

        await request(app).post('/users/initUser').send({userId: userId});
        const reward = await Reward.findOne();
        const response = await request(app).post('/rewards/redeem').send({'userId': userId, 'rewardId': reward._id});
        expect(response.status).toBe(400);
        expect(response.text).toBe('Insufficient points.');
        await User.deleteOne({userId: userId});
    })
    test("With enough points you can redeem a reward successfully", async () => {

        await request(app).post('/users/initUser').send({userId: userId});
        await request(app).post('/rides/record').send(ride_json);
        //const user = await User.findOne({userId: userId})
        const reward = await Reward.findOne();
        const response = await request(app).post('/rewards/redeem').send({'userId': userId, 'rewardId': reward._id});
        expect(response.status).toBe(200);
        expect(response.body.message).toBe('Reward redeemed successfully.');
        //expect(user.rewards.length).toBeGreaterThan(0);
        await User.deleteOne({userId: userId});
        await Ride.deleteMany({userId: userId});
    })
})

describe("GET /list", () => {
    test("Reward list should return successfully", async () => {
        const response = await request(app).get('/rewards/list');
        expect(response.status).toBe(200);
    })
})

describe("GET /getByUser", () => {
    test("Without a correct userId 400 should return", async () => {
        const response = await request(app).get('/rewards/getByUser').query({});
        expect(response.status).toBe(400);
        expect(response.text).toBe('Error: Missing userId parameter!')
    })
    test("With a correct userId redeemed reward list is fetched", async () => {
        await request(app).post('/users/initUser').send({userId: userId});
        const response = await request(app).get('/rewards/getByUser').query({userId: userId});
        expect(response.status).toBe(200);
        await User.deleteOne({userId: userId});
    })
})