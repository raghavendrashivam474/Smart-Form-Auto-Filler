import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/forms_provider.dart';
import '../../submissions/providers/submissions_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../mapping/providers/mapping_provider.dart';
import '../../mapping/screens/mapping_confirmation_screen.dart';

class FormFillScreen extends StatefulWidget {
  final String formId;

  const FormFillScreen({super.key, required this.formId});

  @override
  State<FormFillScreen> createState() => _FormFillScreenState();
}

class _FormFillScreenState extends State<FormFillScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};
  bool _isSubmitting = false;
  bool _isMappingDetected = false;
  Map<String, String>? _fieldMapping;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFormWithMapping();
    });
  }

  // ✅ HELPER - Convert any map to Map<String, dynamic> safely
  Map<String, dynamic> _safeMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }

  // ✅ HELPER - Get profile as safe Map
  Map<String, dynamic> _getProfileMap(dynamic profile) {
    if (profile == null) return {};
    
    try {
      // Try toJson() if available
      if (profile is Map) {
        return Map<String, dynamic>.from(profile);
      }
      
      // Check if profile has toJson method
      final json = profile.toJson();
      if (json is Map) {
        return Map<String, dynamic>.from(json);
      }
      return {};
    } catch (e) {
      print('⚠️ Error converting profile to Map: $e');
      return {};
    }
  }

  Future<void> _loadFormWithMapping() async {
    final formsProvider = context.read<FormsProvider>();
    final profileProvider = context.read<ProfileProvider>();
    final mappingProvider = context.read<MappingProvider>();

    // 1. Load form
    await formsProvider.loadForm(widget.formId);
    final form = formsProvider.currentForm;

    if (form == null) {
      if (mounted) setState(() {});
      return;
    }

    // 2. Load profile
    await profileProvider.loadProfile();
    final profile = profileProvider.profile;

    // 3. Prepare fields for mapping detection
    final fields = form.fields.map((field) => {
      'key': field.id,
      'label': field.label,
      'type': field.type,
    }).toList();

    // 4. Detect mapping
    print('🔍 Detecting mapping for ${fields.length} fields...');
    final mappingResult = await mappingProvider.detectMapping(fields);

    if (mappingResult != null) {
      // ✅ FIXED - Use _safeMap to handle _JsonMap
      final result = _safeMap(mappingResult);
      final needsConfirmation = (result['needsConfirmation'] as List?) ?? [];
      final detectedMapping = _safeMap(result['mapping']);
      final formHash = result['formHash']?.toString() ?? '';
      final isCached = result['cached'] == true;

      print('📊 Mapping detection result:');
      print('   Cached: $isCached');
      print('   Auto-mapped: ${detectedMapping.length}');
      print('   Needs confirmation: ${needsConfirmation.length}');

      // 5. Show mapping confirmation if needed
      if (needsConfirmation.isNotEmpty && !isCached && mounted) {
        // ✅ FIXED - Use _getProfileMap for safe conversion
        final profileMap = _getProfileMap(profile);
        
        final confirmedMapping = await Navigator.push<Map<String, String>>(
          context,
          MaterialPageRoute(
            builder: (context) => MappingConfirmationScreen(
              formName: form.name,
              fields: fields,
              detectedMapping: detectedMapping,
              needsConfirmation: needsConfirmation,
              profile: profileMap,
            ),
          ),
        );

        if (confirmedMapping == null) {
          if (mounted) Navigator.pop(context);
          return;
        }

        await mappingProvider.saveMapping(
          formHash,
          form.name,
          confirmedMapping,
        );

        _fieldMapping = confirmedMapping;
      } else {
        _fieldMapping = _convertDetectedMapping(detectedMapping);

        if (!isCached && formHash.isNotEmpty) {
          await mappingProvider.saveMapping(
            formHash,
            form.name,
            _fieldMapping!,
          );
        }
      }

      _isMappingDetected = true;

      // ✅ FIXED - Use _getProfileMap for safe conversion
      if (_fieldMapping != null && profile != null) {
        final profileMap = _getProfileMap(profile);
        _applyAutoFillWithMapping(profileMap);
      }
    }

    // Initialize controllers
    for (var field in form.fields) {
      if (!_controllers.containsKey(field.id)) {
        _controllers[field.id] = TextEditingController(
          text: field.value?.toString() ?? '',
        );
      }
    }

    if (mounted) setState(() {});
  }

  Map<String, String> _convertDetectedMapping(Map<String, dynamic> detectedMapping) {
    Map<String, String> result = {};
    
    detectedMapping.forEach((fieldKey, value) {
      if (value is Map) {
        final safeValue = _safeMap(value);
        if (safeValue.containsKey('profileKey')) {
          result[fieldKey] = safeValue['profileKey']?.toString() ?? '';
        }
      } else if (value is String) {
        result[fieldKey] = value;
      }
    });
    
    return result;
  }

  void _applyAutoFillWithMapping(Map<String, dynamic> profile) {
    if (_fieldMapping == null) return;

    final formsProvider = context.read<FormsProvider>();

    _fieldMapping!.forEach((fieldKey, profileKey) {
      if (profile.containsKey(profileKey)) {
        final value = profile[profileKey];
        final stringValue = value?.toString() ?? '';
        
        formsProvider.updateFieldValue(fieldKey, stringValue);
        
        if (_controllers.containsKey(fieldKey)) {
          _controllers[fieldKey]?.text = stringValue;
        }
        
        print('✅ Auto-filled: $fieldKey ← $stringValue (from $profileKey)');
      }
    });
  }

  // ✅ FIXED - Save form edits back to profile with proper type handling
  Future<void> _updateProfileFromForm(Map<String, dynamic> formData) async {
    if (_fieldMapping == null) return;

    final profileProvider = context.read<ProfileProvider>();
    Map<String, dynamic> profileUpdates = {};

    // ✅ FIXED - Convert to safe Map
    final safeFormData = _safeMap(formData);

    _fieldMapping!.forEach((fieldKey, profileKey) {
      if (safeFormData.containsKey(fieldKey)) {
        final value = safeFormData[fieldKey];
        if (value != null && value.toString().isNotEmpty) {
          // ✅ Ensure value is a String
          profileUpdates[profileKey] = value.toString();
        }
      }
    });

    if (profileUpdates.isNotEmpty) {
      try {
        await profileProvider.updateProfile(profileUpdates);
        print('✅ Profile updated with form edits: ${profileUpdates.keys.join(", ")}');
      } catch (e) {
        print('⚠️ Failed to update profile: $e');
      }
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final formsProvider = context.read<FormsProvider>();
        final submissionsProvider = context.read<SubmissionsProvider>();

        // ✅ FIXED - Get form data and convert safely
        final rawFormData = formsProvider.getFormData();
        final formData = _safeMap(rawFormData);

        // ✅ SAVE USER EDITS BACK TO PROFILE (Memory Override)
        await _updateProfileFromForm(formData);

        // Submit form
        final submission = await submissionsProvider.submitForm(
          widget.formId,
          formData,
        );

        if (submission != null && mounted) {
          // Generate PDF
          await submissionsProvider.generatePDF(submission.id);

          // Navigate back to forms list
          Navigator.of(context).pop();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '✅ Form submitted & profile updated!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppConstants.successColor,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );

          // Reload forms to show updated data
          formsProvider.loadForms();
        } else {
          throw Exception('Submission failed');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Error: ${e.toString()}'),
              backgroundColor: AppConstants.errorColor,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSubmitting = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill Form'),
        actions: [
          if (_isMappingDetected)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.smart_toy,
                        size: 16,
                        color: AppConstants.successColor,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Smart Fill',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppConstants.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Consumer<FormsProvider>(
        builder: (context, formsProvider, _) {
          if (formsProvider.isLoading) {
            return const LoadingIndicator(message: 'Loading form...');
          }

          final form = formsProvider.currentForm;
          if (form == null) {
            return const Center(child: Text('Form not found'));
          }

          return Column(
            children: [
              // Auto-Fill Stats Banner
              if (form.stats != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppConstants.successColor.withOpacity(0.1),
                        AppConstants.primaryColor.withOpacity(0.1),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: AppConstants.primaryColor,
                        size: 30,
                      ),
                      const SizedBox(width: AppConstants.spacingM),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${form.stats!.percentage}% Auto-Filled!',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.primaryColor,
                              ),
                            ),
                            Text(
                              '${form.stats!.autoFilled} of ${form.stats!.totalFields} fields',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isMappingDetected)
                        const Tooltip(
                          message: 'Intelligent field mapping active',
                          child: Icon(
                            Icons.psychology,
                            color: AppConstants.primaryColor,
                            size: 24,
                          ),
                        ),
                    ],
                  ),
                ),

              // Form Fields
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    itemCount: form.fields.length,
                    itemBuilder: (context, index) {
                      final field = form.fields[index];
                      return _buildFormField(field, formsProvider);
                    },
                  ),
                ),
              ),

              // Submit Button
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingM),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: CustomButton(
                    text: _isSubmitting ? 'Submitting...' : 'Submit Form',
                    onPressed: _isSubmitting ? () {} : _submitForm,
                    isLoading: _isSubmitting,
                    icon: Icons.send,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormField(dynamic field, FormsProvider formsProvider) {
    if (!_controllers.containsKey(field.id)) {
      _controllers[field.id] = TextEditingController(
        text: field.value?.toString() ?? '',
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  field.label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (field.autoFilled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spacingS,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppConstants.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusS),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppConstants.successColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Auto-filled',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spacingS),
          if (field.type == 'date')
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: field.value != null
                      ? DateTime.tryParse(field.value.toString()) ?? DateTime.now()
                      : DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  final dateStr = DateFormat('yyyy-MM-dd').format(date);
                  formsProvider.updateFieldValue(field.id, dateStr);
                  _controllers[field.id]?.text = dateStr;
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  suffixIcon: const Icon(Icons.calendar_today),
                  filled: field.autoFilled,
                  fillColor: field.autoFilled
                      ? AppConstants.successColor.withOpacity(0.05)
                      : Colors.grey[50],
                ),
                child: Text(
                  _controllers[field.id]?.text.isEmpty ?? true
                      ? 'Select date'
                      : _controllers[field.id]!.text,
                  style: TextStyle(
                    color: _controllers[field.id]?.text.isEmpty ?? true
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ),
            )
          else
            TextFormField(
              controller: _controllers[field.id],
              keyboardType: field.type == 'number'
                  ? TextInputType.number
                  : field.type == 'email'
                      ? TextInputType.emailAddress
                      : field.type == 'tel'
                          ? TextInputType.phone
                          : TextInputType.text,
              maxLines: field.type == 'textarea' ? 3 : 1,
              decoration: InputDecoration(
                hintText: 'Enter ${field.label.toLowerCase()}',
                filled: field.autoFilled,
                fillColor: field.autoFilled
                    ? AppConstants.successColor.withOpacity(0.05)
                    : Colors.grey[50],
              ),
              validator: (value) {
                if (field.required && (value?.isEmpty ?? true)) {
                  return 'This field is required';
                }
                return null;
              },
              onChanged: (value) {
                formsProvider.updateFieldValue(field.id, value);
              },
            ),
        ],
      ),
    );
  }
}