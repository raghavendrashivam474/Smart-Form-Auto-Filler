const FieldUsage = require('../models/FieldUsage');

class FieldTrackerService {
  // Track field usage
  static async trackFields(fields) {
    try {
      const updates = [];

      for (const field of fields) {
        if (field.profileKey) {
          const update = FieldUsage.findOneAndUpdate(
            { fieldKey: field.profileKey },
            {
              $inc: { usageCount: 1 },
              $set: { 
                label: field.label,
                lastUsed: new Date()
              }
            },
            { upsert: true, returnDocument: 'after' }
          );
          updates.push(update);
        }
      }

      const results = await Promise.all(updates);

      // Check for fields that should be promoted
      const promoted = results.filter(r => 
        r.usageCount >= r.threshold && !r.inOnboarding
      );

      // Auto-promote high-usage fields
      for (const field of promoted) {
        await FieldUsage.findByIdAndUpdate(field._id, {
          inOnboarding: true
        });
        console.log('🎯 Promoted field to onboarding:', field.label);
      }

      return results;
    } catch (error) {
      console.error('Field tracking error:', error);
      throw error;
    }
  }

  // Get field usage statistics
  static async getStatistics() {
    try {
      const allFields = await FieldUsage.find().sort({ usageCount: -1 });
      const onboardingFields = await FieldUsage.find({ inOnboarding: true });
      const totalUsage = allFields.reduce((sum, f) => sum + f.usageCount, 0);

      return {
        totalFields: allFields.length,
        onboardingFields: onboardingFields.length,
        totalUsage,
        topFields: allFields.slice(0, 10),
        onboarding: onboardingFields,
      };
    } catch (error) {
      throw error;
    }
  }

  // Get recommended onboarding fields
  static async getRecommendedFields(limit = 10) {
    return await FieldUsage.find()
      .sort({ usageCount: -1 })
      .limit(limit);
  }
}

module.exports = FieldTrackerService;
