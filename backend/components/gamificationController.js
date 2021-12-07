const User = require('../schemas.js').User;

async function assignPoints(user, ride) {
    //Calculate points
    var points = (ride.totalKm * 100) + (ride.elevationGain * 10); //add bonus if raining later on
    ride.points = points;
    if (user) {
        console.log("Assigning "+points+" points to "+user.userId);
        user.points += points;
        // return Promise.all([
        //     user.save({session}),
        //     ride.save({session})
        // ])
    } else {
        throw ('Gamification controller could not find the user specified in the ride!');
    }
}

module.exports = { assignPoints };