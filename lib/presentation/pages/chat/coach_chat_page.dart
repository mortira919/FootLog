import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../chat/chat_message.dart';
import '../../../chat/chat_repository.dart';

class CoachChatPage extends StatefulWidget {
  final String chatId;
  const CoachChatPage({super.key, required this.chatId});

  @override
  State<CoachChatPage> createState() => _CoachChatPageState();
}

class _CoachChatPageState extends State<CoachChatPage> {
  final _repo = ChatRepository(FirebaseFirestore.instance);
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Тренер')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<ChatMessage>>(
              stream: _repo.streamMessages(widget.chatId),
              builder: (context, snap) {
                if (!snap.hasData) return const SizedBox();
                final items = snap.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final m = items[i];
                    final isMe = m.role == 'user' && m.senderId == uid;
                    final isBot = m.role == 'assistant';
                    final bubbleColor = isMe
                        ? const Color(0xFF22C55E)
                        : (isBot ? const Color(0xFFEFF6FF) : Colors.grey.shade200);
                    final textColor = isMe ? Colors.white : Colors.black87;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: bubbleColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(m.text, style: TextStyle(color: textColor)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Задай вопрос',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () async {
                      final text = _ctrl.text.trim();
                      if (text.isEmpty) return;
                      _ctrl.clear();
                      await _repo.sendUserMessage(
                        chatId: widget.chatId,
                        uid: uid,
                        text: text,
                      );
                      // ответ придёт автоматом от Функции
                    },
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
