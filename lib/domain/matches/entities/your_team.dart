class YourTeam {
  final String id;
  final String name;
  final String? logoUrl;
  final DateTime? lastPlayedAt;
  final int matchesCount;

  const YourTeam({
    required this.id,
    required this.name,
    this.logoUrl,
    this.lastPlayedAt,
    this.matchesCount = 0,
  });

  static String idFromName(String name) =>
      name.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');

  factory YourTeam.fromMap(String id, Map<String, dynamic> m) => YourTeam(
    id: id,
    name: (m['name'] as String?)?.trim() ?? id,
    logoUrl: m['logoUrl'] as String?,
    lastPlayedAt: (m['lastPlayedAt'] is int)
        ? DateTime.fromMillisecondsSinceEpoch(m['lastPlayedAt'] as int)
        : null,
    matchesCount: (m['matchesCount'] as num?)?.toInt() ?? 0,
  );
}
