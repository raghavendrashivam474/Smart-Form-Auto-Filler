const pdf = require('pdf-parse');
const Tesseract = require('tesseract.js');
const Jimp = require('jimp');
const fs = require('fs').promises;
const path = require('path');

/**
 * Extract text from PDF
 */
async function extractFromPDF(filePath) {
  try {
    console.log('📄 Processing PDF:', filePath);
    
    const dataBuffer = await fs.readFile(filePath);
    const data = await pdf(dataBuffer);
    
    console.log('✅ PDF text extracted:', data.text.length, 'characters');
    
    return {
      success: true,
      text: data.text,
      pages: data.numpages,
      metadata: data.info
    };
  } catch (error) {
    console.error('❌ PDF extraction error:', error);
    throw new Error('Failed to extract text from PDF: ' + error.message);
  }
}

/**
 * Extract text from Image using OCR
 */
async function extractFromImage(filePath) {
  try {
    console.log('📸 Processing image:', filePath);
    
    // Preprocess image for better OCR using Jimp
    const processedPath = filePath.replace(/\.(jpg|jpeg|png)$/i, '_processed.png');
    
    const image = await Jimp.read(filePath);
    await image
      .grayscale()
      .contrast(0.3)
      .normalize()
      .writeAsync(processedPath);
    
    console.log('🔧 Image preprocessed');
    
    // Perform OCR
    const { data: { text } } = await Tesseract.recognize(
      processedPath,
      'eng',
      {
        logger: m => {
          if (m.status === 'recognizing text') {
            console.log(`OCR Progress: ${Math.round(m.progress * 100)}%`);
          }
        }
      }
    );
    
    // Clean up processed image
    await fs.unlink(processedPath).catch(() => {});
    
    console.log('✅ Image text extracted:', text.length, 'characters');
    
    return {
      success: true,
      text: text,
      processedImage: processedPath
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