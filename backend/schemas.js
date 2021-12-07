const mongoose = require("mongoose");
const Schema = mongoose.Schema;
const ObjectId = mongoose.Types.ObjectId;

// Schemas
const UserSchema = new Schema({
    userId: { type: String, required: true },
    points: { type: Number, required: true, default: 0 },
    teams: [{ type: ObjectId, required: false, default: null }],
    statistics: {
        numberOfRides: { type: Number, required: true, default: 0 },
        totalDuration: { type: Number, required: true, default: 0 },
        totalKm: { type: Number, required: true, default: 0 },
        // The elevationGain of a ride is always postiive
        totalElevationGain: { type: Number, required: true, default: 0 },
        averageSpeed: { type: Number, required: true, default: 0 },
        averageDuration: { type: Number, required: true, default: 0 },
        averageKm: { type: Number, required: true, default: 0 },
        averageElevationGain: { type: Number, required: true, default: 0 }
    }
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
    path: [{
        latitude: { type: Number, required: true },
        longitude: { type: Number, required: true },
    }],
    elevationGain: { type: Number, required: true },
    points: { type: Number, required: true },
});

exports.User = mongoose.model("User", UserSchema);
exports.Ride = mongoose.model("Ride", RideSchema);
exports.Team = mongoose.model("Team", TeamSchema);
exports.connection = mongoose.connection;
exports.ObjectId = ObjectId;
