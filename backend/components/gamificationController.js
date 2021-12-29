const User = require('../schemas.js').User;
const Badge = require('../schemas.js').Badge;
const profileController = require("./profileController.js");


async function assignPoints(user, ride, events) {
    //Calculate points
    var points = Math.round((ride.totalKm * 100) + (ride.elevationGain * 10)); //add bonus if raining later on
    ride.points = points;
    var individual_counter = 0;

    var team_counter = 0;
    events.forEach(event => {
        if (ride.date <= event.endDate && ride.date >= event.startDate) {
            if (event.type == "individual" && event.visibility == "public") {
                individual_counter++;
            } else if (event.type == "team") {
                if ((event.visibility == "private" && event.guestTeam != null) || (event.visibility == "public" && event.involvedTeams.size >= 2))
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
                        score.points += points / individual_counter;
                        found = true;
                    }
                    return found;
                });
            }
        });
    }

    if (team_counter > 0) {
        points = points / (team_counter + 1);
        events.forEach(event => {
            if (event.type == "team") {
                if ((event.visibility == "private" && event.guestTeam != null) || (event.visibility == "public" && event.involvedTeams.size >= 2)) {
                    var found = false;
                    event.scoreboard.some(function (score) {
                        if (score.userId == user.userId) {
                            console.log(score);
                            score.points += points;
                            found = true;
                        }
                        return found;
                    });
                }

            }
        })
    }
    console.log("Assigning " + points + " points to " + user.userId + " and to its events");
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