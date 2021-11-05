var express = require('express');
var app = express.Router();
const mongoose = require('mongoose');

// Schema
const Schema = mongoose.Schema;
const UserSchema = new Schema({
  token: String,
  email: String,
  points: Number,
});

// Model
const User = mongoose.model('User', UserSchema);

app.get('/create', (req, res) => {
  console.log('Received createUser GET request:');
  console.log(req.body);
  if (req.body.token && req.body.email) {
    const newUser = new User(req.body);
    newUser.points = 0;

    newUser.save((error) => {
      if (error) {
        console.log('Error saving the user.');
        res.send('Error saving the user!');
      } else {
        console.log('The user has been saved.');
        res.send('User saved correctly!');
      }
    });
  } else {
    console.log('Error: Missing parameters.');
    res.send('Error: Missing parameters.');
  }
});

app.get('/addPoints', (req, res) => {
  //Read token
  //Number of points to add for ID Profile

  if(req.body.points <= 0){
    res.send('Points cannot be negative!');
  }
  else{

  var query = { token: req.body.token };

  

  User.findOne({ 'token': req.body.token }).then(function (oldUser) {
      
    User.findOneAndUpdate(
        query,
        {points: +oldUser.points + +req.body.points},
        { upsert: true },
        function (err, doc) {
          if (err) return res.send(500, { error: err });
          return res.send('Succesfully sum points.');
        }
      );
});
  }

});

 

app.patch('/removePoints', (req, res) => {
  //Read Token
  //Number of points to remove for ID Profile
});

module.exports = app;
