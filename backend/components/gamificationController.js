const User = require('../schemas.js').User;

function assignPoints(user, ride) {
    //Calculate points
    var points = (ride.totalKm * 100) + (ride.elevationGain * 10); //add bonus if raining later on
    ride.points = points;
    console.log("Assigning "+points+" points to "+user.userId);
    user.points += points;
}

module.exports = { assignPoints };