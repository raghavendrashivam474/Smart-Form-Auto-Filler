# 🚀 Smart Form Auto-Filler

> Fill once. Use everywhere.

Smart Form Auto-Filler is a full-stack mobile application designed to eliminate repetitive form filling by allowing users to store personal data and documents once, and reuse them across multiple forms such as scholarships, admissions, and job applications.

---

## 📌 Features

### 🧠 Smart Auto-Fill

* Automatically fills form fields using stored user profile data
* Reduces manual input effort significantly

### 📄 Dynamic Form System

* Schema-driven forms (JSON-based)
* Supports multiple forms without hardcoding UI

### 👤 User Profile Management

* Centralized storage of personal data
* Incrementally updated with new inputs

### 📂 Document Vault

* Upload and reuse documents (e.g., income certificate, ID proof)
* Tag-based organization for easy retrieval

### 🧠 Adaptive Learning

* Tracks frequently used fields
* Promotes important fields into onboarding over time

### 📄 PDF Generation

* Generate downloadable, structured documents from filled forms

---

## 🏗️ Architecture Overview

```plaintext
Mobile App (Flutter)
        ↓
REST API (Node.js + Express)
        ↓
Database (MongoDB)
        ↓
File Storage (Local/Cloud)
```

---

## ⚙️ Tech Stack

### Frontend

* Flutter

### Backend

* Node.js
* Express.js

### Database

* MongoDB (Atlas)

### Other Tools

* JWT Authentication
* Multer (file uploads)
* PDF generation libraries

---

## 🔄 Application Flow

```plaintext
User Login →
Profile Setup →
Select Form →
Auto-Fill Fields →
Fill Missing Data →
Upload/Attach Documents →
Submit Form →
Generate PDF →
Adaptive Learning Updates Profile
```

---

## 📡 API Endpoints (Backend)

### Authentication

* `POST /api/auth/login`
* `GET /api/auth/me`

### Profile

* `GET /api/profile`
* `PUT /api/profile`

### Forms

* `GET /api/forms`
* `GET /api/forms/:formId`

### Submissions

* `POST /api/submissions`
* `GET /api/submissions`
* `GET /api/submissions/:id`
* `DELETE /api/submissions/:id`

### PDF

* `POST /api/submissions/:id/pdf`
* `GET /api/submissions/:id/pdf/download`

### Analytics

* `GET /api/submissions/analytics/fields`

---

## 📂 Project Structure

```plaintext
backend/
├── controllers/
├── models/
├── routes/
├── middleware/
├── utils/
├── uploads/
├── config/
└── server.js

frontend/
├── screens/
├── widgets/
├── services/
└── main.dart
```

---

## ⚡ Getting Started

### Backend Setup

```bash
git clone <repo-url>
cd backend
npm install
npm run dev
```

### Frontend Setup

```bash
cd frontend
flutter pub get
flutter run
```

---

## 🔐 Security Features

* JWT-based authentication
* Password hashing (bcrypt)
* Input validation
* Secure API structure

---

## 📊 Current Status

* ✅ Core backend complete
* ✅ Dynamic form system working
* ✅ Auto-fill engine implemented
* ✅ Document handling (basic)
* ✅ UI screens (Forms, History, Profile)
* 🔄 Ongoing: UI polish and feature integration

---

## 🚀 Future Enhancements

* Real OTP authentication (Twilio)
* Cloud storage integration
* Advanced document recognition (AI/OCR)
* Search & filter forms
* Admin dashboard

---

## 💡 Use Cases

* Students applying for scholarships
* Job seekers filling applications
* Users applying for government schemes

---

## 🧠 Key Highlights

* Schema-driven architecture
* Adaptive learning system
* Reusable data + document model
* Optimized for speed and usability

---

## 🤝 Contributing

Contributions are welcome! Feel free to fork the repo and submit a PR.

---

## 📄 License

This project is licensed under the MIT License.

---

## 👨‍💻 Author

Developed by Raghav
