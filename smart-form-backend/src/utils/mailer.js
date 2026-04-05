const nodemailer = require('nodemailer');

let cachedTransporter = null;

const getTransporter = () => {
  if (cachedTransporter) {
    return cachedTransporter;
  }

  const host = process.env.SMTP_HOST;
  const port = Number(process.env.SMTP_PORT || 587);
  const secure = String(process.env.SMTP_SECURE || 'false') === 'true';
  const user = process.env.SMTP_USER;
  const pass = process.env.SMTP_PASS;

  if (!host || !user || !pass) {
    throw new Error('SMTP is not configured. Set SMTP_HOST, SMTP_PORT, SMTP_USER, and SMTP_PASS.');
  }

  cachedTransporter = nodemailer.createTransport({
    host,
    port,
    secure,
    auth: {
      user,
      pass,
    },
  });

  return cachedTransporter;
};

const sendOtpEmail = async ({ to, otp }) => {
  const from = process.env.SMTP_FROM || process.env.SMTP_USER;
  const transporter = getTransporter();

  await transporter.sendMail({
    from,
    to,
    subject: 'Your Smart Form Filler OTP',
    text: `Your one-time password is ${otp}. It expires in ${process.env.OTP_TTL_MINUTES || 10} minutes.`,
    html: `
      <div style="font-family: Arial, sans-serif; line-height: 1.6; color: #111827;">
        <h2 style="margin: 0 0 12px;">Smart Form Filler</h2>
        <p>Your one-time password is:</p>
        <div style="font-size: 28px; font-weight: 700; letter-spacing: 6px; padding: 12px 18px; background: #f3f4f6; display: inline-block; border-radius: 12px;">${otp}</div>
        <p style="margin-top: 16px;">This code expires in ${process.env.OTP_TTL_MINUTES || 10} minutes.</p>
      </div>
    `,
  });
};

module.exports = {
  sendOtpEmail,
};