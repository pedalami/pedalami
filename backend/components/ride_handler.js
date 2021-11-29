var express = require('express');
var app = express.Router();
app.use(express.json());
const mongoose = require('mongoose');
const Double = mongoose.Schema.Types.Number;
const Schema = mongoose.Schema;
const UserSchema = Schema.UserSchema;


// Schema
const RideSchema = new Schema({
    user_uid: { type: String, required: true },
    name: { type: String, required: true },
    duration_in_seconds: { type: Double, required: true }, 
    total_km: { type: Double, required: true }, 
    pace: { type: Double, required: true }, //Average speed in km/h
    date: { type: Date, required: true },
    elevation_gain: { type: Double, required: true },
    points: { type: Double, required: false},
  });

// Model
const User = mongoose.model('User', UserSchema);
const Ride = mongoose.model('Ride', RideSchema);

// POST /record
app.post('/record', (req, res) => {
    console.log('Received record POST request:');
    console.log(req.body);
    var ride = new Ride();
    console.log(req.body.user_uid);
    ride.user_uid = req.body.user_uid;
    ride.name = req.body.name
    ride.duration_in_seconds = req.body.duration_in_seconds
    ride.total_km = req.body.total_km
    ride.pace =  req.body.total_km/(req.body.duration_in_seconds/3600)
    ride.date = req.body.date
    ride.elevation_gain = req.body.elevation_gain
    if (req.body.user_uid && User.findOne({ uid: req.body.user_uid })){
    ride.save().then(() => {
        //chiama gamification controller
        res.sendStatus(200).json({
            'message': 'Ride saved successfully',
            'points': ride.points,
            'pace' : ride.pace,
            'id' : ride._id
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




module.exports = app;