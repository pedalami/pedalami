var express = require("express");
var app = express.Router();
app.use(express.json());
const models = require('../schemas.js');
const Reward = models.Reward;
const User = models.User;

// POST /redeem
app.post('/redeem', (req, res) => {
    console.log('Received redeem POST request:');
    console.log(req.body);
    if (req.body.rewardId && req.body.userId) {
        Reward.findOne({ _id: req.body.rewardId }, (err, reward) => {
            if (err) {
                console.log(err);
                res.status(500).send('Error in finding the selected reward.');
            }
            else if (reward) {
                User.findOne({ userId: req.body.userId }, (err, user) => {
                    if (err) {
                        console.log(err);
                        res.status(500).send('Error in finding the user.');
                    }
                    else if (user) {
                        if (user.points >= reward.price) {
                            user.points -= reward.price;
                            var newReward = {rewardId: reward._id, redeemedDate: new Date() , rewardContent: "Dummy Reward Content"}
                            user.rewards.push(newReward);
                            user.save().
                                then(() => {
                                    res.status(200).json({
                                        message: 'Reward redeemed successfully.',
                                        selected_reward : reward,
                                        generated_reward: newReward
                                        });
                                }).catch(err => {
                                console.log('Error in assigning the reward to the user: ' + err);
                                res.status(500).send('Error in assigning the reward to the user.');
                            })
                        }
                        else {
                            res.status(400).send('Insufficient points.');
                        }
                    }
                    else {
                        res.status(404).send('User not found.');
                    }
                });
            }
        })
    } else {
        console.log('Error: Missing parameters.');
        res.status(400).send('Error: Missing parameters.');
    }
});

app.get("/list", async (req, res) => {
    console.log("Received GET request /rewards/list");
    Reward.find({}, (error, rewards) => {
        // console.log("Rewards: " + rewards + " Error: " + error);
        if (error || !rewards) {
            console.log("Error after receiving GET rewards/list!\n", error);
            res.status(500).send(error);
        } else {
            res.status(200).send(rewards);
        }
    });
});


// USELESS
// GET /getByUser?userId=userId
app.get("/getByUser", (req, res) => {
    console.log("Received rewards/getByUser GET request with param userId=" + req.query.userId);
    const userId = req.query.userId;
    if (userId) {
      User
        .aggregate([
          {
            $match: {
              userId: userId
            }
          },
          {
            $lookup: {
              from: "rewards", // collection name in db
              localField: "rewards.rewardId", // field of User to make the lookup on (the foreign key)
              foreignField: "_id", // the referred field in rewards
              as: "rewards" // name that the field of the join will have in the result/JSON
            }
          }
        ])
        .exec((error, user) => {
          console.log("User: " + user + " Error: " + error);
          if (error || !user || user.length != 1) {
            console.log("Error finding the user and performing the join with rewards.\n" + error);
            res.status(500).send("Error finding the user and performing the join with rewards.\n" + error);
          } else {
            res.status(200).send(user[0].rewards);
          }
        });
    } else {
      console.log('Error: Missing userId parameter!');
      res.status(400).send('Error: Missing userId parameter!');
    }
  });



module.exports = app;
