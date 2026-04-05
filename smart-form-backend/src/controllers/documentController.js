const multer = require('multer');
const path = require('path');
const fs = require('fs').promises;
const documentProcessor = require('../services/ocr/documentProcessor');
const fieldDetector = require('../services/ocr/fieldDetector');
const Form = require('../models/Form');

// Configure multer for file uploads
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, 'uploads/temp/');
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
    cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({
  storage: storage,
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: function (req, file, cb) {
    const allowedTypes = /jpeg|jpg|png|pdf/;
    const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
    const mimetype = allowedTypes.test(file.mimetype);

    if (mimetype && extname) {
      return cb(null, true);
    } else {
      cb(new Error('Only PDF and image files (JPG, PNG) are allowed!'));
    }
  }
}).single('document');

/**
 * @desc    Upload and process document
 * @route   POST /api/documents/upload
 * @access  Private
 */
const uploadDocument = async (req, res) => {
  upload(req, res, async function (err) {
    if (err) {
      console.error('Upload error:', err);
      return res.status(400).json({
        success: false,
        message: err.message
      });
    }

    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded'
      });
    }

    try {
      const filePath = req.file.path;
      const fileType = req.file.mimetype;

      console.log('📤 File uploaded:', req.file.originalname);
      console.log('📁 Saved to:', filePath);

      // Process document (OCR)
      const { text } = await documentProcessor.processDocument(filePath, fileType);

      // Analyze and detect fields
      const analysis = fieldDetector.analyzeDocument(text);

      // Clean up uploaded file
      await fs.unlink(filePath).catch(() => {});

      res.json({
        success: true,
        message: 'Document processed successfully',
        data: {
          extractedText: text,
          analysis: analysis,
          fileName: req.file.originalname
        }
      });

    } catch (error) {
      console.error('❌ Document processing error:', error);
      
      // Clean up file on error
      if (req.file) {
        await fs.unlink(req.file.path).catch(() => {});
      }

      res.status(500).json({
        success: false,
        message: 'Failed to process document',
        error: error.message
      });
    }
  });
};

/**
 * @desc    Create form from detected fields
 * @route   POST /api/documents/create-form
 * @access  Private
 */
const createFormFromFields = async (req, res) => {
  try {
    const { name, description, fields } = req.body;
    const userId = req.user.userId;

    if (!name || !fields || !Array.isArray(fields)) {
      return res.status(400).json({
        success: false,
        message: 'Form name and fields are required'
      });
    }

    // Create form
    const form = await Form.create({
      name,
      description: description || 'Auto-generated from document',
      fields: fields.map(f => ({
        name: f.name,
        label: f.label,
        type: f.type,
        required: f.required !== false,
        profileKey: f.profileKey,
        options: f.options
      })),
      isActive: true
    });

    console.log('✅ Form created from document:', form.name);

    res.status(201).json({
      success: true,
      message: 'Form created successfully',
      data: form
    });

  } catch (error) {
    console.error('❌ Create form error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create form',
      error: error.message
    });
  }
};

module.exports = {
  uploadDocument,
  createFormFromFields
};