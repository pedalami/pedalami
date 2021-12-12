const request = require('supertest');
const app = require('./../../server');
const mongoose = require('mongoose');
const models = require('../schemas.js');
const Team = models.Team;
const User = models.User;

jest.setTimeout(30000);

beforeAll(async () => {
    await mongoose.connect(process.env.MONGO_URI, { useNewUrlParser: true, useUnifiedTopology: true });
})

afterAll(async () => {
    await mongoose.connection.close();
})

describe("POST /create", () => {
    test("A request without a name field should return 400", async () =>{
        const response = await request(app).post('/teams/create').send({});
        expect(response.status).toBe(400);
    })

    test("A request with a fake userId should return 500", async () =>{
        const response = await request(app).post('/teams/create').send({
            name: "FakeTeam",
            adminId: "n0t3x1st"
        });
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error while creating the team: the team admin specified does not exist!');
    })

    test("A request with a real userId and a name field should return successfully", async () =>{
        const teamName = "testTeamName";
        const testUser = "admin";
        //await request(app).post('/users/initUser').send({ userId: testUser });
        const response = await request(app).post('/teams/create').send({
            name: teamName,
            adminId: testUser
        });
        expect(response.status).toBe(200);
        expect(response.type).toBe("application/json")
        expect(response.body.teamId).toBeDefined();
        //await User.deleteOne({userId: testUser});
        await Team.deleteOne({name: teamName});
    })

})

describe("GET /search", () => {
    test("A request without a name field should return 400", async () =>{
        const response = await request(app).get('/teams/search').query({});
        expect(response.status).toBe(400);
        expect(response.text).toBe('Error: Missing parameters.');
    })
    test("A request with a name field should return 200", async () =>{
        const response = await request(app).get('/teams/search').query({ name: "n0n3x1st1ngT3@m"});
        expect(response.status).toBe(200);
    })
    test("A request with a non existing team name should return an empty array", async () =>{
        const response = await request(app).get('/teams/search').query({ name: "n0n3x1st1ngT3@m"});
        expect(response.status).toBe(200);
        expect(response.body.length).toBe(0);
    })
    test("A request with an existing team name should return an array of teams", async () =>{
        //it needs a team in the db
        const teamName = "testTeam";
        const response = await request(app).get('/teams/search').query({name: teamName});
        expect(response.status).toBe(200);
        expect(response.type).toBe("application/json");
        expect(response.body.length).toBeGreaterThan(0);
        expect(response.body[0].name).toBe(teamName);
    })

})

describe("POST /join", () => {
    test("A request without userId and teamId field should return 400", async () =>{
        const response = await request(app).post('/teams/join').send({});
        expect(response.status).toBe(400);
        expect(response.text).toBe('Error: Missing parameters.');
    })
    test("A request with a fake teamId should return 500", async () =>{
        const response = await request(app).post('/teams/join').send({
            userId: "admin",
            teamId: "n0n3x1st1ngT3@m"
        });
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error finding the user or the team!');
    })

    test("A request with a fake userId should return 500", async () =>{
        const teamName = "testTeam";
        const team = await Team.findOne({name: teamName});
        const response = await request(app).post('/teams/join').send({
            userId: "n0t3x1st",
            teamId: team._id
        });
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error finding the user or the team!');
    })

    test("Joining with a member of the team should return 500", async () =>{
        const testUser = "admin";
        const team = await Team.findOne({userId: testUser});
        const response = await request(app).post('/teams/join').send({
            userId: testUser,
            teamId: team._id
        });
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error: User already in team.');
    })
})

describe("GET /getTeam", () => {})

describe("GET /leave", () => {})