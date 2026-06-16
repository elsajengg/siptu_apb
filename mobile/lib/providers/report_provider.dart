import 'package:flutter/foundation.dart';

import '../data/api_service.dart';

class Report {
  final int databaseId;
  final String id;
  final String title;
  final String description;
  final String location;
  final String roomDetail;
  final String category;
  final String status;
  final String createdBy;
  final List<String> likedBy;
  final int likesCount;
  final String staffName;
  final String staffFeedback;
  final bool needsReporterFeedback;
  final int? reporterRating;
  final String reporterFeedback;
  final List<StaffTaskUpdate> staffUpdates;
  final DateTime createdAt;
  final List<String> photoPaths;
  final List<Uint8List>? photoBytesList;

  Report({
    this.databaseId = 0,
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    this.roomDetail = '',
    required this.category,
    required this.status,
    required this.createdBy,
    required this.likedBy,
    this.likesCount = 0,
    required this.staffName,
    required this.staffFeedback,
    this.needsReporterFeedback = false,
    this.reporterRating,
    this.reporterFeedback = '',
    this.staffUpdates = const [],
    required this.createdAt,
    this.photoPaths = const [],
    this.photoBytesList,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    final task = json['task'] as Map<String, dynamic>?;
    final staff = task?['staff'] as Map<String, dynamic>?;
    final updates =
        (task?['updates'] as List<dynamic>? ?? [])
            .map(
              (update) => StaffTaskUpdate.fromJson(
                Map<String, dynamic>.from(update as Map),
              ),
            )
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final photos = (json['photos'] as List<dynamic>? ?? [])
        .map((photo) => ApiService.mediaUrl(photo['path']?.toString()))
        .where((path) => path.isNotEmpty)
        .toList();

    return Report(
      databaseId: json['id'] as int? ?? 0,
      id: json['ticket_number']?.toString() ?? 'TIK-${json['id']}',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      roomDetail: json['room_detail']?.toString() ?? '',
      category: json['category']?.toString() ?? '',
      status: statusLabel(json['status']?.toString()),
      createdBy:
          (json['user'] as Map<String, dynamic>?)?['name']?.toString() ??
          ApiService.currentUser?['name']?.toString() ??
          'User',
      likedBy: json['is_liked_by_me'] == true
          ? [ApiService.currentUser?['id']?.toString() ?? 'current']
          : const [],
      likesCount: json['likes_count'] as int? ?? 0,
      staffName: staff?['name']?.toString() ?? '',
      staffFeedback: task?['staff_notes']?.toString() ?? '',
      staffUpdates: updates,
      needsReporterFeedback:
          json['status'] == 'resolved' && json['rating'] == null,
      reporterRating: json['rating'] as int?,
      reporterFeedback: json['feedback_notes']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      photoPaths: photos,
    );
  }

  Report copyWith({
    List<String>? likedBy,
    int? likesCount,
    bool? needsReporterFeedback,
    int? reporterRating,
    String? reporterFeedback,
  }) {
    return Report(
      databaseId: databaseId,
      id: id,
      title: title,
      description: description,
      location: location,
      roomDetail: roomDetail,
      category: category,
      status: status,
      createdBy: createdBy,
      likedBy: likedBy ?? this.likedBy,
      likesCount: likesCount ?? this.likesCount,
      staffName: staffName,
      staffFeedback: staffFeedback,
      needsReporterFeedback:
          needsReporterFeedback ?? this.needsReporterFeedback,
      reporterRating: reporterRating ?? this.reporterRating,
      reporterFeedback: reporterFeedback ?? this.reporterFeedback,
      staffUpdates: staffUpdates,
      createdAt: createdAt,
      photoPaths: photoPaths,
      photoBytesList: photoBytesList,
    );
  }

  static String statusLabel(String? status) {
    return switch (status) {
      'pending' => 'Menunggu',
      'assigned' || 'on_progress' => 'Diproses',
      'blocked' => 'Terkendala',
      'resolved' => 'Selesai',
      'rejected' => 'Ditolak',
      _ => status ?? 'Menunggu',
    };
  }

  int get likes => likesCount;
  String? get coverPhotoPath => photoPaths.isEmpty ? null : photoPaths.first;
  Uint8List? get coverPhotoBytes =>
      (photoBytesList?.isEmpty ?? true) ? null : photoBytesList!.first;
}

class StaffTaskUpdate {
  final int databaseId;
  final String status;
  final String notes;
  final String authorName;
  final DateTime createdAt;
  final List<String> photoPaths;

