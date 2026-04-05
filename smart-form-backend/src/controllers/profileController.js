const User = require('../models/User');

/**
 * @desc    Get user profile
 * @route   GET /api/profile
 * @access  Private
 */
const getProfile = async (req, res) => {
  try {
    const user = await User.findById(req.user.userId).select('-__v');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.json({
      success: true,
      data: {
        email: user.email,
        profile: user.profile || {}
      }
    });
  } catch (error) {
    console.error('Get profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching profile'
    });
  }
};

/**
 * @desc    Update user profile (merge-based)
 * @route   PUT /api/profile
 * @access  Private
 */
const updateProfile = async (req, res) => {
  try {
    const userId = req.user.userId;
    const updates = req.body;

    console.log('📝 Profile update request:', {
      userId,
      updates: JSON.stringify(updates, null, 2)
    });

    // Find user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Initialize profile if it doesn't exist
    if (!user.profile) {
      user.profile = {};
    }

    // Create update object
    const updateObject = {};

    // Handle address separately (special case for nested object)
    if (updates.address && typeof updates.address === 'object') {
      console.log('🏠 Processing address update:', updates.address);
      
      // Flatten address to avoid nesting
      const addressUpdate = {
        street: updates.address.street || user.profile.address?.street || '',
        city: updates.address.city || user.profile.address?.city || '',
        state: updates.address.state || user.profile.address?.state || '',
        pincode: updates.address.pincode || user.profile.address?.pincode || ''
      };

      updateObject['profile.address'] = addressUpdate;
      delete updates.address; // Remove from updates to process separately
    }

    // Process all other fields
    for (const [key, value] of Object.entries(updates)) {
      if (key === 'address') continue; // Already handled
      
      // Update only if value is provided and not empty
      if (value !== undefined && value !== null && value !== '') {
        updateObject[`profile.${key}`] = value;
      }
    }

    console.log('🔄 Final update object:', JSON.stringify(updateObject, null, 2));

    // Perform update
    const updatedUser = await User.findByIdAndUpdate(
      userId,
      { $set: updateObject },
      { 
        new: true, 
        runValidators: true,
        select: '-__v'
      }
    );

    console.log('✅ Profile updated successfully');
    console.log('📦 Updated profile:', JSON.stringify(updatedUser.profile, null, 2));

    res.json({
      success: true,
      message: 'Profile updated successfully',
      data: {
        email: updatedUser.email,
        profile: updatedUser.profile
      }
    });

  } catch (error) {
    console.error('❌ Update profile error:', error);
    res.status(500).json({
      success: false,
      message: 'Error updating profile',
      error: error.message
    });
  }
};

// Export functions
module.exports = {
  getProfile,
  updateProfile
};