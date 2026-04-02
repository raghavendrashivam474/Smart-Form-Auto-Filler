import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/forms_provider.dart';
import 'form_fill_screen.dart';

class FormsListScreen extends StatefulWidget {
  const FormsListScreen({super.key});

  @override
  State<FormsListScreen> createState() => _FormsListScreenState();
}

class _FormsListScreenState extends State<FormsListScreen> {
  @override
  void initState() {
    super.initState();
    _loadForms();
  }

  Future<void> _loadForms() async {
    await context.read<FormsProvider>().loadForms();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<FormsProvider>(
      builder: (context, formsProvider, _) {
        if (formsProvider.isLoading) {
          return const LoadingIndicator(message: 'Loading forms...');
        }

        if (formsProvider.forms.isEmpty) {
          return EmptyState(
            icon: Icons.description_outlined,
            title: 'No Forms Available',
            subtitle: 'Check back later for new forms',
          );
        }

        return RefreshIndicator(
          onRefresh: _loadForms,
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            itemCount: formsProvider.forms.length,
            itemBuilder: (context, index) {
              final form = formsProvider.forms[index];
              return Card(
                child: InkWell(
                  onTap: () async {
                    // Navigate and wait for result
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FormFillScreen(formId: form.formId),
                      ),
                    );
                    
                    // Reload forms after returning to refresh auto-fill stats
                    if (mounted) {
                      _loadForms();
                    }
                  },
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  child: Padding(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppConstants.spacingM),
                              decoration: BoxDecoration(
                                gradient: AppConstants.primaryGradient,
                                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                              ),
                              child: const Icon(
                                Icons.description,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: AppConstants.spacingM),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    form.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${form.fields.length} fields',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: AppConstants.primaryColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppConstants.spacingM),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                            vertical: AppConstants.spacingS,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: AppConstants.primaryColor,
                              ),
                              const SizedBox(width: AppConstants.spacingS),
                              Text(
                                'Smart Auto-Fill Available',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
