class Submission {
  final String id;
  final String formId;
  final String formTitle;
  final Map<String, dynamic> data;
  final String? pdfUrl;
  final String status;
  final DateTime createdAt;

  Submission({
    required this.id,
    required this.formId,
    required this.formTitle,
    required this.data,
    this.pdfUrl,
    required this.status,
    required this.createdAt,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      id: json['_id'] ?? '',
      formId: json['formId'] ?? '',
      formTitle: json['formTitle'] ?? '',
      data: Map<String, dynamic>.from(json['data'] ?? {}),
      pdfUrl: json['pdfUrl'],
      status: json['status'] ?? 'submitted',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'formId': formId,
      'formTitle': formTitle,
      'data': data,
      'pdfUrl': pdfUrl,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
