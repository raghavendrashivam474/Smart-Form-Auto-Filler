import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/forms_provider.dart';
import '../../submissions/providers/submissions_provider.dart';
import '../../submissions/screens/submissions_screen.dart';

class FormFillScreen extends StatefulWidget {
  final String formId;

  const FormFillScreen({super.key, required this.formId});

  @override
  State<FormFillScreen> createState() => _FormFillScreenState();
}

class _FormFillScreenState extends State<FormFillScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<FormsProvider>().loadForm(widget.formId);
    });
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
      final formsProvider = context.read<FormsProvider>();
      final submissionsProvider = context.read<SubmissionsProvider>();

      final formData = formsProvider.getFormData();

      final submission = await submissionsProvider.submitForm(
        widget.formId,
        formData,
      );

      if (submission != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Form submitted successfully!'),
            backgroundColor: AppConstants.successColor,
          ),
        );

        // Generate PDF
        await submissionsProvider.generatePDF(submission.id);

        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SubmissionsScreen()),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(submissionsProvider.error ?? 'Submission failed'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fill Form'),
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

          // Initialize controllers
          for (var field in form.fields) {
            if (!_controllers.containsKey(field.id)) {
              _controllers[field.id] = TextEditingController(
                text: field.value?.toString() ?? '',
              );
            }
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
                              '${form.stats!.autoFilled} of ${form.stats!.totalFields} fields pre-filled',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
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
                  child: Consumer<SubmissionsProvider>(
                    builder: (context, submissionsProvider, _) {
                      return CustomButton(
                        text: 'Submit Form',
                        onPressed: _submitForm,
                        isLoading: submissionsProvider.isLoading,
                        icon: Icons.send,
                      );
                    },
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
                      ? DateTime.parse(field.value)
                      : DateTime.now(),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  formsProvider.updateFieldValue(
                    field.id,
                    date.toIso8601String(),
                  );
                  _controllers[field.id]?.text = DateFormat('yyyy-MM-dd').format(date);
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
