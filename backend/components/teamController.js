var express = require('express');
var app = express.Router();
app.use(express.json());
const models = require('../schemas.js');
const Team = models.Team;
const User = models.User;
const ObjectId = models.ObjectId;

// POST /create
app.post('/create', (req, res) => {
  console.log('Received create POST request:');
  console.log(req.body);
  if (req.body.name) {
    newTeam = new Team(req.body);
    User.findOne({ userId: req.body.adminId }, (error, admin) => {
      if (error) {
        console.log('Error while searching for the user specified as admin!\n'+error);
        res.status(500).send('Error while creating the team!\nError while searching for the user specified as admin');
      }
      if (!admin) {
        console.log('Cannot find the user specified as admin!\n');
        res.status(500).send('Error while creating the team: the team admin specified does not exist!');
      } 
      else {
        newTeam.members.push(req.body.adminId);
        admin.teams.push(newTeam._id);
        Promise.all([newTeam.save(), admin.save()]).then(([team, admin]) => {
          if (!admin || !team) {
            console.log('Error while creating the team!\n');
            res.status(400).send('Error while creating the team!');
          } else {
            console.log("Team with id: "+team._id+" added successfully");
            res.status(200).json({
              teamId: team._id
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
    //Team.find({ name: {$regex: to_search} }, 'team_id name', (error, teams) => { //returns only team_id and name fields
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