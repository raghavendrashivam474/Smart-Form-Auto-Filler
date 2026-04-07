import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class MappingConfirmationScreen extends StatefulWidget {
  final String formName;
  final List<dynamic> fields;
  final Map<String, dynamic> detectedMapping;
  final List<dynamic> needsConfirmation;
  final Map<String, dynamic> profile;

  MappingConfirmationScreen({
    required this.formName,
    required this.fields,
    required this.detectedMapping,
    required this.needsConfirmation,
    required this.profile,
  });

  @override
  _MappingConfirmationScreenState createState() =>
      _MappingConfirmationScreenState();
}

class _MappingConfirmationScreenState
    extends State<MappingConfirmationScreen> {
  late Map<String, String> finalMapping;
  late Map<String, bool> userConfirmed;
  late List<String> availableProfileKeys; // ✅ Now mutable

  @override
  void initState() {
    super.initState();

    // Initialize final mapping from detected mapping
    finalMapping = {};
    userConfirmed = {};

    // ✅ Initialize with default keys + any from profile
    availableProfileKeys = [
      'fullName',
      'email',
      'phoneNumber',
      'dateOfBirth',
      'address',
      'city',
      'state',
      'pincode',
      'gender',
      'category',
      'annual_income',
    ];

    // ✅ Add any extra keys from user's existing profile
    widget.profile.keys.forEach((key) {
      if (!availableProfileKeys.contains(key) && key != 'address') {
        availableProfileKeys.add(key);
      }
    });

    // Convert detected mapping to simple key-value
    widget.detectedMapping.forEach((fieldKey, mappingData) {
      if (mappingData is Map && mappingData.containsKey('profileKey')) {
        finalMapping[fieldKey] = mappingData['profileKey'];
        userConfirmed[fieldKey] = mappingData['autoMapped'] == true;
      }
    });
  }

  bool get allFieldsMapped {
    return widget.fields.every((field) =>
        finalMapping.containsKey(field['key']) &&
        finalMapping[field['key']]!.isNotEmpty);
  }

  // ✅ NEW - Show dialog to add custom field
  Future<String?> _showAddCustomFieldDialog(String suggestedName) async {
    final controller = TextEditingController(text: suggestedName);
    
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Custom Field'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Create a new profile field to store this data:',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Field Name',
                hintText: 'e.g., employeeId, fatherName',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
              textInputAction: TextInputAction.done,
              onSubmitted: (value) {
                if (value.trim().isNotEmpty) {
                  Navigator.pop(context, value.trim());
                }
              },
            ),
            SizedBox(height: 8),
            Text(
              '💡 Use camelCase (e.g., employeeId, fatherName)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                Navigator.pop(context, value);
              }
            },
            child: Text('Add Field'),
          ),
        ],
      ),
    );
  }

  // ✅ Convert field label to suggested key name
  String _generateSuggestedKey(String label) {
    // Convert "Employee ID" -> "employeeId"
    final words = label
        .replaceAll(RegExp(r'[^a-zA-Z0-9\s]'), '')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    
    if (words.isEmpty) return 'customField';
    
    final first = words.first.toLowerCase();
    final rest = words.skip(1).map((w) => 
        w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1).toLowerCase()
    ).join('');
    
    return first + rest;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirm Field Mapping'),
      ),
      body: Column(
        children: [
          // Header
          _buildHeader(),

          // Mapping List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: widget.fields.length,
              itemBuilder: (context, index) {
                final field = widget.fields[index];
                final fieldKey = field['key'];
                final fieldLabel = field['label'];
                final isAutoMapped = userConfirmed[fieldKey] ?? false;
                final currentMapping = finalMapping[fieldKey];

                final needsConfirmation = widget.needsConfirmation
                    .any((item) => item['fieldKey'] == fieldKey);

                return _buildMappingCard(
                  fieldKey: fieldKey,
                  fieldLabel: fieldLabel,
                  currentMapping: currentMapping,
                  isAutoMapped: isAutoMapped,
                  needsConfirmation: needsConfirmation,
                );
              },
            ),
          ),

          // Bottom Action Bar
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.formName,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Match form fields to your profile data',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          if (widget.needsConfirmation.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.warningColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 16,
                    color: AppTheme.warningColor,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '${widget.needsConfirmation.length} field${widget.needsConfirmation.length > 1 ? 's' : ''} need manual mapping',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.warningColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMappingCard({
    required String fieldKey,
    required String fieldLabel,
    String? currentMapping,
    required bool isAutoMapped,
    required bool needsConfirmation,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: needsConfirmation
              ? AppTheme.warningColor.withOpacity(0.3)
              : AppTheme.borderColor,
          width: needsConfirmation ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field Label
            Row(
              children: [
                Expanded(
                  child: Text(
                    fieldLabel,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                if (isAutoMapped) ...[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 12,
                          color: AppTheme.successColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Auto',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            SizedBox(height: 12),

            // ✅ UPDATED - Mapping Dropdown with Custom Option
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: availableProfileKeys.contains(currentMapping) 
                        ? currentMapping 
                        : null,
                    decoration: InputDecoration(
                      labelText: 'Map to profile field',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: null,
                        child: Text('-- Select field --',
                            style: TextStyle(color: Colors.grey)),
                      ),
                      ...availableProfileKeys.map((key) {
                        return DropdownMenuItem(
                          value: key,
                          child: Row(
                            children: [
                              Icon(
                                _getIconForProfileKey(key),
                                size: 16,
                                color: AppTheme.textSecondary,
                              ),
                              SizedBox(width: 8),
                              Text(_formatProfileKey(key)),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() {
                        if (value != null) {
                          finalMapping[fieldKey] = value;
                          userConfirmed[fieldKey] = false;
                        } else {
                          finalMapping.remove(fieldKey);
                        }
                      });
                    },
                  ),
                ),
                
                // ✅ ADD CUSTOM FIELD BUTTON
                SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    final suggestedKey = _generateSuggestedKey(fieldLabel);
                    final customKey = await _showAddCustomFieldDialog(suggestedKey);
                    
                    if (customKey != null && customKey.isNotEmpty) {
                      setState(() {
                        // Add to available keys if not exists
                        if (!availableProfileKeys.contains(customKey)) {
                          availableProfileKeys.add(customKey);
                        }
                        // Map to this custom key
                        finalMapping[fieldKey] = customKey;
                        userConfirmed[fieldKey] = false;
                      });
                    }
                  },
                  icon: Icon(Icons.add_circle_outline),
                  tooltip: 'Add custom field',
                  color: AppTheme.primaryColor,
                ),
              ],
            ),

            // ✅ Show custom field badge if using custom key
            if (currentMapping != null && 
                !['fullName', 'email', 'phoneNumber', 'dateOfBirth', 
                  'address', 'city', 'state', 'pincode', 'gender', 
                  'category', 'annual_income'].contains(currentMapping)) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.star, size: 12, color: AppTheme.primaryColor),
                    SizedBox(width: 4),
                    Text(
                      'Custom field: $currentMapping',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Preview value from profile
            if (currentMapping != null &&
                widget.profile.containsKey(currentMapping)) ...[
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.preview,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Value: ',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.profile[currentMapping].toString(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppTheme.borderColor),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: AppTheme.borderColor),
                ),
                child: Text('Cancel'),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: allFieldsMapped ? _confirmMapping : null,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Confirm & Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForProfileKey(String key) {
    switch (key) {
      case 'fullName':
        return Icons.person;
      case 'email':
        return Icons.email;
      case 'phoneNumber':
        return Icons.phone;
      case 'dateOfBirth':
        return Icons.calendar_today;
      case 'address':
        return Icons.home;
      case 'city':
        return Icons.location_city;
      case 'state':
        return Icons.map;
      case 'pincode':
        return Icons.pin_drop;
      case 'gender':
        return Icons.wc;
      default:
        return Icons.article; // Custom fields get generic icon
    }
  }

  String _formatProfileKey(String key) {
    return key
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) =>
            word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
        .join(' ')
        .trim();
  }

  void _confirmMapping() {
    Navigator.pop(context, finalMapping);
  }
}