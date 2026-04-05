const FormMapping = require('../models/FormMapping');
const fieldMappingService = require('../services/fieldMappingService');

/**
 * @desc    Detect field mapping (auto or cached)
 * @route   POST /api/mapping/detect
 * @access  Private
 */
const detectMapping = async (req, res) => {
  try {
    const { fields } = req.body;
    const userId = req.user.userId; // Changed from req.user.id

    console.log('========================================');
    console.log('🔍 Detecting mapping for fields:');
    console.log(JSON.stringify(fields, null, 2));
    console.log('========================================');

    if (!fields || !Array.isArray(fields)) {
      return res.status(400).json({
        success: false,
        message: 'Fields array is required',
      });
    }

    // Generate form hash
    const formHash = fieldMappingService.generateFormHash(fields);
    console.log('📝 Form Hash:', formHash);

    // Check if mapping already exists
    let existingMapping = await FormMapping.findOne({
      formHash,
      userId,
    });

    if (existingMapping) {
      console.log('✅ Found cached mapping');
      existingMapping.lastUsed = new Date();
      existingMapping.usageCount += 1;
      await existingMapping.save();

      return res.json({
        success: true,
        cached: true,
        formHash,
        mapping: Object.fromEntries(existingMapping.mapping),
      });
    }

    console.log('🔍 Running auto-detection...');
    
    // Auto-detect mapping
    const { mapping, needsConfirmation } = fieldMappingService.autoMapForm(fields);

    console.log('📊 Detection Results:');
    console.log('Mapping:', JSON.stringify(mapping, null, 2));
    console.log('Needs Confirmation:', JSON.stringify(needsConfirmation, null, 2));
    console.log('========================================');

    res.json({
      success: true,
      cached: false,
      formHash,
      mapping,
      needsConfirmation,
    });

  } catch (error) {
    console.error('❌ Detect Mapping Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to detect mapping',
      error: error.message
    });
  }
};

/**
 * @desc    Save confirmed mapping
 * @route   POST /api/mapping/save
 * @access  Private
 */
const saveMapping = async (req, res) => {
  try {
    const { formHash, formName, mapping } = req.body;
    const userId = req.user.userId; // Changed from req.user.id

    if (!formHash || !mapping) {
      return res.status(400).json({
        success: false,
        message: 'formHash and mapping are required',
      });
    }

    // Create or update mapping
    const savedMapping = await FormMapping.findOneAndUpdate(
      { formHash, userId },
      {
        formHash,
        userId,
        formName,
        mapping: new Map(Object.entries(mapping)),
        lastUsed: new Date(),
        usageCount: 1
      },
      { upsert: true, new: true }
    );

    console.log('✅ Mapping saved:', formHash);

    res.json({
      success: true,
      message: 'Mapping saved successfully',
      mapping: savedMapping,
    });

  } catch (error) {
    console.error('❌ Save Mapping Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to save mapping',
      error: error.message
    });
  }
};

/**
 * @desc    Get all saved mappings for user
 * @route   GET /api/mapping/user
 * @access  Private
 */
const getUserMappings = async (req, res) => {
  try {
    const userId = req.user.userId; // Changed from req.user.id

    const mappings = await FormMapping.find({ userId })
      .sort({ lastUsed: -1 })
      .limit(50);

    res.json({
      success: true,
      count: mappings.length,
      mappings,
    });

  } catch (error) {
    console.error('❌ Get Mappings Error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to get mappings',
      error: error.message
    });
  }
};

// Export all functions
module.exports = {
  detectMapping,
  saveMapping,
  getUserMappings
};