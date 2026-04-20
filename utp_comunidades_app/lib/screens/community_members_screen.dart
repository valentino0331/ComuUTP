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
  State<CommunityMembersScreenState> createState() =>
      _CommunityMembersScreenState();
}

class _CommunityMembersScreenState extends State<CommunityMembersScreen> {
  // Lista simulada de miembros (en producción, esto vendría de la API)
  late List<Map<String, dynamic>> members;

  @override
  void initState() {
    super.initState();
    members = [
      {
        'id': 1,
        'nombre': 'Admin User',
        'email': 'admin@utp.edu.pe',
        'rol': 'admin',
        'solicitudEnviada': false,
      },
      {
        'id': 2,
        'nombre': 'Juan Pérez',
        'email': 'juan@utp.edu.pe',
        'rol': 'miembro',
        'solicitudEnviada': false,
      },
      {
        'id': 3,
        'nombre': 'María García',
        'email': 'maria@utp.edu.pe',
        'rol': 'miembro',
        'solicitudEnviada': false,
      },
      {
        'id': 4,
        'nombre': 'Carlos López',
        'email': 'carlos@utp.edu.pe',
        'rol': 'miembro',
        'solicitudEnviada': false,
      },
      {
        'id': 5,
        'nombre': 'Ana Martínez',
        'email': 'ana@utp.edu.pe',
        'rol': 'miembro',
        'solicitudEnviada': false,
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        elevation: 8,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFED1C24),
                const Color(0xFFB21132),
              ],
            ),
          ),
        ),
        toolbarHeight: 70,
        leading: IconButton(
          icon: const Icon(PhosphorIcons.arrowLeft, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Miembros',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                fontFamily: 'Montserrat',
              ),
            ),
            Text(
              '${members.length} personas en ${widget.community.nombre}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white.withOpacity(0.8),
                fontFamily: 'Montserrat',
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return _buildMemberCard(context, member, index);
        },
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
            // Avatar con gradiente
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
            // Información del miembro
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
            // Botón de acción (solo para no-admins)
            if (member['rol'] != 'admin')
              GestureDetector(
                onTap: solicitudEnviada
                    ? null
                    : () {
                        setState(() {
                          members[index]['solicitudEnviada'] = true;
                        });

                        // Mostrar snackbar
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
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../models/community.dart';
import '../providers/community_provider.dart';
import '../theme/app_theme.dart';

class CommunityMembersScreen extends StatefulWidget {
  final Community community;
  
  const CommunityMembersScreen({
    super.key,
    required this.community,
  });

  @override
  State<CommunityMembersScreenState> createState() =>
      _CommunityMembersScreenState();
}

class _PantallaMiembrosComunidadState extends State<PantallaMiembrosComunidad> {
  late Future<List<Map<String, dynamic>>> _miembrosFuture;

  @override
  void initState() {
    super.initState();
    _miembrosFuture = context
        .read<CommunityProvider>()
        .getMembersOfCommunity(widget.comunidadId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Miembros'),
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _miembrosFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.colorRojoUTP),
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text('Error al cargar miembros'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _miembrosFuture = context
                            .read<CommunityProvider>()
                            .getMembersOfCommunity(widget.comunidadId);
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final miembros = snapshot.data ?? [];

          if (miembros.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppTheme.colorGris,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No hay miembros aún',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.colorGris,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: miembros.length,
            itemBuilder: (context, index) {
              final miembro = miembros[index];
              final nombre = miembro['nombre'] ?? 'Usuario';
              final email = miembro['email'] ?? '';
              final esCreador = miembro['es_creador'] ?? false;

              return _TarjetaMiembro(
                nombre: nombre,
                email: email,
                esCreador: esCreador,
              );
            },
          );
        },
      ),
    );
  }
}

/// Tarjeta individual de miembro
class _TarjetaMiembro extends StatelessWidget {
  final String nombre;
  final String email;
  final bool esCreador;

  const _TarjetaMiembro({
    required this.nombre,
    required this.email,
    required this.esCreador,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.colorRojoUTP,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Text(
                  nombre.isNotEmpty ? nombre[0].toUpperCase() : '👤',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Información del miembro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.colorNegro,
                        ),
                      ),
                      if (esCreador) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.colorRojoUTP,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Creador',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.colorGris,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Icono de información
            const Icon(
              Icons.info_outline,
              color: AppTheme.colorGris,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
