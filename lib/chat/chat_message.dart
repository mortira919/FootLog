// chat_message.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String role; // 'user' | 'assistant'
  final String text;
  final DateTime? createdAt;
  final String senderId;

  ChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    required this.senderId,
  });

  factory ChatMessage.fromDoc(String id, Map<String, dynamic> d) {
    return ChatMessage(
      id: id,
      role: (d['role'] as String?) ?? 'user',
      text: (d['text'] as String?) ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate(),
      senderId: (d['senderId'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
    'role': role,
    'text': text,
    'createdAt': FieldValue.serverTimestamp(),
    'senderId': senderId,
  };
}
