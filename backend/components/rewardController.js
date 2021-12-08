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

app.get("getByUser")

module.exports = app;