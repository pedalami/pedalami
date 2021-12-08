var express = require("express");
var app = express.Router();
app.use(express.json());

const Reward = require('../schemas.js').Reward;


app.get("/list", async (req, res) => {
    console.log("Received GET request /reward/list");
    Reward.find({}, (error, rewards) => {
        // console.log("Rewards: " + rewards + " Error: " + error);
        if (error || !rewards) {
            console.log("Error after receiving GET rewards/list!\n", error);
            res.status(500).send(error);
        } else {
            res.status(200).send(rewards);
        }
    }).catch(error => { // Is it needed :?
        console.log("Error after receiving GET rewards/list!\n", error);
        res.status(500).send(error);
    });
});


// USELESS
// GET /getByUser?userId=userId
app.get("/getByUser", (req, res) => {
    console.log("Received rewards/getByUser GET request with param userId=" + req.query.userId);
    if (req.query.userId) {
      User.findOne({ userId: req.query.userId }, (user, error) => {
        console.log("User: " + user + " Error: " + error);
        if (error || !user) {
          console.log("Error finding the specified user.\n" + error);
          res.status(500).send("Error finding the specified user!");
        } else {
          res.status(200).send(user.rewards);
        }
      });
    } else {
      console.log("Error: Missing parameter userId");
      res.status(400).send("Error: Missing parameter userId");
    }
  });


module.exports = app;