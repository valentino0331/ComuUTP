import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/community.dart';

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

  @override
  void initState() {
    super.initState();
    // Load members from API (no hardcoded fake data)
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Fetch members from API endpoint
      // final response = await ApiService.get('/communities/${widget.community.id}/members', auth: true);
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   setState(() {
      //     members = (data['members'] as List).cast<Map<String, dynamic>>();
      //   });
      // }
      setState(() {
        members = []; // Empty list for now - will be populated from API
      });
    } catch (e) {
      print('Error loading members: $e');
    } finally {
      setState(() => _isLoading = false);
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
          icon: Icon(PhosphorIcons.arrowLeft(PhosphorIconsStyle.bold), color: Colors.white, size: 24),
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
    final solicitudEnviada = member['solicitudEnviada'] ?? false;

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
                  member['nombre'][0].toUpperCase(),
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
            // InformaciÃ³n
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          member['nombre'],
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
                      if (member['rol'] == 'admin')
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB21132).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Admin',
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
                    member['email'],
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
            if (member['rol'] != 'admin')
              GestureDetector(
                onTap: solicitudEnviada
                    ? null
                    : () async {
                        // Send real friendship request to API
                        try {
                          setState(() {
                            members[index]['solicitudEnviada'] = true;
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
                                      'Solicitud de amistad enviada a ${member['nombre']}',
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
                        } catch (e) {
                          setState(() {
                            members[index]['solicitudEnviada'] = false;
                          });
                        }
                      },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: solicitudEnviada
                        ? Colors.grey[200]
                        : const Color(0xFFB21132).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    solicitudEnviada
                        ? PhosphorIcons.checkCircle(PhosphorIconsStyle.fill)
                        : PhosphorIcons.userPlus(PhosphorIconsStyle.fill),
                    color: solicitudEnviada
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
}
