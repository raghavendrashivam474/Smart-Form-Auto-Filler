const nodemailer = require("nodemailer");

class EmailService {
  static transporter = null;

  static init() {
    this.transporter = nodemailer.createTransport({
      service: "gmail",
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
      debug: true,
      logger: true,
    });

    // 🔥 VERY IMPORTANT: Verify SMTP connection
    this.transporter.verify((error, success) => {
      if (error) {
        console.error("❌ SMTP ERROR:", error);
      } else {
        console.log("✅ SMTP READY - Server is ready to send emails");
      }
    });
  }

  static async sendOTPEmail(email, otp) {
    try {
      if (!this.transporter) {
        this.init();
      }

      const mailOptions = {
        from: {
          name: "Smart Form Filler",
          address: process.env.EMAIL_USER,
        },
        to: email,
        subject: "Your OTP - Smart Form Filler",
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 20px;">
            <div style="text-align: center; padding: 20px; background: linear-gradient(135deg, #6366F1, #8B5CF6); border-radius: 12px;">
              <h1 style="color: white; margin: 0;">Smart Form Filler</h1>
              <p style="color: rgba(255,255,255,0.8); margin: 5px 0 0 0;">Email Verification</p>
            </div>
            
            <div style="padding: 30px 20px; text-align: center;">
              <p style="font-size: 16px; color: #333;">Your One-Time Password is:</p>
              
              <div style="background: #F3F4F6; padding: 20px; border-radius: 12px; margin: 20px 0;">
                <h2 style="font-size: 36px; letter-spacing: 8px; color: #6366F1; margin: 0;">${otp}</h2>
              </div>
              
              <p style="color: #666; font-size: 14px;">This OTP expires in <strong>5 minutes</strong></p>
              <p style="color: #999; font-size: 12px;">If you didn't request this, please ignore this email.</p>
            </div>
            
            <div style="text-align: center; padding: 15px; background: #F9FAFB; border-radius: 8px;">
              <p style="color: #999; font-size: 11px; margin: 0;">
                Smart Form Filler - Fill forms faster with intelligent auto-fill
              </p>
            </div>
          </div>
        `,
      };

      const info = await this.transporter.sendMail(mailOptions);

      console.log("📧 EMAIL SENT:", info.response);
      console.log("📧 TO:", email);

      return { success: true };

    } catch (error) {
      console.error("❌ EMAIL ERROR FULL:", error);

      return {
        success: false,
        error: error.message,
      };
    }
  }
}

module.exports = EmailService;