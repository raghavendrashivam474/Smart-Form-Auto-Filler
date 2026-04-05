const Form = require('../models/Form');
const User = require('../models/User');

/**
 * Helper function to get nested property value
 */
const getNestedValue = (obj, path) => {
  if (!path) return null;
  return path.split('.').reduce((current, prop) => current?.[prop], obj);
};

/**
 * @desc    Get all forms
 * @route   GET /api/forms
 * @access  Private
 */
const getForms = async (req, res) => {
  try {
    const forms = await Form.find({ isActive: true })
      .select('-__v')
      .sort({ createdAt: -1 });
    
    res.json({
      success: true,
      count: forms.length,
      data: forms,
    });
  } catch (error) {
    console.error('Get forms error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching forms',
      error: error.message,
    });
  }
};

/**
 * @desc    Get single form with auto-fill
 * @route   GET /api/forms/:formId
 * @access  Private
 */
const getFormById = async (req, res) => {
  try {
    const form = await Form.findById(req.params.formId);
    
    if (!form) {
      return res.status(404).json({
        success: false,
        message: 'Form not found',
      });
    }

    // Get user profile for auto-fill
    const user = await User.findById(req.user.userId); // Changed from req.user._id
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const profile = user.profile || {};
    
    // Add top-level identity fields to the auto-fill profile map
    const fullProfile = {
      ...profile,
      email: user.email,
    };

    console.log('👤 User profile for auto-fill:', JSON.stringify(fullProfile, null, 2));

    // Auto-fill fields
    const filledFields = form.fields.map(field => {
      let value = null;
      let autoFilled = false;

      // Try mapping with profileKey first
      if (field.profileKey) {
        value = getNestedValue(fullProfile, field.profileKey);
        if (value !== null && value !== undefined && value !== '') {
          autoFilled = true;
        }
      }
      
      // If not found, try direct field.name lookup
      if (!autoFilled && field.name) {
        value = fullProfile[field.name];
        if (value !== null && value !== undefined && value !== '') {
          autoFilled = true;
        }
      }

      // If still not found, try field.label variations
      if (!autoFilled && field.label) {
        const labelKey = field.label.toLowerCase().replace(/\s+/g, '');
        value = fullProfile[labelKey];
        if (value !== null && value !== undefined && value !== '') {
          autoFilled = true;
        }
      }

      console.log(`📋 Field "${field.label}": ${autoFilled ? '✅ Auto-filled' : '⚪ Empty'} (value: ${value})`);

      return {
        _id: field._id,
        name: field.name,
        label: field.label,
        type: field.type,
        required: field.required,
        options: field.options,
        value: value || '',
        autoFilled: autoFilled,
      };
    });

    // Calculate auto-fill percentage
    const autoFilledCount = filledFields.filter(f => f.autoFilled).length;
    const autoFillPercentage = filledFields.length > 0 
      ? Math.round((autoFilledCount / filledFields.length) * 100) 
      : 0;

    console.log(`📊 Form ${form.name}: ${autoFilledCount}/${filledFields.length} auto-filled (${autoFillPercentage}%)`);

    res.json({
      success: true,
      data: {
        _id: form._id,
        name: form.name,
        description: form.description,
        fields: filledFields,
        stats: {
          totalFields: filledFields.length,
          autoFilled: autoFilledCount,
          percentage: autoFillPercentage
        }
      },
    });
  } catch (error) {
    console.error('Get form error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching form',
      error: error.message,
    });
  }
};

/**
 * @desc    Create new form (Admin only - for testing)
 * @route   POST /api/forms
 * @access  Private
 */
const createForm = async (req, res) => {
  try {
    const { name, description, fields } = req.body;

    if (!name || !fields || !Array.isArray(fields)) {
      return res.status(400).json({
        success: false,
        message: 'Name and fields array are required',
      });
    }

    const form = await Form.create({
      name,
      description,
      fields,
      isActive: true
    });

    console.log('✅ Form created:', form.name);

    res.status(201).json({
      success: true,
      message: 'Form created successfully',
      data: form,
    });
  } catch (error) {
    console.error('Create form error:', error);
    res.status(500).json({
      success: false,
      message: 'Error creating form',
      error: error.message,
    });
  }
};

// Export all functions
module.exports = {
  getForms,
  getFormById,
  createForm
};