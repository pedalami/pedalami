var express = require('express');
var app = express.Router();
app.use(express.json());
const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const ObjectId = require('mongodb').ObjectId;
const UserSchema = Schema.UserSchema;

// Schema
const TeamSchema = new Schema({
  adminId: { type: String, required: true },
  name: { type: String, required: true },
  description: { type: String, required: false },
  members: { type: Array, required: true }, // At least the admin
  activeEvents: { type: Array, required: false }, // IDs of active events
  eventRequests: { type: Array, required: false }, // To better define once requests are defined
});

// Model
const Team = mongoose.model('Team', TeamSchema);
const User = mongoose.model('User', UserSchema);

// POST /create
app.post('/create', (req, res) => {
  console.log('Received create POST request:');
  console.log(req.body);
  if (req.body.name) {
    newTeam = new Team(req.body);

    const admin = User.findOne({ uid: req.body.adminId }, (error, admin) => {
      if (error) {
        console.log('Error while searching for the user specified as admin!\n'+error);
        res.status(500).send('Error while creating the team!\nError while searching for the user specified as admin');
      }
      if (!admin) {
        console.log('Cannot find the user specified as admin!\n');
        res.status(500).send('Error while creating the team: the team admin specified does not exist!');
      } 
      else {
        //newTeam.members.push(req.body.adminId);
        newTeam.save((error, team) => {
          if (error || !team) {
            console.log('Error while saving the team!\n'+error);
            res.status(400).send('Error while creating the team!');
          } else {
            console.log("Team with id: "+team._id+" added successfully");
            res.status(200).json({
              team_id: team._id
            });
          }
        }
        );
      }
    });
  } else {
    console.log('Error: Missing parameters.');
    res.status(400).send('Error: Missing parameters.');
  }
});


// GET /search?name=start_of_name
app.get('/search', (req, res) => {
  const to_search = req.query.name;
  console.log('Received search GET request with param name='+to_search);
  if (to_search) {
    //Team.find({ name: {$regex: to_search} }, 'teamId name', (error, teams) => { //returns only team_id and name fields
    Team.find({ name: {$regex: to_search} }, (error, teams) => {
      if (error) {
        console.log('Error finding the teams.\n'+error);
        res.status(500).send('Error finding the teams!');
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
  if (req.body.teamId && req.body.userId) {
    Promise.all([
      User.findOne({ userId: req.body.userId }),
      Team.findOne({ _id: req.body.teamId })
    ]).then(([user, team]) => {
      console.log(team);
      console.log(user);
      if (team.members.includes(req.body.userId)) {
        console.log('Error: User already in team.');
        res.status(500).send('Error: User already in team.');
      } else {
        if (user.teams == null) {
          user.teams = [];
        }
        user.teams.push(req.body.teamId);
        team.members.push(req.body.userId);
        Promise.all([
          team.save(),
          user.save()
        ])
        .then(([user, team]) => {
          if (user != null && team != null) {
            console.log('The user has been added to the team.');
            res.status(200).send('The user has been added to the team.');
          }
        })
        .catch((error2) => {
          console.log('Error while joining the team\n'+error2);
          res.status(500).send('Error while joining the team');
        });
      }
    }).catch((error) => {
      console.log('Error finding the user or the team.\n'+error);
      res.status(500).send('Error finding the user or the team!');
    });
    
  }
  else {
    console.log('Error: Missing parameters.');
    res.status(400).send('Error: Missing parameters.');
  }
});

module.exports = app;