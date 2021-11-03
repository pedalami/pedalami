require('dotenv').config();
const express = require('express');
const path = require('path');
const mongoose = require('mongoose');


const app = express();
const PORT = process.env.PORT || 8000



const uri = String(process.env.MONGO_URI);
console.log(uri)
const connectionParams={
    useNewUrlParser: true,
    useUnifiedTopology: true 
}
mongoose.connect(uri,connectionParams)
    .then( () => {
        console.log('Connected to database ')
    })
    .catch( (err) => {
        console.error(`Error connecting to the database. \n${err}`);
    })


app.get('/api', (req, res) => {
    const data = {
        user: 'emanuele'
    }
})