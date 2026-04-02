require('dotenv').config();
const mongoose = require('mongoose');
const Form = require('./src/models/Form');

const forms = [
  {
    formId: 'scholarship_2024',
    title: 'Scholarship Application 2024',
    fields: [
      { id: 'full_name', label: 'Full Name', type: 'text', required: true, profileKey: 'fullName' },
      { id: 'email', label: 'Email Address', type: 'email', required: true, profileKey: 'email' },
      { id: 'dob', label: 'Date of Birth', type: 'date', required: true, profileKey: 'dateOfBirth' },
      { id: 'phone', label: 'Phone Number', type: 'tel', required: true, profileKey: 'phoneNumber' },
      { id: 'address', label: 'Full Address', type: 'textarea', required: true, profileKey: 'address.street' },
      { id: 'city', label: 'City', type: 'text', required: true, profileKey: 'address.city' },
      { id: 'state', label: 'State', type: 'text', required: true, profileKey: 'address.state' },
      { id: 'pincode', label: 'PIN Code', type: 'text', required: true, profileKey: 'address.pincode' },
      { id: 'annual_income', label: 'Annual Family Income', type: 'number', required: true, profileKey: null },
      { id: 'category', label: 'Category', type: 'select', required: true, profileKey: null }
    ],
    isActive: true
  },
  {
    formId: 'job_application',
    title: 'Job Application Form',
    fields: [
      { id: 'full_name', label: 'Full Name', type: 'text', required: true, profileKey: 'fullName' },
      { id: 'email', label: 'Email', type: 'email', required: true, profileKey: 'email' },
      { id: 'phone', label: 'Phone', type: 'tel', required: true, profileKey: 'phoneNumber' },
      { id: 'dob', label: 'Date of Birth', type: 'date', required: true, profileKey: 'dateOfBirth' },
      { id: 'position', label: 'Position Applied For', type: 'text', required: true, profileKey: null },
      { id: 'experience', label: 'Years of Experience', type: 'number', required: true, profileKey: null },
      { id: 'current_company', label: 'Current Company', type: 'text', required: false, profileKey: null }
    ],
    isActive: true
  }
];

async function seedForms() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    await Form.deleteMany({});
    console.log('🗑️  Cleared existing forms');

    await Form.insertMany(forms);
    console.log('✅ Added sample forms');

    const count = await Form.countDocuments();
    console.log('📊 Total forms:', count);

    mongoose.connection.close();
    console.log('👋 Done!');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

seedForms();
