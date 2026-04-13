import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class BottomNav extends StatefulWidget {
  final int currentIndex;
  final Function(int) onTap;
  final VoidCallback? onCreateTap;
  final int unreadNotifications;
  final int unreadMessages;
  
  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.onCreateTap,
    this.unreadNotifications = 0,
    this.unreadMessages = 0,
  });

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.currentIndex;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animationController.forward();
    if (widget.unreadNotifications > 0 || widget.unreadMessages > 0) {
      _pulseController.repeat();
    }
  }

  @override
  void didUpdateWidget(BottomNav oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentIndex != _selectedIndex) {
      _selectedIndex = widget.currentIndex;
    }
    if ((widget.unreadNotifications > 0 || widget.unreadMessages > 0) &&
        !_pulseController.isAnimating) {
      _pulseController.repeat();
    } else if (widget.unreadNotifications == 0 && widget.unreadMessages == 0) {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90,
      color: Colors.transparent,
      child: Center(
        child: Container(
          width: 355,
          height: 53,
          decoration: BoxDecoration(
            // Matte, very light grey background (pill-shaped)
            color: const Color(0xFFE8E4E4),
            borderRadius: BorderRadius.circular(30),
            // Soft, diffused drop shadow for floating effect
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                offset: const Offset(0, 4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                offset: const Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Home icon
              _buildAnimatedNavItem(
                index: 0,
                icon: PhosphorIcons.house(PhosphorIconsStyle.fill),
                isActive: widget.currentIndex == 0,
              ),
              
              // Community icon
              _buildAnimatedNavItem(
                index: 1,
                icon: PhosphorIcons.usersThree(PhosphorIconsStyle.fill),
                isActive: widget.currentIndex == 1,
              ),
              
              // Center button - Deep burgundy red circle with white '+'
              _buildCenterButton(),
              
              // Notifications icon with badge
              _buildAnimatedNavItem(
                index: 2,
                icon: PhosphorIcons.bell(PhosphorIconsStyle.fill),
                isActive: widget.currentIndex == 2,
                hasNotification: widget.unreadNotifications > 0,
                notificationCount: widget.unreadNotifications,
              ),
              
              // Profile icon
              _buildAnimatedNavItem(
                index: 3,
                icon: PhosphorIcons.user(PhosphorIconsStyle.fill),
                isActive: widget.currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedNavItem({
    required int index,
    required IconData icon,
    required bool isActive,
    bool hasNotification = false,
    int notificationCount = 0,
  }) {
    return GestureDetector(
      onTap: () {
        _animationController.forward(from: 0);
        widget.onTap(index);
      },
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          final isPressed = _selectedIndex == index;
          return Transform.scale(
            scale: isPressed ? 1.0 : 1.0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isActive 
                    ? const Color(0xFFB21132).withOpacity(0.12) 
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFFB21132).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    transform: Matrix4.identity()
                      ..scale(isActive ? 1.15 : 1.0),
                    child: Icon(
                      icon,
                      size: 24,
                      color: isActive 
                          ? const Color(0xFFB21132)
                          : const Color(0xFF6B5B5B),
                    ),
                  ),
                  // Notification badge
                  if (hasNotification && !isActive)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: 1.0 + (_pulseController.value * 0.2),
                            child: Container(
                              width: notificationCount > 9 ? 18 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF2D55),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFE8E4E4),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFFF2D55).withOpacity(0.5),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: notificationCount > 9
                                  ? Center(
                                      child: Text(
                                        '9+',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/create_post');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFB21132),
              Color(0xFFD32F5A),
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB21132).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 6),
              spreadRadius: 2,
            ),
            BoxShadow(
              color: const Color(0xFFB21132).withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
