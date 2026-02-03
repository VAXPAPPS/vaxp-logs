import 'package:flutter/material.dart';

import '../../../../core/colors/vaxp_colors.dart';
import '../../domain/entities/log_entry.dart';

/// Sidebar widget for category navigation
class LogsSidebar extends StatelessWidget {
  final LogCategory selectedCategory;
  final Map<LogCategory, int> counts;
  final ValueChanged<LogCategory> onCategorySelected;

  const LogsSidebar({
    super.key,
    required this.selectedCategory,
    required this.counts,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: VaxpColors.glassSurface.withOpacity(0.1),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: VaxpColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.article_outlined,
                    color: VaxpColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السجلات',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'عارض سجلات النظام',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 8),

          // Categories
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                _buildSectionHeader('الفئات'),
                ...LogCategory.values.map((category) => _buildCategoryItem(
                  category: category,
                  count: counts[category] ?? 0,
                  isSelected: selectedCategory == category,
                  onTap: () => onCategorySelected(category),
                )),
              ],
            ),
          ),

          // Footer with stats
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.storage,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 6),
                Text(
                  '${counts[LogCategory.all] ?? 0} سجل',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.grey[500],
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildCategoryItem({
    required LogCategory category,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final color = VaxpColors.getCategoryColor(category.englishName);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected 
                  ? color.withOpacity(0.15) 
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? color.withOpacity(0.3) 
                    : Colors.transparent,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? color.withOpacity(0.2) 
                        : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getCategoryIcon(category),
                    size: 16,
                    color: isSelected ? color : Colors.grey[400],
                  ),
                ),
                const SizedBox(width: 10),
                
                // Label
                Expanded(
                  child: Text(
                    category.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? color : Colors.grey[300],
                    ),
                  ),
                ),
                
                // Count badge
                if (count > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? color.withOpacity(0.2) 
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count > 999 ? '999+' : count.toString(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? color : Colors.grey[400],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
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
