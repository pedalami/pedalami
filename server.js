require('dotenv').config();
const express = require('express');
const path = require('path');
const mongoose = require('mongoose');
const { getMaxListeners } = require('process');


const app = express();
app.use(express.json());

const PORT = process.env.PORT || 8000

const uri = String(process.env.MONGO_URI);
console.log(uri)
const connectionParams={
    useNewUrlParser: true,
    useUnifiedTopology: true 
}
mongoose.connect(uri,connectionParams)
    .then( () => {
        console.log('Connected to database!')
    })
    .catch( (err) => {
        console.error(`Error connecting to the database. \n${err}`);
    })

var listener = app.listen(PORT, function(){
    console.log('Listening on port ' + listener.address().port);
});

app.get('/', (req, res) => {
    console.log(req.body)
    res.send('test response');
})

/*
// Schema
const Schema = mongoose.Schema;
const UserSchema = new Schema({
    token: String,
    email: String
})

// Model
const User = mongoose.model('User', UserSchema)

const example_user_data = {
    token: 'a5d122cb9edf7',
    email: 'et@gmail.com'
}
const newUser = new User(example_user_data)
newUser.save((error) => {
    if(error) {
        console.log('Error saving the user.');
    } else {
        console.log('The user has been saved.')
    }
})*/