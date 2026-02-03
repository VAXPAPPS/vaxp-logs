import 'package:equatable/equatable.dart';

/// Log category enumeration
enum LogCategory {
  application,
  system,
  security,
  hardware,
  all;

  String get displayName {
    switch (this) {
      case LogCategory.application:
        return 'تطبيقات';
      case LogCategory.system:
        return 'نظام';
      case LogCategory.security:
        return 'أمان';
      case LogCategory.hardware:
        return 'هاردوير';
      case LogCategory.all:
        return 'الكل';
    }
  }

  String get englishName {
    switch (this) {
      case LogCategory.application:
        return 'Application';
      case LogCategory.system:
        return 'System';
      case LogCategory.security:
        return 'Security';
      case LogCategory.hardware:
        return 'Hardware';
      case LogCategory.all:
        return 'All';
    }
  }
}

/// Log entry entity representing a system log
class LogEntry extends Equatable {
  final String id;
  final String message;
  final DateTime timestamp;
  final LogCategory category;
  final String source;
  final String priority;
  final String? processId;
  final String rawLine;

  const LogEntry({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.category,
    required this.source,
    required this.priority,
    this.processId,
    required this.rawLine,
  });

  @override
  List<Object?> get props => [id, message, timestamp, category, source, priority, processId];

  /// Check if log matches search query
  bool matchesQuery(String query) {
    final lowerQuery = query.toLowerCase();
    return message.toLowerCase().contains(lowerQuery) ||
        source.toLowerCase().contains(lowerQuery) ||
        priority.toLowerCase().contains(lowerQuery);
  }
}
