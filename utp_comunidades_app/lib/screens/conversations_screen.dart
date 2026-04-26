import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/message_provider.dart';
import '../providers/auth_provider.dart';
import 'chat_screen.dart';
import '../theme/app_theme.dart';

class ConversationsScreen extends StatefulWidget {
  const ConversationsScreen({super.key});

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MessageProvider>().fetchConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFB21132),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mensajes',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Consumer<MessageProvider>(
        builder: (context, messageProvider, child) {
          if (messageProvider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (messageProvider.conversations.isEmpty) {
            return Center(
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
                      PhosphorIcons.chatCircleDots(PhosphorIconsStyle.fill),
                      size: 40,
                      color: const Color(0xFFB21132),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Sin conversaciones',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Inicia una conversación con tus amigos',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: messageProvider.conversations.length,
            itemBuilder: (context, index) {
              final conversation = messageProvider.conversations[index];
              return _buildConversationTile(conversation);
            },
          );
        },
      ),
    );
  }

  Widget _buildConversationTile(dynamic conversation) {
    final currentUser = context.read<AuthProvider>().user;
    final isUser1 = conversation['usuario1_id'] == currentUser?.id;
    final otherUserName = isUser1 
        ? conversation['usuario2_nombre'] 
        : conversation['usuario1_nombre'];
    final otherUserPhoto = isUser1 
        ? conversation['usuario2_foto'] 
        : conversation['usuario1_foto'];
    final unreadCount = conversation['mensajes_no_leidos'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              conversationId: conversation['id'],
              otherUserName: otherUserName,
              otherUserPhoto: otherUserPhoto,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundImage: otherUserPhoto != null 
                  ? NetworkImage(otherUserPhoto) 
                  : null,
              child: otherUserPhoto == null 
                  ? const Icon(Icons.person, size: 32) 
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        otherUserName,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      if (unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB21132),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    conversation['ultimo_mensaje'] ?? 'Sin mensajes',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
