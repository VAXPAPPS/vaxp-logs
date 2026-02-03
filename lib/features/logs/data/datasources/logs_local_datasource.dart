import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../domain/entities/log_entry.dart';
import '../models/log_entry_model.dart';

/// Local data source for reading system logs
class LogsLocalDataSource {
  /// Get logs using journalctl (preferred) or fallback to log files
  Future<List<LogEntry>> getLogs({int limit = 500}) async {
    // Try journalctl first (most reliable on modern Linux)
    try {
      final result = await Process.run(
        'journalctl',
        ['-n', limit.toString(), '-o', 'json', '--no-pager'],
        stdoutEncoding: utf8,
        stderrEncoding: utf8,
      );

      if (result.exitCode == 0 && result.stdout.toString().isNotEmpty) {
        return _parseJournalOutput(result.stdout.toString());
      }
    } catch (e) {
      // journalctl not available, fallback to log files
    }

    // Fallback: Read log files directly
    return _readLogFiles(limit);
  }

  /// Parse journalctl JSON output
  List<LogEntry> _parseJournalOutput(String output) {
    final logs = <LogEntry>[];
    final lines = output.split('\n');
    int index = 0;

    for (final line in lines) {
      if (line.trim().isEmpty) continue;
      try {
        final json = jsonDecode(line) as Map<String, dynamic>;
        final entry = LogEntryModel.fromJournalEntry(json, index);
        if (entry != null) {
          logs.add(entry);
          index++;
        }
      } catch (e) {
        // Skip malformed JSON lines
      }
    }

    return logs;
  }

  /// Read logs from traditional log files
  Future<List<LogEntry>> _readLogFiles(int limit) async {
    final logs = <LogEntry>[];
    final logFiles = [
      '/var/log/syslog',
      '/var/log/messages',
      '/var/log/auth.log',
      '/var/log/kern.log',
    ];

    for (final filePath in logFiles) {
      try {
        final file = File(filePath);
        if (await file.exists()) {
          final lines = await file.readAsLines();
          final startIndex = lines.length > limit ? lines.length - limit : 0;
          
          for (int i = startIndex; i < lines.length; i++) {
            final entry = LogEntryModel.fromSyslogLine(lines[i], logs.length);
            if (entry != null) {
              logs.add(entry);
            }
          }
        }
      } catch (e) {
        // Permission denied or file not accessible
      }
    }

    // If no logs from files, generate demo logs
    if (logs.isEmpty) {
      return _generateDemoLogs(limit);
    }

    // Sort by timestamp descending
    logs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return logs.take(limit).toList();
  }

  /// Generate demo logs for testing when real logs aren't accessible
  List<LogEntry> _generateDemoLogs(int limit) {
    final now = DateTime.now();
    final demoLogs = <LogEntry>[];
    
    final sources = [
      ('systemd', LogCategory.system),
      ('kernel', LogCategory.hardware),
      ('sshd', LogCategory.security),
      ('gnome-shell', LogCategory.application),
      ('NetworkManager', LogCategory.hardware),
      ('sudo', LogCategory.security),
      ('docker', LogCategory.application),
      ('cron', LogCategory.system),
    ];

    final messages = [
      ('Started Session', 'info'),
      ('Device connected: USB Mass Storage', 'info'),
      ('Authentication failure for user admin', 'warning'),
      ('Service started successfully', 'info'),
      ('Network connection established', 'info'),
      ('Permission denied accessing /root', 'error'),
      ('Container started: nginx-app', 'info'),
      ('Scheduled task completed', 'info'),
      ('Memory usage high: 85%', 'warning'),
      ('Disk write error on /dev/sda1', 'error'),
      ('New Bluetooth device paired', 'info'),
      ('Firewall rule updated', 'info'),
      ('Package update available', 'info'),
      ('Session opened for user root', 'warning'),
      ('Core dump generated', 'error'),
    ];

    for (int i = 0; i < limit && i < 200; i++) {
      final sourceInfo = sources[i % sources.length];
      final messageInfo = messages[i % messages.length];

      demoLogs.add(LogEntryModel(
        id: 'demo_$i',
        message: '${messageInfo.$1} [Demo Log #$i]',
        timestamp: now.subtract(Duration(minutes: i * 2)),
        category: sourceInfo.$2,
        source: sourceInfo.$1,
        priority: messageInfo.$2,
        processId: '${1000 + i}',
        rawLine: '${now.subtract(Duration(minutes: i * 2))} ${sourceInfo.$1}: ${messageInfo.$1}',
      ));
    }

    return demoLogs;
  }

  /// Search logs by query
  Future<List<LogEntry>> searchLogs(String query, List<LogEntry> allLogs) async {
    if (query.isEmpty) return allLogs;
    
    final lowerQuery = query.toLowerCase();
    return allLogs.where((log) => log.matchesQuery(lowerQuery)).toList();
  }

  /// Filter logs by category
  List<LogEntry> filterByCategory(LogCategory category, List<LogEntry> allLogs) {
    if (category == LogCategory.all) return allLogs;
    return allLogs.where((log) => log.category == category).toList();
  }

  /// Stream for real-time log monitoring
  Stream<LogEntry> watchLogs() {
    final controller = StreamController<LogEntry>();

    Future<void> startWatching() async {
      try {
        final process = await Process.start(
          'journalctl',
          ['-f', '-o', 'json', '-n', '0'],
        );

        int index = 0;
        process.stdout.transform(utf8.decoder).listen((data) {
          for (final line in data.split('\n')) {
            if (line.trim().isEmpty) continue;
            try {
              final json = jsonDecode(line) as Map<String, dynamic>;
              final entry = LogEntryModel.fromJournalEntry(json, index++);
              if (entry != null) {
                controller.add(entry);
              }
            } catch (e) {
              // Skip malformed entries
            }
          }
        });
      } catch (e) {
        // journalctl not available
        controller.addError('Real-time monitoring not available');
      }
    }

    startWatching();
    return controller.stream;
  }
}
