import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/colors/vaxp_colors.dart';
import '../../domain/entities/log_entry.dart';

/// Optimized log list item widget
class LogListItem extends StatelessWidget {
  final LogEntry log;
  final VoidCallback onTap;
  final bool isSelected;

  const LogListItem({
    super.key,
    required this.log,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColor = VaxpColors.getCategoryColor(log.category.englishName);
    final timeFormat = DateFormat('HH:mm:ss');

    return Card(
      color: isSelected 
          ? categoryColor.withValues(alpha: 0.2) 
          : const Color.fromARGB(195, 0, 0, 0),
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              
              // Priority icon
              _buildPriorityIcon(),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      children: [
                        // Source
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log.source,
                            style: TextStyle(
                              fontSize: 11,
                              color: categoryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Category chip
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: categoryColor.withValues(alpha: 0.5),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            log.category.displayName,
                            style: TextStyle(
                              fontSize: 10,
                              color: categoryColor.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                        const Spacer(),
                        // Time
                        Text(
                          timeFormat.format(log.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Message
                    Text(
                      log.message,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.chevron_right,
                color: Colors.grey[600],
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityIcon() {
    IconData icon;
    Color color;

    switch (log.priority.toLowerCase()) {
      case 'error':
      case 'critical':
      case 'emergency':
      case 'alert':
        icon = Icons.error_outline;
        color = VaxpColors.errorColor;
        break;
      case 'warning':
      case 'warn':
        icon = Icons.warning_amber;
        color = VaxpColors.warningColor;
        break;
      case 'debug':
        icon = Icons.bug_report_outlined;
        color = Colors.grey;
        break;
      default:
        icon = Icons.info_outline;
        color = VaxpColors.primaryColor;
    }

    return Icon(icon, color: color, size: 22);
  }
}
