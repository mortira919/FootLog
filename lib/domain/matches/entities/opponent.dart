class Opponent {
  final String id;
  final String name;
  final String? logoUrl;
  final DateTime? lastPlayedAt;
  final int matchesCount;

  const Opponent({
    required this.id,
    required this.name,
    this.logoUrl,
    this.lastPlayedAt,
    this.matchesCount = 0,
  });

  static String idFromName(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');

  factory Opponent.fromMap(String id, Map<String, dynamic> m) => Opponent(
    id: id,
    name: (m['name'] as String?)?.trim() ?? id,
    logoUrl: m['logoUrl'] as String?,
    lastPlayedAt: (m['lastPlayedAt'] is int)
        ? DateTime.fromMillisecondsSinceEpoch(m['lastPlayedAt'] as int)
        : null,
    matchesCount: (m['matchesCount'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'logoUrl': logoUrl,
    'lastPlayedAt': lastPlayedAt?.millisecondsSinceEpoch,
    'matchesCount': matchesCount,
    'name_lc': name.toLowerCase(),
  };
}
