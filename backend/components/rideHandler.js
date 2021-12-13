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
  ride.pace = Math.round(ride.totalKm / (ride.durationInSeconds / 3600) * 100) / 100;

  if (req.body.userId) {
    const user = await User.findOne({ userId: req.body.userId });
    if (user) {
      gamificationController.assignPoints(user, ride);
      profileController.updateUserStatistics(user, ride);
      await gamificationController.checkNewBadgesAfterRide(user, ride);
      /*connection.transaction((session) => {
        return Promise.all([
          user.save({ session }),
          ride.save({ session })
        ])
      })
      */
      user.save().then(() => {
        ride.save().then(() => {
          res.json({
            message: "Ride saved successfully, user statistics and badges updated successfully",
            points: ride.points,
            pace: ride.pace,
            id: ride._id,
          });
        })
          .catch((err) => {
            console.log("Errors found:\n" + err);
            res.status(500).send(err);
          })
      }).catch((err) => {
        console.log("Errors found:\n" + err);
        res.status(500).send(err);
      });
    } else {
      console.error("Cannot find the user specified!\n");
      res.status(500).send("Cannot find the user specified!");
    }
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
