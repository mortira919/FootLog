import 'dart:math' as math;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../pages/chat/coach_chat_page.dart';
import 'chat/coach_chat_fab.dart';

class PageScaffold extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  /// Показывать зелёный пузырёк?
  final bool showCoachFab;

  /// «Чистая» высота навбара (без safe area снизу).
  /// Нужна, чтобы поднять FAB ровно на 8dp над верхом бара.
  final double bottomBarCoreHeight;

  const PageScaffold({
    super.key,
    required this.body,
    this.appBar,
    this.bottomNavigationBar,
    this.showCoachFab = false,
    this.bottomBarCoreHeight = 0,
  });

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    // FAB будет на 8dp выше верхнего края бара: safe + core + 8
    final fabBottom = math.max(0.0, safeBottom) + bottomBarCoreHeight + 8.0.h;

    return Scaffold(
      appBar: appBar,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        children: [
          Positioned.fill(child: body),

          // Строгое позиционирование справа-снизу
          Positioned(
            right: 16.w,
            bottom: fabBottom,
            child: CoachChatFabButton(
              visible: showCoachFab,
              onTap: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Войдите в аккаунт, чтобы открыть чат'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }

                final chatId = await _ensureCoachChatForUid(user.uid);
                if (!context.mounted) return;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CoachChatPage(chatId: chatId),
                    settings: const RouteSettings(name: '/coach-chat'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> _ensureCoachChatForUid(String uid) async {
  final db = FirebaseFirestore.instance;

  final existing = await db
      .collection('chats')
      .where('participants', arrayContains: uid)
      .limit(1)
      .get();

  if (existing.docs.isNotEmpty) return existing.docs.first.id;

  final doc = await db.collection('chats').add({
    'participants': [uid],
    'title': 'Диалог с тренером',
    'createdAt': FieldValue.serverTimestamp(),
  });

  await db.collection('chats/${doc.id}/messages').add({
    'role': 'assistant',
    'text':
    'Привет! Я твой тренер-бот. Спроси про самочувствие, тренировки или матчи 😊',
    'senderId': 'coach-bot',
    'createdAt': FieldValue.serverTimestamp(),
  });

  return doc.id;
}
