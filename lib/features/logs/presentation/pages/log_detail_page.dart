import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors/vaxp_colors.dart';
import '../../domain/entities/log_entry.dart';

/// Log detail page showing full log information
class LogDetailPage extends StatelessWidget {
  final LogEntry log;

  const LogDetailPage({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    final categoryColor = VaxpColors.getCategoryColor(log.category.englishName);
    final dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

    return Scaffold(
      backgroundColor: const Color.fromARGB(188, 0, 0, 0),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(188, 30, 30, 30),
        title: const Text('Log Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy',
            onPressed: () => _copyToClipboard(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Card(
              color: const Color.fromARGB(134, 32, 32, 32),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and priority row
                    Row(
                      children: [
                        _buildCategoryChip(categoryColor),
                        const SizedBox(width: 12),
                        _buildPriorityChip(),
                        const Spacer(),
                        if (log.processId != null)
                          _buildInfoChip('PID: ${log.processId}', Colors.grey),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Source
                    _buildInfoRow(
                      Icons.source,
                      'Source',
                      log.source,
                      categoryColor,
                    ),
                    const Divider(height: 24, color: Colors.grey),

                    // Timestamp
                    _buildInfoRow(
                      Icons.access_time,
                      'Time',
                      dateTimeFormat.format(log.timestamp),
                      VaxpColors.primaryColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Message card
            Card(
              color: const Color.fromARGB(134, 32, 32, 32),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.message,
                          color: VaxpColors.primaryColor,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Message',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 18),
                          onPressed: () => _copyMessage(context),
                          tooltip: 'Copy Message',
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: VaxpColors.backgroundDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                      ),
                      child: SelectableText(
                        log.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          height: 1.5,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Raw line card
            Card(
              color: const Color.fromARGB(134, 32, 32, 32),
              child: ExpansionTile(
                leading: const Icon(Icons.code, color: Colors.grey),
                title: const Text(
                  'Raw Line',
                  style: TextStyle(color: Colors.white70),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        log.rawLine,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getCategoryIcon(log.category), size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            log.category.displayName,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityChip() {
    final (color, icon) = _getPriorityInfo();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            log.priority.toUpperCase(),
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: color, fontFamily: 'monospace'),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  (Color, IconData) _getPriorityInfo() {
    switch (log.priority.toLowerCase()) {
      case 'error':
      case 'critical':
      case 'emergency':
      case 'alert':
        return (VaxpColors.errorColor, Icons.error_outline);
      case 'warning':
      case 'warn':
        return (VaxpColors.warningColor, Icons.warning_amber);
      case 'debug':
        return (Colors.grey, Icons.bug_report_outlined);
      default:
        return (VaxpColors.primaryColor, Icons.info_outline);
    }
  }

  IconData _getCategoryIcon(LogCategory category) {
    switch (category) {
      case LogCategory.all:
        return Icons.list_alt;
      case LogCategory.application:
        return Icons.apps;
      case LogCategory.system:
        return Icons.settings_suggest;
      case LogCategory.security:
        return Icons.security;
      case LogCategory.hardware:
        return Icons.memory;
    }
  }

  void _copyToClipboard(BuildContext context) {
    final text =
        '''
Category: ${log.category.displayName}
Source: ${log.source}
Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(log.timestamp)}
Priority: ${log.priority}
${log.processId != null ? 'PID: ${log.processId}\n' : ''}
Message:
${log.message}

Raw Line:
${log.rawLine}
''';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Log copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _copyMessage(BuildContext context) {
    Clipboard.setData(ClipboardData(text: log.message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
