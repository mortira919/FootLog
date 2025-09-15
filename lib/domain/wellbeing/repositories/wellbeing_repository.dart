import 'package:footlog/domain/wellbeing/entities/wellbeing_entry.dart';

abstract class WellbeingRepository {

  Future<WellbeingEntry?> loadEntry({
    required String uid,
    required DateTime date,
  });


  Future<void> saveEntry({
    required String uid,
    required WellbeingEntry entry,
  });
}
