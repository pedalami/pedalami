const User = require('../schemas.js').User;
const Badge = require('../schemas.js').Badge;

function assignPoints(user, ride) {
    //Calculate points
    var points = Math.round((ride.totalKm * 100) + (ride.elevationGain * 10)); //add bonus if raining later on
    ride.points = points;
    console.log("Assigning " + points + " points to " + user.userId);
    user.points += points;
}

async function checkNewBadgesAfterRide(user, ride) {
    const badgeList = await Badge.find({});
    badgeList.forEach(badge => {
        if (!user.badges.includes(badge._id)) {
            if (badge.type === "userStat" && user.statistics[badge.criteria] > badge.criteriaValue)
                user.badges.push(badge);
            if (badge.type === "ride" && ride[badge.criteria] > badge.criteriaValue)
                user.badges.push(badge);
        }
    });
}

module.exports = {
    assignPoints: assignPoints,
    checkNewBadgesAfterRide: checkNewBadgesAfterRide
};