const User = require('../schemas.js').User;
const Badge = require('../schemas.js').Badge;
const eventHandler = require("./eventHandler.js");


async function assignPoints(user, ride) {
    //Calculate points
    var points = Math.round((ride.totalKm * 100) + (ride.elevationGain * 10)); //add bonus if raining later on
    ride.points = points;
    var events = await eventHandler.getEvents(user);
    var individual_counter = 0;

    var team_counter = 0;
    events.forEach(event => {
        if (ride.date <= event.endDate && ride.date >= event.startDate) {
            if (event.type == "individual" && event.visibility == "public") {
                individual_counter++;
            } else if (event.type == "team") {
                team_counter++;
            }
        }
    });

    if (individual_counter > 0) {
        events.forEach(event => {
            if (event.type == "individual" && event.visibility == "public" && ride.date <= event.endDate && ride.date >= event.startDate) {
                var found = false;
                event.scoreboard.some(function (score) {
                    if (score.userId == user.userId) {
                        console.log(score);
                        score.points += points;
                        found = true;
                        event.save(); //TO BE REMOVED FROM HERE!!!!!
                    }
                    return found;
                });
                /*
                .forEach(score => {
                    if (score.userId == user._id) {
                        score.points += points;
                        found = true;
                        break;
                    }
                });
                */

                if (!found) {
                    event.scoreboard.push({
                        userId: user._id,
                        points: points
                    })
                    event.save(); //TO BE REMOVED FROM HERE!!!!!
                    console.log("New user added to event scoreboard");
                }
            }
        });
    }

       /*
    if (team_counter > 0) {
        points = points / team_counter;
        events.forEach(event => {
            if (event.type == "team") {
                event.scoreboard.push({
                    userId: user._id,
                    //teamId: event.hostTeam, //TO BE CHANGED!!!!!!!
                    points: points
                });
            }
        }
    }
    */

        console.log("Assigning " + points + " points to " + user.userId+ " and to its events");
        user.points += points;
    }

    async function checkNewBadgesAfterRide(user, ride) {
        const badgeList = await Badge.find({});
        badgeList.forEach(badge => {
            if (!user.badges.includes(badge._id)) {
                if (badge.type == "userStat" && user.statistics[badge.criteria] > badge.criteriaValue)
                    user.badges.push(badge);
                if (badge.type == "ride" && ride[badge.criteria] > badge.criteriaValue)
                    user.badges.push(badge);
            }
        });
    }

    module.exports = {
        assignPoints: assignPoints,
        checkNewBadgesAfterRide: checkNewBadgesAfterRide
    };