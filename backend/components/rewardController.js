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
                                }).
                            catch(err => {
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

module.exports = app;
