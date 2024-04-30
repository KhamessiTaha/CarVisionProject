const UserModel = require("../model/user.model");
const jwt = require("jsonwebtoken");
class UserServices{
 
    static async registerUser(username,email,password){
        try{
                console.log("username-----Email --- Password-----",username,email,password);
                
                const createUser = new UserModel({username,email,password});
                return await createUser.save();
        }catch(err){
            throw err;
        }
    }
    static async checkUser(email){
        try {
            return await UserModel.findOne({email});
        } catch (error) {
            throw error;
        }
    }
    static async generateAccessToken(tokenData,JWTSecret_Key,JWT_EXPIRE){
        return jwt.sign(tokenData, JWTSecret_Key, { expiresIn: JWT_EXPIRE });
    }
    static async updateUser(userId, updatedData) {
        try {
            // Find the user by ID and update the data
            const updatedUser = await UserModel.findByIdAndUpdate(userId, updatedData, { new: true });
            return updatedUser;
        } catch (err) {
            throw err;
        }
    }
    static async getUserById(userId) {
        try {
            return await UserModel.findById(userId);
        } catch (err) {
            throw err;
        }
    }
    static async registerAdmin(username, email, password) {
        try {
            const createUser = new UserModel({ username, email, password, isAdmin: true });
            return await createUser.save();
        } catch (err) {
            throw err;
        }
    }
    static async getAllUsers() {
        try {
            return await UserModel.find();
        } catch (err) {
            throw err;
        }
    }

    static async deleteUserById(userId) {
        try {
            await UserModel.findByIdAndDelete(userId);
        } catch (err) {
            throw err;
        }
    }
}
module.exports = UserServices;