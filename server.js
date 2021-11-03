require('dotenv').config();
const express = require('express');
const path = require('path');
const mongoose = require('mongoose');

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
    res.send('<h1>Welcome!<h1>');
})


// Schema
const Schema = mongoose.Schema;
const UserSchema = new Schema({
    token: String,
    email: String
})

// Model
const User = mongoose.model('User', UserSchema)

app.post('/createUser', (req, res) => {
    //console.log(req)
    console.log(req.body)
    
    const newUser = new User(req.body)
    newUser.save((error) => {
        if(error) {
            console.log('Error saving the user.');
        } else {
            console.log('The user has been saved.')
        }
    })
    res.send('test response');

})
/*
const example_user_data = {
    token: 'a5d122cb9edf7',
    email: 'et@gmail.com'
}
*/