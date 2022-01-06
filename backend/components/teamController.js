var express = require('express');
var app = express.Router();
app.use(express.json());
const models = require('../schemas.js');
const Team = models.Team;
const User = models.User;
const ObjectId = models.ObjectId;
const connection = models.connection;

// POST /create
app.post('/create', (req, res) => {
  console.log('Received create POST request:');
  console.log(req.body);
  if (req.body.name && req.body.adminId) {
    newTeam = new Team(req.body);
    connection.transaction(async (session) => {
      const admin = await User.findOne({ userId: req.body.adminId }).session(session).exec()
      if (!admin) {
        console.log('Cannot find the user specified as admin!\n');
        throw new Error('the team admin specified does not exist!');
      } else {
        newTeam.members.push(req.body.adminId);
        admin.teams.push(newTeam._id);
        await Promise.all([
          newTeam.save({ session }),
          admin.save({ session })
        ]);
      }
    })
      .then(() => {
        res.status(200).json({
          teamId: newTeam._id
        });
      })
      .catch((error) => {
        console.log('Error while creating the team: ' + error);
        res.status(500).send('Error while creating the team. ' + error);
      });
  } else {
    console.log('Error: Missing parameters.');
    res.status(400).send('Error: Missing parameters.');
  }
});

// GET /search?name=portion_of_name
app.get('/search', (req, res) => {
  const to_search = req.query.name;
  console.log('Received search GET request with param name=' + to_search);
  if (to_search) {
    //Team.find({ name: {$regex: to_search} }, 'team_id name', (error, teams) => { //returns only team_id and name fields
    Team.find({ name: { $regex: '.*' + to_search + ".*", $options: 'i' } }, (error, teams) => {
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
  if (req.body.teamId && req.body.userId) {
    connection.transaction(async (session) => {
      const [user, team] = await Promise.all([
        User.findOne({ userId: req.body.userId }).session(session).exec(),
        Team.findOne({ _id: req.body.teamId }).session(session).exec()
      ]);
      if (team.members.includes(req.body.userId)) {
        throw new Error('Error: User already in team.');
      } else {
        if (user.teams == null) {
          user.teams = [];
        }
        user.teams.push(req.body.teamId);
        team.members.push(req.body.userId);
        await Promise.all([
          team.save({ session }),
          user.save({ session })
        ])
      }
    })
      .then(() => {
        res.status(200).send('Team joined successfully');
      })
      .catch((err) => {
        console.log('Error while joining the team\n' + err);
        res.status(500).send('Error while joining the team');
      })
  }
  else {
    console.log('Error: Missing parameters.');
    res.status(400).send('Error: Missing parameters.');
  }
});

//POST /leave
app.post('/leave', (req, res) => {
  console.log('Received leave POST request:');
  console.log(req.body);
  if (req.body.teamId && req.body.userId) {
    connection.transaction(async (session) => {
      const [user, team] = await Promise.all([
        User.findOne({ userId: req.body.userId }).session(session).exec(),
        Team.findOne({ _id: req.body.teamId }).session(session).exec()
      ]);
      if (!team.members.includes(req.body.userId)) {
        throw new Error('Error: User not in team.');
      } else {
        if (team.adminId == req.body.userId) {
          throw new Error('Forbidden: An admin cannot leave the team.');
        } else {
          user.teams.splice(user.teams.indexOf(ObjectId(req.body.teamId)), 1);
          team.members.splice(team.members.indexOf(req.body.userId), 1);
          //await connection.transaction((session) => {
            return Promise.all([
              team.save({ session }),
              user.save({ session })
            ]);
          //});
        }
      }
    })
      .then(() => {
        res.status(200).send('Team left successfully');
      })
      .catch((err) => {
        console.log('Error while leaving the team\n' + err);
        res.status(500).send('Error while leaving the team');
      })
  }
  else {
    console.log('Error: Missing parameters.');
    res.status(400).send('Error: Missing parameters.');
  }
});

// GET /getTeam?teamId=teamId
app.get('/getTeam', (req, res) => {
  const teamId = req.query.teamId;
  console.log('Received getTeam GET request with params teamId=' + teamId);
  if (teamId) {
    var teamIdObject;
    try {
      teamIdObject = new ObjectId(teamId);
    } catch (error) {
      console.log('The specified teamId is not a valid objectId' + error);
      res.status(500).send('The specified teamId is not a valid objectId');
    }
    Team.aggregate([
      {
        $match: {
          _id: teamIdObject
        }
      },
      {
        $lookup: {
          from: "users", // collection name in db
          localField: "members", // field of Team to make the lookup on (the field with the "foreign key")
          foreignField: "userId", // the referred field in users 
          as: "members" // name that the field of the join will have in the result/JSON
        }
      },
      {
        $unset: ["members.teams", "members._id", "members.__v", "__v", "members.rewards"]
      }
    ])
      .exec((error, teams) => {
        if (error) {
          console.log('Error finding the team.\n' + error);
          res.status(500).send('Error finding the team!');
        } else {
          if (teams && teams.length === 1) {
            res.status(200).send(teams[0]);
          } else {
            res.status(500).send('Error finding the team!');
          }
        }
      })
  } else {
    console.log('Error: Missing parameters.');
    res.status(400).send('Error: Missing parameters.');
  }
});

module.exports = app;