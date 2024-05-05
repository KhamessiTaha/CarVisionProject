const express = require("express");
const bodyParser = require("body-parser")
const UserRoute = require("./routers/user.router");
const CarRoute = require("./routers/car.router");
const path = require("path"); // Add this line to import 'path'


const app = express();
app.use(bodyParser.json());
app.use(express.json());


app.use("/",UserRoute);
app.use("/car/",CarRoute);

// Serve images from the 'uploads' directory
app.use("/car/uploads", express.static(path.join(__dirname, "uploads")));

module.exports = app;