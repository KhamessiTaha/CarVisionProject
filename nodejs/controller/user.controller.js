const UserServices = require('../services/user.services');

exports.register = async (req, res, next) => {
    try {
        console.log("---req body---", req.body);
        const {username, email, password } = req.body;
       
        const response = await UserServices.registerUser(username,email, password);
        res.json({ status: true, success: 'User registered successfully' });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);
    }
}
exports.login = async (req, res, next) => {
    try {
        const { email, password } = req.body;
      
        let user = await UserServices.checkUser(email);
        if (!user) {
            throw new Error('User does not exist');
        }
        const isPasswordCorrect = await user.comparePassword(password);
        if (isPasswordCorrect === false) {
            throw new Error(`Username or Password does not match`);
        }
        // Creating Token
        let tokenData;
        tokenData = { _id: user._id, isAdmin: user.isAdmin};
    
        const token = await UserServices.generateAccessToken(tokenData,"secret","1h")
        res.status(200).json({ status: true, success: "sendData", token: token });
    } catch (error) {
        console.log(error, 'err---->');
        next(error);
    }
}
exports.updateUser = async (req, res, next) => {
    try {
        const userId = req.params.userId;
        const updatedData = req.body; // Data to update
        
        const updatedUser = await UserServices.updateUser(userId, updatedData);
        
        res.json({ status: true, success: 'User updated successfully', user: updatedUser });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);
    }
}
exports.getUserById = async (req, res, next) => {
    try {
        const userId = req.params.userId;
        const user = await UserServices.getUserById(userId);
        
        if (!user) {
            return res.status(404).json({ status: false, error: 'User not found' });
        }

        res.json({ status: true, user });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);
    }
}
exports.registerAdmin = async (req, res, next) => {
    try {
        const { username, email, password } = req.body;

        // Check if admin already exists
        const existingAdmin = await UserServices.checkUser(email);
        if (existingAdmin) {
            throw new Error('Admin already exists');
        }

        // Create admin user
        const response = await UserServices.registerAdmin(username, email, password);
        res.json({ status: true, success: 'Admin registered successfully' });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);
    }
}
exports.getAllUsers = async (req, res, next) => {
    try {
        const users = await UserServices.getAllUsers();
        res.json({ status: true, users });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);
    }
}

exports.deleteUserById = async (req, res, next) => {
    try {
        const userId = req.params.userId;
        await UserServices.deleteUserById(userId);
        res.json({ status: true, success: 'User deleted successfully' });
    } catch (err) {
        console.log("---> err -->", err);
        next(err);
    }
}