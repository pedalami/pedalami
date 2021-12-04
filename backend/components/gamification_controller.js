const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const UserSchema = Schema.UserSchema;


// Model
const User = mongoose.model('User', UserSchema);


async function assign_points(ride) {
    //Calculate points
    var points = (ride.total_km * 100) + (ride.elevation_gain * 10); //add bonus if raining later on
    ride.points = points;
    await User.findOne({ uid: ride.uid }).then((user) => {
        if (user) {
            console.log(user);
            if (user.points) {
                user.points += points;
            } else {
                user.points = points;
            }
            Promise.all([
                user.save(),
                ride.save()
            ]).catch(err => {
                console.log(err);
                throw (err);
            });
            return ride;
        }
        else {
            throw ('Gamification controller could not find the user specified in the ride!');
        }
    }).catch(err => {
        throw (err);
    });
}

module.exports = { assign_points };