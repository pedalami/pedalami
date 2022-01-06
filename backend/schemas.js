const mongoose = require("mongoose");
const Schema = mongoose.Schema;
const ObjectId = mongoose.Types.ObjectId;
const Date = mongoose.Schema.Types.Date;
const Mixed = mongoose.Schema.Types.Mixed;

// Schemas
const UserSchema = new Schema({
    userId: { type: String, required: true },
    points: { type: Number, required: true, default: 0 },
    teams: [{ type: ObjectId, required: false, default: null }],
    statistics: {
        numberOfRides: { type: Number, required: true, default: 0 },
        totalDuration: { type: Number, required: true, default: 0 },
        totalKm: { type: Number, required: true, default: 0 },
        totalElevationGain: { type: Number, required: true, default: 0 },
        averageSpeed: { type: Number, required: true, default: 0 },
        averageDuration: { type: Number, required: true, default: 0 },
        averageKm: { type: Number, required: true, default: 0 },
        averageElevationGain: { type: Number, required: true, default: 0 }
    },
    badges: [{ type: ObjectId, required: false, default: null }],
    rewards: [new Schema({
        _id: false,
        rewardId: { type: ObjectId, required: true, default: null },
        redeemedDate: { type: Date, required: true, default: null },
        rewardContent: { type: String, required: true, default: null }
    })],
    joinedEvents: [{ type: ObjectId, required: false, default: null }], // IDs of joined events
});

const TeamSchema = new Schema({
    adminId: { type: String, required: true },
    name: { type: String, required: true },
    description: { type: String, required: false },
    members: [{ type: String, required: true, default: null }], // At least the admin
    activeEvents: [{ type: ObjectId, required: false, default: null }], // IDs of active events
    eventRequests: [{ type: ObjectId, required: false, default: null }] // To better define once requests are defined
});

const RideSchema = new Schema({
    userId: { type: String, required: true },
    name: { type: String, required: true },
    durationInSeconds: { type: Number, required: true },
    totalKm: { type: Number, required: true },
    pace: { type: Number, required: true }, //Average speed in km/h
    date: { type: Date, required: true },
    path: [new Schema({
        _id: false,
        latitude: { type: Number, required: true },
        longitude: { type: Number, required: true },
    })],
    elevationGain: { type: Number, required: true },
    points: { type: Number, required: true },
});

const BadgeSchema = new Schema({
    // Criteria can be totalKm, totalElevationGain, totalDuration, numberOfRides
    criteria: { type: String, required: true },
    // The criteria value can be, depending on the criteria, a number like 10, 100, 1000, etc
    criteriaValue: { type: Number, required: true },
    // The badge image is dependent both on the criteria and the criteriaValue
    image: { type: String, required: true },
    // The type is the context where the badge is checked
    type: { type: String, required: true },
    description: { type: String, required: true }
});

const RewardSchema = new Schema({
    price: { type: Number, required: true },
    description: { type: String, required: true },
    image: { type: String, required: true },
});

const EventSchema = new Schema({
    name: { type: String, required: true },
    description: { type: String, required: true },
    startDate: { type: Date, required: true },
    endDate: { type: Date, required: true },
    closed: { type: Boolean, required: true, default: false },
    type: { type: String, required: true }, // The event can be team or individual
    visibility: { type: String, required: true }, // The event can be public or private
    prize: { type: Number, required: false }, // The event must have a prize only if visibility is "public" and type is "individual"

    // if it is a private team event
    hostTeam: { type: ObjectId, required: false }, //the team proposing the event
    guestTeam: { type: ObjectId, required: false }, //the teams invited to the event

    //if it is a public team event, involvedTeams is the list of teams that are partecipating to the event, including the host
    //if it is a private team event, it is a singleton list with the invited team that has not accepted yet the invitation
    involvedTeams: [{ type: ObjectId, required: false }], //the teams that are involved in the event
    winningTeam: { type: ObjectId, required: false }, //the team that wins the event

    status: { type: String, required: false }, //It is set only if the event is a public team event, it can be "pending", "approved", "rejected".


    scoreboard: [new Schema({
        _id: false,
        //add indexes on teamId and userId
        userId: { type: String, required: true },
        teamId: { type: ObjectId, required: false, default: null }, //null if it is an individual event
        points: { type: Number, required: true, default: 0 }
    })],

    teamScoreboard: [new Schema({ //if it's a team event, the scoreboard contains the teamId and the sum of the points collected by the team
        _id: false,
        teamId: { type: ObjectId, required: false },
        points: { type: Number, required: false, default: 0 }
    })]
});

exports.User = mongoose.model("User", UserSchema);
exports.Ride = mongoose.model("Ride", RideSchema);
exports.Team = mongoose.model("Team", TeamSchema);
exports.Badge = mongoose.model("Badge", BadgeSchema);
exports.Reward = mongoose.model("Reward", RewardSchema);
exports.Event = mongoose.model("Event", EventSchema);

exports.connection = mongoose.connection;
exports.ObjectId = ObjectId;
exports.Date = Date;
