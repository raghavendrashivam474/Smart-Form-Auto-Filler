const Form = require('../models/Form');
const User = require('../models/User');

// Get all forms
exports.getAllForms = async (req, res) => {
  try {
    const forms = await Form.find({ isActive: true });
    
    res.json({
      success: true,
      data: forms,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Helper function to get nested property value
const getNestedValue = (obj, path) => {
  if (!path) return null;
  return path.split('.').reduce((current, prop) => current?.[prop], obj);
};

// Get single form with auto-fill
exports.getForm = async (req, res) => {
  try {
    const form = await Form.findOne({ formId: req.params.formId });
    
    if (!form) {
      return res.status(404).json({
        success: false,
        message: 'Form not found',
      });
    }

    // Get user profile for auto-fill
    const user = await User.findById(req.user._id);
    const profile = user.profile || {};
    
    // Add phoneNumber to profile for mapping
    const fullProfile = {
      ...profile,
      phoneNumber: user.phoneNumber
    };

    // Auto-fill fields
    const filledFields = form.fields.map(field => {
      let value = null;
      let autoFilled = false;

      // Try mapping with profileKey first
      if (field.profileKey) {
        value = getNestedValue(fullProfile, field.profileKey);
        if (value !== null && value !== undefined) {
          autoFilled = true;
        }
      }
      
      // If not found, try direct field.id lookup
      if (!autoFilled) {
        value = fullProfile[field.id];
        if (value !== null && value !== undefined) {
          autoFilled = true;
        }
      }

      return {
        id: field.id,
        label: field.label,
        type: field.type,
        required: field.required,
        value: value,
        autoFilled: autoFilled,
      };
    });

    // Calculate auto-fill percentage
    const autoFilledCount = filledFields.filter(f => f.autoFilled).length;
    const autoFillPercentage = Math.round((autoFilledCount / filledFields.length) * 100);

    console.log(`📊 Form ${req.params.formId}: ${autoFilledCount}/${filledFields.length} auto-filled (${autoFillPercentage}%)`);

    res.json({
      success: true,
      data: {
        formId: form.formId,
        title: form.title,
        fields: filledFields,
        stats: {
          totalFields: filledFields.length,
          autoFilled: autoFilledCount,
          percentage: autoFillPercentage
        }
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
