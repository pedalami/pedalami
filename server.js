require('dotenv').config();
const express = require('express');
const path = require('path');
const mongoose = require('mongoose');
const routes = require('routes');

const app = express();
app.use(express.json());

const PORT = process.env.PORT || 8000
const MONGO_URI = String(process.env.MONGO_URI);

const connectionParams={
    useNewUrlParser: true,
    useUnifiedTopology: true 
}
mongoose.connect(MONGO_URI,connectionParams)
    .then( () => {
        console.log('Connected to database!')
    })
    .catch( (err) => {
        console.error(`Error connecting to the database.\n${err}`);
    })

var listener = app.listen(PORT, function(){
    console.log('Listening on port ' + listener.address().port);
});

app.get('/', (req, res) => {
    res.send('<h1>Welcome to PedalaMi!<h1>');
})


// Schema
const Schema = mongoose.Schema;
const UserSchema = new Schema({
    token: String,
    email: String
})

// Model
const User = mongoose.model('User', UserSchema)

app.get('/createUser', (req, res) => {
    console.log("Received createUser GET request:")
    console.log(req.body)
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
})
