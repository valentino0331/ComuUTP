import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'home_screen.dart';
import 'communities_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import 'create_post_screen.dart';
import 'friend_requests_screen.dart';
import 'conversations_screen.dart';
import '../widgets/bottom_nav.dart';
import '../providers/community_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../providers/friendship_provider.dart';

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;


  @override
  void initState() {
    super.initState();
    // Cargar comunidades y notificaciones al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityProvider>(context, listen: false).fetchCommunities();
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  void _openCreatePost() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CreatePostScreen(),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final communities = Provider.of<CommunityProvider>(context).communities;
    final user = Provider.of<AuthProvider>(context).user;
    final unreadNotifications = Provider.of<NotificationProvider>(context).unreadCount;
    final List<Widget> screens = [
      HomeScreen(),
      CommunitiesScreen(communities: communities),
      NotificationsScreen(),
      user != null ? ProfileScreen(user: user) : const Center(child: Text('No autenticado')),
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFB21132),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'UTP Comunidades',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        onCreateTap: _openCreatePost,
        unreadNotifications: unreadNotifications,
      ),
    );
  }
}
