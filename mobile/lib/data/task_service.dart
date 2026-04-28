import 'package:image_picker/image_picker.dart';

class CompletedTask {
  final String id;
  final String title;
  final String location;
  final String date;
  final String status;
  final String note;
  final List<XFile> images;

  CompletedTask({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.status,
    required this.note,
    required this.images,
  });
}

class TaskService {
  // Singleton pattern
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final List<CompletedTask> _completedTasks = [];

  List<CompletedTask> get completedTasks => List.unmodifiable(_completedTasks);

  void addCompletedTask(CompletedTask task) {
    _completedTasks.insert(0, task); // Newest at the top
  }
}
