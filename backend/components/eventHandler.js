var express = require("express");
var app = express.Router();
app.use(express.json());
const models = require('../schemas.js');
const User = models.User;
const Team = models.Team;
const Event = models.Event;
const ObjectId = models.ObjectId;
const connection = models.connection;

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


app.post('/join', (req, res) => {
    console.log('Received join POST request:');
    console.log(req.body);
    const userId = req.body.userId;
    const eventId = req.body.eventId;
    const teamId = req.body.teamId;
    connection.transaction( async (session) => {
        if (!userId || !eventId)
            throw new Error('Missing userId or eventId');
        var [user, event] = await Promise.all([
            User.findOne({ userId: userId }).session(session).exec(),
            Event.findOne({ _id: eventId }).session(session).exec()
        ]);
        if (event.type == 'team') {
            if (!teamId)
                throw new Error('Missing teamId');
            //TODO FOR NEXT SPRINT
            throw new Error('Functionality not yet implemented');
        } else if (event.type == 'individual') {
            var scoreboardEntry = {userId: userId, teamId: null, points: 0};
            event.scoreboard.push(scoreboardEntry);
            if (!user.joinedEvents)
                user.joinedEvents = [];
            user.joinedEvents += event._id;
        } else {
            throw new Error('Unknown event type');
        }
        await Promise.all([
            event.save(),
            user.save()
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
    console.log('Received search GET request with param name='+to_search);
    if (to_search) {
      Event.find({ name: { $regex: '.*' + to_search + ".*", $options: 'i' } }, (error, events) => {
        if (error) {
          console.log('Error finding the events.\n'+error);
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

async function getEvents(user) {
    var events = await Event.find({ _id: { $in: user.joinedEvents } }).exec();
    return events;
}


/* app.post("/acceptInvite", (req, res) => {
    newEvent.findOneAndUpdate({ _id: req.body.newEventId }, { $push: { acceptedTeams: req.body.teamId } }).
        then(() => {
            res.status(200).json({
                message: 'Invite accepted successfully.'
            });
        }).catch(err => {
            console.log('Error in accepting the invite' + err);
            res.status(500).send('Error in accepting the invite');
        })
});
 */


module.exports = {app:app, getEvents:getEvents};