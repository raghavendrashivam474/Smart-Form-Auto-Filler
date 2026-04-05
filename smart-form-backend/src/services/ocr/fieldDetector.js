/**
 * Detect form fields from extracted text
 */
function detectFields(text) {
  console.log('🔍 Analyzing text for form fields...');
  
  const fields = [];
  const lines = text.split('\n').map(line => line.trim()).filter(Boolean);
  
  // Common field patterns
  const patterns = {
    name: /\b(full\s*name|name|applicant\s*name|student\s*name|your\s*name|candidate\s*name)\b/i,
    email: /\b(email|e-mail|email\s*id|email\s*address|mail|e\s*mail)\b/i,
    phone: /\b(phone|mobile|contact|telephone|cell|number|phone\s*no|mobile\s*no|contact\s*number)\b/i,
    dob: /\b(date\s*of\s*birth|dob|birth\s*date|birthday|d\.o\.b)\b/i,
    address: /\b(address|residential|permanent|current\s*address|street|house\s*address)\b/i,
    city: /\b(city|town)\b/i,
    state: /\b(state|province)\b/i,
    pincode: /\b(pin\s*code|pincode|zip\s*code|postal\s*code|pin)\b/i,
    country: /\b(country|nation)\b/i,
    gender: /\b(gender|sex)\b/i,
    age: /\b(age)\b/i,
    father: /\b(father'?s?\s*name|father)\b/i,
    mother: /\b(mother'?s?\s*name|mother)\b/i,
    qualification: /\b(qualification|education|degree|educational\s*qualification)\b/i,
    occupation: /\b(occupation|profession|job|designation|current\s*occupation)\b/i,
    company: /\b(company|organization|employer|current\s*company)\b/i,
    experience: /\b(experience|years\s*of\s*experience|work\s*experience)\b/i,
    pan: /\b(pan\s*number|pan\s*card|pan)\b/i,
    aadhar: /\b(aadhar|aadhaar|aadhar\s*number)\b/i,
    passport: /\b(passport|passport\s*number)\b/i,
    nationality: /\b(nationality)\b/i,
    marital: /\b(marital\s*status|marital)\b/i,
    blood: /\b(blood\s*group|blood\s*type)\b/i,
  };
  
  // Field type inference
  const typeMap = {
    name: 'text',
    email: 'email',
    phone: 'tel',
    dob: 'date',
    address: 'textarea',
    city: 'text',
    state: 'text',
    pincode: 'text',
    country: 'text',
    gender: 'select',
    age: 'number',
    father: 'text',
    mother: 'text',
    qualification: 'text',
    occupation: 'text',
    company: 'text',
    experience: 'number',
    pan: 'text',
    aadhar: 'text',
    passport: 'text',
    nationality: 'text',
    marital: 'select',
    blood: 'select',
  };
  
  // Profile key mapping
  const profileKeyMap = {
    name: 'fullName',
    email: 'email',
    phone: 'phoneNumber',
    dob: 'dateOfBirth',
    address: 'address.street',
    city: 'address.city',
    state: 'address.state',
    pincode: 'address.pincode',
    country: 'country',
    gender: 'gender',
    age: 'age',
    father: 'fatherName',
    mother: 'motherName',
    qualification: 'qualification',
    occupation: 'occupation',
    company: 'currentCompany',
    experience: 'experience',
    pan: 'panNumber',
    aadhar: 'aadharNumber',
    passport: 'passportNumber',
    nationality: 'nationality',
    marital: 'maritalStatus',
    blood: 'bloodGroup',
  };
  
  // Options for select fields
  const optionsMap = {
    gender: ['Male', 'Female', 'Other'],
    marital: ['Single', 'Married', 'Divorced', 'Widowed'],
    blood: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'],
  };
  
  // Detect fields from text
  const detected = new Map(); // Use Map to track unique fields
  
  lines.forEach((line, index) => {
    for (const [key, pattern] of Object.entries(patterns)) {
      if (pattern.test(line)) {
        // Skip if already detected this field type
        if (detected.has(key)) continue;
        
        // Clean the label
        let label = line
          .replace(/[:*_\-]+/g, ' ')
          .replace(/\s+/g, ' ')
          .trim();
        
        // If label is too long (likely includes other text), extract just the matched part
        if (label.length > 50) {
          const match = line.match(pattern);
          if (match) {
            label = match[0];
          }
        }
        
        // Generate field name (camelCase)
        const fieldName = key + (detected.size > 0 ? '' : '');
        
        const field = {
          key: key,
          name: fieldName,
          label: toTitleCase(label) || toTitleCase(key),
          type: typeMap[key] || 'text',
          required: ['name', 'email', 'phone'].includes(key), // Core fields are required
          profileKey: profileKeyMap[key],
          confidence: 85, // Base confidence
          detectedFrom: line,
          lineNumber: index + 1
        };
        
        // Add options for select fields
        if (optionsMap[key]) {
          field.options = optionsMap[key];
        }
        
        detected.set(key, field);
        fields.push(field);
        
        console.log(`✅ Detected: ${field.label} → ${profileKeyMap[key]} (${typeMap[key]})`);
      }
    }
  });
  
  console.log(`🎯 Detected ${fields.length} unique fields`);
  
  return fields;
}

/**
 * Convert string to title case
 */
function toTitleCase(str) {
  return str
    .replace(/([A-Z])/g, ' $1')
    .replace(/^./, char => char.toUpperCase())
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Analyze and create form structure
 */
function analyzeDocument(text) {
  console.log('========================================');
  console.log('📋 DOCUMENT ANALYSIS STARTED');
  console.log('========================================');
  
  const fields = detectFields(text);
  
  const analysis = {
    totalFields: fields.length,
    fields: fields,
    summary: {
      hasPersonalInfo: fields.some(f => ['name', 'email', 'phone'].includes(f.key)),
      hasAddress: fields.some(f => ['address', 'city', 'state'].includes(f.key)),
      hasIdentity: fields.some(f => ['pan', 'aadhar', 'passport'].includes(f.key)),
      hasEducation: fields.some(f => f.key === 'qualification'),
      hasOccupation: fields.some(f => ['occupation', 'company'].includes(f.key)),
    },
    confidence: fields.length > 0 ? Math.min(95, 60 + (fields.length * 5)) : 0,
    extractedText: text.substring(0, 500) + (text.length > 500 ? '...' : '')
  };
  
  console.log('========================================');
  console.log('📊 ANALYSIS COMPLETE');
  console.log('   Total Fields:', analysis.totalFields);
  console.log('   Confidence:', analysis.confidence + '%');
  console.log('   Has Personal Info:', analysis.summary.hasPersonalInfo);
  console.log('   Has Address:', analysis.summary.hasAddress);
  console.log('========================================');
  
  return analysis;
}

module.exports = {
  detectFields,
  analyzeDocument,
  toTitleCase
};