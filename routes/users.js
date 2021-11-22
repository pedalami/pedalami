var express = require('express');
var app = express.Router();
app.use(express.json());
const mongoose = require('mongoose');
const Schema = mongoose.Schema;

// Schema
const UserSchema = new Schema({
  uid: {type: String, required: true},
  points: {type: Number, required: true, default: 0},
});

// Model
const User = mongoose.model('User', UserSchema);



app.post('/create', (req, res) => {
  console.log('Received create POST request:');
  console.log(req.body);
  if (req.body.uid) {
    const newUser = new User(req.body);
    newUser.save((error) => {
      if (error) {
        console.log('Error saving the user.');
        res.status(500).send('Error saving the user!');
      } else {
        console.log('The user has been saved.');
        res.status(200).send('User saved correctly!');
      }
    });
  } else {
    console.log('Error: Missing parameters.');
    res.status(400).send('Error: Missing parameters.');
  }
});

app.get('/addPoints', (req, res) => {
  if (req.body.points <= 0) {
    res.send('Points cannot be negative!');
  } else {
    var query = { token: req.body.token };

    User.findOne({ token: req.body.token }).then(function (oldUser) {
      User.findOneAndUpdate(
        query,
        { points: +oldUser.points + +req.body.points },
        { upsert: true },
        function (err, doc) {
          if (err) return res.send(500, { error: err });
          return res.send('Succesfully added points.');
        }
      );
    }).catch(err => res.status(500).send({ error: err.message }));
  }
});

app.get('/removePoints', (req, res) => {

  if (req.body.points <= 0) {
    res.send('Points cannot be negative!');
  } else {
    var query = { token: req.body.token };

    User.findOne({ token: req.body.token }).then(function (oldUser) {
      if (0 > +oldUser.points - +req.body.points) {
        res.send('User Points Result cannot be negative!');
      } else {
        User.findOneAndUpdate(
          query,
          { points: +oldUser.points - +req.body.points },
          { upsert: true },
          function (err, doc) {
            if (err) return res.send(500, { error: err });
            return res.send('Succesfully removed points.');
          }
        );
      }
    }).catch(err => res.status(500).send({ error: err.message }));
  }
});

module.exports = app;
