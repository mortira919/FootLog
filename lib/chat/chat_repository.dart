
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_message.dart';

class ChatRepository {
  final FirebaseFirestore db;
  ChatRepository(this.db);

  CollectionReference<Map<String, dynamic>> _messagesCol(String chatId) =>
      db.collection('chats').doc(chatId).collection('messages');

  Stream<List<ChatMessage>> streamMessages(String chatId) {
    return _messagesCol(chatId)
        .orderBy('createdAt', descending: false)
        .limit(200)
        .snapshots()
        .map((snap) => snap.docs
        .map((d) => ChatMessage.fromDoc(d.id, d.data()))
        .toList());
  }

  Future<void> sendUserMessage({
    required String chatId,
    required String uid,
    required String text,
  }) {
    final msg = ChatMessage(
      id: '',
      role: 'user',
      text: text.trim(),
      createdAt: null,
      senderId: uid,
    );
    return _messagesCol(chatId).add(msg.toMap());
  }
}
