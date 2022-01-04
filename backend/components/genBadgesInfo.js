/* istanbul ignore file */
var express = require('express');
var app = express.Router();
app.use(express.json());
const mongoose = require("mongoose");
const Badge = require("../schemas.js").Badge;
const imageToBase64 = require('image-to-base64');


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

//NOT NEEDED
app.get("/genImg", (req, res) => {
    Badge.find({}, (err, badges) => {
        if (err) {
            res.status(500).send("Error: "+err);
        } else {
            badges.forEach(async (badge) => {
                    if (badge.type == "ride") {
                        // Criteria can be totalKm, totalElevationGain, totalDuration, numberOfRides
                        if (badge.criteria == "totalKm") {
                            if (badge.criteriaValue == 1){
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/totKm1.png");
                                console.log(badge.image);
                            }
                            /*if (badge.criteriaValue == 10)
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/totKm10.png");
                            if (badge.criteriaValue == 20)
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/totKm20.png");*/
                        }
                        /*if (badge.criteria == "elevationGain") {
                            if (badge.criteriaValue == 10)
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/elevationGain (1).png");
                            if (badge.criteriaValue == 100)
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/elevationGain (2).png");
                            if (badge.criteriaValue == 200)
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/elevationGain (3).png");
                        }
                        if (badge.criteria == "pace") {
                            if (badge.criteriaValue == 10)
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/pace10kmh.png");
                            if (badge.criteriaValue == 20)
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/pace20kmh.png");
                            if (badge.criteriaValue == 40)
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/pace40kmh.png");
                        }
                        if (badge.criteria == "durationInSeconds") {
                            if (badge.criteriaValue == 1800)
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/durationInSeconds1800.png");
                            if (badge.criteriaValue == 3600)
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/durationInSeconds3600.png");
                            if (badge.criteriaValue == 10800)
                                badge.image = await imageToBase64("/Users/vi/Downloads/badges/durationInSeconds10800.png");
                        }*/
                    } else {
                        /*if (badge.type == "userStat") {
                            if (badge.criteria == "totalKm") {
                                if (badge.criteriaValue == 10)
                                    badge.image = await imageToBase64("/Users/vi/Downloads/badges/userTotalKm10.png");
                                if (badge.criteriaValue == 100)
                                    badge.image = await imageToBase64("/Users/vi/Downloads/badges/userTotalKm100.png");
                                if (badge.criteriaValue == 1000)
                                    badge.image = await imageToBase64("/Users/vi/Downloads/badges/userTotalKm1000.png");
                            }
                            if (badge.criteria == "nukberOfRides") {
                                if (badge.criteriaValue == 1)
                                    badge.image = await imageToBase64("/Users/vi/Downloads/badges/numberOfRides (2).png");
                                if (badge.criteriaValue == 10)
                                    badge.image = await imageToBase64("/Users/vi/Downloads/badges/numberOfRides (3).png");
                                if (badge.criteriaValue == 100)
                                    badge.image = await imageToBase64("/Users/vi/Downloads/badges/numberOfRides (1).png");
                            }
                        }*/
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