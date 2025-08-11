import '../enums/positions.dart';

class PlayerProfile {
  final String name;
  final Position primaryPosition;
  final List<Position> positions;

  const PlayerProfile({
    required this.name,
    required this.primaryPosition,
    required this.positions,
  });

  PlayerProfile copyWith({
    String? name,
    Position? primaryPosition,
    List<Position>? positions,
  }) {
    return PlayerProfile(
      name: name ?? this.name,
      primaryPosition: primaryPosition ?? this.primaryPosition,
      positions: positions ?? this.positions,
    );
  }
}
