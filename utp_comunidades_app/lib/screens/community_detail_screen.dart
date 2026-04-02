import 'package:flutter/material.dart';
import '../models/community.dart';
import '../models/message.dart';

class CommunityDetailScreen extends StatefulWidget {
  final Community community;
  const CommunityDetailScreen({super.key, required this.community});

  @override
  State<CommunityDetailScreen> createState() => _CommunityDetailScreenState();
}

class _CommunityDetailScreenState extends State<CommunityDetailScreen> {
  final _messageController = TextEditingController();
  final List<Message> _messages = [];

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;
    setState(() {
      _messages.add(Message(
        id: _messages.length + 1,
        usuarioId: 1, // Demo user
        comunidadId: widget.community.id,
        contenido: _messageController.text,
        fecha: DateTime.now(),
      ));
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.community.nombre),
        subtitle: Text(widget.community.descripcion, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('Inicia la conversación'))
                : ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, i) {
                      final msg = _messages[i];
                      return Padding(
                        padding: const EdgeInsets.symetric(vertical: 8, horizontal: 16),
                        child: Column(
                          crossAxisAlignment: msg.usuarioId == 1 ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            Text('Usuario ${msg.usuarioId}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            Container(
                              decoration: BoxDecoration(
                                color: msg.usuarioId == 1 ? Colors.deepPurple : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Text(
                                msg.contenido,
                                style: TextStyle(color: msg.usuarioId == 1 ? Colors.white : Colors.black),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
