import 'package:footlog/domain/wellbeing/entities/wellbeing_entry.dart';

abstract class WellbeingRepository {
  /// Прочитать запись на конкретную дату (или null, если её нет)
  Future<WellbeingEntry?> loadEntry({
    required String uid,
    required DateTime date,
  });

  /// Сохранить/перезаписать запись на дату (docId = yyyy-MM-dd)
  Future<void> saveEntry({
    required String uid,
    required WellbeingEntry entry,
  });
}
