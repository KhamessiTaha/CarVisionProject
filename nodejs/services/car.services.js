const CarModel = require("../model/car.model");

class CarService{
    static async savecar(userId,Make,model,year,input_Price,predicted_price,image){
            const savecar = new CarModel({userId,Make,model,year,input_Price,predicted_price,image});
            return await savecar.save();
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