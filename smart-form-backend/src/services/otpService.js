const EmailService = require('./emailService');
const OTPModel = require('../models/OTP');

class OTPService {

  // Generate 6-digit OTP
  static generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  // Send OTP via Email
  static async sendOTP(email) {
    try {
      const otp = this.generateOTP();

      // Delete old OTPs
      await OTPModel.deleteMany({ email });

      // Save new OTP
      await OTPModel.create({
        email,
        otp,
        expiresAt: new Date(Date.now() + 5 * 60 * 1000) // 5 min
      });

      console.log("📦 OTP SAVED:", email, otp);

      // 🔥 Send email (MAIN STEP)
      const emailResponse = await EmailService.sendOTPEmail(email, otp);

      if (!emailResponse.success) {
        throw new Error("Email failed");
      }

      return {
        success: true,
        message: "OTP sent to email",
        emailSent: true
      };

    } catch (error) {
      console.error("❌ SEND OTP ERROR:", error);

      return {
        success: false,
        message: "Failed to send OTP"
      };
    }
  }

  // Verify OTP
  static async verifyOTP(email, otp) {
    try {
      console.log("🔍 VERIFY:", email, otp);

      const record = await OTPModel.findOne({ email });

      if (!record) {
        return { success: false, message: "OTP not found" };
      }

      // Check expiry
      if (new Date(record.expiresAt).getTime() < Date.now()) {
        await OTPModel.deleteMany({ email });
        return { success: false, message: "OTP expired" };
      }

      // Check match
      if (record.otp.toString() !== otp.toString()) {
        return { success: false, message: "Invalid OTP" };
      }

      // Delete after success
      await OTPModel.deleteMany({ email });

      return { success: true };

    } catch (error) {
      console.error("❌ VERIFY ERROR:", error);
      return { success: false, message: "Verification failed" };
    }
  }
}

module.exports = OTPService;