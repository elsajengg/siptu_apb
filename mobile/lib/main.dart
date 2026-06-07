import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:workmanager/workmanager.dart';
import 'firebase_options.dart';
import 'features/splash/splash_page.dart';
import 'services/notification_service.dart';
import 'data/task_service.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      final notifService = NotificationService();
      await notifService.init();

      // Logika Floating: Cek jumlah data yang selesai (Mocked data: asumsi hari ini)
      final completedToday = TaskService().completedTasks.length;

      String title = 'Laporan Harian SIPTU 🏢';
      String body = completedToday > 0 
          ? 'Ada $completedToday perbaikan fasilitas yang selesai hari ini.'
          : 'Sistem aman! Tidak ada laporan perbaikan fasilitas hari ini.';

      await notifService.showNotification(title: title, body: body);

      // Re-schedule untuk besok
      _scheduleNextDailyTask();
    } catch (e) {
      debugPrint('Background Task Error: $e');
      return Future.value(false);
    }
    return Future.value(true);
  });
}

void _scheduleNextDailyTask() {
  final now = DateTime.now();
  var scheduledDate = DateTime(now.year, now.month, now.day, 17, 0);
  
  // Jika sudah lewat jam 17:00, jadwalkan untuk besok
  if (now.isAfter(scheduledDate)) {
    scheduledDate = scheduledDate.add(const Duration(days: 1));
  }
  
  final initialDelay = scheduledDate.difference(now);

  Workmanager().registerOneOffTask(
    'daily_report_task',
    'daily_report_task',
    initialDelay: initialDelay,
    existingWorkPolicy: ExistingWorkPolicy.replace,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    
    // Daftarkan trigger pertama
    _scheduleNextDailyTask();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIPTU - Media Pelaporan Fasilitas Kampus',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red.shade800),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      ),
      home: const SplashPage(),
    );
  }
}
