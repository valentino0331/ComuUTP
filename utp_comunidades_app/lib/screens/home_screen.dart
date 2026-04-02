import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/post_provider.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar publicaciones de la primera comunidad (puedes mejorar esto para mostrar todas las comunidades del usuario)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PostProvider>(context, listen: false).fetchPostsByCommunity(1); // Demo: comunidad 1
    });
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comunidades UTP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(context, '/notifications');
            },
          ),
        ],
      ),
      body: postProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : postProvider.posts.isEmpty
              ? const Center(child: Text('No hay publicaciones'))
              : ListView.builder(
                  itemCount: postProvider.posts.length,
                  itemBuilder: (context, i) {
                    final post = postProvider.posts[i];
                    return PostCard(post: post);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_post');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
