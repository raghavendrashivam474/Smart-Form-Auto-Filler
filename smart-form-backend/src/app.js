const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');

const authRoutes = require('./routes/auth');
const profileRoutes = require('./routes/profile');
const formRoutes = require('./routes/forms');
const submissionRoutes = require('./routes/submissions');
const mappingRoutes = require('./routes/mapping');
const documentRoutes = require('./routes/documents'); // ✅ NEW

const errorHandler = require('./middleware/errorHandler');

const app = express();

// Security middleware
app.use(helmet({
  crossOriginResourcePolicy: false,
}));

// CORS configuration - Allow all origins for development
app.use(cors({
  origin: true,
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

app.use(morgan('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

// Root route
app.get('/', (req, res) => {
  res.json({
    name: 'Smart Form Filler API',
    version: '1.0.0',
    status: 'running',
    endpoints: {
      api: '/api',
      health: '/health'
    }
  });
});

// API Welcome Route
app.get('/api', (req, res) => {
  res.json({
    success: true,
    message: 'Smart Form Filler API',
    version: '1.0.0',
    endpoints: {
      auth: {
        requestOtp: 'POST /api/auth/request-otp',
        verifyOtp: 'POST /api/auth/verify-otp',
        login: 'POST /api/auth/login',
        me: 'GET /api/auth/me'
      },
      profile: {
        get: 'GET /api/profile',
        update: 'PUT /api/profile'
      },
      forms: {
        getAll: 'GET /api/forms',
        getOne: 'GET /api/forms/:formId'
      },
      submissions: {
        submit: 'POST /api/submissions',
        getAll: 'GET /api/submissions',
        getOne: 'GET /api/submissions/:id',
        generatePDF: 'POST /api/submissions/:id/pdf',
        downloadPDF: 'GET /api/submissions/:id/pdf/download',
        analytics: 'GET /api/submissions/analytics/fields'
      },
      mapping: {
        detect: 'POST /api/mapping/detect',
        save: 'POST /api/mapping/save',
        getUserMappings: 'GET /api/mapping/user'
      },
      documents: { // ✅ NEW
        upload: 'POST /api/documents/upload',
        createForm: 'POST /api/documents/create-form'
      }
    },
    documentation: 'See README for full API documentation',
    health: '/health'
  });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/profile', profileRoutes);
app.use('/api/forms', formRoutes);
app.use('/api/submissions', submissionRoutes);
app.use('/api/mapping', mappingRoutes);
app.use('/api/documents', documentRoutes); // ✅ NEW

// Health check
app.get('/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Smart Form Backend is running',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV,
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
    path: req.originalUrl,
  });
});

// Error handler
app.use(errorHandler);

module.exports = app;