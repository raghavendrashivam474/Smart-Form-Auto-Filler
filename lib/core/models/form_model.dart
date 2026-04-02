class FormModel {
  final String formId;
  final String title;
  final List<FormField> fields;
  final FormStats? stats;

  FormModel({
    required this.formId,
    required this.title,
    required this.fields,
    this.stats,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      formId: json['formId'] ?? '',
      title: json['title'] ?? '',
      fields: (json['fields'] as List<dynamic>?)
              ?.map((field) => FormField.fromJson(field))
              .toList() ??
          [],
      stats: json['stats'] != null ? FormStats.fromJson(json['stats']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'formId': formId,
      'title': title,
      'fields': fields.map((f) => f.toJson()).toList(),
      if (stats != null) 'stats': stats!.toJson(),
    };
  }
}

class FormField {
  final String id;
  final String label;
  final String type;
  final bool required;
  final dynamic value;
  final bool autoFilled;

  FormField({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.value,
    this.autoFilled = false,
  });

  factory FormField.fromJson(Map<String, dynamic> json) {
    return FormField(
      id: json['id'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'text',
      required: json['required'] ?? false,
      value: json['value'],
      autoFilled: json['autoFilled'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'type': type,
      'required': required,
      'value': value,
      'autoFilled': autoFilled,
    };
  }

  FormField copyWith({
    String? id,
    String? label,
    String? type,
    bool? required,
    dynamic value,
    bool? autoFilled,
  }) {
    return FormField(
      id: id ?? this.id,
      label: label ?? this.label,
      type: type ?? this.type,
      required: required ?? this.required,
      value: value ?? this.value,
      autoFilled: autoFilled ?? this.autoFilled,
    );
  }
}

class FormStats {
  final int totalFields;
  final int autoFilled;
  final int percentage;

  FormStats({
    required this.totalFields,
    required this.autoFilled,
    required this.percentage,
  });

  factory FormStats.fromJson(Map<String, dynamic> json) {
    return FormStats(
      totalFields: json['totalFields'] ?? 0,
      autoFilled: json['autoFilled'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalFields': totalFields,
      'autoFilled': autoFilled,
      'percentage': percentage,
    };
  }
}
