const models = require('../schemas.js');
const User = models.User;
const Team = models.Team;
const Event = models.Event;
const ObjectId = models.ObjectId;
const connection = models.connection;
const request = require('supertest');
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

event_miss = {
    'name': 'prova',
    'description': 'descrizione',
    'type': 'team',
    'visibility': 'public'
}

event_fake = {
    'name': 'prova',
    'description': 'descrizione',
    'startDate': new Date(),
    'endDate': new Date(),
    'type': 'unknown',
    'visibility': 'public'
}

event_no_host_team = {
    'name': 'prova',
    'description': 'descrizione',
    'startDate': new Date(),
    'endDate': new Date(),
    'type': 'team',
    'visibility': 'public'
}

event_indiv = {
    'name': 'prova',
    'description': 'descrizione',
    'startDate': new Date(),
    'endDate': new Date(),
    'type': 'individual',
    'visibility': 'public'
}


describe("POST /createPrivateTeam", () => {
    test("Create a Private Team event without a host team should return 500", async () => {
        const response = await request(app).post('/events/createPrivateTeam').send(event_no_host_team);
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error in creating the newEvent: missing host or guest team or adminId');
    })
    test("Create a Private Team event without a guest team should return 500", async () => {
        const hostTeam = await Team.findOne({'name': 'testTeam'});
        const adminId = hostTeam.adminId
        var event_no_guest = {
            'name': 'prova_private_event',
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': hostTeam._id,
            'adminId': adminId
        }
        const response = await request(app).post('/events/createPrivateTeam').send(event_no_guest);
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error in creating the newEvent: missing host or guest team or adminId');
    })
    test("Create a Private Team event without the adminId should return 500", async () => {
        const hostTeam = await Team.findOne({'name': 'testTeam'});
        const guestTeam = await Team.findOne({'name': 'guestTeam'});
        var event_no_admin = {
            'name': 'prova_private_event',
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': hostTeam._id,
            'invitedTeamId': guestTeam._id
        }
        const response = await request(app).post('/events/createPrivateTeam').send(event_no_admin);
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error in creating the newEvent: missing host or guest team or adminId');
    })
    test("Create a Private Team without be the host team admin should return 500", async () => {
        const hostTeam = await Team.findOne({'name': 'testTeam'});
        const guestTeam = await Team.findOne({'name': 'guestTeam'});
        const adminId = "carlo"
        var event_fake_admin = {
            'name': 'prova_private_event',
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': hostTeam._id,
            'invitedTeamId': guestTeam._id,
            'adminId': adminId
        }
        const response = await request(app).post('/events/createPrivateTeam').send(event_fake_admin);
        expect(response.status).toBe(500);
        expect(response.text).toBe('Could not find host team or guest team or admin');
    })

    test("Create a Private Team with fake ids should return 500", async () => {
        const hostTeam = await Team.findOne({'name': 'testTeam'});
        const adminId = hostTeam.adminId
        var event_fake_guest = {
            'name': 'prova_private_event',
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': hostTeam._id,
            'invitedTeamId': '1a2b3c4d5e6f7a8b9cadbecf',
            'adminId': adminId
        }
        const response = await request(app).post('/events/createPrivateTeam').send(event_fake_guest);
        expect(response.status).toBe(500);
        expect(response.text).toBe('Could not find host team or guest team or admin');
    })

    test("Create a Private Team event with existing teams should return 200", async () => {
        const hostTeam = await Team.findOne({'name': 'testTeam'});
        const guestTeam = await Team.findOne({'name': 'guestTeam'});
        const adminId = hostTeam.adminId
        var event_team_priv = {
            'name': 'prova_private_event',
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': hostTeam._id,
            'invitedTeamId': guestTeam._id,
            'adminId': adminId
        }
        const response = await request(app).post('/events/createPrivateTeam').send(event_team_priv);
        await Event.deleteOne({'name': 'prova_private_event'})
        expect(response.status).toBe(200);
        expect(response.body.name).toBe('prova_private_event');
    })

})

describe("POST /createPublicTeam", () => {
    test("Create a Private Team event without a host team should return 500", async () => {
        const response = await request(app).post('/events/createPublicTeam').send(event_no_host_team);
        expect(response.status).toBe(500);
        expect(response.text).toBe("Error in creating the new Public Team Event: missing host team or adminId");
    })

    test("Create a Public Team event without the adminId should return 500", async () => {
        const hostTeam = await Team.findOne({'name': 'testTeam'});
        var event_no_admin = {
            'name': 'prova_private_event',
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': hostTeam._id
        }
        const response = await request(app).post('/events/createPublicTeam').send(event_no_admin);
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error in creating the new Public Team Event: missing host team or adminId');
    })
    test("Create a Public Team without be the host team admin should return 500", async () => {
        const hostTeam = await Team.findOne({'name': 'testTeam'});
        const adminId = "carlo"
        var event_fake_admin = {
            'name': 'prova_private_event',
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': hostTeam._id,
            'adminId': adminId
        }
        const response = await request(app).post('/events/createPublicTeam').send(event_fake_admin);
        expect(response.status).toBe(500);
        expect(response.text).toBe('Could not find host team or admin');
    })

    test("Create a Public Team event correctly should return 200", async () => {
        const hostTeam = await Team.findOne({'name': 'testTeam'});
        const adminId = hostTeam.adminId
        var event_team_pub = {
            'name': 'prova_public_event',
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': hostTeam._id,
            'adminId': adminId
        }
        const response = await request(app).post('/events/createPublicTeam').send(event_team_pub);
        await Event.deleteOne({'name': 'prova_public_event'})
        expect(response.status).toBe(200);
        expect(response.body.name).toBe('prova_public_event');
    })


})

