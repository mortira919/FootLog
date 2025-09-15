// lib/presentation/pages/profile/profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

// ключ рутового навигатора (чтобы показывать/закрывать лоадер при логауте)
import 'package:footlog/presentation/navigation/app_router.dart' show rootNavigatorKey;

import 'package:footlog/core/app_theme.dart';
import 'package:footlog/presentation/cubit/profile/profile_cubit.dart';
import 'package:footlog/presentation/cubit/profile/profile_state.dart';
import 'package:footlog/domain/profile/entities/player_profile.dart' as edit_prof;
import 'package:footlog/domain/auth/usecases/logout_usecase.dart';

// мини-шит «полного» редактирования
import '../../widgets/profile/edit_full_profile_sheet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, s) {
        final p = s.data;

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'Профиль',
              style: TextStyle(color: Colors.black),
            ),
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.black),
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            elevation: 0,
          ),
          body: s.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
            padding: EdgeInsets.all(16.w),
            children: [

              AppCard(
                padding: EdgeInsets.all(14.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Основная информация',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    _row('Имя', p.name.isEmpty ? '—' : p.name),
                    _row('Возраст', _ageString(p.birthDate)),
                    _row('Рост и вес', _heightWeight(p)),
                    _row('Рабочая нога', _footRu(p.dominantFoot)),
                    _row(
                      'Позиция',
                      edit_prof.positionLabelsRu[p.position] ?? p.position,
                    ),
                    _row('Игровой номер', p.kitNumber ?? '—'),
                    _row('Команда', p.teamName ?? 'Название'),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 44.h,
                      child: ElevatedButton(
                        onPressed: () async {
                          final current = context.read<ProfileCubit>().state.data;

                          final updated = await showFullProfileSheet(
                            context,
                            initial: current,
                          );
                          if (updated == null) return;

                          final cubit = context.read<ProfileCubit>();
                          cubit.updateName(updated.name);
                          cubit.updateBirthDate(updated.birthDate);
                          cubit.updateHeight(updated.heightCm?.toString() ?? '');
                          cubit.updateWeight(updated.weightKg?.toString() ?? '');
                          cubit.updateDominantFoot(updated.dominantFoot);
                          cubit.updatePosition(updated.position);
                          cubit.updateKitNumber(updated.kitNumber ?? '');
                          cubit.updateTeamName(updated.teamName ?? '');
                          await cubit.save();
                        },
                        child: const Text('Редактировать'),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12.h),


              AppCard(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Настройки',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),

                    _SettingsRow(
                      title: 'Язык приложения',
                      value: 'Русский',
                      onTap: () {
                        // TODO: выбор языка
                      },
                    ),
                    SizedBox(height: 8.h),

                    _SettingsRow(
                      title: 'Цветовая тема',
                      value: 'Светлая',
                      onTap: () {
                        // TODO: выбор темы
                      },
                    ),

                    SizedBox(height: 16.h),

                    _LogoutRow(
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogCtx) => AlertDialog(
                            title: const Text('Выйти из аккаунта?'),
                            content: const Text('Вы сможете войти снова в любое время.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(dialogCtx).pop(false),
                                child: const Text('Отмена'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.of(dialogCtx).pop(true),
                                child: const Text('Выйти'),
                              ),
                            ],
                          ),
                        ) ??
                            false;
                        if (!confirm) return;


                        final rootCtx = rootNavigatorKey.currentContext ?? context;
                        bool loaderShown = false;
                        if (rootCtx.mounted) {
                          loaderShown = true;

                          showDialog(
                            context: rootCtx,
                            barrierDismissible: false,
                            builder: (_) => const Center(child: CircularProgressIndicator()),
                          );
                        }

                        try {
                          await GetIt.I<LogoutUseCase>().call();

                        } catch (e) {
                          final scCtx = rootNavigatorKey.currentContext ?? context;
                          if (scCtx.mounted) {
                            ScaffoldMessenger.of(scCtx).showSnackBar(
                              SnackBar(
                                content: Text('Не удалось выйти: $e'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } finally {

                          final nav = rootNavigatorKey.currentState;
                          if (loaderShown && (nav?.canPop() ?? false)) {
                            nav!.pop();
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  static Widget _row(String l, String r) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            r,
            textAlign: TextAlign.right,
            style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ],
      ),
    );
  }

  static String _ageString(DateTime? bdate) {
    if (bdate == null) return '—';
    final now = DateTime.now();
    var years = now.year - bdate.year;
    final hadBirthday = (now.month > bdate.month) || (now.month == bdate.month && now.day >= bdate.day);
    if (!hadBirthday) years--;

    final n = years % 100, n1 = years % 10;
    String suffix;
    if (n > 10 && n < 20) {
      suffix = 'лет';
    } else if (n1 == 1) {
      suffix = 'год';
    } else if (n1 >= 2 && n1 <= 4) {
      suffix = 'года';
    } else {
      suffix = 'лет';
    }
    return '$years $suffix';
  }

  static String _heightWeight(edit_prof.PlayerProfile p) {
    final h = p.heightCm;
    final w = p.weightKg;
    if (h == null && w == null) return '—';
    if (h != null && w == null) return '$h см';
    if (h == null && w != null) return '$w кг';
    return '$h см, $w кг';
  }

  static String _footRu(String f) => f == 'left' ? 'Левая' : 'Правая';
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.title,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w400,
      color: Colors.black,
    );
    final valueStyle = TextStyle(
      fontSize: 16.sp,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Expanded(child: Text(title, style: titleStyle)),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(value, style: valueStyle),
                SizedBox(width: 8.w),
                Icon(Icons.chevron_right, size: 20.sp, color: Colors.black),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoutRow extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutRow({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Text(
          'Выйти из аккаунта',
          style: TextStyle(
            color: Colors.red,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
