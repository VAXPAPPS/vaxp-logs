import '../../domain/entities/log_entry.dart';

/// Data model for LogEntry with parsing capabilities
class LogEntryModel extends LogEntry {
  const LogEntryModel({
    required super.id,
    required super.message,
    required super.timestamp,
    required super.category,
    required super.source,
    required super.priority,
    super.processId,
    required super.rawLine,
  });

  /// Parse a syslog line into LogEntryModel
  /// Format: Month Day HH:MM:SS hostname process[pid]: message
  static LogEntryModel? fromSyslogLine(String line, int index) {
    try {
      // Skip empty lines
      if (line.trim().isEmpty) return null;

      // Basic syslog parsing
      final regex = RegExp(
        r'^(\w+\s+\d+\s+\d+:\d+:\d+)\s+(\S+)\s+(\S+?)(?:\[(\d+)\])?:\s*(.*)$',
      );

      final match = regex.firstMatch(line);
      if (match == null) {
        // Fallback for non-standard lines
        return LogEntryModel(
          id: 'log_$index',
          message: line,
          timestamp: DateTime.now(),
          category: _categorizeByContent(line),
          source: 'unknown',
          priority: 'info',
          rawLine: line,
        );
      }

      final timestampStr = match.group(1)!;
      final process = match.group(3)!;
      final pid = match.group(4);
      final message = match.group(5)!;

      final timestamp = _parseTimestamp(timestampStr);
      final category = _categorizeBySource(process, message);
      final priority = _extractPriority(message);

      return LogEntryModel(
        id: 'log_$index',
        message: message,
        timestamp: timestamp,
        category: category,
        source: process,
        priority: priority,
        processId: pid,
        rawLine: line,
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse journalctl JSON output
  static LogEntryModel? fromJournalEntry(Map<String, dynamic> json, int index) {
    try {
      final message = json['MESSAGE'] as String? ?? '';
      final syslogIdentifier = json['SYSLOG_IDENTIFIER'] as String? ?? 'system';
      final priorityStr = json['PRIORITY'] as String? ?? '6';
      final pid = json['_PID'] as String?;
      final timestampMicros = json['__REALTIME_TIMESTAMP'] as String?;

      DateTime timestamp;
      if (timestampMicros != null) {
        final micros = int.tryParse(timestampMicros) ?? 0;
        timestamp = DateTime.fromMicrosecondsSinceEpoch(micros);
      } else {
        timestamp = DateTime.now();
      }

      final category = _categorizeBySource(syslogIdentifier, message);
      final priority = _priorityFromLevel(int.tryParse(priorityStr) ?? 6);

      return LogEntryModel(
        id: 'log_$index',
        message: message,
        timestamp: timestamp,
        category: category,
        source: syslogIdentifier,
        priority: priority,
        processId: pid,
        rawLine: message,
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse timestamp from syslog format
  static DateTime _parseTimestamp(String timestampStr) {
    try {
      final now = DateTime.now();
      final parts = timestampStr.split(RegExp(r'\s+'));
      if (parts.length < 3) return now;

      final months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6,
        'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };

      final month = months[parts[0]] ?? now.month;
      final day = int.tryParse(parts[1]) ?? now.day;
      final timeParts = parts[2].split(':');
      final hour = int.tryParse(timeParts[0]) ?? 0;
      final minute = int.tryParse(timeParts[1]) ?? 0;
      final second = timeParts.length > 2 ? int.tryParse(timeParts[2]) ?? 0 : 0;

      return DateTime(now.year, month, day, hour, minute, second);
    } catch (e) {
      return DateTime.now();
    }
  }

  /// Categorize log by source process
  static LogCategory _categorizeBySource(String source, String message) {
    final lowerSource = source.toLowerCase();
    final lowerMessage = message.toLowerCase();

    // Security related
    if (lowerSource.contains('auth') ||
        lowerSource.contains('sudo') ||
        lowerSource.contains('sshd') ||
        lowerSource.contains('pam') ||
        lowerSource.contains('polkit') ||
        lowerSource.contains('security') ||
        lowerMessage.contains('authentication') ||
        lowerMessage.contains('password') ||
        lowerMessage.contains('session opened') ||
        lowerMessage.contains('session closed')) {
      return LogCategory.security;
    }

    // Hardware related
    if (lowerSource.contains('kernel') ||
        lowerSource.contains('udev') ||
        lowerSource.contains('usb') ||
        lowerSource.contains('disk') ||
        lowerSource.contains('nvidia') ||
        lowerSource.contains('bluetooth') ||
        lowerSource.contains('wpa_supplicant') ||
        lowerSource.contains('networkmanager') ||
        lowerMessage.contains('device') ||
        lowerMessage.contains('driver') ||
        lowerMessage.contains('hardware')) {
      return LogCategory.hardware;
    }

    // Application related
    if (lowerSource.contains('gnome') ||
        lowerSource.contains('kde') ||
        lowerSource.contains('chrome') ||
        lowerSource.contains('firefox') ||
        lowerSource.contains('code') ||
        lowerSource.contains('snap') ||
        lowerSource.contains('flatpak') ||
        lowerSource.contains('docker') ||
        lowerSource.contains('flutter')) {
      return LogCategory.application;
    }

    // Default to system
    return LogCategory.system;
  }

  /// Categorize by content (fallback)
  static LogCategory _categorizeByContent(String content) {
    final lower = content.toLowerCase();
    if (lower.contains('error') || lower.contains('warning') || lower.contains('fail')) {
      return LogCategory.system;
    }
    if (lower.contains('auth') || lower.contains('login') || lower.contains('password')) {
      return LogCategory.security;
    }
    if (lower.contains('usb') || lower.contains('disk') || lower.contains('device')) {
      return LogCategory.hardware;
    }
    return LogCategory.application;
  }

  /// Extract priority from message
  static String _extractPriority(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('error') || lower.contains('critical') || lower.contains('emergency')) {
      return 'error';
    }
    if (lower.contains('warning') || lower.contains('warn')) {
      return 'warning';
    }
    if (lower.contains('debug')) {
      return 'debug';
    }
    return 'info';
  }

  /// Convert numeric priority to string
  static String _priorityFromLevel(int level) {
    switch (level) {
      case 0:
        return 'emergency';
      case 1:
        return 'alert';
      case 2:
        return 'critical';
      case 3:
        return 'error';
      case 4:
        return 'warning';
      case 5:
        return 'notice';
      case 6:
        return 'info';
      case 7:
        return 'debug';
      default:
        return 'info';
    }
  }
}
