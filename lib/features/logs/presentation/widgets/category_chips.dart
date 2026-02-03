import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/log_entry.dart';

/// Category filter chips widget
class CategoryChips extends StatelessWidget {
  final LogCategory selectedCategory;
  final Map<LogCategory, int> counts;
  final ValueChanged<LogCategory> onCategorySelected;

  const CategoryChips({
    super.key,
    required this.selectedCategory,
    required this.counts,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: LogCategory.values.map((category) {
          final isSelected = selectedCategory == category;
          final color = AppTheme.getCategoryColor(category.englishName);
          final count = counts[category] ?? 0;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              onSelected: (_) => onCategorySelected(category),
              backgroundColor: AppTheme.cardDark,
              selectedColor: color.withValues(alpha: 0.3),
              checkmarkColor: color,
              side: BorderSide(
                color: isSelected ? color : Colors.transparent,
                width: 1.5,
              ),
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getCategoryIcon(category),
                    size: 16,
                    color: isSelected ? color : Colors.grey[400],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    category.displayName,
                    style: TextStyle(
                      color: isSelected ? color : Colors.grey[300],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? color.withValues(alpha: 0.3) 
                            : Colors.grey[700],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        count > 999 ? '999+' : count.toString(),
                        style: TextStyle(
                          fontSize: 11,
                          color: isSelected ? color : Colors.grey[400],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
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
}
