require('dotenv').config();
const express = require('express');
const path = require('path');
const mongoose = require('mongoose');

var usersRouter = require('./backend/components/profile_controller');
var teamsRouter = require('./backend/components/team_controller');
var rideRouter = require('./backend/components/ride_handler');

var swaggerUi = require('swagger-ui-express');
var swaggerDocument = require('./backend/swagger.json');


const PORT = process.env.PORT || 8000
const MONGO_URI = process.env.MONGO_URI;

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

const app = express();
app.use(express.json());

var listener = app.listen(PORT, function(){
    console.log('Listening on port ' + listener.address().port);
});

app.get('/', (req, res) => {
    res.send('<h1>Welcome to PedalaMi!<h1>');
});

app.use('/users', usersRouter);
app.use('/teams', teamsRouter);
app.use('/rides', rideRouter);

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));



