import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../models/community.dart';
import '../services/api_service.dart';
import '../providers/friendship_provider.dart';
import 'dart:convert';

class CommunityMembersScreen extends StatefulWidget {
  final Community community;

  const CommunityMembersScreen({
    super.key,
    required this.community,
  });

  @override
  State<CommunityMembersScreen> createState() => _CommunityMembersScreenState();
}

class _CommunityMembersScreenState extends State<CommunityMembersScreen> {
  late List<Map<String, dynamic>> members = [];
  bool _isLoading = true;
  Map<int, String?> _friendshipStatus = {};

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get('/communities/members/${widget.community.id}', auth: true);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          members = (data['miembros'] as List).cast<Map<String, dynamic>>();
        });
        
        // Check friendship status for each member
        for (var member in members) {
          if (member['id'] != null) {
            _checkFriendshipStatus(member['id']);
          }
        }
      }
    } catch (e) {
      print('Error loading members: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _checkFriendshipStatus(int userId) async {
    final friendshipProvider = context.read<FriendshipProvider>();
    final status = await friendshipProvider.checkFriendshipStatus(userId);
    if (mounted) {
      setState(() {
        _friendshipStatus[userId] = status;
      });
    }
  }

  Future<void> _sendFriendRequest(int userId, String userName) async {
    final friendshipProvider = context.read<FriendshipProvider>();
    final success = await friendshipProvider.sendFriendRequest(userId);
    if (success && mounted) {
      setState(() {
        _friendshipStatus[userId] = 'pendiente';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                PhosphorIcons.checkCircle(PhosphorIconsStyle.fill),
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Solicitud de amistad enviada a $userName',
                  style: const TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFFB21132),
          duration: const Duration(milliseconds: 2500),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFB21132),
        elevation: 0,
        toolbarHeight: 56,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Miembros',
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          // Header con información de la comunidad
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFB21132).withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: const Color(0xFFB21132).withOpacity(0.1), width: 1),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color(0xFFB21132).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          widget.community.nombre.isNotEmpty ? widget.community.nombre[0].toUpperCase() : 'C',
                          style: const TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w700,
                            fontSize: 24,
                            color: Color(0xFFB21132),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.community.nombre,
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${members.length} miembros',
                            style: TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Lista de miembros
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFB21132)),
                  )
                : members.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: const Color(0xFFB21132).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                PhosphorIcons.users(PhosphorIconsStyle.fill),
                                size: 40,
                                color: const Color(0xFFB21132),
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay miembros aún',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
                        itemCount: members.length,
                        itemBuilder: (context, index) {
                          final member = members[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildMemberCard(context, member, index),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, Map<String, dynamic> member, int index) {
    final friendshipStatus = _friendshipStatus[member['id']];
    final isCreator = member['es_creador'] ?? false;
    final userName = '${member['nombre'] ?? ''} ${member['apellido'] ?? ''}'.trim();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFED1C24).withOpacity(0.7),
                    const Color(0xFFB21132),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Información
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          userName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                            fontFamily: 'Montserrat',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isCreator)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB21132).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Creador',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB21132),
                              fontFamily: 'Montserrat',
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Miembro desde ${_formatDate(member['fecha_union'])}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      fontFamily: 'Montserrat',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Button for action
            if (!isCreator)
              GestureDetector(
                onTap: friendshipStatus == 'aceptada' || friendshipStatus == 'pendiente'
                    ? null
                    : () => _sendFriendRequest(member['id'], userName),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: friendshipStatus == 'aceptada'
                        ? Colors.green.withOpacity(0.1)
                        : friendshipStatus == 'pendiente'
                            ? Colors.grey[200]
                            : const Color(0xFFB21132).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    friendshipStatus == 'aceptada'
                        ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                        : friendshipStatus == 'pendiente'
                            ? PhosphorIcons.clock(PhosphorIconsStyle.fill)
                            : PhosphorIcons.userPlus(PhosphorIconsStyle.fill),
                    color: friendshipStatus == 'aceptada'
                        ? Colors.green
                        : friendshipStatus == 'pendiente'
                            ? Colors.grey[600]
                            : const Color(0xFFB21132),
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
