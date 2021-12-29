var express = require("express");
var app = express.Router();
app.use(express.json());
const models = require('../schemas.js');
const User = models.User;
const Team = models.Team;
const Event = models.Event;
const ObjectId = models.ObjectId;
const connection = models.connection;

//INTERNAL API for creating individual events
app.post("/createIndividual", async (req, res) => {
    var newEvent = new Event({
        name: req.body.name,
        description: req.body.description,
        startDate: req.body.startDate,
        endDate: req.body.endDate,
        prize: req.body.prize,
        type: "individual",
        visibility: "public"
    });
    newEvent.save()
        .then(() => {
            res.status(200).send(newEvent);
        })
        .catch(err => {
            console.log('The following error occurred in creating the newEvent: ' + err);
            res.status(500).send('Error in creating the newEvent');
        })
});

app.post("/createPrivateTeam", async (req, res) => {
    if (req.body.hostTeamId && req.body.guestTeamId && req.body.userId) {
    
        var [guestTeam, hostTeam] = await Promise.all([
            Team.findOne({ _id: ObjectId(req.body.guestTeamId) }).exec(),
            Team.findOne({ _id: ObjectId(req.body.hostTeamId) }).exec()
        ])

        if (guestTeam && hostTeam && hostTeam.adminId == req.body.userId) {
            var newEvent = new Event({
                name: req.body.name,
                description: req.body.description,
                startDate: req.body.startDate,
                endDate: req.body.endDate,
                type: "team",
                visibility: "private",
                hostTeam: req.body.hostTeamId,
                guestTeam: null,
                involvedTeams: [req.body.guestTeamId]
            });
            hostTeam.activeEvents.push(newEvent._id);
            guestTeam.eventRequests.push(newEvent._id);
            connection.transaction(async (session) => {
                await Promise.all([
                    hostTeam.save({ session }),
                    guestTeam.save({ session }),
                    newEvent.save({ session })
                    ])
                })
                .then(() => {
                    res.status(200).send(newEvent);
                })
                .catch(err => {
                    console.log('The following error occurred in creating the new Private Event: ' + err);
                    res.status(500).send('Error in creating the new Private Event');
                })
        } else {
            res.status(500).send('Could not find host team or guest team');
        }
    }
    else {
        res.status(500).send('Error in creating the newEvent: missing host or guest team');
    }
});

app.post("/createPublicTeam", async (req, res) => {
    if (req.body.hostTeamId && req.body.adminId) {
        var hostTeam = await Team.findOne({ _id: ObjectId(req.body.hostTeamId) }).exec();
        if (hostTeam) {
            var newEvent = new Event({
                name: req.body.name,
                description: req.body.description,
                startDate: req.body.startDate,
                endDate: req.body.endDate,
                type: "team",
                visibility: "public",
                hostTeam: req.body.hostTeam,
                involvedTeams: [req.body.hostTeamId]
            });
            hostTeam.activeEvents.push(newEvent._id);
            connection.transaction(async (session) => {
                await Promise.all([
                    hostTeam.save({ session }),
                    newEvent.save({ session })
                    ])
                })
                .then(() => {
                    res.status(200).send(newEvent);
                })
                .catch(err => {
                    console.log('The following error occurred in creating the new Public Team Event: ' + err);
                    res.status(500).send('Error in creating the new Public Team Event');
                })
        } else {
            res.status(500).send('Could not find host team');
        }
    }
    else {
        res.status(500).send('Error in creating the new Public Team Event: missing host team');
    }
});


app.post('/joinPublicTeam', async (req, res) => {
    if (req.body.eventId && req.body.teamId && req.body.userId) {
        const event = await Event.findOne({ _id: ObjectId(req.body.eventId) }).exec();
        const team = await Team.findOne({ _id: ObjectId(req.body.teamId) }).exec();
        const user = await User.findOne({ userId: req.body.userId }).exec();
        if (event && team && user) {
            if (event.visibility == "public" && event.type == "team") {
                if (event.involvedTeams.includes(team._id)) {
                    user.joinedEvents.push(event._id);
                    //TODO COMPLETE
                }

            }
        }
    }
}           
);

app.post('/enrollTeamPublic', async (req, res) => {
    if (req.body.eventId && req.body.teamId && req.body.adminId) {
        const event = await Event.findOne({ _id: ObjectId(req.body.eventId) }).exec();
        const team = await Team.findOne({ _id: ObjectId(req.body.teamId) }).exec();
        const admin = await User.findOne({ adminId: req.body.adminId }).exec();
        if (event && team && admin && team.adminId == admin.userId) {
            if (event.visibility == "public" && event.type == "team"){
                if(!event.involvedTeams.includes(team._id)) {
                    event.involvedTeams.push(team._id);
                    team.activeEvents.push(event._id);
                    if(event.involvedTeams.length == 1) {
                        event.involvedTeams.push(event.hostTeam); //the host team is put in the list of involved teams only if there is at least an opposing team   
                    }
                    connection.transaction(async (session) => {
                        await Promise.all([
                            event.save({ session }),
                            team.save({ session })
                            ])
                        }
                    ).then(() => {
                        res.status(200).send(event);
                    }
                    ).catch(err => {
                        console.log('The following error occurred in enrolling the team to the event: ' + err);
                        res.status(500).send('Error in enrolling the team to the event: ' + err);
                    })
            } else {
                res.status(500).send('The team is already enrolled in the event');
            }
            
        } else {
            res.status(500).send('The event is not public or is not a team event');
        }
    } else {
        res.status(500).send('Error in enrolling the team to the event: user, event or team not found');
    }
} else {
    res.status(500).send('Error in enrolling the team to the event: missing parameters');
}
});

