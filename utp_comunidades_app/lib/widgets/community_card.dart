import 'package:flutter/material.dart';
import '../models/community.dart';

class CommunityCard extends StatelessWidget {
  final Community community;
  final VoidCallback? onTap;
  const CommunityCard({super.key, required this.community, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        title: Text(community.nombre),
        subtitle: Text(community.descripcion),
        trailing: IconButton(
          icon: const Icon(Icons.group_add),
          onPressed: () {},
        ),
        onTap: onTap,
      ),
    );
  }
}
