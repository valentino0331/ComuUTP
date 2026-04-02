import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'communities_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';
import '../widgets/bottom_nav.dart';
import '../providers/community_provider.dart';
import '../providers/auth_provider.dart';

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
    // Cargar comunidades al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityProvider>(context, listen: false).fetchCommunities();
    });
  }

  @override
  Widget build(BuildContext context) {
    final communities = Provider.of<CommunityProvider>(context).communities;
    final user = Provider.of<AuthProvider>(context).user;
    final List<Widget> screens = [
      HomeScreen(),
      CommunitiesScreen(communities: communities),
      NotificationsScreen(),
      user != null ? ProfileScreen(user: user) : const Center(child: Text('No autenticado')),
    ];
    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNav(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
