var express = require('express');
var app = express.Router();
app.use(express.json());
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// Schema
const TeamSchema = new Schema({
  team_id: {type: String, required: true},
  admin_uid: {type: String, required: true},
  members: {type: Array, required: true}, // At least the admin
  points: {type: Number, required: true, default: 0},
  active_events: {type: Array, required: false}, // IDs of active events
  event_requests: {type: Array, required: false}, // To better define once requests are defined
});

// Model
const Team = mongoose.model('Team', TeamSchema);

// POST /create
app.post('/create', (req, res) => {
    console.log('Received create POST request:');
    console.log(req.body);
    if (req.body.team_id) {
      const newTeam = new Team(req.body);
      newTeam.save((error) => {
        if (error) {
          console.log('Error saving the team.');
          res.status(500).send('Error saving the team!');
        } else {
          console.log('The team has been saved.');
          res.status(200).send('Team saved correctly!');
        }
      });
    } else {
      console.log('Error: Missing parameters.');
      res.status(400).send('Error: Missing parameters.');
    }
  });