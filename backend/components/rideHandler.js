var express = require("express");
var app = express.Router();
app.use(express.json());
const gamificationController = require("./gamificationController.js");
const profileController = require("./profileController.js");
const models = require('../schemas.js');
const Ride = models.Ride;
const User = models.User;
const connection = models.connection;


// POST /record
app.post("/record", async (req, res) => {
  console.log("Received record POST request:");
  console.log(req.body);
  var ride = new Ride(req.body);
  if (req.body.userId) {
    connection.transaction(async (session) => {
      ride.pace = Math.round(ride.totalKm / (ride.durationInSeconds / 3600) * 100) / 100;
      const user = await User.findOne({ userId: req.body.userId }).session(session).exec();
      if (user) {
        gamificationController.assignPoints(user, ride);
        profileController.updateUserStatistics(user, ride);
        await gamificationController.checkNewBadgesAfterRide(user, ride);
        await Promise.all([
          user.save({ session }),
          ride.save({ session })
        ])
      } else {
        throw new Error("Cannot find the user specified!");
      }
    })
    .then(() => {
      res.json({
        message: "Ride saved successfully, user statistics and badges updated successfully",
        points: ride.points,
        pace: ride.pace,
        id: ride._id,
      });
    })
    .catch((err) => {
      console.log("Impossible to record the ride:\n" + err);
      res.status(500).send("Impossible to record the ride");
    });
  } else {
    console.error("User not specified!");
    res.status(500).send("User not specified!");
  }
});

// GET /getAllByUser
app.get("/getAllByUserId", (req, res) => {
  console.log("Received getAllByUserId GET request:");
  console.log("User:", req.query.userId);

  if (req.query.userId) {
    // I return an array of rides without the field __v
    Ride.find({ userId: req.query.userId }, "-__v", (error, rides) => {
      if (error) {
        console.log("Error finding the rides of the specified userId.\n" + error);
        res.status(500).send("Error finding the rides!");
      } else {
        res.status(200).send(rides);
      }
    });
  } else {
    console.log("Error: Missing the userId parameter.");
    res.status(400).send("Error: Missing the userId parameter.");
  }
});

module.exports = app;
