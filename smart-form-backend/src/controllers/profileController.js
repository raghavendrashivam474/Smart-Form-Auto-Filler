const User = require('../models/User');

// Get user profile
exports.getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    
    res.json({
      success: true,
      data: user.profile || {},
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Update user profile
exports.updateProfile = async (req, res) => {
  try {
    const updates = req.body;
    
    const user = await User.findByIdAndUpdate(
      req.user._id,
      { profile: updates },
      { returnDocument: 'after', runValidators: true }
    );
    
    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: user.profile,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
