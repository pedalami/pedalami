var express = require("express");
var app = express.Router();
app.use(express.json());
const models = require('../schemas.js');
const Reward = models.Reward;
const User = models.User;

// POST /redeem
app.post('/redeem', async (req, res) => {
    console.log('Received redeem POST request:');
    console.log(req.body);
    const rewardId = req.body.rewardId;
    const userId = req.body.userId;
    if (rewardId && userId) {
      try {
        const [reward, user] = await Promise.all([
          Reward.findOne({ _id: req.body.rewardId }).exec(),
          User.findOne({ userId: req.body.userId }).exec()
        ])
        .catch(() => {
          throw new Error('Error while finding the reward or the user');
        });
        if (user.points >= reward.price) {
          user.points -= reward.price;
          var newReward = {rewardId: reward._id, redeemedDate: new Date(), rewardContent: "Dummy Reward Content"}
          user.rewards.push(newReward);
          newReward.description = reward.description;
          newReward.price = reward.price;
          newReward.image = reward.image;
          await user.save()
          .catch(err => {
            throw new Error('Error in assigning the reward to the user: ' + err);
          });
          res.status(200).send(newReward);
        } else {
          throw new Error('Insufficient points');
        }
      } catch (error) {
        console.log(error);
        res.status(500).send(error);
      }
    } else {
      console.log('Error: Missing parameters.');
      res.status(400).send('Error: Missing parameters.');
    }
});

app.get("/list", async (req, res) => {
  console.log("Received GET request /rewards/list");
  Reward.find({}, (error, rewards) => {
    if (error || !rewards) {
        console.log("Error after receiving GET rewards/list!\n", error);
        res.status(500).send(error);
    } else {
        res.status(200).send(rewards);
    }
  });
});


// GET /getByUser?userId=userId
app.get("/getByUser", (req, res) => {
  console.log("Received rewards/getByUser GET request with param userId=" + req.query.userId);
  const userId = req.query.userId;
  if (userId) {
    User.aggregate([
      { $match: { userId: userId } },
      { $unwind: {
        path: "$rewards",
        preserveNullAndEmptyArrays: true
      }},
      { $lookup: {
        from: "rewards", // collection name in db
        localField: "rewards.rewardId", // field of User to make the lookup on (the field with the "foreign key")
        foreignField: "_id", // the referred field in rewards
        as: "baseReward" // name that the field of the join will have in the result/JSON
      }},
      {$unwind: {
        path: "$baseReward",
        preserveNullAndEmptyArrays: true
      }},
      {$group: {
        _id: "$_id",
        userId: {$first: "$userId"},
        badges: {$first: "$badges"},
        statistics: {$first: "$statistics"},
        points: {$first: "$points"},
        teams: {$first: "$teams"},
        rewards: {$push: {
          $cond:[
            { $eq: [ { "$ifNull": [ "$rewards", null ] }, null ] },
            "$$REMOVE",
            {
              rewardId: "$rewards.rewardId",
              redeemedDate: "$rewards.redeemedDate",
              rewardContent: "$rewards.rewardContent",
              description: "$baseReward.description",
              image: "$baseReward.image",
              price: "$baseReward.price"
            }
          ]
        }}
      }},
      { $unset: [ "__v"] }
    ])
    .exec((error, users) => {
      if (error || !users) {
        console.log("Error finding the user and performing the join with rewards.\n" + error);
        res.status(500).send("Error finding the user and performing the join with rewards.");
      } else {
        res.status(200).send(users[0].rewards);
      }
    });
  } else {
    console.log('Error: Missing userId parameter!');
    res.status(500).send('Error: Missing userId parameter!');
  }
});



module.exports = app;
