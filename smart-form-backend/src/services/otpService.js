const EmailService = require('./emailService');
const OTPModel = require('../models/OTP');

// In-memory OTP storage
const otpStore = new Map();

class OTPService {
  // Generate 6-digit OTP
  static generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  // Send OTP via Email
 static async sendOTP(email) {
  const otp = Math.floor(100000 + Math.random() * 900000).toString();

  // Delete old OTPs for this email
  await OTPModel.deleteMany({ email });

  // Save new OTP
  await OTPModel.create({
    email,
    otp,
    expiresAt: new Date(Date.now() + 5 * 60 * 1000) // 5 min
  });

  console.log("📦 OTP SAVED IN DB:", email, otp);
  console.log("EMAIL CONFIG:",
    process.env.EMAIL_USER,
    process.env.EMAIL_PASS ? "PASS OK" : 
    "NO PASS");
    
  try {
  await EmailService.sendOTPEmail(email, otp);  // 🔥 MAIN LINE

  return {
    success: true,
    message: "OTP sent to email",
    emailSent: true
  };

} catch (error) {
  console.log("❌ EMAIL ERROR:", error);

  return {
    success: true,
    message: "OTP generated (email failed)",
    emailSent: false,
    demo_otp: otp
  };
}
}

  // Verify OTP
 static async verifyOTP(email, otp) {
  console.log("🔍 VERIFY:", email, otp);

  const record = await OTPModel.findOne({ email });

  console.log("📦 DB RECORD:", record);

  if (!record) {
    return { success: false, message: "OTP not found" };
  }

  if (new Date(record.expiresAt).getTime() < Date.now()) {
    console.log("⏰ OTP expired for:", email);
    await OTPModel.deleteMany({ email });
    return { success: false, message: "OTP expired" };
  }

if (record.otp.toString() !== otp.toString()) {
    return { success: false, message: "Invalid OTP" };
  }

  // Optional: delete after success
  await OTPModel.deleteMany({ email });

  return { success: true };
}
}

module.exports = OTPService;