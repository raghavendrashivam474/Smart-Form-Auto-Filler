const Document = require('../models/Document');
const path = require('path');
const fs = require('fs').promises;

// Upload document
exports.uploadDocument = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'No file uploaded',
      });
    }

    const { name, category } = req.body;

    if (!name || !category) {
      // Delete uploaded file if validation fails
      await fs.unlink(req.file.path);
      return res.status(400).json({
        success: false,
        message: 'Name and category are required',
      });
    }

    const document = await Document.create({
      userId: req.user._id,
      name,
      category,
      filename: req.file.filename,
      path: req.file.path,
      mimeType: req.file.mimetype,
      size: req.file.size,
    });

    res.status(201).json({
      success: true,
      message: 'Document uploaded successfully',
      data: document,
    });
  } catch (error) {
    // Clean up file if database save fails
    if (req.file) {
      await fs.unlink(req.file.path).catch(console.error);
    }
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Get all user documents
exports.getDocuments = async (req, res) => {
  try {
    const { category } = req.query;
    
    const filter = { userId: req.user._id };
    if (category) {
      filter.category = category;
    }

    const documents = await Document.find(filter).sort({ createdAt: -1 });

    res.json({
      success: true,
      data: documents,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Get single document
exports.getDocument = async (req, res) => {
  try {
    const document = await Document.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found',
      });
    }

    res.json({
      success: true,
      data: document,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Delete document
exports.deleteDocument = async (req, res) => {
  try {
    const document = await Document.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found',
      });
    }

    // Delete file from filesystem
    await fs.unlink(document.path);

    // Delete from database
    await document.deleteOne();

    res.json({
      success: true,
      message: 'Document deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Download document
exports.downloadDocument = async (req, res) => {
  try {
    const document = await Document.findOne({
      _id: req.params.id,
      userId: req.user._id,
    });

    if (!document) {
      return res.status(404).json({
        success: false,
        message: 'Document not found',
      });
    }

    res.download(document.path, document.filename);
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
