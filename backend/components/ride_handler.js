var express = require('express');
var app = express.Router();
app.use(express.json());
const mongoose = require('mongoose');
const Double = mongoose.Schema.Types.Number;
const Schema = mongoose.Schema;
const UserSchema = Schema.UserSchema;
const gamification_controller = require('./gamification_controller.js');


// Schema
const RideSchema = new Schema({
    uid: { type: String, required: true },
    name: { type: String, required: true },
    duration_in_seconds: { type: Double, required: true },
    total_km: { type: Double, required: true },
    pace: { type: Double, required: true }, //Average speed in km/h
    date: { type: Date, required: true },
    elevation_gain: { type: Double, required: true },
    points: { type: Double, required: false },
});

// Model
const User = mongoose.model('User', UserSchema);
const Ride = mongoose.model('Ride', RideSchema);

// POST /record
app.post('/record', (req, res) => {
    console.log('Received record POST request:');
    console.log(req.body);
    var ride = new Ride();
    ride.uid = req.body.uid;
    ride.name = req.body.name
    ride.duration_in_seconds = req.body.duration_in_seconds
    ride.total_km = req.body.total_km
    ride.pace = req.body.total_km / (req.body.duration_in_seconds / 3600)
    ride.date = req.body.date
    ride.elevation_gain = req.body.elevation_gain
    // We cannot do User.findById since the uid is not the _id
    if (req.body.uid && User.findOne({ uid: req.body.uid })) {
        Promise.all([
            gamification_controller.assign_points(ride)
        ]).then(() => {
            res.json({
                'message': 'Ride saved successfully',
                'points': ride.points,
                'pace': ride.pace,
                'id': ride._id
            });
        }).catch((err) => {
            console.log(err);
            res.sendStatus(500).send("Cannot save the ride in the DB");
        });
    }
    else {
        console.log('Cannot find the user specified!\n');
        res.status(500).send('Cannot find the user specified!');
    }
});

// GET /getAllByUser
app.post('/getAllByUserId', (req, res) => {
    console.log('Received getAllByUserId GET request:');
    console.log("User:", req.body.uid);

    if (req.body.uid) {
        // I return an array of rides without the fields _id and __v
        Ride.find({ uid: req.body.uid }, '-_id -__v', (error, rides) => {
            if (error) {
                console.log('Error finding the rides of the specified uid.\n' + error);
                res.status(500).send('Error finding the rides!');
            } else {
                res.status(200).send(rides);
            }
        });
    } else {
        console.log('Error: Missing the uid parameter.');
        res.status(400).send('Error: Missing the uid parameter.');
    }
});




module.exports = app;