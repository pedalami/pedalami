var express = require("express");
var app = express.Router();
app.use(express.json());
const gamificationController = require("./gamificationController.js");
const profileController = require("./profileController.js");
const models = require('../schemas.js');
const Ride = models.Ride;
const User = models.User;
const connection = models.connection;

