const jwt = require('jsonwebtoken');
const User = require('../models/User');
const OTPService = require('../services/otpService');

/**
 * @desc    Send OTP to email
 * @route   POST /api/auth/send-otp
 * @access  Public
 */
const sendOTP = async (req, res) => {
  try {
    console.log("🔥 SEND OTP HIT");

    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required",
      });
    }

    const normalizedEmail = email.toLowerCase().trim();

    const result = await OTPService.sendOTP(normalizedEmail);

    console.log("OTP RESULT:", result);

    return res.status(200).json({
      success: true,
      message: result?.emailSent
        ? `OTP sent to ${normalizedEmail}`
        : "OTP generated (check logs)",
      data: {
        emailSent: result?.emailSent || false,
        demoOtp: result?.demo_otp || null,
      },
    });

  } catch (error) {
    console.error("❌ SEND OTP ERROR:", error);

    return res.status(500).json({
      success: false,
      message: error.message || "Server error",
    });
  }
};

/**
 * @desc    Verify OTP & Login
 * @route   POST /api/auth/verify-otp
 * @access  Public
 */
const verifyOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;

    console.log('========================================');
    console.log('📩 Verify OTP Request:');
    console.log('   Email:', email);
    console.log('   OTP:', otp);
    console.log('========================================');

    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: 'Email and OTP are required',
      });
    }

    const normalizedEmail = email.toLowerCase().trim();
    const verification = OTPService.verifyOTP(normalizedEmail, otp);

    if (!verification.success) {
      console.log('❌ OTP verification failed:', verification.message);
      return res.status(400).json({
        success: false,
        message: verification.message,
      });
    }

    console.log('✅ OTP verified successfully');

    let user = await User.findOne({
      $or: [
        { email: normalizedEmail },
        { 'profile.email': normalizedEmail },
      ]
    });

    if (!user) {
      console.log('🆕 Creating new user for:', normalizedEmail);
      user = await User.create({
        email: normalizedEmail,
        profile: { email: normalizedEmail },
      });
    } else {
      console.log('✅ User found:', user._id);
    }

    const token = jwt.sign(
      { userId: user._id },
      process.env.JWT_SECRET || 'your-secret-key-change-this',
      { expiresIn: process.env.JWT_EXPIRE || '30d' }
    );

    console.log('✅ Login successful for:', normalizedEmail);

    res.json({
      success: true,
      message: 'Login successful',
      token,
      data: {
        token,
        user: {
          id: user._id,
          email: normalizedEmail,
          profile: user.profile || {},
        },
      },
    });

  } catch (error) {
    console.error('❌ Verify OTP Error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

/**
 * @desc    Get current logged-in user
 * @route   GET /api/auth/me
 * @access  Private
 */
const getMe = async (req, res) => {
  try {
    const userId = req.user.userId;
    console.log('👤 Getting user:', userId);
    
    const user = await User.findById(userId).select('-__v');

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.json({
      success: true,
      data: {
        id: user._id,
        email: user.email || user.profile?.email,
        profile: user.profile || {},
      },
    });
  } catch (error) {
    console.error('❌ Get Me Error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// ✅ Export ALL function names that routes might use
module.exports = {
  sendOTP,
  verifyOTP,
  getMe,
  getCurrentUser: getMe  // Alias for compatibility
};