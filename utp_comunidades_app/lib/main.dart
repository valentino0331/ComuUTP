import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/splash_screen.dart';
import 'screens/create_post_screen.dart';
import 'screens/create_story_screen.dart';
import 'screens/story_viewer_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/friend_requests_screen.dart';
import 'screens/conversations_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/hashtags_screen.dart';
import 'screens/saved_posts_screen.dart';
import 'screens/search_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/community_provider.dart';
import 'providers/post_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/story_provider.dart';
import 'providers/follower_provider.dart';
import 'providers/friendship_provider.dart';
import 'providers/reaction_provider.dart';
import 'providers/message_provider.dart';
import 'providers/hashtag_provider.dart';
import 'providers/saved_provider.dart';
import 'providers/search_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CommunityProvider()),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => FollowerProvider()),
        ChangeNotifierProvider(create: (_) => FriendshipProvider()),
        ChangeNotifierProvider(create: (_) => ReactionProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
        ChangeNotifierProvider(create: (_) => HashtagProvider()),
        ChangeNotifierProvider(create: (_) => SavedProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
      ],
      child: MaterialApp(
        title: 'UTP Comunidades',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => PantallaInicio(),
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/home': (context) => HomeScreen(),
          '/main': (context) => MainScaffold(),
          '/create_post': (context) => const CreatePostScreen(),
          '/create_story': (context) => CreateStoryScreen(),
          '/admin': (context) => const AdminScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/friend_requests': (context) => const FriendRequestsScreen(),
          '/conversations': (context) => const ConversationsScreen(),
          '/hashtags': (context) => const HashtagsScreen(),
          '/saved_posts': (context) => const SavedPostsScreen(),
          '/search': (context) => const SearchScreen(),
        },
      ),
    );
  }
}
