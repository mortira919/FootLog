// lib/presentation/pages/wellbeing/wellbeing_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart' as intl;

// + эти два импорта для работы с Firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:footlog/presentation/cubit/wellbeing/wellbeing_cubit.dart';
import 'package:footlog/presentation/cubit/wellbeing/wellbeing_state.dart';

// карточки
import 'package:footlog/presentation/widgets/wellbeing/mood_card.dart';
import 'package:footlog/presentation/widgets/wellbeing/energy_sleep_card.dart';
import 'package:footlog/presentation/widgets/wellbeing/nutrition_card.dart';
import 'package:footlog/presentation/widgets/wellbeing/injury_card.dart';

// экран чата
import 'package:footlog/presentation/pages/chat/coach_chat_page.dart';

class WellbeingPage extends StatelessWidget {
  const WellbeingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WellbeingCubit>();

    return BlocBuilder<WellbeingCubit, WellbeingState>(
      builder: (context, s) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Твоё самочувствие'),
            leading: IconButton(icon: const Icon(Icons.chevron_left), onPressed: cubit.prevDay),
            actions: [IconButton(icon: const Icon(Icons.chevron_right), onPressed: cubit.nextDay)],
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(28.h),
              child: Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  _fmtDate(s.date),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
          body: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              MoodCard(state: s),
              SizedBox(height: 12.h),
              EnergySleepCard(state: s),
              SizedBox(height: 12.h),
              NutritionCard(state: s),
              SizedBox(height: 12.h),


              InjuryCard(
                state: s,
                onAskCoach: () async {
                  final chatId = await _ensureCoachChat();
                  if (context.mounted) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CoachChatPage(chatId: chatId),
                        settings: const RouteSettings(name: '/coach-chat'),
                      ),
                    );


                  }
                },
              ),

              SizedBox(height: 20.h),
              _SaveButton(saving: s.saving, onPressed: cubit.save),
              if (s.error != null) ...[
                SizedBox(height: 12.h),
                Text('Ошибка: ${s.error}', style: TextStyle(color: Colors.red, fontSize: 12.sp)),
              ],
              SizedBox(height: 24.h),
            ],
          ),
        );
      },
    );
  }



  static Future<String> _ensureCoachChat() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('Пользователь не авторизован');
    }

    final db = FirebaseFirestore.instance;

    final q = await db
        .collection('chats')
        .where('participants', arrayContains: uid)
        .where('title', isEqualTo: 'Диалог с тренером')
        .limit(1)
        .get();

    if (q.docs.isNotEmpty) {
      return q.docs.first.id;
    }


    final doc = await db.collection('chats').add({
      'participants': [uid],
      'title': 'Диалог с тренером',
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }
}

class _SaveButton extends StatelessWidget {
  final bool saving;
  final VoidCallback onPressed;
  const _SaveButton({required this.saving, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: saving ? null : onPressed,
        child: saving
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const Text('Сохранить'),
      ),
    );
  }
}

String _fmtDate(DateTime d) => intl.DateFormat('dd.MM.yy').format(d);