  StaffTaskUpdate({
    required this.databaseId,
    required this.status,
    required this.notes,
    required this.authorName,
    required this.createdAt,
    required this.photoPaths,
  });

  factory StaffTaskUpdate.fromJson(Map<String, dynamic> json) {
    final photos = (json['photos'] as List<dynamic>? ?? [])
        .map((photo) => ApiService.mediaUrl(photo['path']?.toString()))
        .where((path) => path.isNotEmpty)
        .toList();
    return StaffTaskUpdate(
      databaseId: json['id'] as int? ?? 0,
      status: switch (json['status']?.toString()) {
        'on_progress' => 'Progress',
        'resolved' => 'Selesai',
        'blocked' => 'Terkendala',
        _ => json['status']?.toString() ?? 'Progress',
      },
      notes: json['notes']?.toString() ?? '',
      authorName:
          (json['author'] as Map<String, dynamic>?)?['name']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
      photoPaths: photos,
    );
  }
}

class ReportProvider extends ChangeNotifier {
  List<Report> _reports = [];
  List<Report> _myReports = [];
  bool _loading = false;
  String? _error;

  List<Report> get reports => List.unmodifiable(_reports);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadFeed() async {
    await _load(feed: true);
  }

  Future<void> loadMine() async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.getReports();
    if (result['success'] == true) {
      _myReports = (result['data'] as List<dynamic>)
          .map(
            (item) => Report.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } else {
      _error = result['message']?.toString();
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> _load({required bool feed}) async {
    _loading = true;
    _error = null;
    notifyListeners();

    final result = await ApiService.getReports(feed: feed);
    if (result['success'] == true) {
      _reports = (result['data'] as List<dynamic>)
          .map(
            (item) => Report.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList();
    } else {
      _error = result['message']?.toString();
    }

    _loading = false;
    notifyListeners();
  }

  void addReport(Report report) {
    _reports.insert(0, report);
    _myReports.insert(0, report);
    notifyListeners();
  }

  Future<void> toggleLike(String reportId, String userId) async {
    final index = _reports.indexWhere((report) => report.id == reportId);
    if (index == -1) return;
    final result = await ApiService.toggleReportLike(
      _reports[index].databaseId,
    );
    if (result['success'] != true) return;
    final data = Map<String, dynamic>.from(result['data'] as Map);
    _replaceLikeState(
      reports: _reports,
      reportId: reportId,
      userId: userId,
      liked: data['liked'] == true,
      likesCount: data['likes_count'] as int?,
    );
    _replaceLikeState(
      reports: _myReports,
      reportId: reportId,
      userId: userId,
      liked: data['liked'] == true,
      likesCount: data['likes_count'] as int?,
    );
    notifyListeners();
  }

  void _replaceLikeState({
    required List<Report> reports,
    required String reportId,
    required String userId,
    required bool liked,
    required int? likesCount,
  }) {
    final index = reports.indexWhere((report) => report.id == reportId);
    if (index == -1) return;
    final likedBy = List<String>.from(reports[index].likedBy);
    liked ? likedBy.add(userId) : likedBy.remove(userId);
    reports[index] = reports[index].copyWith(
      likedBy: likedBy.toSet().toList(),
      likesCount: likesCount ?? reports[index].likes,
    );
  }

  Future<bool> submitReporterFeedback({
    required String reportId,
    required int rating,
    required String feedback,
  }) async {
    final index = _myReports.indexWhere((report) => report.id == reportId);
    if (index == -1) return false;
    final result = await ApiService.submitReportFeedback(
      reportId: _myReports[index].databaseId,
      rating: rating,
      notes: feedback.trim(),
    );
    if (result['success'] != true) return false;
    _myReports[index] = _myReports[index].copyWith(
      needsReporterFeedback: false,
      reporterRating: rating,
      reporterFeedback: feedback.trim(),
    );
    notifyListeners();
    return true;
  }

  List<Report> getByUser(String _) => List.unmodifiable(_myReports);
}
