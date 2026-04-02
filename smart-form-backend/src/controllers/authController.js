const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Simple login (no OTP for testing)
exports.login = async (req, res) => {
  try {
    const { phoneNumber } = req.body;

    if (!phoneNumber) {
      return res.status(400).json({
        success: false,
        message: 'Phone number is required',
      });
    }

    // Find or create user
    let user = await User.findOne({ phoneNumber });

    if (!user) {
      user = await User.create({ phoneNumber });
    }

    // Generate JWT token
    const token = jwt.sign(
      { id: user._id },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRE }
    );

    res.json({
      success: true,
      message: 'Login successful',
      data: {
        token,
        user: {
          id: user._id,
          phoneNumber: user.phoneNumber,
          profile: user.profile,
        },
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Get current user
exports.getMe = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    
    res.json({
      success: true,
      data: {
        id: user._id,
        phoneNumber: user.phoneNumber,
        profile: user.profile,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
