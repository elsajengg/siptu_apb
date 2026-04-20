/// Model laporan untuk feed forum.
class Report {
  final String title;
  final String description;
  final String location;
  final String category;
  final String status; // Menunggu, Diproses, Selesai
  final String createdBy;
  final int likes;
  final String staffName;
  final String staffFeedback;
  final DateTime createdAt;
  /// URL https atau data URI base64 dari lampiran foto.
  final List<String> images;

  Report({
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.status,
    required this.createdBy,
    required this.likes,
    required this.staffName,
    required this.staffFeedback,
    required this.createdAt,
    this.images = const [],
  });
}
