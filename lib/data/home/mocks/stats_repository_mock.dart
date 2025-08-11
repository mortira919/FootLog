import 'dart:async';
import 'package:footlog/domain/home/entities/quick_stats.dart';
import 'package:footlog/domain/home/enums/period.dart';
import 'package:footlog/domain/home/repositories/stats_repository.dart';

class StatsRepositoryMock implements StatsRepository {
  @override
  Future<QuickStats> getQuickStats(String uid, Period period) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return switch (period) {
      Period.m1  => const QuickStats(matches: 34, goals: 34, assists: 34, interceptions: 34, tackles: 34),
      Period.m6  => const QuickStats(matches: 12, goals: 8,  assists: 5,  interceptions: 21, tackles: 19),
      Period.m12 => const QuickStats(matches: 55, goals: 20, assists: 11, interceptions: 70, tackles: 65),
    };
  }
}
