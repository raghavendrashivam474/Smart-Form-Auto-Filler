import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/document_service.dart';
import 'field_detection_screen.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({Key? key}) : super(key: key);

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final DocumentService _documentService = DocumentService();
  final ImagePicker _imagePicker = ImagePicker();
  
  bool _isProcessing = false;
  File? _selectedFile;
  FilePickerResult? _pickerResult;
  String? _error;

  Future<void> _pickFile() async {
    try {
      // Use FilePicker correctly
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        withData: kIsWeb,
      );

      if (result != null) {
        setState(() {
          _pickerResult = result;
          if (!kIsWeb && result.files.single.path != null) {
            _selectedFile = File(result.files.single.path!);
          }
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to pick file: $e';
      });
      print('File picker error: $e');
    }
  }

  Future<void> _takePhoto() async {
    if (kIsWeb) {
      setState(() {
        _error = 'Camera not available on web. Please upload a file.';
      });
      return;
    }

    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _selectedFile = File(photo.path);
          _pickerResult = null;
          _error = null;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to take photo: $e';
      });
      print('Camera error: $e');
    }
  }

  Future<void> _processDocument() async {
    if (_selectedFile == null) {
      setState(() {
        _error = 'Please select a file first';
      });
      return;
    }

    if (kIsWeb) {
      setState(() {
        _error = 'Document upload is only available on mobile. Please use the mobile app.';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _error = null;
    });

    try {
      print('📤 Starting upload...');
      final result = await _documentService.uploadDocument(_selectedFile!);
      
      print('✅ Upload successful');
      
      setState(() {
        _isProcessing = false;
      });

      // Navigate to field detection screen
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FieldDetectionScreen(
              analysisResult: result['data'],
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Upload error: $e');
      setState(() {
        _isProcessing = false;
        _error = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  String get _fileName {
    if (_selectedFile != null) {
      return _selectedFile!.path.split('/').last;
    }
    if (_pickerResult != null) {
      return _pickerResult!.files.first.name;
    }
    return '';
  }

  int? get _fileSize {
    if (_selectedFile != null) {
      return _selectedFile!.lengthSync();
    }
    if (_pickerResult != null) {
      return _pickerResult!.files.first.size;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasFile = _selectedFile != null || _pickerResult != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Document'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            const Icon(
              Icons.document_scanner,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload Form Document',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              kIsWeb 
                  ? 'Feature available on mobile app only'
                  : 'Take a photo or upload a PDF/image of your form',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: kIsWeb ? Colors.red : Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // Upload options
            if (!kIsWeb) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _pickFile,
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.all(16),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Web message
            if (kIsWeb) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Document upload requires mobile app. Download the APK or run on Android/iOS.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Selected file preview
            if (hasFile) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 48),
                    const SizedBox(height: 8),
                    Text(
                      'Selected: $_fileName',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (_fileSize != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${(_fileSize! / 1024).toStringAsFixed(2)} KB',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Process button
              ElevatedButton(
                onPressed: _isProcessing ? null : _processDocument,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: _isProcessing
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Processing...'),
                        ],
                      )
                    : const Text(
                        'Process Document',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ],

            // Error message
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[300]!),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Instructions
            if (!kIsWeb)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Tips for best results:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('Use good lighting'),
                    _buildTip('Keep text clear and readable'),
                    _buildTip('Avoid shadows and glare'),
                    _buildTip('Supported: PDF, JPG, PNG'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 4),
      child: Row(
        children: [
          const Icon(Icons.check, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}