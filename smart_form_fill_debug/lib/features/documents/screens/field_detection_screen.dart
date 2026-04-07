import 'package:flutter/material.dart';
import '../../forms/screens/forms_list_screen.dart';

class FieldDetectionScreen extends StatelessWidget {
  final Map<String, dynamic> analysisResult;

  const FieldDetectionScreen({
    Key? key,
    required this.analysisResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final analysis = analysisResult['analysis'] as Map<String, dynamic>;
    final fields = analysis['fields'] as List<dynamic>;
    final totalFields = analysis['totalFields'] as int;
    final confidence = analysis['confidence'] as int;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detected Fields'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue[600]!, Colors.blue[800]!],
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Document Processed!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalFields fields detected',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confidence: $confidence%',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Fields list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: fields.length,
              itemBuilder: (context, index) {
                final field = fields[index] as Map<String, dynamic>;
                final label = field['label'] as String;
                final type = field['type'] as String;
                final profileKey = field['profileKey'] as String?;
                final fieldConfidence = field['confidence'] as int? ?? 85;

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getTypeColor(type).withOpacity(0.2),
                      child: Icon(
                        _getTypeIcon(type),
                        color: _getTypeColor(type),
                      ),
                    ),
                    title: Text(
                      label,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text('Type: $type'),
                        if (profileKey != null)
                          Text(
                            'Maps to: $profileKey',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                            ),
                          ),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getConfidenceColor(fieldConfidence),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$fieldConfidence%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Action button
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Create form from fields
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormsListScreen(),
                    ),
                    (route) => route.isFirst,
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'Create Form & Auto-Fill',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'email':
        return Icons.email;
      case 'tel':
        return Icons.phone;
      case 'date':
        return Icons.calendar_today;
      case 'number':
        return Icons.numbers;
      case 'textarea':
        return Icons.notes;
      case 'select':
        return Icons.arrow_drop_down_circle;
      default:
        return Icons.text_fields;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'email':
        return Colors.red;
      case 'tel':
        return Colors.green;
      case 'date':
        return Colors.blue;
      case 'number':
        return Colors.orange;
      case 'textarea':
        return Colors.purple;
      case 'select':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  Color _getConfidenceColor(int confidence) {
    if (confidence >= 90) return Colors.green;
    if (confidence >= 70) return Colors.orange;
    return Colors.red;
  }
}