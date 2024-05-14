const db = require('../config/db');
const bcrypt = require("bcrypt");
const mongoose = require('mongoose');

const { Schema } = mongoose;

const userSchema = new Schema({
    username: {
        type: String,
        required: [true, "username is required"],
        unique: true
    },
    email: {
        type: String,
        lowercase: true,
        required: [true, "email can't be empty"],
        unique: true,
    },
    password: {
        type: String,
        required: [true, "password is required"]
    },
    isAdmin: {
        type: Boolean,
        default: false
    },
    numberOfCars: {
        type: Number,
        default: 0
    }
},
{
    timestamps:true
});



userSchema.pre("save",async function(){
    var user = this;
    try{
        const salt = await bcrypt.genSalt(10);
        const hash = await bcrypt.hash(user.password,salt);
        user.password = hash;
    }catch(err){
        throw err;
    }
});
userSchema.pre("findOneAndUpdate", async function(next) {
    try {
        const update = this.getUpdate();
        if (update.password) {
            const salt = await bcrypt.genSalt(10);
            const hash = await bcrypt.hash(update.password, salt);
            this.set('password', hash);
        }
        next();
    } catch (err) {
        next(err);
    }
});




userSchema.methods.comparePassword = async function (userPassword) {
    try {
        console.log('----------------no password',this.password);
        const isMatch = await bcrypt.compare(userPassword, this.password);
        return isMatch;
    } catch (error) {
        throw error;
    }
};


const UserModel = db.model('user',userSchema);
module.exports = UserModel;