const crypto = require('crypto');

const otpMap = new Map();

const OTP_TTL_MINUTES = Number(process.env.OTP_TTL_MINUTES || 10);
const OTP_MAX_ATTEMPTS = Number(process.env.OTP_MAX_ATTEMPTS || 5);
const OTP_TTL_MS = OTP_TTL_MINUTES * 60 * 1000;

const normalizeEmail = (value) => value?.trim().toLowerCase();

const cleanupExpiredOtps = () => {
  const now = Date.now();

  for (const [email, entry] of otpMap.entries()) {
    if (entry.expiresAt <= now) {
      otpMap.delete(email);
    }
  }
};

const create = (email) => {
  const normalizedEmail = normalizeEmail(email);
  const otp = crypto.randomInt(100000, 999999).toString();

  otpMap.set(normalizedEmail, {
    otp,
    attempts: 0,
    expiresAt: Date.now() + OTP_TTL_MS,
  });

  return otp;
};

const verify = (email, otp) => {
  cleanupExpiredOtps();

  const normalizedEmail = normalizeEmail(email);
  const entry = otpMap.get(normalizedEmail);

  if (!entry) {
    return { success: false, message: 'OTP not found or expired. Please request a new one.' };
  }

  if (entry.expiresAt <= Date.now()) {
    otpMap.delete(normalizedEmail);
    return { success: false, message: 'OTP expired. Please request a new one.' };
  }

  entry.attempts += 1;

  if (entry.attempts > OTP_MAX_ATTEMPTS) {
    otpMap.delete(normalizedEmail);
    return { success: false, message: 'Too many invalid attempts. Please request a new OTP.' };
  }

  if (entry.otp !== otp) {
    otpMap.set(normalizedEmail, entry);
    return { success: false, message: 'Invalid OTP. Please try again.' };
  }

  otpMap.delete(normalizedEmail);
  return { success: true };
};

const getTtlMinutes = () => OTP_TTL_MINUTES;

setInterval(cleanupExpiredOtps, 60 * 1000).unref();

module.exports = {
  create,
  verify,
  getTtlMinutes,
};