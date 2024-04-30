const express = require("express");
const bodyParser = require("body-parser")
const UserRoute = require("./routers/user.router");



const app = express();
app.use(bodyParser.json());
app.use(express.json());


app.use("/",UserRoute);



module.exports = app;