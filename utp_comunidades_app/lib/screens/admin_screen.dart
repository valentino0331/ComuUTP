import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'dart:convert';
import 'package:utp_comunidades_app/services/api_service.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _users = [];
  bool _isLoading = false;
  final Map<String, int> _stats = {
    'users': 0,
    'communities': 0,
    'posts': 0,
    'reports': 0,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final usersResponse = await ApiService.get('/users', auth: true);
      if (usersResponse.statusCode == 200) {
        final List<dynamic> data = json.decode(usersResponse.body);
        if (mounted) {
          setState(() {
            _users = data;
            _stats['users'] = data.length;
            _stats['communities'] = 12;
            _stats['posts'] = 156;
            _stats['reports'] = 4;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleUserRole(String userId, String currentRole) async {
    try {
      _loadData(); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Users'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Stats'),
            Tab(icon: Icon(Icons.build), text: 'Tools'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildUsersTab(),
          _buildStatsTab(),
          _buildToolsTab(),
        ],
      ),
    );
  }

  Widget _buildUsersTab() {
    final filteredUsers = _users.where((user) {
      final name = user['name']?.toString().toLowerCase() ?? '';
      return name.contains(_searchController.text.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.bold)),
              border: const OutlineInputBorder(),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  final String name = user['name']?.toString() ?? 'Unknown';
                  final String email = user['email']?.toString() ?? '';
                  final String role = user['role']?.toString() ?? 'user';
                  final String id = user['id']?.toString() ?? '';

                  return ListTile(
                    leading: CircleAvatar(child: Text(name.isNotEmpty ? name[0] : 'U')),
                    title: Text(name),
                    subtitle: Text(email),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            role == 'admin' 
                              ? PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill)
                              : PhosphorIcons.shield(PhosphorIconsStyle.bold)
                          ),
                          onPressed: () => _toggleUserRole(id, role),
                        ),
                        IconButton(
                          icon: Icon(PhosphorIcons.lock(PhosphorIconsStyle.bold)),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildStatsTab() {
    return GridView.count(
      crossAxisCount: 2,
      padding: const EdgeInsets.all(16),
      children: [
        _statCard('Users', _stats['users'].toString(), PhosphorIcons.users(PhosphorIconsStyle.bold), Colors.blue),
        _statCard('Communities', _stats['communities'].toString(), PhosphorIcons.browser(PhosphorIconsStyle.bold), Colors.green),
        _statCard('Posts', _stats['posts'].toString(), PhosphorIcons.chatTeardropDots(PhosphorIconsStyle.bold), Colors.orange),
        _statCard('Reports', _stats['reports'].toString(), PhosphorIcons.warningCircle(PhosphorIconsStyle.bold), Colors.red),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: color),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(title),
        ],
      ),
    );
  }

  Widget _buildToolsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(PhosphorIcons.trash(PhosphorIconsStyle.bold)),
          label: const Text('Delete Inactive Users'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(PhosphorIcons.megaphone(PhosphorIconsStyle.bold)),
          label: const Text('Send Global Notification'),
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () {},
          icon: Icon(PhosphorIcons.database(PhosphorIconsStyle.bold)),
          label: const Text('Backup Database'),
        ),
      ],
    );
  }
}
