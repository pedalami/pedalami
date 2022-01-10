const Badge = require('../schemas.js').Badge;
const profileController = require("./profileController.js");


async function assignPoints(user, ride, events, weatherId) {
    //Calculate points based on ride totalKm and elevationGain
    var points = Math.round((ride.totalKm * 100) + (ride.elevationGain * 10));
    console.log("Calcolo il weather Bonus dal weatherId: " + weatherId);
    //Add weather bonus if the ride is at least 1km
    weatherBonus = getWeatherBonusPoints(weatherId);
    if (ride.totalKm >= 1) {
        console.log("Initial Points: " + points + " Weather Bonus: " + weatherBonus);
        points += weatherBonus;
    }

    ride.points = points;
    console.log("Assigning " + points + " points to " + user.userId);
    var individual_counter = 0;

    var team_counter = 0;
    events.forEach(event => {
        //console.log("Event: " + event.name);
        //console.log("Event type: " + event.type);
        //console.log("Event visibility: " + event.visibility);
        //console.log(new Date());
        if (ride.date <= event.endDate && ride.date >= event.startDate) {
            if (event.type === "individual" && event.visibility === "public") {
                individual_counter++;
            } else if (event.type === "team") {
                //console.log("Team event" + (event.visibility === "public") + " involved team size: " + event.involvedTeams.length);
                if ((event.visibility === "private" && event.guestTeam != null) || (event.visibility === "public" && event.involvedTeams.length >= 2)){
                    console.log("Team event QUI");
                    team_counter++;
                }
            }
        }
    });
    if (individual_counter > 0) {
        events.forEach(event => {
            if (event.type === "individual" && event.visibility === "public" && ride.date <= event.endDate && ride.date >= event.startDate) {
                var found = false;
                event.scoreboard.some(function (score) {
                    if (score.userId === user.userId) {
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
        //console.log("Team counter:" + team_counter);
        points = points / (team_counter + 1);
        events.forEach(event => {
            //console.log("For each" + event.name);
            if (event.type === "team" && ride.date <= event.endDate && ride.date >= event.startDate) {
                if ((event.visibility === "private" && event.guestTeam != null) || (event.visibility === "public" && event.involvedTeams.length >= 2)) {
                    var foundUser = false;
                    var foundTeam = false;
                    var userTeamId;
                    console.log("Ho trovato l'evento " + event.name + "che è di tipo " + event.type + " e di visibilità " + event.visibility);
                    event.scoreboard.some(function (score) {
                        if (score.userId === user.userId) {
                            console.log("Ho trovato l'utente con score " + score.userId);
                            //console.log(score);
                            userTeamId = score.teamId;
                            score.points += points;
                            foundUser = true;
                        }
                        return foundUser;
                    });
                    if (event.teamScoreboard != null && event.teamScoreboard.length > 0) {
                        event.teamScoreboard.some(function (teamScore) {
                            //console.log("Ho trovato la squadra con id " + teamScore.teamId);
                            //console.log("userTeamId: " + userTeamId);
                            //console.log(teamScore.teamId === userTeamId);
                            //console.log(teamScore.teamId.equals(userTeamId));
                            if (teamScore.teamId.equals(userTeamId)) {
                                console.log("Assining " + points + "points to team " + userTeamId + " for event " + event.name + " ride " + ride.rideId + " user " + user.userId);
                                teamScore.points += points;
                                foundTeam = true;
                            }
                            return foundTeam;
                        });
                        if (!foundTeam) {
                            event.teamScoreboard.push({ "teamId": userTeamId, "points": points });
                            console.log("Adding new score: assigning "  + points + " points to team " + userTeamId + " for event " + event.name + " ride " + ride.rideId + " user " + user.userId);
                        }
                        
                    } else {
                        event.teamScoreboard = [];
                        event.teamScoreboard.push({ "teamId": userTeamId, "points": points });
                        console.log("Creating new score: assigning " + points + " points to team " + userTeamId + " for event " + event.name + " ride " + ride.rideId + " user " + user.userId);
                    }
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

function getWeatherBonusPoints(weatherId) {
    if(weatherId != null) {
        //Thunderstorm
        if (weatherId>=200 && weatherId<=232) {
            return 10;
        }
        //Drizzle
        if (weatherId>=300 && weatherId<=321) {
            return 3;
        }
        //Rain
        if (weatherId>=500 && weatherId<=531) {
            return 5;
        }
        //Snow
        if (weatherId>=600 && weatherId<=622) {
            return 10;
        }
        //Atmosphere
        if (weatherId>=701 && weatherId<=780) {
            return 3;
        }
        //Tornado
        if (weatherId>=781) {
            return 20;
        }
        if (weatherId>=800) {
            return 333;
        }
    }
    else return 100;
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
    if (teamScoreboard.length > 0) {
        const winningTeam = teamScoreboard.reduce(function (prev, current) {
            return (prev.points > current.points) ? prev : current
        })
        var totalPoints = 0;
        event.teamScoreboard.forEach(function (score) {
            totalPoints += score.points;
        });
        if (winningTeam.points > 0) {
            var userScoreboard = event.scoreboard.filter(score => {
                return score.userId === user.userId && score.teamId.equals(winningTeam.teamId);
            })
            if (userScoreboard.length != null) {
                if (userScoreboard.length >= 1)
                    userScoreboard = userScoreboard[0];
                console.log("TotalPoints:" + totalPoints)
                console.log("User points:" + userScoreboard.points)
                console.log("Team Points:" + winningTeam.points)
                user.points += totalPoints * userScoreboard.points / winningTeam.points;
            }
        }
    }
}


module.exports = {
    assignPoints: assignPoints,
    checkNewBadgesAfterRide: checkNewBadgesAfterRide,
    getBestPlayerIndividualEvent: getBestPlayerIndividualEvent,
    assignPrizeIndividualEvent: assignPrizeIndividualEvent,
    computeTeamScoreboard: computeTeamScoreboard,
    assignPrizeTeamEvent: assignPrizeTeamEvent

};