describe("POST /createIndividual", () => {
    test("An individual event with missing parameters should return 500", async () => {
        const response = await request(app).post('/events/createIndividual').send(event_miss);
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error in creating the newEvent');
    })
    test("An individual event with correct parameters should return 200", async () => {
        const response = await request(app).post('/events/createIndividual').send(event_indiv);
        expect(response.status).toBe(200);
        expect(response.body.name).toBe('prova');
        await Event.deleteOne({'name': 'prova'})
    })
})


describe("POST /approvePublic", () => {

    test("Approving without eventId should return 400", async () => {
        const response = await request(app).post('/events/approvePublicTeam').send({});
        expect(response.status).toBe(400);
        expect(response.text).toBe('Missing eventId')
    })

    test("Approving without eventId should return 400", async () => {
        const response = await request(app).post('/events/approvePublicTeam').send({
            'eventId': 'aaaaaaaaaaaa'
        });
        expect(response.status).toBe(500);
        expect(response.text).toBe('Event not found');
    })

    test("Approving a public pending team event should return 200 and be activated", async () => {
        const team = await Team.findOne({'name': 'testTeam'});
        const adminId = team.adminId;
        const name = 'approve_test';
        var event_team_pub = {
            'name': name,
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': team._id,
            'adminId': adminId
        }
        const resp_event = await request(app).post('/events/createPublicTeam').send(event_team_pub);
        const response = await request(app).post('/events/approvePublicTeam').send({
            'eventId': resp_event.body._id
        });
        await Event.deleteOne({'name': name});
        expect(response.status).toBe(200); // correct response
        expect(response.body._id).toStrictEqual(resp_event.body._id); // the event returned should be the same sent
        expect(response.body.status).toBe('active'); // the event should be active

    })
    test("Approving an active event should return 500", async () => {
        const team = await Team.findOne({'name': 'testTeam'});
        const adminId = team.adminId;
        const name = 'approve_test_active';
        var event_team_pub = {
            'name': name,
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': team._id,
            'adminId': adminId
        }
        const resp_event = await request(app).post('/events/createPublicTeam').send(event_team_pub);
        const resp_act =await request(app).post('/events/approvePublicTeam').send({
            'eventId': resp_event.body._id
        });
        expect(resp_act.body.status).toBe('active'); // the event should be active
        const response = await request(app).post('/events/approvePublicTeam').send({
            'eventId': resp_event.body._id
        });
        await Event.deleteOne({'name': name});
        expect(response.status).toBe(500); // correct response
        expect(response.text).toBe('Event is not pending');
    })
    test("Approving a Private Team event should return 500", async () => {
        const hostTeam = await Team.findOne({'name': 'testTeam'});
        const guestTeam = await Team.findOne({'name': 'guestTeam'});
        const adminId = hostTeam.adminId;
        const name = 'approve_test_private';
        var event_team_priv = {
            'name': name,
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': hostTeam._id,
            'invitedTeamId': guestTeam._id,
            'adminId': adminId
        }
        const resp_event = await request(app).post('/events/createPrivateTeam').send(event_team_priv);
        const response = await request(app).post('/events/approvePublicTeam').send({
            'eventId': resp_event.body._id
        });
        await Event.deleteOne({'name': name});
        expect(response.status).toBe(500); // correct response
        expect(response.text).toBe('Event is not public');
    })

    test("Approving an individual event should return 500", async () => {
        const name = 'approve_test_indiv';
        const resp_event = await request(app).post('/events/createIndividual').send({
            'name': name,
            'description': 'descrizione',
            'startDate': new Date(),
            'endDate': new Date(),
            'type': 'individual',
            'visibility': 'public'
        });
        const response = await request(app).post('/events/approvePublicTeam').send({
            'eventId': resp_event.body._id
        });
        await Event.deleteOne({'name': name});
        expect(response.status).toBe(500); // correct response
        expect(response.text).toBe('Event is not a team event');
    })
})

