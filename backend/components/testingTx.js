var express = require('express');
var app = express.Router();
app.use(express.json());
const mongoose = require("mongoose");
const ObjectId = mongoose.Types.ObjectId;

const TestSchema = new mongoose.Schema({
    points: { type: Number, required: true, default: 0 }
});

const Test = mongoose.model("Test", TestSchema);

app.get("/test", (req, res) => {
    const toCreate1 = new Test({ _id : ObjectId("aaaa97a91e413045b1c7aaaa"), points : 11});
    const toCreate2 = new Test({ _id : ObjectId("aaaa97a91e413045b1c7aacc"), points : 22});
    mongoose.connection.transaction( (session) => {
        return Promise.all([
            toCreate1.save({session}),
            toCreate2.save({session})
        ])
    }).then(() => {
        console.log("NO errors");
        res.status(200).send('FINE');
    }).catch((err) => {
        console.log("Errors:\n"+err);
        res.status(500).send('NOT FINE');
    })
    
});


module.exports = app;

/*
try {
    const created1 = toCreate1.save({session});
    const created2 = toCreate2.save({session});
    await created1;
    await created2;
    console.log("RESULTS\n"+created1+"\n"+created2);
    session.commitTransaction();
    //session.endSession();
    res.status(200).send('FINE');
} catch (err) {
    try {
        session.abortTransaction();
        console.error('\nAn error occurred: \n' + err);
    } catch (err2) {
        console.error('Impossible to abort transaction: \n' + err2);
    }
    res.status(500).send('Error');
}





await Promise.all([
        toCreate1.save({session}),
        toCreate2.save({session})
    ])
    .then( ([res1, res2]) => {
        if (res1 && res2) {
            console.log("RESULTS\n"+res1+"\n"+res2);
            session.commitTransaction();
            session.endSession();
            res.status(200).send('FINE');
        }
    })
    .catch( (err) => {
        if (err) {
            session.endSession();
            console.error('\nAn error occurred: \n' + err);
            res.status(500).send('Error');
        }
    });








.then(([t1,t2]) => {
        res.status(200).send("FINE");
    })
*/