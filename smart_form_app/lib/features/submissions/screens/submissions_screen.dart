import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../providers/submissions_provider.dart';

class SubmissionsScreen extends StatefulWidget {
  const SubmissionsScreen({super.key});

  @override
  State<SubmissionsScreen> createState() => _SubmissionsScreenState();
}

class _SubmissionsScreenState extends State<SubmissionsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SubmissionsProvider>().loadSubmissions();
    });
  }

  void _showPdfUrl(String pdfUrl) {
    final fullUrl = pdfUrl.startsWith('http') 
        ? pdfUrl 
        : 'http://localhost:5000$pdfUrl';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Generated'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your PDF is ready!'),
            const SizedBox(height: 16),
            const Text('Click the link below to open:'),
            const SizedBox(height: 8),
            SelectableText(
              fullUrl,
              style: const TextStyle(
                color: AppConstants.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Copy to clipboard would go here
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Open this link: $fullUrl')),
              );
              Navigator.pop(context);
            },
            child: const Text('Copy Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubmissionsProvider>(
      builder: (context, submissionsProvider, _) {
        if (submissionsProvider.isLoading) {
          return const LoadingIndicator(message: 'Loading submissions...');
        }

        if (submissionsProvider.submissions.isEmpty) {
          return const EmptyState(
            icon: Icons.inbox_outlined,
            title: 'No Submissions Yet',
            subtitle: 'Fill and submit a form to see it here',
          );
        }

        return RefreshIndicator(
          onRefresh: () => submissionsProvider.loadSubmissions(),
          child: ListView.builder(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            itemCount: submissionsProvider.submissions.length,
            itemBuilder: (context, index) {
              final submission = submissionsProvider.submissions[index];
              final pdfUrl = submission.pdfUrl != null
                  ? (submission.pdfUrl!.startsWith('http')
                      ? submission.pdfUrl!
                      : 'http://localhost:5000${submission.pdfUrl}')
                  : null;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppConstants.spacingS),
                            decoration: BoxDecoration(
                              gradient: AppConstants.primaryGradient,
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            ),
                            child: const Icon(
                              Icons.description,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppConstants.spacingM),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  submission.formTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('MMM dd, yyyy • HH:mm')
                                      .format(submission.createdAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppConstants.spacingS,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppConstants.successColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(AppConstants.radiusS),
                            ),
                            child: Text(
                              submission.status.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppConstants.successColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppConstants.spacingM),
                      if (pdfUrl != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () => _showPdfUrl(pdfUrl),
                              icon: const Icon(Icons.picture_as_pdf, size: 18),
                              label: const Text('View PDF'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppConstants.errorColor,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spacingS),
                            Container(
                              padding: const EdgeInsets.all(AppConstants.spacingS),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(AppConstants.radiusS),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.link, size: 16, color: Colors.grey),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      pdfUrl,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey[700],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: () async {
                            final newPdfUrl = await submissionsProvider
                                .generatePDF(submission.id);
                            if (newPdfUrl != null && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('PDF generated successfully!'),
                                  backgroundColor: AppConstants.successColor,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text('Generate PDF'),
                        ),
                    ],
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