describe("POST /rejectPublicTeam", () => {

    test("Rejecting without eventId should return 400", async () => {
        const response = await request(app).post('/events/rejectPublicTeam').send({});
        expect(response.status).toBe(400);
        expect(response.text).toBe('Missing eventId')
    })

    test("Rejecting without eventId should return 400", async () => {
        const response = await request(app).post('/events/rejectPublicTeam').send({
            'eventId': 'aaaaaaaaaaaa'
        });
        expect(response.status).toBe(500);
        expect(response.text).toBe('Event not found');
    })

    test("Rejecting a public pending team event should return 200 and be activated", async () => {
        const team = await Team.findOne({'name': 'guestTeam'});
        const adminId = team.adminId;
        const name = 'reject_test';
        var event_team_pub = {
            'name': name,
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': team._id,
            'adminId': adminId
        }
        const resp_event = await request(app).post('/events/createPublicTeam').send(event_team_pub);
        const response = await request(app).post('/events/rejectPublicTeam').send({
            'eventId': resp_event.body._id
        });
        await Event.deleteOne({'name': name});
        expect(response.status).toBe(200); // correct response
        expect(response.body._id).toStrictEqual(resp_event.body._id); // the event returned should be the same sent
        expect(response.body.status).toBe('rejected'); // the event should be active

    })
    test("Rejecting a not pending event should return 500", async () => {
        const team = await Team.findOne({'name': 'guestTeam'});
        const adminId = team.adminId;
        const name = 'reject_test_active';
        var event_team_pub = {
            'name': name,
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': team._id,
            'adminId': adminId
        }
        const resp_event = await request(app).post('/events/createPublicTeam').send(event_team_pub);
        const resp_act =await request(app).post('/events/rejectPublicTeam').send({
            'eventId': resp_event.body._id
        });
        expect(resp_act.body.status).toBe('rejected'); // the event should be active
        const response = await request(app).post('/events/rejectPublicTeam').send({
            'eventId': resp_event.body._id
        });
        await Event.deleteOne({'name': name});
        expect(response.status).toBe(500); // correct response
        expect(response.text).toBe('Event is not pending');
    })
    test("Rejecting a Private Team event should return 500", async () => {
        const hostTeam = await Team.findOne({'name': 'testTeam'});
        const guestTeam = await Team.findOne({'name': 'guestTeam'});
        const adminId = hostTeam.adminId;
        const name = 'reject_test_private';
        var event_team_priv = {
            'name': name,
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': hostTeam._id,
            'invitedTeamId': guestTeam._id,
            'adminId': adminId
        }
        const resp_event = await request(app).post('/events/createPrivateTeam').send(event_team_priv);
        const response = await request(app).post('/events/rejectPublicTeam').send({
            'eventId': resp_event.body._id
        });
        await Event.deleteOne({'name': name});
        expect(response.status).toBe(500); // correct response
        expect(response.text).toBe('Event is not public');
    })

    test("Rejecting an individual event should return 500", async () => {
        const name = 'reject_test_indiv';
        const resp_event = await request(app).post('/events/createIndividual').send({
            'name': name,
            'description': 'descrizione',
            'startDate': new Date(),
            'endDate': new Date(),
            'type': 'individual',
            'visibility': 'public'
        });
        const response = await request(app).post('/events/rejectPublicTeam').send({
            'eventId': resp_event.body._id
        });
        await Event.deleteOne({'name': name});
        expect(response.status).toBe(500); // correct response
        expect(response.text).toBe('Event is not a team event');
    })
})

describe("POST /search", () => {
    test("Searching an event without parameters should return 400", async () => {
        const response = await request(app).post('/events/search').send({});
        expect(response.status).toBe(400);
        expect(response.text).toBe('Error while searching for events: missing parameters');
    })
    test("Searching an event with fake ids should return 400", async () => {
        const response = await request(app).post('/events/search').send({
            'name': 'name',
            'teamId': 'aaaaaaaaaaaa',
            'adminId': 'adminId'
        });
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error while searching for events: user or team not found');
    })
    test("searching a not existing event should return an empty array", async () => {
        const team = await Team.findOne({'name': 'testTeam'});
        const adminId = team.adminId;
        const response = await request(app).post('/events/search').send({
            'name': 'hulkufj',
            'teamId': team._id,
            'adminId': adminId
        });
        expect(response.status).toBe(200);
        expect(response.body.length).toBe(0);
    })
    test("searching an existing event should return 200", async () => {
        const team1 = await Team.findOne({'name': 'guestTeam'});
        const adminId1 = team1.adminId
        const name = 'search_test'
        var event_team_pub = {
            'name': name,
            'description': 'descrizione',
            'startDate': yesterday,
            'endDate': tomorrow,
            'type': 'team',
            'visibility': 'private',
            'hostTeamId': team1._id,
            'adminId': adminId1
        }
        const resp_event = await request(app).post('/events/createPublicTeam').send(event_team_pub);
        await request(app).post('/events/approvePublicTeam').send({
            'eventId': resp_event.body._id
        });
        const team2 = await Team.findOne({'name': 'testTeam'});
        const adminId2 = team2.adminId;
        const response = await request(app).post('/events/search').send({
            'name': name,
            'teamId': team2._id,
            'adminId': adminId2
        });
        await Event.deleteOne({'name': name});
        expect(response.status).toBe(200);
        expect(response.body.length).toBeGreaterThanOrEqual(1); //deve essere attivato prima

    })
})

describe("POST /join", () => {
    test("An individual event with missing parameters should return 500", async () => {
        const response = await request(app).post('/events/join').send(event_miss);
        expect(response.status).toBe(500);
        expect(response.text).toBe('Error while joining the event');
    })
})