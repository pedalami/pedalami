require('dotenv').config();
const express = require('express');
const path = require('path');
const mongoose = require('mongoose');


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
mongoose.Promise = Promise;
const app = express();
app.use(express.json());
var listener = app.listen(PORT, function(){
    console.log('Listening on port ' + listener.address().port);
});


var usersRouter = require('./backend/components/profileController').router;
var teamsRouter = require('./backend/components/teamController');
var rideRouter = require('./backend/components/rideHandler');

var swaggerUi = require('swagger-ui-express');
var swaggerDocument = require('./backend/swagger.json');

app.use('/users', usersRouter);
app.use('/teams', teamsRouter);
app.use('/rides', rideRouter);
//app.use('/tests', require('./backend/components/testingTx'));

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));


app.get('/', (req, res) => {
    res.send('<h1>Welcome to PedalaMi!<h1>');
});
