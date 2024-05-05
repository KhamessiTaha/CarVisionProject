const db = require('../config/db');
const UserModel = require("./user.model");
const mongoose = require('mongoose');
const { Schema } = mongoose;

const CarSchema = new Schema({
    userId:{
        type: Schema.Types.ObjectId,
        ref: UserModel.modelName
    },
    Make: {
        type: String,
    },
    model: {
        type: String,
    },
    year: {
        type: String,
    },
    input_Price: {
        type: Number,
    },
    predicted_price: {
        type: Number,
    },
    image: {
        type: String,
    },
},{timestamps:true});

const CarModel = db.model('car',CarSchema);
module.exports = CarModel;



