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
    userId: { type: String, required: true },
    name: { type: String, required: true },
    durationInSseconds: { type: Double, required: true },
    totalKm: { type: Double, required: true },
    pace: { type: Double, required: true }, //Average speed in km/h
    date: { type: Date, required: true },
    elevationGain: { type: Double, required: true },
    points: { type: Double, required: false },
});

// Model
const User = mongoose.model('User', UserSchema);
const Ride = mongoose.model('Ride', RideSchema);

// POST /record
app.post('/record', async (req, res) => {
    console.log('Received record POST request:');
    console.log(req.body);
    var ride = new Ride(req.body);
    ride.pace = ride.totalKm / (ride.durationInSeconds / 3600)
   
    // We cannot do User.findById since the uid is not the _id
    if (req.body.uid && await User.findOne({ uid: req.body.uid })) {
        gamification_controller.assign_points(ride).then(() => {
                res.json({
                    'message': 'Ride saved successfully',
                    'points': ride.points,
                    'pace': ride.pace,
                    'id': ride._id
                });
            }).catch((err) => {
            console.error(err);
            res.status(500).send("Cannot save the ride in the DB");
        });
    }
    else {
        console.error('Cannot find the user specified!\n');
        res.status(500).send('Cannot find the user specified!');
    }
});

// GET /getAllByUser
app.get('/getAllByUserId', (req, res) => {
    console.log('Received getAllByUserId GET request:');
    console.log("User:", req.query.userId);

    if (req.query.userId) {
        // I return an array of rides without the fields _id and __v
        Ride.find({ userId: req.query.userId }, '-_id -__v', (error, rides) => {
            if (error) {
                console.log('Error finding the rides of the specified userId.\n' + error);
                res.status(500).send('Error finding the rides!');
            } else {
                res.status(200).send(rides);
            }
        });
    } else {
        console.log('Error: Missing the userId parameter.');
        res.status(400).send('Error: Missing the userId parameter.');
    }
});




module.exports = app;