# 🤖 Smart Form Auto-Filler

> An intelligent form automation system that learns, adapts, and gets smarter with every use.

[![Flutter](https://img.shields.io/badge/Flutter-3.0+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?logo=mongodb&logoColor=white)](https://www.mongodb.com)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[🎥 **Demo Video**](#) | [📱 **Download APK**](#) | [🌐 **Live API**](#) | [📚 **Documentation**](#api-documentation)

---

## ✨ **What Makes This Special?**

Unlike typical form fillers that just remember what you typed, Smart Form Auto-Filler **understands** your forms and **learns** from your behavior.
Traditional Form Filler Smart Form Auto-Filler
❌ Static field matching → ✅ Intelligent pattern recognition
❌ Manual data entry → ✅ AI-like synonym detection
❌ No learning capability → ✅ Adaptive learning system
❌ Fixed field types → ✅ Unlimited custom fields
❌ No document processing → ✅ OCR-powered form extraction

text


---

## 🎯 **Core Features**

### 🧠 **Intelligent Field Mapping**
- **AI-like detection** with 85-100% accuracy
- **Synonym matching**: "Contact Number" → `phoneNumber`
- **Confidence scoring** for smart auto-fill
- **20+ pre-trained field patterns**

```javascript
// Example Detection
"Full Name"       → fullName      (100% confidence) ✅ Auto-fill
"Email ID"        → email         (95% confidence)  ✅ Auto-fill
"Phone No."       → phoneNumber   (85% confidence)  ✅ Auto-fill
"Employee ID"     → ???           (0% confidence)   ⚠️ Ask user
📄 OCR Document Processing
Upload PDF or images of forms
Tesseract.js powered text extraction
Pattern-based field detection
Automatically generates fillable forms
🔄 Adaptive Learning System
Learns from corrections: User edits → Profile updates
Mapping cache: 2nd use = instant fill (<10ms)
Chronological memory: Latest value always wins
Cross-form intelligence: Shares knowledge across all forms
👤 Unified Profile Memory
Single source of truth for user data
Merge-based updates (never loses data)
Nested object support (address with street/city/state)
Unlimited custom fields (dynamic schema)
📊 Smart Analytics
Field usage tracking
Mapping confidence visualization
Auto-fill percentage by form
Performance metrics
🚀 Quick Start
Prerequisites
Bash

Node.js >= 18.0.0
Flutter >= 3.0.0
MongoDB (Atlas recommended)
Backend Setup
Bash

cd smart-form-backend
npm install

# Create .env file
cp .env.example .env

# Add your credentials:
MONGODB_URI=mongodb+srv://your-connection-string
JWT_SECRET=your-super-secret-key
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-specific-password

# Start server
npm run dev
Server runs on: http://localhost:5000

Frontend Setup
Bash

cd smart_form_app
flutter pub get

# Update API URL in lib/core/constants/api_constants.dart
# For Android Emulator: http://10.0.2.2:5000/api
# For Web: http://localhost:5000/api

# Run app
flutter run -d chrome  # Web
flutter run            # Mobile
📐 Architecture
text

┌─────────────────────────────────────────────────────────┐
│                    FLUTTER APP                          │
│  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐  │
│  │  Auth   │  │  Forms  │  │  OCR    │  │ Profile │  │
│  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘  │
└───────┼───────────┼────────────┼────────────┼─────────┘
        │           │            │            │
        └───────────┴────────────┴────────────┘
                    │ REST API (JWT)
        ┌───────────▼────────────────────────┐
        │      NODE.JS + EXPRESS             │
        │  ┌──────────────────────────────┐  │
        │  │  Controllers                 │  │
        │  │  - Auth (OTP)                │  │
        │  │  - Profile (Merge)           │  │
        │  │  - Forms (Auto-fill)         │  │
        │  │  - Mapping (AI Detection)    │  │
        │  │  - Documents (OCR)           │  │
        │  └──────────────────────────────┘  │
        │  ┌──────────────────────────────┐  │
        │  │  Services                    │  │
        │  │  - Field Mapping Engine      │  │
        │  │  - OCR Processor             │  │
        │  │  - PDF Generator             │  │
        │  └──────────────────────────────┘  │
        └───────────┬────────────────────────┘
                    │ Mongoose ODM
        ┌───────────▼────────────────────────┐
        │         MONGODB ATLAS              │
        │  ┌────────────────────────────┐    │
        │  │  Collections:              │    │
        │  │  - users (Map schema)      │    │
        │  │  - forms (dynamic fields)  │    │
        │  │  - submissions (with PDFs) │    │
        │  │  - formmappings (cache)    │    │
        │  └────────────────────────────┘    │
        └────────────────────────────────────┘
🎯 How It Works
1. First Time: Learn & Map
text

User uploads form → OCR extracts fields → AI detects types
→ Maps to profile → Auto-fills known data → User fills unknown
→ Saves to profile + mapping cache
2. Second Time: Instant Fill
text

User opens similar form → Cache hit! → Instant auto-fill (<10ms)
→ User reviews → Submits → Updates profile if changed
3. Learning Cycle
JavaScript

// Day 1: User fills "Employee ID: EMP12345"
profile.employeeId = "EMP12345" ✅ Saved

// Day 7: New form has "Emp No."
System detects: "Emp No." → employeeId (cached)
Auto-fills: "EMP12345" ✅ Learned!
🛠️ Tech Stack
Backend
Technology	Purpose
Node.js + Express	REST API server
MongoDB (Mongoose)	Database with dynamic schemas
JWT	Stateless authentication
Tesseract.js	OCR text extraction
PDFKit	PDF generation
Nodemailer	OTP email delivery
Jimp	Image preprocessing
Frontend
Technology	Purpose
Flutter 3.0+	Cross-platform UI
Provider	State management
Dio	HTTP client
File Picker	Document upload
Image Picker	Camera integration
Shared Preferences	Local storage
📊 Performance Metrics
Metric	Value
API Response Time	50-100ms
Field Detection (first time)	60-100ms
Cached Mapping	<10ms
Auto-fill Accuracy	85-100%
OCR Processing	2-5 seconds
PDF Generation	200-500ms
📁 Project Structure
text

smart-form-filler/
├── smart-form-backend/          # Node.js Backend
│   ├── src/
│   │   ├── controllers/         # Business logic
│   │   ├── models/             # MongoDB schemas
│   │   ├── routes/             # API endpoints
│   │   ├── services/           # Core services
│   │   │   ├── ocr/           # OCR processing
│   │   │   ├── fieldMappingService.js
│   │   │   ├── pdfGenerator.js
│   │   │   └── otpService.js
│   │   ├── middleware/         # Auth, error handling
│   │   └── app.js
│   ├── package.json
│   └── server.js
│
└── smart_form_app/              # Flutter Frontend
    ├── lib/
    │   ├── core/               # Core functionality
    │   │   ├── constants/
    │   │   ├── models/
    │   │   ├── services/
    │   │   └── theme/
    │   ├── features/           # Feature modules
    │   │   ├── auth/
    │   │   ├── forms/
    │   │   ├── profile/
    │   │   ├── submissions/
    │   │   ├── documents/      # OCR upload
    │   │   └── mapping/        # Field mapping
    │   └── main.dart
    └── pubspec.yaml
🔌 API Documentation
Authentication
http

POST   /api/auth/send-otp
POST   /api/auth/verify-otp
GET    /api/auth/me
Profile
http

GET    /api/profile              # Get user profile
PUT    /api/profile              # Update (merge-based)
Forms
http

GET    /api/forms                # List all forms
GET    /api/forms/:formId        # Get form + auto-fill
POST   /api/forms                # Create form
Submissions
http

POST   /api/submissions          # Submit + update profile
GET    /api/submissions          # User's submissions
POST   /api/submissions/:id/pdf  # Generate PDF
GET    /api/submissions/:id/pdf/download
Mapping
http

POST   /api/mapping/detect       # Auto-detect mappings
POST   /api/mapping/save         # Save confirmed mapping
GET    /api/mapping/user         # Get cached mappings
Documents (OCR)
http

POST   /api/documents/upload     # Upload PDF/image
POST   /api/documents/create-form # Create form from OCR
🎓 What I Learned
Building adaptive systems without ML libraries
Implementing merge-based state management
Handling complex nested MongoDB updates
JWT authentication flows
Dynamic form rendering from schemas
OCR integration with preprocessing
Cross-platform mobile development
RESTful API design patterns
🚀 Future Enhancements
 Multi-language support
 Dark mode
 Offline support with sync
 Voice input for forms
 Advanced ML-based field detection
 Form template marketplace
 Data export (CSV, JSON)
 Browser extension
🐛 Known Issues
Web version doesn't support file upload (use mobile app)
OCR accuracy depends on image quality
Confidence scoring needs fine-tuning for edge cases
🤝 Contributing
Contributions welcome! Please read CONTRIBUTING.md first.

Fork the repository
Create your feature branch (git checkout -b feature/amazing-feature)
Commit your changes (git commit -m 'Add amazing feature')
Push to the branch (git push origin feature/amazing-feature)
Open a Pull Request
📄 License
This project is licensed under the MIT License - see the LICENSE file for details.

👨‍💻 Author
Raghavendra Singh
GitHub | LinkedIn | Email

🙏 Acknowledgments
Tesseract.js for OCR capabilities
Flutter team for amazing framework
MongoDB for flexible database
Open source community
⭐ Star this repo if you found it helpful!
Built with ❤️ using Flutter and Node.js
