const jwt = require('jsonwebtoken');
const User = require('../models/User');

const auth = async (req, res, next) => {
  try {
    let token;

    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
      token = req.headers.authorization.split(' ')[1];
    }

    if (!token) {
      return res.status(401).json({
        success: false,
        message: 'Not authorized, no token',
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'your-secret-key-change-this');
    
    // ✅ Set userId from decoded token
    req.user = {
      userId: decoded.userId || decoded.id || decoded._id
    };

    // Optional: Also load full user if needed
    const user = await User.findById(req.user.userId);
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found',
      });
    }

    // Add full user data to request
    req.user._id = user._id;
    req.user.email = user.email;
    req.user.profile = user.profile;

    console.log('🔐 Auth successful - User ID:', req.user.userId);

    next();
  } catch (error) {
    console.error('Auth error:', error.message);
    res.status(401).json({
      success: false,
      message: 'Not authorized, token failed',
    });
  }
};

// ✅ Export as default function (not as object)
module.exports = auth;