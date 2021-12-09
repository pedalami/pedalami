var express = require("express");
var app = express.Router();
app.use(express.json());
const models = require('../schemas.js');
const User = models.User;
const Event = models.Event;
const connection = models.connection;

app.post("/create",  (req, res) => {
    var event  = new Event({
        name: req.body.name,
        description: req.body.description,
        startDate: req.body.startDate,
        endDate: req.body.endDate,
        location: req.body.location,
        type: req.body.type,
        visibility: req.body.visibility});
    if (req.body.type == "team") {
        event.proposingTeam = req.body.proposingTeam;
        event.invitedTeams = req.body.invitedTeams; //MUST BE DONE CHECK ON WETHER TEAMS EXISTS IN THE DB OR NOT
    } else if (req.body.type == "individual") {
        event.prize = req.body.prize;
    }

    if (event.startDate <= new Date() && event.endDate >= new Date()) {
        event.status = "active";
    } else if (event.endDate <= new Date()) {
        event.status = "closed";
    } else {
        event.status = "inactive";
    }

    //TODO SEND INVITED TO INVITED TEAMS, IF ANY

    event.save().
    then(() => {
        res.status(200).json({
            message: 'Event saved successfully.',
            event: event
            });
    }).catch(err => {
    console.log('Error in creating the event' + err);
    res.status(500).send('Error in creating the event');
})

});

exports.app = app;