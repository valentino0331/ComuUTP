import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/community.dart';
import '../providers/community_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import './create_community_screen.dart';
import './community_members_screen.dart';

class PantallaComunidadesNueva extends StatefulWidget {
  const PantallaComunidadesNueva({super.key});

  @override
  State<PantallaComunidadesNueva> createState() =>
      _PantallaComunidadesNuevaState();
}

class _PantallaComunidadesNuevaState extends State<PantallaComunidadesNueva> {
  late TextEditingController _searchController;
  String _filtroSeleccionado = 'Todas';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _irACrearComunidad() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PantallaCrearComunidad(),
      ),
    );
  }

  void _irAVerMiembros(Community comunidad) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PantallaMiembrosComunidad(
          comunidadId: comunidad.id,
          nombreComunidad: comunidad.nombre,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.colorGrisClaro,
      body: Column(
        children: [
          // Encabezado
          _construirEncabezado(),

          // Búsqueda
          _construirBarraBusqueda(),

          // Filtros
          _construirFiltros(),

          // Lista de comunidades
          Expanded(
            child: _construirListaComunidades(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irACrearComunidad,
        backgroundColor: AppTheme.colorRojoUTP,
        label: const Text('Crear Comunidad'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  /// Encabezado con título y descripción
  Widget _construirEncabezado() {
    return Container(
      color: AppTheme.colorBlancoFondo,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comunidades UTP',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.colorNegro,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Únete a comunidades y conecta con estudiantes',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.colorGris,
            ),
          ),
        ],
      ),
    );
  }

  /// Barra de búsqueda
  Widget _construirBarraBusqueda() {
    return Container(
      color: AppTheme.colorBlancoFondo,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: 'Buscar comunidad...',
          hintStyle: const TextStyle(color: AppTheme.colorGris),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.colorGris,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  child: const Icon(Icons.close, color: AppTheme.colorGris),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.colorGrisClaro),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppTheme.colorGrisClaro),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppTheme.colorRojoUTP,
              width: 2,
            ),
          ),
          filled: true,
          fillColor: AppTheme.colorGrisClaro,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  /// Filtros de categoría
  Widget _construirFiltros() {
    final filtros = ['Todas', 'Mis Comunidades', 'Nuevas', 'Popular'];

    return Container(
      color: AppTheme.colorBlancoFondo,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filtros.map((filtro) {
            final isSelected = _filtroSeleccionado == filtro;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filtro),
                selected: isSelected,
                onSelected: (_) => setState(() => _filtroSeleccionado = filtro),
                backgroundColor: AppTheme.colorGrisClaro,
                selectedColor: AppTheme.colorRojoUTP,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.colorNegro,
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Lista de comunidades
  Widget _construirListaComunidades() {
    return Consumer2<CommunityProvider, AuthProvider>(
      builder: (context, proveedorComunidades, proveedorAuth, _) {
        if (proveedorComunidades.loading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppTheme.colorRojoUTP),
            ),
          );
        }

        if (proveedorComunidades.error != null) {
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
                Text(
                  'Error: ${proveedorComunidades.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        }

        var comunidades = proveedorComunidades.communities;

        // Aplicar búsqueda
        if (_searchController.text.isNotEmpty) {
          comunidades = comunidades
              .where((c) => c.nombre
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
              .toList();
        }

        // Aplicar filtro
        if (_filtroSeleccionado == 'Mis Comunidades') {
          comunidades =
              comunidades.where((c) => c.esMiembro ?? false).toList();
        }

        if (comunidades.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.public_off_outlined,
                  size: 64,
                  color: AppTheme.colorGris,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay comunidades',
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: comunidades.length,
          itemBuilder: (context, index) {
            final comunidad = comunidades[index];
            return _TarjetaComunidad(
              comunidad: comunidad,
              onVerMiembros: () => _irAVerMiembros(comunidad),
            );
          },
        );
      },
    );
  }
}

/// Tarjeta de comunidad mejorada
class _TarjetaComunidad extends StatelessWidget {
  final Community comunidad;
  final VoidCallback onVerMiembros;

  const _TarjetaComunidad({
    required this.comunidad,
    required this.onVerMiembros,
  });

  @override
  Widget build(BuildContext context) {
    final esMiembro = comunidad.esMiembro ?? false;

    return GestureDetector(
      onTap: onVerMiembros,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.borderRadiusStandard),
            gradient: esMiembro
                ? LinearGradient(
                    colors: [
                      AppTheme.colorRojoUTP.withOpacity(0.1),
                      AppTheme.colorBlancoFondo,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado: Avatar, nombre y badge
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppTheme.colorRojoUTP,
                        borderRadius: BorderRadius.circular(
                        AppTheme.borderRadiusStandard,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          comunidad.nombre.isNotEmpty
                              ? comunidad.nombre[0].toUpperCase()
                              : '👥',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Nombre y descripción corta
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comunidad.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.colorNegro,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            comunidad.descripcion,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.colorGris,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Badge de miembro
                    if (esMiembro)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.colorRojoUTP,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Miembro',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Estadísticas
                Row(
                  children: [
                    _ConstructorEstadistica(
                      icono: Icons.people_outline,
                      etiqueta: 'Miembros',
                      valor: '${comunidad.miembros ?? 0}',
                    ),
                    const SizedBox(width: 16),
                    _ConstructorEstadistica(
                      icono: Icons.article_outlined,
                      etiqueta: 'Posts',
                      valor: '${comunidad.posts ?? 0}',
                    ),
                    const Spacer(),

                    // Botón de acción (unirse o abandonar)
                    _BotónAcción(
                      esMiembro: esMiembro,
                      comunidadId: comunidad.id,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Estadística (miembros, posts)
class _ConstructorEstadistica extends StatelessWidget {
  final IconData icono;
  final String etiqueta;
  final String valor;

  const _ConstructorEstadistica({
    required this.icono,
    required this.etiqueta,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icono,
          size: 20,
          color: AppTheme.colorRojoUTP,
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.colorNegro,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 11,
            color: AppTheme.colorGris,
          ),
        ),
      ],
    );
  }
}

/// Botón de acción (Unirse/Abandonar)
class _BotónAcción extends StatefulWidget {
  final bool esMiembro;
  final int comunidadId;

  const _BotónAcción({
    required this.esMiembro,
    required this.comunidadId,
  });

  @override
  State<_BotónAcción> createState() => _BotónAcciónState();
}

class _BotónAcciónState extends State<_BotónAcción> {
  late bool _esMiembro;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _esMiembro = widget.esMiembro;
  }

  Future<void> _procesarAccion() async {
    final provedor = context.read<CommunityProvider>();
    setState(() => _cargando = true);

    try {
      bool exito;
      if (_esMiembro) {
        exito = await provedor.leaveCommunity(widget.comunidadId);
      } else {
        exito = await provedor.joinCommunity(widget.comunidadId);
      }

      if (exito) {
        setState(() => _esMiembro = !_esMiembro);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _esMiembro ? '¡Te uniste a la comunidad!' : 'Abandonaste la comunidad',
              ),
              backgroundColor: AppTheme.colorRojoUTP,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _cargando ? null : _procesarAccion,
      style: ElevatedButton.styleFrom(
        backgroundColor: _esMiembro
            ? AppTheme.colorGrisClaro
            : AppTheme.colorRojoUTP,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: _cargando
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.colorRojoUTP,
                ),
              ),
            )
          : Text(
              _esMiembro ? 'Abandonar' : 'Unirse',
              style: TextStyle(
                color: _esMiembro ? AppTheme.colorNegro : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
    );
  }
}
