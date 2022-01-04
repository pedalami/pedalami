const Badge = require('../schemas.js').Badge;
const profileController = require("./profileController.js");


async function assignPoints(user, ride, events) {
    //Calculate points
    var points = Math.round((ride.totalKm * 100) + (ride.elevationGain * 10)); //add bonus if raining later on
    ride.points = points;
    console.log("Assigning " + points + " points to " + user.userId);
    //user.points += points;
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
            if (event.type == "team" && ride.date <= event.endDate && ride.date >= event.startDate) {
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
            if (badge.type === "userStat" && user.statistics[badge.criteria] >= badge.criteriaValue)
                user.badges.push(badge);
            if (badge.type === "ride" && ride[badge.criteria] >= badge.criteriaValue)
                user.badges.push(badge);
        }
    });
}

function getBestPlayerIndividualEvent(event) {
    if (event.prize != null && event.scoreboard.length > 0) {
        const bestPlayer = event.scoreboard.reduce(function (prev, current) {
            return (prev.points > current.points) ? prev : current
        })
        return bestPlayer
    }
    return null;
}

function assignPrizeIndividualEvent(user, event) {
    if (event.prize != null) {
        user.points += event.prize;
    }
    return user;
}

function computeTeamScoreboard(event) {
    var teamScoreboardMap = new Map();
    var teamScoreboard = [];
    event.scoreboard.forEach(function (score) {
        var scoreboardValue = teamScoreboardMap.get(score.teamId);
        if (scoreboardValue === undefined) {
            teamScoreboardMap.set(score.teamId, score.points);
        } else {
            teamScoreboardMap.set(score.teamId, scoreboardValue + score.points);
        }
    });
    teamScoreboardMap.forEach((value, key) => {
        teamScoreboard.push({ "teamId": key, "points": value });
    });
    return teamScoreboard;
}

function assignPrizeTeamEvent(user, event) {

    var teamScoreboard = event.teamScoreboard;
    if (teamScoreboard === undefined) {
        teamScoreboard = computeTeamScoreboard(event);
        event.teamScoreboard = teamScoreboard;
    }
    if (teamScoreboard.lenght > 0) {
        const winningTeam = teamScoreboard.reduce(function (prev, current) {
            return (prev.points > current.points) ? prev : current
        })
        var totalPoints = 0;
        event.teamScoreboard.forEach(function (score) {
            totalPoints += score.points;
        });
        if (winningTeam.points > 0) {
            var userScoreboard = event.scoreboard.filter(score => {
                return score.userId === user.userId && score.teamId === winningTeam.teamId;
            })
            if (userScoreboard.length != null) {
                if (userScoreboard.length > 1)
                    userScoreboard = userScoreboard[0];
                user.points += totalPoints * userScoreboard.points / winningTeam.points;
            }
        }
    }
}


module.exports = {
    assignPoints: assignPoints,
    checkNewBadgesAfterRide: checkNewBadgesAfterRide,
    getBestPlayerIndividualEvent: getBestPlayerIndividualEvent,
    assignPrizeIndividualEvent: assignPrizeIndividualEvent
};