app.post('/acceptPrivateTeamInvite', async (req, res) => {
    if (req.body.eventId && req.body.teamId && req.body.userId) {
        const event = await Event.findOne({ _id: ObjectId(req.body.eventId) }).exec();
        const team = await Team.findOne({ _id: ObjectId(req.body.teamId) }).exec();
        const admin = await User.findOne({ userId: req.body.userId }).exec();
        if (event && team && admin && team.adminId == admin.userId && event.visibility == "private" && event.type == "team" 
            && event.involvedTeams!=null && event.involvedTeams.includes(team._id) && event.guestTeam == null) {
                    event.involvedTeams = null;
                    event.guestTeam = team._id;
                    team.eventRequests.remove(event._id);
                    team.activeEvents.push(event._id);
                    connection.transaction(async (session) => {
                        await Promise.all([
                            team.save({ session }),
                            event.save({ session })
                            ])
                        }
                    ).then(() => {
                        res.status(200).send(event);
                    }
                    ).catch(err => {
                        console.log('The following error occurred in joining the team event: ' + err);
                        res.status(500).send('Error in joining the team event');
                    });
                } else {res.status(500).send('Error in joining the team event: missing event or team');}
    } else {
        res.status(500).send('Error in joining the team event: missing parameters');
    }
});

app.post('/rejectPrivateTeamInvite', async (req, res) => {
    if (req.body.eventId && req.body.teamId && req.body.userId) {
        const event = await Event.findOne({ _id: ObjectId(req.body.eventId) }).exec();
        const team = await Team.findOne({ _id: ObjectId(req.body.teamId) }).exec();
        const admin = await User.findOne({ userId: req.body.userId }).exec();
        if (event && team && admin && team.adminId == admin.userId && event.visibility == "private" && event.type == "team" 
            && event.involvedTeams != null && event.involvedTeams.includes(team._id) && event.guestTeam == null) {
                event.involvedTeams = null;
                team.eventRequests.remove(event._id);
                connection.transaction(async (session) => {
                    await Promise.all([
                        team.save({ session }),
                        event.save({ session })
                        ])
                    }
                ).then(() => {
                    res.status(200).send("Invite rejected successfully");
                }
                ).catch(err => {
                    console.log('The following error occurred in rejecting the team event: ' + err);
                    res.status(500).send('Error in rejecting the team event');
                }
            );

            } else {res.status(500).send('Error in rejecting the team event invite: missing event or team');}
    } else {
        res.status(500).send('Error in rejecting the team event invite: missing parameters');
    }
});

app.post('/invitePrivateTeam', async (req, res) => {
    if (req.body.eventId && req.body.hostTeamId && req.body.userId && req.body.guestTeamId && req.body.guestTeamId != req.body.hostTeamId) {
        const event = await Event.findOne({ _id: ObjectId(req.body.eventId) }).exec();
        const hostTeam = await Team.findOne({ _id: ObjectId(req.body.hostTeamId) }).exec();
        const guestTeam = await Team.findOne({ _id: ObjectId(req.body.guestTeamId) }).exec();
        if (event && hostTeam && guestTeam && hostTeam.adminId == req.body.userId && event.visibility == "private" && event.type == "team" && 
        event.hostTeam.equals(hostTeam._id) && event.involvedTeams == null && event.guestTeam == null) {
                event.involvedTeams = [req.body.guestTeamId];
                guestTeam.eventRequests.push(event._id);
                connection.transaction(async (session) => {
                    await Promise.all([
                        guestTeam.save({ session }),
                        event.save({ session })
                        ])
                    }
                ).then(() => {
                    res.status(200).send(event);
                }
                ).catch(err => {
                    console.log('The following error occurred in inviting the team to the event: ' + err);
                    res.status(500).send('Error in inviting the team to the event');
                }
            );
            } else {res.status(500).send('Error in inviting the team to the event: incorrect parameters');}
    }else {res.status(500).send('Error in inviting the team to the event: missing parameters');}
});


