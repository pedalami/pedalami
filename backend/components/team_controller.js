var express = require('express');
var app = express.Router();
app.use(express.json());
const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const ObjectId = mongoose.Types.ObjectId
const UserSchema = Schema.UserSchema;

// Schema
const TeamSchema = new Schema({
  admin_uid: { type: String, required: true },
  name: { type: String, required: true },
  description: { type: String, required: false },
  members: [{ type: String, required: true, default: null }], // At least the admin
  active_events: [{ type: ObjectId, required: false, default: null }], // IDs of active events
  event_requests: [{ type: ObjectId, required: false, default: null }] // To better define once requests are defined
});

// Model
const Team = mongoose.model('Team', TeamSchema);
const User = mongoose.model('User', UserSchema);

// POST /create
app.post('/create', (req, res) => {
  console.log('Received create POST request:');
  console.log(req.body);
  if (req.body.name) {
    newTeam = new Team();
    newTeam.admin_uid = req.body.admin_uid;
    newTeam.name = req.body.name;
    newTeam.description = req.body.description;
    newTeam.members = [req.body.admin_uid];
    User.findOne({ uid: req.body.admin_uid }, (error, admin) => {
      if (error) {
        console.log('Error while searching for the user specified as admin!\n' + error);
        res.status(500).send('Error while creating the team!\nError while searching for the user specified as admin');
      }
      if (!admin) {
        console.log('Cannot find the user specified as admin!\n');
        res.status(500).send('Error while creating the team: the team admin specified does not exist!');
      }
      else {
        //newTeam.members.push(req.body.admin_uid);
        admin.teams.push(newTeam._id)
        Promise.all([newTeam.save(), admin.save()]).then(([team, admin]) => {
          if (!admin || !team) {
            console.log('Error while creating the team!\n');
            res.status(400).send('Error while creating the team!');
          } else {
            console.log("Team with id: " + team._id + " added successfully");
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
  console.log('Received search GET request with param name=' + to_search);
  if (to_search) {
    //Team.find({ name: {$regex: to_search} }, 'team_id name', (error, teams) => { //returns only team_id and name fields
    Team.find({ name: { $regex: to_search } }, (error, teams) => {
      if (error) {
        console.log('Error finding the teams.\n' + error);
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
  if (req.body.team_id && req.body.uid) {
    Promise.all([
      User.findOne({ uid: req.body.uid }),
      Team.findOne({ _id: req.body.team_id })
    ]).then(([user, team]) => {
      console.log(team);
      console.log(user);
      if (team.members.includes(req.body.uid)) {
        console.log('Error: User already in team.');
        res.status(500).send('Error: User already in team.');
      } else {
        if (user.teams == null) {
          user.teams = [];
        }
        user.teams.push(req.body.team_id);
        team.members.push(req.body.uid);
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
            console.log('Error while joining the team\n' + error2);
            res.status(500).send('Error while joining the team');
          });
      }
    }).catch((error) => {
      console.log('Error finding the user or the team.\n' + error);
      res.status(500).send('Error finding the user or the team!');
    });

  }
  else {
    console.log('Error: Missing parameters.');
    res.status(400).send('Error: Missing parameters.');
  }
});


// GET /getTeam?teamID=teamID
app.get('/getTeam', (req, res) => {
  const teamID = req.query.teamID;
  console.log('Received getTeam GET request with param id=' + teamID);
  if (teamID) {
    Team
      .aggregate([
        {
          $match: {
            _id: ObjectId(teamID)
          }
        },
        {
          $lookup: {
            from: "users", // collection name in db
            localField: "members", // field of User to make the lookup on (the foreign key)
            foreignField: "userID", // the referred field in teams ///DA CAMBIARE ///TODO
            as: "members" // name that the field of the join will have in the result/JSON
          }
        },
        {
          $unset: ["members.teams", "members._id", "members.__v", "__v"]
        }
      ])
      .exec((error, team) => {
        if (error) {
          console.log('Error finding the user.\n' + error);
          res.status(500).send('Error finding the team!');
        } else {
          res.status(200).send(team);
        }
      });
  } else {
    console.log('Error: Missing parameters.');
    res.status(400).send('Error: Missing parameters.');
  }
});


module.exports = app;