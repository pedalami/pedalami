const mongoose = require('mongoose');
const Schema = mongoose.Schema;
const UserSchema = Schema.UserSchema;


// Model
const User = mongoose.model('User2', UserSchema);


async function assignPoints(ride) {
    //Calculate points
    var points = (ride.totalKm * 100) + (ride.elevationGain * 10); //add bonus if raining later on
    ride.points = points;
    await User.findOne({ userId: ride.userId }).then((user) => {
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

module.exports = { assignPoints };