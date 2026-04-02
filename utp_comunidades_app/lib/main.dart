
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/community_provider.dart';
import 'providers/post_provider.dart';
import 'providers/comment_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/like_provider.dart';
import 'providers/report_provider.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/create_post_screen.dart';


void main() {
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
      title: 'UTP Comunidades',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/main': (context) => const MainScaffold(),
        '/create_post': (context) => const CreatePostScreen(),
      },
    );
  }
}
