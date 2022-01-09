var express = require("express");
var app = express.Router();
app.use(express.json());
const models = require('../schemas.js');
const gamificationController = require("./gamificationController.js");
const User = models.User;
const Team = models.Team;
const Event = models.Event;
const ObjectId = models.ObjectId;
const connection = models.connection;

//INTERNAL APIs
app.post("/createIndividual", async (req, res) => {
    var prize = 0;
    if (req.body.prize) {
        prize = req.body.prize;
    }
    var newEvent = new Event({
        name: req.body.name,
        description: req.body.description,
        startDate: req.body.startDate,
        endDate: req.body.endDate,
        prize: prize,
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

app.post('/approvePublicTeam', async (req, res) => {
    const eventId = req.body.eventId;
    if (!eventId) {
        res.status(400).send('Missing eventId');
        return;
    }
    const event = await Event.findOne({ _id: eventId }).exec();
    if (!event) {
        res.status(500).send('Event not found');
        return;
    }
    if (event.type !== 'team') {
        res.status(500).send('Event is not a team event');
        return;
    }
    if (event.visibility !== 'public') {
        res.status(500).send('Event is not public');
        return;
    }
    if (event.status !== 'pending') {
        res.status(500).send('Event is not pending');
        return;
    }
    event.status = 'approved';
    event.save().then(() => {
        res.status(200).send(event);
    }).catch(err => {
        res.status(500).send('Error in approving the event');
    });

});

app.post('/rejectPublicTeam', async (req, res) => {
    const eventId = req.body.eventId;
    if (!eventId) {
        res.status(400).send('Missing eventId');
        return;
    }
    const event = await Event.findOne({ _id: eventId }).exec();
    if (!event) {
        res.status(500).send('Event not found');
        return;
    }
    if (event.type !== 'team') {
        res.status(500).send('Event is not a team event');
        return;
    }
    if (event.visibility !== 'public') {
        res.status(500).send('Event is not public');
        return;
    }
    if (event.status !== 'pending') {
        res.status(500).send('Event is not pending');
        return;
    }
    event.status = 'rejected';
    event.save().then(() => {
        res.status(200).send(event);
    }).catch(err => {
        res.status(500).send('Error in rejecting the event');
    });

});




// APIs USED BY TEAM ADMINS TO CREATE TEAM EVENTS
app.post("/createPrivateTeam", async (req, res) => {
    console.log('Received createPrivateTeam POST request:');
    console.log(req.body);
    if (req.body.hostTeamId && req.body.invitedTeamId && req.body.adminId) {
        var newEvent = new Event({
            name: req.body.name,
            description: req.body.description,
            startDate: req.body.startDate,
            endDate: req.body.endDate,
            type: "team",
            visibility: "private",
            hostTeam: req.body.hostTeamId,
            guestTeam: null,
            involvedTeams: [req.body.invitedTeamId]
        });
        connection.transaction(async (session) => {
            var [guestTeam, hostTeam] = await Promise.all([
                Team.findOne({ _id: ObjectId(req.body.invitedTeamId) }).session(session).exec(),
                Team.findOne({ _id: ObjectId(req.body.hostTeamId) }).session(session).exec()
            ]);
            if (guestTeam && hostTeam && hostTeam.adminId === req.body.adminId) {
                hostTeam.activeEvents.push(newEvent._id);
                guestTeam.eventRequests.push(newEvent._id);
                await newEvent.save();
                await Promise.all([
                    hostTeam.save({ session }),
                    guestTeam.save({ session })
                ])
                    .catch(async err => {
                        console.log('The following error occurred in creating the newEvent: ' + err);
                        await Event.deleteOne({ _id: newEvent._id });
                        throw err;
                    });
            } else {
                throw new Error('Could not find host team or guest team or admin');
            }
        })
            .then(() => {
                console.log('Event created!');
                res.status(200).send(newEvent);
            })
            .catch(err => {
                console.log(err);
                res.status(500).send(err.message);
            })
    } else {
        console.log('Error in creating the newEvent: missing host or guest team or adminId');
        res.status(400).send('Error in creating the newEvent: missing host or guest team or adminId');
    }
});

app.post("/proposePublicTeam", async (req, res) => {
    console.log('Received proposePublicTeam POST request:');
    console.log(req.body);
    if (req.body.hostTeamId && req.body.adminId) {
        const newEvent = new Event({
            name: req.body.name,
            description: req.body.description,
            startDate: req.body.startDate,
            endDate: req.body.endDate,
            type: "team",
            visibility: "public",
            hostTeam: req.body.hostTeamId,
            involvedTeams: [], //empty until an opponent team joins the event
            status: "pending"
        });
        connection.transaction(async (session) => {
            const hostTeam = await Team.findOne({ _id: ObjectId(req.body.hostTeamId) }).session(session).exec();
            if (hostTeam && req.body.adminId == hostTeam.adminId) {
                hostTeam.activeEvents.push(newEvent._id);
                await Promise.all([
                    newEvent.save({ session: session }),
                    hostTeam.save({ session: session })
                ]);
            } else {
                throw new Error('Could not find host team or admin');
            }
        })
            .then(() => {
                console.log('Event created with id: ' + newEvent._id);
                res.status(200).send(newEvent);
            })
            .catch((err) => {
                console.log(err);
                res.status(500).send(err.message);
            })
    } else {
        console.log('Missing host team or adminId');
        res.status(400).send('Error in creating the new Public Team Event: missing host team or adminId');
    }
});


// APIs USED BY TEAM ADMINS TO MANAGE TEAM EVENTS
app.post('/enrollToPublicTeam', async (req, res) => {
    console.log('Received enrollToPublicTeam POST request:');
    console.log(req.body);
    if (req.body.eventId && req.body.teamId && req.body.adminId) {
        connection.transaction(async (session) => {
            const [eventFound, team, admin] = await Promise.all([
                Event.findOne({ _id: ObjectId(req.body.eventId) }).session(session).exec(),
                Team.findOne({ _id: ObjectId(req.body.teamId) }).session(session).exec(),
                User.findOne({ userId: req.body.adminId }).session(session).exec()
            ]);
            if (eventFound && team && admin) {
                if (team.adminId === admin.userId) {
                    if (eventFound.visibility === "public" && eventFound.type === "team") {
                        if (!eventFound.involvedTeams.includes(team._id)) {
                            eventFound.involvedTeams.push(team._id);
                            team.activeEvents.push(eventFound._id);
                            if (eventFound.involvedTeams.length == 1) {
                                eventFound.involvedTeams.push(eventFound.hostTeam); //the host team is put in the list of involved teams only if there is at least an opposing team   
                            }
                            await Promise.all([
                                eventFound.save({ session: session }),
                                team.save({ session: session })
                            ])
                        } else
                            throw new Error('The team is already enrolled in the event');
                    } else
                        throw new Error('The event is not public or is not a team event');
                } else
                    throw new Error('Specified admin is not an admin of the specified team');
            } else
                throw new Error('Error in enrolling the team to the event: user, event or team not found');
        })
            .then(() => {
                res.status(200).send('Team successfully enrolled to event!')
            })
            .catch((err) => {
                console.log(err);
                res.status(500).send(err.message);
            })


    } else {
        console.log('Error in enrolling the team to the event: missing params');
        res.status(400).send('Error in enrolling the team to the event: missing parameters');
    }
});

app.post('/acceptPrivateTeamInvite', async (req, res) => {
    console.log('Received acceptPrivateTeamInvite POST request:');
    console.log(req.body);
    if (req.body.eventId && req.body.teamId && req.body.adminId) {
        connection.transaction(async (session) => {
            var [event, team, admin] = await Promise.all([
                Event.findOne({ _id: ObjectId(req.body.eventId) }).session(session).exec(),
                Team.findOne({ _id: ObjectId(req.body.teamId) }).session(session).exec(),
                User.findOne({ userId: req.body.adminId }).session(session).exec()
            ]);
            if (event && team && admin) {
                if (team.adminId == admin.userId && event.visibility == "private" && event.type == "team"
                    && event.involvedTeams != null && event.involvedTeams.includes(team._id) && event.guestTeam == null) {
                    event.involvedTeams = null;
                    event.guestTeam = team._id;
                    team.eventRequests.remove(event._id);
                    team.activeEvents.push(event._id);
                    await Promise.all([
                        team.save({ session: session }),
                        event.save({ session: session })
                    ])
                } else {
                    throw new Error('Conditions not matched');
                }
            } else {
                throw new Error('Error in joining the team event: event or team or admin not found');
            }
        })
            .then(() => {
                res.status(200).send('Invite accepted');
            })
            .catch((err) => {
                res.status(500).send(err.message);
            })
    } else {
        console.log('Missing params');
        res.status(400).send('Error in joining the team event: missing parameters');
    }
});

app.post('/rejectPrivateTeamInvite', async (req, res) => {
    console.log('Received rejectPrivateTeamInvite POST request:');
    console.log(req.body);
    if (req.body.eventId && req.body.teamId && req.body.adminId) {
        connection.transaction(async (session) => {
            var [event, team, admin] = await Promise.all([
                Event.findOne({ _id: ObjectId(req.body.eventId) }).session(session).exec(),
                Team.findOne({ _id: ObjectId(req.body.teamId) }).session(session).exec(),
                User.findOne({ userId: req.body.adminId }).session(session).exec()
            ]);
            if (event && team && admin) {
                if (team.adminId == admin.userId && event.visibility == "private" && event.type == "team"
                    && event.involvedTeams != null && event.involvedTeams.includes(team._id) && event.guestTeam == null) {
                    event.involvedTeams = null;
                    team.eventRequests.remove(event._id);
                    await Promise.all([
                        team.save({ session: session }),
                        event.save({ session: session })
                    ])
                } else
                    throw new Error('Conditions not matched');
            } else
                throw new Error('Error in rejecting the team invite: event or team or admin not found');
        })
            .then(() => {
                res.status(200).send('Invite rejected successfully');
            })
            .catch((err) => {
                res.status(500).send(err.message);
            })
    } else {
        console.log('Missing params');
        res.status(400).send('Error in rejecting the team event invite: missing parameters');
    }
});

// if the invited team reject to challenge the host team, the latter can invite another team
app.post('/invitePrivateTeam', async (req, res) => {
    console.log('Received invitePrivateTeam POST request:');
    console.log(req.body);
    if (req.body.eventId && req.body.hostTeamId && req.body.adminId && req.body.invitedTeamId && req.body.invitedTeamId !== req.body.hostTeamId) {
        connection.transaction(async (session) => {
            const [eventFound, hostTeam, guestTeam] = await Promise.all([
                Event.findOne({ _id: ObjectId(req.body.eventId) }).session(session).exec(),
                Team.findOne({ _id: ObjectId(req.body.hostTeamId) }).session(session).exec(),
                Team.findOne({ _id: ObjectId(req.body.invitedTeamId) }).session(session).exec()
            ]);
            if (eventFound && hostTeam && guestTeam) {
                if (hostTeam.adminId === req.body.adminId && eventFound.visibility === "private" && eventFound.type === "team" &&
                    eventFound.hostTeam.equals(hostTeam._id) && eventFound.involvedTeams == null && eventFound.guestTeam == null) {
                    eventFound.involvedTeams = [req.body.invitedTeamId];
                    guestTeam.eventRequests.push(eventFound._id);
                    await Promise.all([
                        guestTeam.save({ session: session }),
                        eventFound.save({ session: session })
                    ]);
                } else
                    throw new Error('Conditions not matched');
            } else
                throw new Error('Teams or event not found');
        })
            .then(() => {
                res.status(200).send('Team invited correctly');
            })
            .catch((err) => {
                console.log(err);
                res.status(500).send(err.message);
            })
    } else {
        console.log('Missing params');
        res.status(400).send('Error in inviting the team to the event: missing parameters');
    }
});



// API used by a user to join an event
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
        if (!user || !event)
            throw new Error('User or event not found!');
        if (user.joinedEvents.includes(eventId))
            throw new Error('User already joined the event!');
        if (event.type === 'team') {
            if (!teamId)
                throw new Error('Missing teamId');
            var team = await Team.findOne({ _id: teamId }).session(session).exec();
            if (!team)
                throw new Error('Team not found');
            scoreboardEntry = { userId: userId, teamId: teamId, points: 0 };
        } else if (event.type === 'individual') {
            scoreboardEntry = { userId: userId, teamId: null, points: 0 };
        } else {
            throw new Error('Unknown event type');
        }
        event.scoreboard.push(scoreboardEntry);
        if (!user.joinedEvents)
            user.joinedEvents = [];
        user.joinedEvents.push(event._id);
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

// API used by a user to leave an event
app.post('/leave', async (req, res) => {
    console.log('Received leave POST request:');
    console.log(req.body);
    const userId = req.body.userId;
    const eventId = req.body.eventId;
    if (userId && eventId) {
        connection.transaction(async (session) => {
            var [user, event] = await Promise.all([
                User.findOne({ userId: userId }).session(session).exec(),
                Event.findOne({ _id: eventId }).session(session).exec()
            ]);
            if (!user || !event)
                throw new Error('User or event not found');
            if (user.joinedEvents.includes(eventId)) {
                user.joinedEvents.remove(eventId);
                await user.save();
            } else
                throw new Error('Error while leaving the event: user is not enrolled in the event');
        })
            .then(() => {
                res.status(200).send('Event left successfully');
            })
            .catch((err) => {
                console.log(err);
                res.status(500).send(err.message);
            })
    } else {
        console.log('Missing params');
        res.status(400).send('Error while leaving the event: missing parameters');
    }
});


//Team admins specify their team and the event they want to search. Empty name means all events.
app.post('/search', async (req, res) => {
    console.log('Received search POST request');
    console.log(req.body);
    const to_search = req.body.name;
    const adminId = req.body.adminId;
    const teamId = req.body.teamId;
    if (!(to_search && adminId && teamId)) {
        console.log('Error while searching for events: missing parameters');
        res.status(400).send('Error while searching for events: missing parameters');
        return;
    }
    var [user, team] = await Promise.all([
        User.findOne({ userId: adminId }).exec(),
        Team.findOne({ _id: teamId }).exec()
    ]);
    if (!user || !team) {
        console.log('Error while searching for events: user or team not found');
        res.status(500).send('Error while searching for events: user or team not found');
        return;
    }
    if (user.userId !== team.adminId) {
        console.log('Error while searching for events: user is not the team admin');
        res.status(500).send('Error while searching for events: user is not the team admin');
        return;
    }
    Event.find(
        {
            $and: [
                { name: { $regex: '.*' + to_search + ".*", $options: 'i' } },
                { _id: { $nin: team.activeEvents } }, //excludes the events team is already enrolled in
                { startDate: { $lte: new Date() } }, //excludes the events that have not started
                { endDate: { $gte: new Date() } }, //excludes the events that have already ended
                { type: 'team' },
                {
                    $or: [
                        {
                            $and: [{ visibility: 'public' }, { status: 'approved' }]
                        }, //if the event is public and active
                        { involvedTeams: { $in: [teamId] } } //if the event is private and the team has been invited to join
                    ]
                }
            ]
        }, (error, events) => {
            if (error) {
                console.log('Error finding the events.\n' + error);
                res.status(500).send('Error finding the events!');
            } else {
                res.status(200).send(events);
            }
        });
});


// API used by a user to get the list of all the events that he can join
app.get('/getJoinableEvents', async (req, res) => {
    const userId = req.query.userId;
    var to_search = ""
    if (req.query.name) {
        to_search = req.query.name;
    }
    console.log('Received getEvents GET request with param userId=' + userId);
    if (userId) {
        const user = await User.findOne({ userId: userId }).exec();
        if (user) {
            const events = await Event.find({
                $and: [
                    { name: { $regex: '.*' + to_search + ".*", $options: 'i' } },
                    { _id: { $nin: user.joinedEvents } }, //excludes the events the user has already joined
                    { startDate: { $lte: new Date() } }, //excludes the events that have not started
                    { endDate: { $gte: new Date() } }, //excludes the events that have already ended
                    {
                        $or: [
                            {
                                $and: [
                                    { hostTeam: { $in: user.teams } }, //if the user is in the host team and there is a guest team that has accepted the challenge
                                    { guestTeam: { $ne: null } }
                                ]
                            },
                            { guestTeam: { $in: user.teams } }, //if the user is in the guest team of a private team event
                            {
                                $and: [ //if the user is in the involved teams of a public team event
                                    { visibility: 'public' },
                                    { type: 'team' },
                                    { involvedTeams: { $in: user.teams } }
                                ]
                            },
                            { type: "individual" } //if the event is a public individual event
                        ]
                    }
                ]
            }).exec();
            if (events) {
                res.status(200).send(events);
            } else {
                console.log('Error while getting the events');
                res.status(500).send('Error while getting the events');
            }
        } else {
            console.log('Error: User not found');
            res.status(500).send('Error: User not found');
        }
    } else {
        console.log('Error: Missing userId.');
        res.status(400).send('Error: Missing userId.');
    }

});

async function terminateEvents() {
    await connection.transaction(async (session) => {
        const events = await Event.find({
            $and: [
                { endDate: { $lt: new Date() } },
                { closed: false }
            ]
        }).session(session).exec();
        if (!events)
            throw new Error('Events not found!');
        var promiseArray = [];
        for (const event of events) {
            event.closed = true;
            if (event.type === 'team') {
                var hostTeam = await Team.findOne({ _id: event.hostTeam }).exec();
                if (hostTeam) { //removes the event from the host team
                    hostTeam.activeEvents = hostTeam.activeEvents.filter(e => e != event._id);
                    promiseArray.push(hostTeam.save({ session: session }));
                }
                if (event.visibility === 'public') {
                    if (event.involvedTeams.length >= 2) {
                        for (const teamId of event.involvedTeams) {
                            var team = await Team.findOne({ _id: teamId }).exec();
                            if (team) {
                                team.activeEvents = team.activeEvents.filter(e => e != event._id);
                                promiseArray.push(team.save({ session: session }));
                            }
                        }
                    }
                } else if (event.visibility === 'private') {
                    if (event.guestTeam) { //removes the active event from the guest team
                        const guestTeam = await Team.findOne({ _id: event.guestTeam }).exec();
                        if (guestTeam) {
                            guestTeam.activeEvents = guestTeam.activeEvents.filter(e => e != event._id);
                            promiseArray.push(guestTeam.save({ session: session }));
                        }
                    } else {
                        for (const teamId of event.involvedTeams) { //removes the unaccepted event request from the involved teams
                            var team = await Team.findOne({ _id: teamId }).exec();
                            if (team) {
                                team.eventRequests = team.eventRequests.filter(e => e != event._id);
                                promiseArray.push(team.save({ session: session }));
                            }
                        }

                    }
                }
            } else if (event.type === 'individual') {
                var bestPlayer = gamificationController.getBestPlayerIndividualEvent(event);
                if (bestPlayer) {
                    var user = await User.findOne({ _id: bestPlayer.userId }).exec();
                    if (user) {
                        gamificationController.assignPrizeIndividualEvent(user, event);
                        promiseArray.push(user.save({ session: session }));
                    }
                }
            }
            const users = await User.find({ joinedEvents: { $in: event._id } }).exec();
            if (users) {
                users.forEach(user => {
                    user.joinedEvents = user.joinedEvents.filter(e => e !== event._id);
                    if (event.type === 'team')
                        gamificationController.assignPrizeTeamEvent(user, event);
                    promiseArray.push(user.save({ session: session }));
                });

            }
            promiseArray.push(event.save({ session: session }));
        }
        await Promise.all(promiseArray)
            .then(() => {
                console.log('Events up to ' + new Date() + 'closed');
            })
            .catch(err => {
                console.log('Error in closing events:' + err);
                throw err;
            });
    })
}


app.post("/getUsersEvents", async (req, res) => {
    console.log('Received getUsersEvents POST request');
    console.log(req.body);
    var userId = req.body.userId;
    if (userId) {
        const user = await User.findOne({ userId: userId }).exec();
        if (user) {
            var events = await Event.aggregate([{
                $match: {
                    _id: { $in: user.joinedEvents }
                }
            },
            {
                $lookup: {
                  from: "teams", // collection name in db
                  localField: "hostTeam", // field of Event to make the lookup on (the field with the "foreign key")
                  foreignField: "_id", // the referred field in Team 
                  as: "hostTeam" // name that the field of the join will have in the result/JSON
                }
              },
              {
                $lookup: {
                  from: "teams", // collection name in db
                  localField: "guestTeam", // field of Event to make the lookup on (the field with the "foreign key")
                  foreignField: "_id", // the referred field in Team 
                  as: "guestTeam" // name that the field of the join will have in the result/JSON
                }
              },
              {
                $lookup: {
                  from: "teams", // collection name in db
                  localField: "involvedTeams", // field of Event to make the lookup on (the field with the "foreign key")
                  foreignField: "_id", // the referred field in Team 
                  as: "involvedTeams" // name that the field of the join will have in the result/JSON
                }
              },
              {
                $unset: ["hostTeam.activeEvents", "hostTeam.eventRequests" , "guestTeam.activeEvents", "guestTeam.eventRequests" ,
                 "involvedTeams.activeEvents", "involvedTeams.eventRequests" ,]
              }
        ]).exec().catch(err => {
            console.log('Error while getting the events: ' + err);
            res.status(500).send('Error while getting the events');
            return;
        });
            res.status(200).send(events);
        } else {
            res.status(500).send('Error in getting the user events: user not found');
        }
    } else {
        res.status(400).send('Error in getting the user events: missing parameter');
    }
});

app.post("/getTeamActiveEvents", async (req, res) => {
    console.log('Received getTeamActiveEvents POST request');
    console.log(req.body);
    var teamId = req.body.teamId;
    if (teamId) {
        var team = await Team.findOne({ _id: ObjectId(teamId) }).exec();
        if (team) {
            var events = await Event.aggregate([{
                $match: {
                    _id: { $in: team.activeEvents }
                }
            },
            {
                $lookup: {
                  from: "teams", // collection name in db
                  localField: "hostTeam", // field of Event to make the lookup on (the field with the "foreign key")
                  foreignField: "_id", // the referred field in Team 
                  as: "hostTeam" // name that the field of the join will have in the result/JSON
                }
              },
              {
                $lookup: {
                  from: "teams", // collection name in db
                  localField: "guestTeam", // field of Event to make the lookup on (the field with the "foreign key")
                  foreignField: "_id", // the referred field in Team 
                  as: "guestTeam" // name that the field of the join will have in the result/JSON
                }
              },
              {
                $lookup: {
                  from: "teams", // collection name in db
                  localField: "involvedTeams", // field of Event to make the lookup on (the field with the "foreign key")
                  foreignField: "_id", // the referred field in Team 
                  as: "involvedTeams" // name that the field of the join will have in the result/JSON
                }
              },
              {
                $unset: ["hostTeam.activeEvents", "hostTeam.eventRequests" , "guestTeam.activeEvents", "guestTeam.eventRequests" ,
                 "involvedTeams.activeEvents", "involvedTeams.eventRequests" ,]
              }
        ]).exec().catch(err => {
            console.log('Error while getting the events: ' + err);
            res.status(500).send('Error while getting the events');
            return;
        });
            res.status(200).send(events);
        } else {
            console.log('Error in getting the team events: team not found')
            res.status(500).send('Error in getting the team events: team not found');
        }
    } else {
        console.log('Missing params');
        res.status(400).send('Error in getting the team events: missing parameter');
    }

});

app.post("/getTeamEventRequests", async (req, res) => {
    console.log('Received getTeamEventRequests POST request');
    console.log(req.body);
    var teamId = req.body.teamId;
    if (teamId) {
        var team = await Team.findOne({ _id: ObjectId(teamId) }).exec();
        if (team) {
            var events = await Event.find({ _id: { $in: team.eventRequests } }).exec();
            res.status(200).send(events);
        } else {
            console.log('Error in getting the team events: team not found');
            res.status(500).send('Error in getting the team events: team not found');
        }
    } else {
        console.log('Missing params');
        res.status(400).send('Error in getting the team events: missing parameter');
    }
})

app.get("/closeEvents", async (req, res) => {
    console.log('Received closeEvents request');
    try {
        await terminateEvents();
    }
    catch (err) {
        res.status(500).send('Error in closing events');
        return;
    }
    res.status(200).send('Events closed');
});

module.exports = { app: app, terminateEvents: terminateEvents };


