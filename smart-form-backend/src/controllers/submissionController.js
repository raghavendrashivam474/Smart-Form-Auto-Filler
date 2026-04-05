const Submission = require('../models/Submission');
const Form = require('../models/Form');
const User = require('../models/User');
const pdfGenerator = require('../services/pdfGenerator');

/**
 * @desc    Submit form
 * @route   POST /api/submissions
 * @access  Private
 */
const submitForm = async (req, res) => {
  try {
    const { formId, data } = req.body;
    const userId = req.user.userId;

    console.log('📝 Form submission:', { formId, userId, data });

    // Validate form exists
    const form = await Form.findById(formId);
    if (!form) {
      return res.status(404).json({
        success: false,
        message: 'Form not found'
      });
    }

    // Create submission
    const submission = await Submission.create({
      user: userId,
      form: formId,
      data,
      submittedAt: new Date()
    });

    console.log('✅ Submission created:', submission._id);

    // ============================================
    // UPDATE USER PROFILE (MERGE-BASED) - FIXED
    // ============================================
    const user = await User.findById(userId);
    if (user) {
      const updateObject = {};

      // Handle address separately
      if (data.address && typeof data.address === 'object') {
        console.log('🏠 Updating address from submission:', data.address);
        
        const addressUpdate = {
          street: data.address.street || user.profile?.address?.street || '',
          city: data.address.city || user.profile?.address?.city || '',
          state: data.address.state || user.profile?.address?.state || '',
          pincode: data.address.pincode || user.profile?.address?.pincode || ''
        };

        updateObject['profile.address'] = addressUpdate;
      }

      // Process all other fields
      for (const [key, value] of Object.entries(data)) {
        if (key === 'address') continue; // Already handled
        
        if (value !== undefined && value !== null && value !== '') {
          updateObject[`profile.${key}`] = value;
        }
      }

      console.log('🔄 Updating profile with:', JSON.stringify(updateObject, null, 2));

      await User.findByIdAndUpdate(
        userId,
        { $set: updateObject },
        { runValidators: true }
      );

      console.log('✅ Profile updated from submission');
    }

    // Populate form details
    await submission.populate('form', 'name description');

    res.status(201).json({
      success: true,
      message: 'Form submitted successfully',
      data: submission
    });

  } catch (error) {
    console.error('❌ Submit form error:', error);
    res.status(500).json({
      success: false,
      message: 'Error submitting form',
      error: error.message
    });
  }
};

/**
 * @desc    Get all submissions for logged-in user
 * @route   GET /api/submissions
 * @access  Private
 */
const getSubmissions = async (req, res) => {
  try {
    const userId = req.user.userId;

    const submissions = await Submission.find({ user: userId })
      .populate('form', 'name description')
      .sort({ submittedAt: -1 })
      .select('-__v');

    res.json({
      success: true,
      count: submissions.length,
      data: submissions
    });

  } catch (error) {
    console.error('Get submissions error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching submissions'
    });
  }
};

/**
 * @desc    Get single submission
 * @route   GET /api/submissions/:id
 * @access  Private
 */
const getSubmission = async (req, res) => {
  try {
    const submission = await Submission.findOne({
      _id: req.params.id,
      user: req.user.userId
    }).populate('form', 'name description fields');

    if (!submission) {
      return res.status(404).json({
        success: false,
        message: 'Submission not found'
      });
    }

    res.json({
      success: true,
      data: submission
    });

  } catch (error) {
    console.error('Get submission error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching submission'
    });
  }
};

/**
 * @desc    Generate PDF for submission
 * @route   POST /api/submissions/:id/pdf
 * @access  Private
 */
const generatePDF = async (req, res) => {
  try {
    const submission = await Submission.findOne({
      _id: req.params.id,
      user: req.user.userId
    }).populate('form', 'name description fields');

    if (!submission) {
      return res.status(404).json({
        success: false,
        message: 'Submission not found'
      });
    }

    // Generate PDF
    const pdfBuffer = await pdfGenerator.generateSubmissionPDF(submission);

    // Save PDF reference
    submission.pdfGenerated = true;
    submission.pdfData = pdfBuffer;
    await submission.save();

    res.json({
      success: true,
      message: 'PDF generated successfully',
      data: {
        submissionId: submission._id,
        pdfGenerated: true
      }
    });

  } catch (error) {
    console.error('Generate PDF error:', error);
    res.status(500).json({
      success: false,
      message: 'Error generating PDF'
    });
  }
};

/**
 * @desc    Download PDF for submission
 * @route   GET /api/submissions/:id/pdf/download
 * @access  Private
 */
const downloadPDF = async (req, res) => {
  try {
    const submission = await Submission.findOne({
      _id: req.params.id,
      user: req.user.userId
    }).populate('form', 'name');

    if (!submission) {
      return res.status(404).json({
        success: false,
        message: 'Submission not found'
      });
    }

    if (!submission.pdfGenerated || !submission.pdfData) {
      return res.status(404).json({
        success: false,
        message: 'PDF not generated yet'
      });
    }

    res.set({
      'Content-Type': 'application/pdf',
      'Content-Disposition': `attachment; filename="submission-${submission._id}.pdf"`,
      'Content-Length': submission.pdfData.length
    });

    res.send(submission.pdfData);

  } catch (error) {
    console.error('Download PDF error:', error);
    res.status(500).json({
      success: false,
      message: 'Error downloading PDF'
    });
  }
};

/**
 * @desc    Delete submission
 * @route   DELETE /api/submissions/:id
 * @access  Private
 */
const deleteSubmission = async (req, res) => {
  try {
    const submission = await Submission.findOneAndDelete({
      _id: req.params.id,
      user: req.user.userId
    });

    if (!submission) {
      return res.status(404).json({
        success: false,
        message: 'Submission not found'
      });
    }

    res.json({
      success: true,
      message: 'Submission deleted successfully'
    });

  } catch (error) {
    console.error('Delete submission error:', error);
    res.status(500).json({
      success: false,
      message: 'Error deleting submission'
    });
  }
};

// Export all functions
module.exports = {
  submitForm,
  getSubmissions,
  getSubmission,
  generatePDF,
  downloadPDF,
  deleteSubmission
};