const CarService = require('../services/car.services');


exports.savecar =  async (req,res,next)=>{
    try {
        if (!req.file || !req.file.path) {
            throw new Error('No file uploaded');
        }
        let imagee = req.file.path 
        const { userId,Make,model,year,input_Price,predicted_price } = req.body;
        let CarData = await CarService.savecar(userId,Make,model,year,input_Price,predicted_price,imagee);
        res.json({status: true,success:CarData});
        
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}
exports.deletecar = async (req, res, next) => {
    try {
        const carId = req.params.id;
        await CarService.deletecar(carId);
        res.json({ status: true, message: "Car deleted successfully" });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};
exports.getAllCars = async (req, res, next) => {
    try {
        const cars = await CarService.getAllCars();
        res.json({ status: true, data: cars });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};
exports.getCarsByUser = async (req, res, next) => {
    try {
        const userId = req.params.userId;
        const cars = await CarService.getCarsByUser(userId);
        res.json({ status: true, data: cars });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
};