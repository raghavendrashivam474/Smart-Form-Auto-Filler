const EmailService = require('./emailService');

// In-memory OTP storage
const otpStore = new Map();

class OTPService {
  // Generate 6-digit OTP
  static generateOTP() {
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  // Send OTP via Email
  static async sendOTP(email) {
    const otp = this.generateOTP();

    // Store OTP with 5 minute expiry
    otpStore.set(email, {
      otp: otp,
      expiresAt: Date.now() + 5 * 60 * 1000,
      attempts: 0,
    });

    console.log('========================================');
    console.log('📧 OTP for ' + email + ': ' + otp);
    console.log('⏰ Expires in 5 minutes');
    console.log('========================================');

    // Try sending email
    try {
      await EmailService.sendOTPEmail(email, otp);
      return {
        success: true,
        message: 'OTP sent to email',
        emailSent: true,
      };
    } catch (error) {
      // If email fails, still return OTP for demo
      console.log('⚠️ Email failed, showing OTP in response for demo');
      return {
        success: true,
        message: 'OTP generated (email delivery failed)',
        emailSent: false,
        demo_otp: otp,
      };
    }
  }

  // Verify OTP
  static verifyOTP(email, otp) {
    const stored = otpStore.get(email);

    if (!stored) {
      return { success: false, message: 'OTP expired or not found. Request a new one.' };
    }

    if (Date.now() > stored.expiresAt) {
      otpStore.delete(email);
      return { success: false, message: 'OTP expired. Request a new one.' };
    }

    if (stored.attempts >= 3) {
      otpStore.delete(email);
      return { success: false, message: 'Too many attempts. Request a new OTP.' };
    }

    stored.attempts++;

    if (stored.otp !== otp) {
      return { 
        success: false, 
        message: 'Invalid OTP. ' + (3 - stored.attempts) + ' attempts remaining.' 
      };
    }

    otpStore.delete(email);
    return { success: true, message: 'OTP verified successfully' };
  }
}

module.exports = OTPService;