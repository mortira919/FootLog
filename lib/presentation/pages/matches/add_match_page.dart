// lib/presentation/pages/matches/add_match_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:footlog/di/di.dart';
import 'package:footlog/core/app_theme.dart';
import 'package:footlog/core/my_result.dart';

import 'package:footlog/domain/matches/entities/opponent.dart';
import 'package:footlog/domain/matches/usecases/get_recent_opponents_usecase.dart';

import 'package:footlog/presentation/cubit/matches/add_match/add_match_cubit.dart';
import 'package:footlog/presentation/cubit/matches/add_match/add_match_state.dart';

import 'package:footlog/presentation/widgets/matches/date_duration_sheet.dart';
import 'package:footlog/presentation/widgets/matches/field_weather_segment.dart';
import 'package:footlog/presentation/widgets/matches/score_stepper.dart';
import 'package:footlog/presentation/widgets/matches/section_card.dart';
import 'package:footlog/presentation/widgets/matches/team_inputs.dart';

import '../../widgets/matches/match_personal_stats_card.dart';

class AddMatchPage extends StatelessWidget {
  const AddMatchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddMatchCubit, AddMatchState>(
      listenWhen: (p, c) => p.error != c.error && c.error != null,
      listener: (ctx, s) {
        if (s.error != null) {
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text(s.error!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddMatchCubit>();

        return Scaffold(
          appBar: AppBar(title: const Text('Добавление матча')),
          body: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // ====== Дата и длительность ======
              MatchSectionCard(
                title: 'Дата и длительность матча',
                child: state.date == null
                    ? Align(
                  alignment: Alignment.center,
                  child: GreenPillButton(
                    text: 'Выбрать дату и длительность',
                    onTap: () async {
                      final picked = await _pickDateDuration(
                        context,
                        initialDate: state.date,
                        initialDuration: state.durationMin,
                      );
                      if (picked != null) {
                        cubit.setDateDuration(picked.$1, picked.$2);
                      }
                    },
                  ),
                )
                    : Center(
                  child: Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: [
                      _InfoPill(
                        text: _datePillLabel(context, state.date!),
                      ),
                      _InfoPill(
                        text: _durationPillLabel(
                            context, state.durationMin),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),

              // ====== Результат матча ======
              MatchSectionCard(
                title: 'Результат матча',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // кнопка выбора соперника из последних
                    Align(
                      alignment: Alignment.center,
                      child: GreenPillButton(
                        text: 'Выбрать соперника из последних',
                        onTap: () async {
                          final picked =
                          await _showOpponentPicker(context); // Opponent?
                          if (picked != null) {
                            context
                                .read<AddMatchCubit>()
                                .setOpponentFromRecent(picked);
                          }
                        },
                      ),
                    ),

                    SizedBox(height: 12.h),

                    // --- Команды (как на макете) ---
                    TeamsLogosRow(
                      yourLogoUrl: state.yourLogoUrl,
                      opponentLogoUrl: state.opponentLogoUrl,
                      loadingYourLogo: state.isUploadingYourLogo,
                      loadingOpponentLogo: state.isUploadingOpponentLogo,
                      onPickYour: () => cubit.pickAndUploadYourLogo(),
                      onPickOpponent: () => cubit.pickAndUploadOpponentLogo(),
                    ),

                    SizedBox(height: 12.h),

                    // Инпуты названий команд
                    TeamInputs(
                      yourTeam: state.yourTeam,
                      opponentTeam: state.opponentTeam,
                      onYourChanged: (v) => cubit.setTeams(yours: v),
                      onOpponentChanged: (v) => cubit.setTeams(opponent: v),
                    ),

                    SizedBox(height: 16.h),

                    Center(
                      child: Text(
                        'Счёт матча',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 8.h),

                    ScoreRowFigma(
                      label: 'Голы вашей команды',
                      value: state.yourGoals,
                      onMinus: () => cubit
                          .setGoals(you: (state.yourGoals - 1).clamp(0, 999)),
                      onPlus: () => cubit
                          .setGoals(you: (state.yourGoals + 1).clamp(0, 999)),
                    ),
                    SizedBox(height: 8.h),
                    ScoreRowFigma(
                      label: 'Голы соперника',
                      value: state.opponentGoals,
                      onMinus: () => cubit
                          .setGoals(opp: (state.opponentGoals - 1).clamp(0, 999)),
                      onPlus: () => cubit
                          .setGoals(opp: (state.opponentGoals + 1).clamp(0, 999)),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),

              // ====== Условия ======
              MatchSectionCard(
                title: 'Условия матча',
                child: FieldWeatherSegment(
                  fieldType: state.fieldType,
                  weather: state.weather,
                  onFieldChanged: cubit.setFieldType,
                  onWeatherChanged: cubit.setWeather,
                ),
              ),

              SizedBox(height: 20.h),

              // ====== Личная статистика ======
              MatchSectionCard(
                title: 'Ваша статистика в матче',
                child: MatchPersonalStatsCard(
                  goals: state.myGoals,
                  assists: state.myAssists,
                  interceptions: state.myInterceptions,
                  tackles: state.myTackles,
                  saves: state.mySaves,
                  onGoals: (v) => cubit.setPersonalStats(goals: v),
                  onAssists: (v) => cubit.setPersonalStats(assists: v),
                  onInterceptions: (v) =>
                      cubit.setPersonalStats(interceptions: v),
                  onTackles: (v) => cubit.setPersonalStats(tackles: v),
                  onSaves: (v) => cubit.setPersonalStats(saves: v),
                ),
              ),

              SizedBox(height: 20.h),

              ElevatedButton(
                onPressed: state.saving
                    ? null
                    : () async {
                  final res = await cubit.submit();
                  if (context.mounted && res is! Error) {
                    Navigator.pop(context, true);
                  }
                },
                child: Text(state.saving ? 'Сохраняю…' : 'Сохранить матч'),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===== helpers =====

  static String _datePillLabel(BuildContext context, DateTime d) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ru') {
      const months = [
        'января',
        'февраля',
        'марта',
        'апреля',
        'мая',
        'июня',
        'июля',
        'августа',
        'сентября',
        'октября',
        'ноября',
        'декабря',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } else {
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    }
  }

  static String _durationPillLabel(BuildContext context, int minutes) {
    final lang = Localizations.localeOf(context).languageCode;
    if (lang == 'ru') {
      return '$minutes ${_ruPlural(minutes, "минута", "минуты", "минут")}';
    }
    return '$minutes minutes';
  }

  static String _ruPlural(int n, String one, String few, String many) {
    final m10 = n % 10, m100 = n % 100;
    if (m10 == 1 && m100 != 11) return one;
    if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return few;
    return many;
  }
}

// Серая «таблетка» с зелёным текстом
class _InfoPill extends StatelessWidget {
  final String text;
  const _InfoPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3F5),
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

// Небольшая зелёная таблетка-кнопка
class GreenPillButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  const GreenPillButton({super.key, required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary.withOpacity(0.12),
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
            ),
          ),
        ),
      ),
    );
  }
}

// ---- Pickers ----
Future<(DateTime, int)?> _pickDateDuration(
    BuildContext context, {
      DateTime? initialDate,
      int initialDuration = 90,
    }) {
  return showDateDurationSheet(
    context,
    initialDate: initialDate,
    initialDurationMin: initialDuration,
  );
}

/// Заголовок «Команды» + две плитки логотипов
class TeamsLogosRow extends StatelessWidget {
  final String? yourLogoUrl;
  final String? opponentLogoUrl;
  final bool loadingYourLogo;
  final bool loadingOpponentLogo;
  final VoidCallback onPickYour;
  final VoidCallback onPickOpponent;

  const TeamsLogosRow({
    super.key,
    required this.yourLogoUrl,
    required this.opponentLogoUrl,
    required this.loadingYourLogo,
    required this.loadingOpponentLogo,
    required this.onPickYour,
    required this.onPickOpponent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Команды',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.black,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: _LogoTile(
                title: 'Логотип вашей\nкоманды',
                imageUrl: yourLogoUrl,
                loading: loadingYourLogo,
                onTap: onPickYour,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _LogoTile(
                title: 'Логотип команды\nсоперников',
                imageUrl: opponentLogoUrl,
                loading: loadingOpponentLogo,
                onTap: onPickOpponent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Квадратная плитка логотипа 72x72 с “+”
class _LogoTile extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final bool loading;
  final VoidCallback? onTap;

  const _LogoTile({
    required this.title,
    this.imageUrl,
    this.loading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = 16.r;
    final s = 72.w; // размер квадрата

    Widget square;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      square = ClipRRect(
        borderRadius: BorderRadius.circular(r),
        child: Stack(
          children: [
            SizedBox(
              width: s,
              height: s,
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFF2F3F5),
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
            if (loading)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    } else {
      square = Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F4),
          borderRadius: BorderRadius.circular(r),
        ),
        alignment: Alignment.center,
        child: loading
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : Icon(Icons.add, size: 24.sp, color: AppColors.black.withOpacity(0.75)),
      );
    }

    return Column(
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.black,
            height: 1.15,
          ),
        ),
        SizedBox(height: 8.h),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(r),
            onTap: loading ? null : onTap,
            child: square,
          ),
        ),
      ],
    );
  }
}

Future<Opponent?> _showOpponentPicker(BuildContext context) async {
  final items = await _loadRecentOpponents(context);
  if (items.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Пока нет последних соперников'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return null;
  }

  Opponent selected = items.first;

  return showModalBottomSheet<Opponent>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (ctx) {
      final bottom = MediaQuery.of(ctx).padding.bottom;
      final maxH = MediaQuery.of(ctx).size.height * 0.75;

      Widget avatar(String? url) {
        final size = 22.r;
        return ClipOval(
          child: Container(
            width: size,
            height: size,
            color: const Color(0xFFB0B3B8),
            child: (url == null || url.isEmpty)
                ? const SizedBox.shrink()
                : Image.network(url, fit: BoxFit.cover),
          ),
        );
      }

      return SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxH),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h + bottom),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Команда-соперник',
                  style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: StatefulBuilder(
                    builder: (ctx, set) => ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1.h, color: AppColors.divider),
                      itemBuilder: (_, i) {
                        final op = items[i];
                        final isSel = op.id == selected.id;

                        return InkWell(
                          onTap: () => set(() => selected = op),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Row(
                              children: [
                                avatar(op.logoUrl),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    op.name,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: AppColors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Icon(
                                  isSel
                                      ? Icons.check_circle
                                      : Icons.radio_button_unchecked,
                                  color: isSel
                                      ? AppColors.primary
                                      : AppColors.divider,
                                  size: 22.sp,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, selected),
                    child: const Text('Готово'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<List<Opponent>> _loadRecentOpponents(BuildContext context) async {
  final uid = context.read<AddMatchCubit>().uid;
  try {
    final uc = getIt<GetRecentOpponentsUseCase>();
    final res = await uc(uid, limit: 20);

    if (res is List<Opponent>) return res;

    if (res is MyResult<List<Opponent>>) {
      return switch (res) {
        Success(:final data) => data,
        Error(:final message) => throw Exception(message),
        _ => <Opponent>[],
      };
    }

    return <Opponent>[];
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка загрузки соперников: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    return <Opponent>[];
  }
}
