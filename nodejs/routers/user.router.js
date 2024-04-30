const router = require("express").Router();


const UserController = require('../controller/user.controller');

router.post("/register",UserController.register);
router.post("/login",UserController.login);
router.put('/update/:userId', UserController.updateUser);
router.get('/getuserbyid/:userId', UserController.getUserById);
router.post("/register/admin", UserController.registerAdmin); // New route for registering admin
router.get("/getallusers", UserController.getAllUsers);
router.delete('/deleteuserbyid/:userId', UserController.deleteUserById);

module.exports = router;