app.post('/join', (req, res) => {
    console.log('Received join POST request:');
    console.log(req.body);
    const userId = req.body.userId;
    const eventId = req.body.eventId;
    const teamId = req.body.teamId;
    var scoreboardEntry;
    connection.transaction(async (session) => {
        if (!userId || !eventId)
            throw new Error('Missing userId or eventId');
        var [user, event] = await Promise.all([
            User.findOne({ userId: userId }).session(session).exec(),
            Event.findOne({ _id: eventId }).session(session).exec()
        ]);
        if (event.type == 'team') {
            if (!teamId)
                throw new Error('Missing teamId');
            var team = await Team.findOne({ _id: teamId }).session(session).exec();
            if (!team)
                throw new Error('Team not found');
            scoreboardEntry = { userId: userId, teamId: teamId, points: 0 };

        } else if (event.type == 'individual') {
            scoreboardEntry = { userId: userId, teamId: null, points: 0 };
        } else {
            throw new Error('Unknown event type');
        }
        event.scoreboard.push(scoreboardEntry);
        if (!user.joinedEvents)
            user.joinedEvents = [];
        user.joinedEvents += event._id;
        await Promise.all([
            event.save({ session: session }),
            user.save({ session: session })
        ]);
    })
        .then(() => {
            res.status(200).send('Event joined successfully');
        })
        .catch((err) => {
            console.log('Error while joining the event\n' + err);
            res.status(500).send('Error while joining the event');
        });
});


// GET /search?name=portion_of_name
app.get('/search', (req, res) => {
    const to_search = req.query.name;
    console.log('Received search GET request with param name=' + to_search);
    if (to_search) {
        Event.find({ name: { $regex: '.*' + to_search + ".*", $options: 'i' } }, (error, events) => {
            if (error) {
                console.log('Error finding the events.\n' + error);
                res.status(500).send('Error finding the events!');
            } else {
                res.status(200).send(events);
            }
        });
    } else {
        console.log('Error: Missing parameters.');
        res.status(400).send('Error: Missing parameters.');
    }
});

app.post('/getJoinableEvents', async(req, res) => {
    console.log('Received getEvents POST request');
    if(req.body.userId){
        const user = await User.findOne({userId: req.body.userId}).exec();
        if(user){
            const events = await Event.find({$and: [
                    {_id: {$nin: user.joinedEvents}}, //excludes the events the user has already joined
                    {startDate: {$lte: new Date()}}, //excludes the events that have not started
                    {endDate: {$gte: new Date()}}, //excludes the events that have already ended
                    {$or:[
                        {$and: [
                            {hostTeam: {$in: user.teams}}, //if the user is in the host team and there is a guest team that has accepted the challenge
                            {guestTeam: {$ne: null}}
                        ]},
                        {guestTeam: {$in: user.teams}}, //if the user is in the guest team of a private team event
                        {$and:[ //if the user is in the involved teams of a public team event
                            {visibility: 'public'}, 
                            {type: 'team'},
                            {involvedTeams: {$in: user.teams}}
                        ]}, 
                        {type: "individual"} //if the event is a public individual event
                    ]}
                ]}).exec();
            if(events){
                res.status(200).send(events);
            }
            else{
                res.status(500).send('Error while getting the events');
            }
        } else{
            console.log('Error: User not found');
            res.status(500).send('Error: User not found');
        }

    } else {
        console.log('Error: Missing userId.');
        res.status(400).send('Error: Missing userId.');
    }
    
});


module.exports = { app: app };


///Old stuff
/*
app.post("/create", async (req, res) => {
    var newEvent = new Event({
        name: req.body.name,
        description: req.body.description,
        startDate: req.body.startDate,
        endDate: req.body.endDate,
        type: req.body.type,
        visibility: req.body.visibility
    });
    try {
        const eventType = req.body.type;
        if (eventType == "team") {
            const hostTeamId = req.body.hostTeam;
            if (hostTeamId) {
                const hostTeamPromise = Team.findOne({ _id: ObjectId(hostTeamId) }).exec();
                if (req.body.visibility == "private") {
                    const guestTeamId = req.body.guestTeam;
                    if (guestTeamId) {
                        await Promise.all([
                            hostTeamPromise,
                            Team.findOne({ _id: ObjectId(guestTeamId) }).exec()
                        ])
                            .catch(() => {
                                throw new Error('Impossible to find some of the specified teams');
                            })
                        newEvent.hostTeam = ObjectId(hostTeamId);
                        newEvent.guestTeam = guestTeamId;
                        //TODO SEND INVITE TO THE GUEST TEAM
                    } else
                        throw new Error('Missing guest team');
                } else if (req.body.visibility == "public") {
                    // In public team newEvents the "host" team is the team which proposes the newEvent
                    const hostTeam = await hostTeamPromise;
                    if (!hostTeam)
                        throw new Error('Impossible to find the host team');
                    newEvent.involvedTeams = [hostTeamId];
                    if (!hostTeam.activeEvents)
                        hostTeam.activeEvents = [];
                    hostTeam.activeEvents += newEvent._id
                } else {
                    throw new Error('Unknown option for newEvent visibility');
                }
            } else {
                throw new Error('Missing host team');
            }
        } else if (eventType == "individual") {
            throw new Error('Individual public newEvents can be created only by system admins');
            //newEvent.prize = req.body.prize;
        } else {
            throw new Error('Unknown event type');
        }
        newEvent.save()
            .then(() => {
                res.status(200).send(newEvent);
            })
            .catch(err => {
                console.log('The following error occurred in creating the newEvent: ' + err);
                res.status(500).send('Error in creating the newEvent');
            })
    } catch (error) {
        console.log(error);
        res.status(500).send(error);
    }
});
*/
