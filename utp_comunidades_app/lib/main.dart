import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/community_provider.dart';
import 'providers/post_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/like_provider.dart';
import 'providers/report_provider.dart';
import 'providers/attendance_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen_new.dart';
import 'screens/register_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/create_post_screen.dart';
import 'screens/create_community_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/attendance/submit_attendance_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase with platform-specific options
  if (kIsWeb) {
    // Web requires explicit configuration
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } catch (e) {
      // If Firebase web config is missing, continue without Firebase
      debugPrint('Firebase web config not available: $e');
    }
  } else {
    // Android/iOS uses google-services.json / GoogleService-Info.plist
    await Firebase.initializeApp();
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => LikeProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
      ],
      child: const UtpComunidadesApp(),
    ),
  );
}

class UtpComunidadesApp extends StatelessWidget {
  const UtpComunidadesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UTP Comunidades',
      theme: AppTheme.temaClaro(),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const PantallaInicio(),
        '/login': (context) => const PantallaLogin(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScaffold(),
        '/create_post': (context) => const CreatePostScreen(),
        '/create_community': (context) => const CreateCommunityScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/submit_attendance': (context) => const SubmitAttendanceScreen(),
      },
    );
  }
}
