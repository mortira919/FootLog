import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:footlog/domain/stats/repositories/stats_repository.dart';
import 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  final StatsRepository repo;
  final String uid;

  StatsCubit(this.repo, this.uid) : super(const StatsState());

  Future<void> load({int months = 6}) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final data = await repo.monthly(uid, months: months);
      emit(state.copyWith(loading: false, data: data));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
