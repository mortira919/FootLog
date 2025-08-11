import 'package:flutter/material.dart';
import 'edit_profile_sheet.dart';
import '../../../domain/home/entities/player_profile.dart';

/// Хелпер для показа шторки редактирования профиля.
/// Возвращает [PlayerProfile], если пользователь нажал "Готово", иначе null.
Future<PlayerProfile?> showEditProfileBottomSheet({
  required BuildContext context,
  required PlayerProfile initial,
}) {
  return showModalBottomSheet<PlayerProfile>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: EditProfileBottomSheet(initial: initial),
      );
    },
  );
}
