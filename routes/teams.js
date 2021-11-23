var express = require('express');
var app = express.Router();
app.use(express.json());
const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const UserSchema = Schema.UserSchema;

// Schema
const TeamSchema = new Schema({
  team_id: { type: String, required: true },
  admin_uid: { type: String, required: true },
  name: { type: String, required: true },
  members: { type: Array, required: true }, // At least the admin
  active_events: { type: Array, required: false }, // IDs of active events
  event_requests: { type: Array, required: false }, // To better define once requests are defined
});

// Model
const Team = mongoose.model('Team', TeamSchema);
const User = mongoose.model('User', UserSchema);

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


// GET /search?name=start_of_name
app.get('/search', (req, res) => {
  console.log('Received search GET request:');
  console.log(req.body);
  const to_search = req.query.name;
  if (to_search) {
    console.log(to_search);
    const teams = Team.find({ name: "test" }, (error, team) => {
      if (error) {
        console.log('Error finding the user.');
        res.status(500).send('Error finding the user!');
      } else {
        res.status(200).send(teams);
      }
    });
  } else {
    console.log('Error: Missing parameters.');
    res.status(400).send('Error: Missing parameters.');
  }
});


// POST /join
app.post('/join', (req, res) => {
  console.log('Received join POST request:');
  console.log(req.body);
  if (req.body.team_id && req.body.uid) {
    const user = User.findOne({ uid: req.body.uid }, (error, user) => {
      if (error) {
        console.log('Error finding the user.');
        res.status(500).send('Error finding the user!');
      }
    });
    const team = Team.findOne({ team_id: req.body.team_id }, (error, team) => {
      if (error) {
        console.log('Error finding the team.');
        res.status(500).send('Error finding the team!');
      } else {
        if (team) {
          if (team.members.includes(req.body.uid)) {
            console.log('Error: User already in team.');
            res.status(400).send('Error: User already in team.');
          } else {
            if (user.teams == null) {
              user.teams = [];
            }
            user.teams.push(req.body.team_id);
            team.members.push(req.body.uid);
            team.save((error) => {
              if (error) {
                console.log('Error adding the user in the team.');
                res.status(500).send('Error adding the user in the team!');
              } else {
                user.save((error) => {
                  if (error) {
                    console.log('Error adding the team in the user.');
                    res.status(500).send('Error adding the team in the user!');
                  } else {
                    console.log('The user has been added to the team.');
                    res.status(200).send('The user has been added to the team.');
                  }
                })
              }
            })
          }
        }
      }
    })
  }
  else {
    console.log('Error: Missing parameters.');
    res.status(400).send('Error: Missing parameters.');
  }
});

module.exports = app;