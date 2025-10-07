class Session {
  final String id;
  final DateTime createdAt;
  final DateTime expiresAt;
  final String userAgent;
  final bool isCurrent;

  Session({
    required this.id,
    required this.createdAt,
    required this.expiresAt,
    required this.userAgent,
    this.isCurrent = false,
  });

  factory Session.fromJson(Map<String, dynamic> json, {String? currentSessionId}) {
    final sessionId = json['id'] as String;
    return Session(
      id: sessionId,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      userAgent: json['userAgent'] as String? ?? 'Unknown Device',
      isCurrent: currentSessionId != null && sessionId == currentSessionId,
    );
  }
}