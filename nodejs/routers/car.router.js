const router = require("express").Router();
const CarController = require('../controller/car.controller')
const upload = require('../middleware/upload')

router.post("/savecar",upload.single('image'),CarController.savecar);
router.delete("/deletecar/:id", CarController.deletecar);
router.get("/getallcars", CarController.getAllCars);
router.get("/getcarsbyuser/:userId", CarController.getCarsByUser);



module.exports = router;