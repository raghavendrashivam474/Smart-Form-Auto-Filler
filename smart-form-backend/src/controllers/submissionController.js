const Submission = require('../models/Submission');
const Form = require('../models/Form');
const User = require('../models/User');
const FieldTrackerService = require('../services/fieldTracker');
const PDFGeneratorService = require('../services/pdfGenerator');
const path = require('path');
const fs = require('fs').promises;

// Submit form
exports.submitForm = async (req, res) => {
  try {
    const { formId, data, documents } = req.body;

    const form = await Form.findOne({ formId });
    if (!form) {
      return res.status(404).json({
        success: false,
        message: 'Form not found',
      });
    }

    const submission = await Submission.create({
      userId: req.user._id,
      formId,
      formTitle: form.title,
      data,
      documents: documents || [],
      status: 'submitted',
    });

    // Track field usage (adaptive learning)
    await FieldTrackerService.trackFields(form.fields);

    // ✨ ENHANCED: Save ALL form data to profile for future auto-fill
    const profileUpdates = {};
    
    Object.keys(data).forEach(key => {
      const field = form.fields.find(f => f.id === key);
      
      if (data[key]) {
        if (field && field.profileKey) {
          // Has explicit mapping - use it
          profileUpdates['profile.' + field.profileKey] = data[key];
        } else {
          // No mapping - save with field ID as key
          profileUpdates['profile.' + key] = data[key];
        }
      }
    });

    if (Object.keys(profileUpdates).length > 0) {
      await User.findByIdAndUpdate(req.user._id, {
        $set: profileUpdates
      });
      console.log('✅ Profile updated with', Object.keys(profileUpdates).length, 'fields');
      console.log('📝 Updated fields:', Object.keys(profileUpdates));
    }

    res.status(201).json({
      success: true,
      message: 'Form submitted successfully',
      data: submission,
    });
  } catch (error) {
    console.error('❌ Submission error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Get all user submissions
exports.getSubmissions = async (req, res) => {
  try {
    const submissions = await Submission.find({ userId: req.user._id })
      .sort({ createdAt: -1 });

    res.json({
      success: true,
      count: submissions.length,
      data: submissions,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Get single submission
exports.getSubmission = async (req, res) => {
  try {
    const submission = await Submission.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!submission) {
      return res.status(404).json({
        success: false,
        message: 'Submission not found',
      });
    }

    res.json({
      success: true,
      data: submission,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Delete submission
exports.deleteSubmission = async (req, res) => {
  try {
    const submission = await Submission.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!submission) {
      return res.status(404).json({
        success: false,
        message: 'Submission not found',
      });
    }

    if (submission.pdfUrl) {
      await fs.unlink(path.join(__dirname, '../..', submission.pdfUrl)).catch(console.error);
    }

    await submission.deleteOne();

    res.json({
      success: true,
      message: 'Submission deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Generate PDF
exports.generatePDF = async (req, res) => {
  try {
    const submission = await Submission.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!submission) {
      return res.status(404).json({
        success: false,
        message: 'Submission not found',
      });
    }

    const pdfDir = path.join(__dirname, '../../uploads/pdfs');
    await fs.mkdir(pdfDir, { recursive: true });

    const filename = `submission-${submission._id}.pdf`;
    const filepath = path.join(pdfDir, filename);

    await PDFGeneratorService.generateFormPDF(submission, filepath);

    submission.pdfUrl = `/uploads/pdfs/${filename}`;
    await submission.save();

    res.json({
      success: true,
      message: 'PDF generated successfully',
      data: {
        pdfUrl: submission.pdfUrl
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Download PDF
exports.downloadPDF = async (req, res) => {
  try {
    const submission = await Submission.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!submission || !submission.pdfUrl) {
      return res.status(404).json({
        success: false,
        message: 'PDF not found',
      });
    }

    const filepath = path.join(__dirname, '../..', submission.pdfUrl);
    res.download(filepath);
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Get field statistics
exports.getFieldStatistics = async (req, res) => {
  try {
    const stats = await FieldTrackerService.getStatistics();
    
    res.json({
      success: true,
      data: stats,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
