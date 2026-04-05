const crypto = require('crypto');

class FieldMappingService {
  constructor() {
    // Synonym dictionary for smart matching
    this.synonyms = {
      fullName: ['name', 'full name', 'applicant name', 'candidate name', 'your name'],
      email: ['email', 'email address', 'e-mail', 'email id'],
      phoneNumber: ['phone', 'mobile', 'contact', 'phone number', 'mobile number', 'contact number'],
      dateOfBirth: ['dob', 'date of birth', 'birth date', 'birthday'],
      address: ['address', 'street address', 'residence', 'location'],
      city: ['city', 'town'],
      state: ['state', 'province', 'region'],
      pincode: ['pincode', 'zip', 'postal code', 'zip code'],
      gender: ['gender', 'sex'],
      category: ['category', 'caste', 'community'],
      annual_income: ['income', 'annual income', 'yearly income', 'salary'],
    };

    this.confidenceThreshold = 0.8; // 80%
  }

  /**
   * Generate unique hash for a form based on field labels
   */
  generateFormHash(fields) {
    const fieldLabels = fields
      .map(f => f.label.toLowerCase().trim())
      .sort()
      .join('|');
    
    return crypto.createHash('md5').update(fieldLabels).digest('hex');
  }

  /**
   * Auto-detect mapping for a single field
   */
  detectFieldMapping(fieldLabel) {
    const normalized = fieldLabel.toLowerCase().trim();
    
    for (const [profileKey, keywords] of Object.entries(this.synonyms)) {
      for (const keyword of keywords) {
        // Exact match
        if (normalized === keyword) {
          return { profileKey, confidence: 1.0 };
        }
        
        // Contains match
        if (normalized.includes(keyword) || keyword.includes(normalized)) {
          return { profileKey, confidence: 0.85 };
        }
        
        // Fuzzy match (simple Levenshtein-like)
        const similarity = this.calculateSimilarity(normalized, keyword);
        if (similarity > 0.7) {
          return { profileKey, confidence: similarity };
        }
      }
    }
    
    return { profileKey: null, confidence: 0 };
  }

  /**
   * Simple similarity calculation
   */
  calculateSimilarity(str1, str2) {
    const longer = str1.length > str2.length ? str1 : str2;
    const shorter = str1.length > str2.length ? str2 : str1;
    
    if (longer.length === 0) return 1.0;
    
    const editDistance = this.levenshteinDistance(longer, shorter);
    return (longer.length - editDistance) / longer.length;
  }

  /**
   * Levenshtein distance
   */
  levenshteinDistance(str1, str2) {
    const matrix = [];
    
    for (let i = 0; i <= str2.length; i++) {
      matrix[i] = [i];
    }
    
    for (let j = 0; j <= str1.length; j++) {
      matrix[0][j] = j;
    }
    
    for (let i = 1; i <= str2.length; i++) {
      for (let j = 1; j <= str1.length; j++) {
        if (str2.charAt(i - 1) === str1.charAt(j - 1)) {
          matrix[i][j] = matrix[i - 1][j - 1];
        } else {
          matrix[i][j] = Math.min(
            matrix[i - 1][j - 1] + 1,
            matrix[i][j - 1] + 1,
            matrix[i - 1][j] + 1
          );
        }
      }
    }
    
    return matrix[str2.length][str1.length];
  }

  /**
   * Auto-detect mapping for entire form
   */
  autoMapForm(fields) {
    const mapping = {};
    const needsConfirmation = [];
    
    for (const field of fields) {
      const detection = this.detectFieldMapping(field.label);
      
      if (detection.profileKey && detection.confidence >= this.confidenceThreshold) {
        // High confidence - auto-map
        mapping[field.key] = {
          profileKey: detection.profileKey,
          confidence: detection.confidence,
          autoMapped: true,
        };
      } else if (detection.profileKey) {
        // Low confidence - needs user confirmation
        mapping[field.key] = {
          profileKey: detection.profileKey,
          confidence: detection.confidence,
          autoMapped: false,
        };
        needsConfirmation.push({
          fieldKey: field.key,
          fieldLabel: field.label,
          suggestedKey: detection.profileKey,
          confidence: detection.confidence,
        });
      } else {
        // No match found
        needsConfirmation.push({
          fieldKey: field.key,
          fieldLabel: field.label,
          suggestedKey: null,
          confidence: 0,
        });
      }
    }
    
    return { mapping, needsConfirmation };
  }
}

module.exports = new FieldMappingService();