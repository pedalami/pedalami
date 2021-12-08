var express = require('express');
var app = express.Router();
app.use(express.json());
const mongoose = require("mongoose");
const Badge = require("../schemas.js").Badge;
const ObjectId = mongoose.Types.ObjectId;


app.get("/genInfo", (req, res) => {
    Badge.find({}, (err, badges) => {
        if (err) {
            res.status(500).send("Error: "+err);
        } else {
            
            badges.forEach((badge) => {
                if (!badge.description) {
                    if (badge.type == "ride") {
                        // Criteria can be totalKm, totalElevationGain, totalDuration, numberOfRides
                        if (badge.criteria == "totalKm")
                            badge.description = "This badge is assigned to users who rode "+badge.criteriaValue+"km on a single ride"
                        if (badge.criteria == "elevationGain") 
                            badge.description = "This badge is assigned to users who reached "+badge.criteriaValue+"m of elevation gain on a single ride";
                        if (badge.criteria == "pace") 
                            badge.description = "This badge is assigned to users who had a pace of "+badge.criteriaValue+"km/h on a single ride";
                        if (badge.criteria == "durationInSeconds") 
                            badge.description = "This badge is assigned to users who made a ride of at least "+(badge.criteriaValue/60).toFixed(0)+" minutes";
                    } else {
                        if (badge.type == "userStat") {
                            // Criteria can be totalKm, totalElevationGain, totalDuration, numberOfRides
                            if (badge.criteria == "totalKm")
                                badge.description = "This badge is assigned to users who rode "+badge.criteriaValue+"km in total"
                            if (badge.criteria == "totalElevationGain") 
                                badge.description = "This badge is assigned to users who reached "+badge.criteriaValue+"m of elevation gain in total";
                            if (badge.criteria == "totalDuration") 
                                badge.description = "This badge is assigned to users who rode for "+(badge.criteriaValue/60).toFixed(0)+" minutes in total";
                            if (badge.criteria == "numberOfRides") 
                                badge.description = "This badge is assigned to users who performed a total of "+badge.criteriaValue+" rides";
                        }
                    }
                }
                
            })
            mongoose.connection.transaction( (session) => {
                return Promise.all(badges.map((badge) => badge.save({session})))
            }).then(() => {
                console.log("NO errors");
                res.status(200).send('FINE');
            }).catch((err) => {
                console.log("Errors:\n"+err);
                res.status(500).send('NOT FINE');
            })
            
        }
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