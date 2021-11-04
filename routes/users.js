var express = require('express');
var app = express.Router();
const mongoose = require('mongoose');


// Schema
const Schema = mongoose.Schema;
const UserSchema = new Schema({
    token: String,
    email: String
})

// Model
const User = mongoose.model('User', UserSchema)

app.get('/create', (req, res) => {
    console.log("Received createUser GET request:")
    console.log(req.body)
    if(req.body.token && req.body.email) {
    const newUser = new User(req.body)
    newUser.save((error) => {
        if(error) {
            console.log('Error saving the user.');
            res.send('Error saving the user!');
        } else {
            console.log('The user has been saved.')
            res.send('User saved correctly!');
        }
    })
    } else {
        console.log('Error: Missing parameters.')
        res.send('Error: Missing parameters.');
    }
})

module.exports = app;
