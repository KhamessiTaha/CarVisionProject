const CarModel = require("../model/car.model");
const UserModel = require("../model/user.model");

class CarService{
    static async savecar(userId, Make, model, year, input_Price, predicted_price, image) {
        try {
            const savecar = new CarModel({ userId, Make, model, year, input_Price, predicted_price, image });
            const savedCar = await savecar.save();

            // Update numberOfCars in the user model
            await UserModel.findByIdAndUpdate(userId, { $inc: { numberOfCars: 1 } });

            return savedCar;
        } catch (error) {
            throw error;
        }
    }
    static async deletecar(carId) {
        try {
            await CarModel.findByIdAndDelete(carId);
        } catch (err) {
            throw err;
        }
        
    }
    static async getAllCars() {
        try {
            return await CarModel.find();
        } catch (err) {
            throw err;
        }
        
    }
    static async getCarsByUser(userId) {
        try {
            return await CarModel.find({ userId });
        } catch (err) {
            throw err;
        }
    }
   
    
}

module.exports = CarService;