var express = require("express");
var app = express.Router();
app.use(express.json());
const gamificationController = require("./gamificationController.js");
const profileController = require("./profileController.js");
const models = require('../schemas.js');
const Ride = models.Ride;
const User = models.User;


// POST /record
app.post("/record", async (req, res) => {
  console.log("Received record POST request:");
  console.log(req.body);
  var ride = new Ride(req.body);
  ride.pace = ride.totalKm / (ride.durationInSeconds / 3600);

  // We cannot do User.findById since the userId is not the _id
  if (req.body.userId && (await User.findOne({ userId: req.body.userId }))) {
    gamificationController.assignPoints(ride)
      .then(() => {
        profileController.updateUserStatistics(ride)
          .catch((err) => {
            console.error(err);
            res.status(500).send("Cannot save the ride in the database due to a profile controller's updateUserStatistics method failure");
          });
        res.json({
          message: "Ride saved successfully, user statistics updated successfully",
          points: ride.points,
          pace: ride.pace,
          id: ride._id,
        });
      })
      .catch((err) => {
        console.error(err);
        res.status(500).send("Cannot save the ride in the database due to a gamification controller failure");
      });
  } else {
    console.error("Cannot find the user specified!\n");
    res.status(500).send("Cannot find the user specified!");
  }
});

// GET /getAllByUser
app.get("/getAllByUserId", (req, res) => {
  console.log("Received getAllByUserId GET request:");
  console.log("User:", req.query.userId);

  if (req.query.userId) {
    // I return an array of rides without the fields _id and __v
    Ride.find({ userId: req.query.userId }, "-_id -__v", (error, rides) => {
      if (error) {
        console.log(
          "Error finding the rides of the specified userId.\n" + error
        );
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
