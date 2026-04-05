const Tesseract = require('tesseract.js');
const fs = require('fs').promises;
const path = require('path');

/**
 * Extract text from PDF using simple text reading
 */
async function extractFromPDF(filePath) {
  try {
    console.log('📄 Processing PDF:', filePath);
    
    const dataBuffer = await fs.readFile(filePath);
    const text = dataBuffer.toString('utf-8');
    
    // Clean extracted text
    const cleanText = text
      .replace(/[^\x20-\x7E\n\r]/g, ' ')
      .replace(/\s+/g, ' ')
      .trim();
    
    console.log('✅ PDF text extracted:', cleanText.length, 'characters');
    
    return {
      success: true,
      text: cleanText || 'Unable to extract text from this PDF. Please try an image instead.',
      pages: 1
    };
  } catch (error) {
    console.error('❌ PDF extraction error:', error);
    return {
      success: true,
      text: 'PDF text extraction failed. Please upload an image (JPG/PNG) instead.',
      pages: 0
    };
  }
}

/**
 * Extract text from Image using OCR
 */
async function extractFromImage(filePath) {
  try {
    console.log('📸 Processing image:', filePath);
    
    // Perform OCR
    const { data: { text } } = await Tesseract.recognize(
      filePath,
      'eng',
      {
        logger: m => {
          if (m.status === 'recognizing text') {
            console.log(`OCR Progress: ${Math.round(m.progress * 100)}%`);
          }
        }
      }
    );
    
    console.log('✅ Image text extracted:', text.length, 'characters');
    
    return {
      success: true,
      text: text
    };
  } catch (error) {
    console.error('❌ Image OCR error:', error);
    throw new Error('Failed to extract text from image: ' + error.message);
  }
}

/**
 * Main document processor
 */
async function processDocument(filePath, fileType) {
  try {
    let result;
    
    if (fileType === 'application/pdf') {
      result = await extractFromPDF(filePath);
    } else if (fileType.startsWith('image/')) {
      result = await extractFromImage(filePath);
    } else {
      throw new Error('Unsupported file type: ' + fileType);
    }
    
    return result;
  } catch (error) {
    console.error('❌ Document processing error:', error);
    throw error;
  }
}

module.exports = {
  extractFromPDF,
  extractFromImage,
  processDocument
};