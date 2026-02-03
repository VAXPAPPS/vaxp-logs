import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/colors/vaxp_colors.dart';
import '../../../../core/venom_layout.dart';
import '../../domain/entities/log_entry.dart';
import '../bloc/logs_bloc.dart';
import '../widgets/log_list_item.dart';
import '../widgets/logs_sidebar.dart';
import 'log_detail_page.dart';

/// Main logs page with sidebar and search
class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<LogsBloc>().add(const LoadLogs());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LogsBloc, LogsState>(
      buildWhen: (previous, current) {
        if (previous is LogsLoaded && current is LogsLoaded) {
          return previous.selectedCategory != current.selectedCategory ||
              previous.logs.length != current.logs.length;
        }
        return true;
      },
      builder: (context, state) {
        final counts = <LogCategory, int>{};
        LogCategory selectedCategory = LogCategory.all;

        if (state is LogsLoaded) {
          for (final category in LogCategory.values) {
            counts[category] = state.getCountByCategory(category);
          }
          selectedCategory = state.selectedCategory;
        }

        return VenomScaffold(
          title: "VaxpLogs",
          sidebar: LogsSidebar(
            selectedCategory: selectedCategory,
            counts: counts,
            onCategorySelected: (category) {
              context.read<LogsBloc>().add(FilterByCategory(category));
            },
          ),
          body: Column(
            children: [
              _buildSearchBar(),
              _buildStatsBar(),
              const Divider(height: 1, color: Color.fromARGB(26, 26, 25, 25)),
              Expanded(child: _buildLogsList()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<LogsBloc>().add(SearchLogs(value));
        },
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'البحث في السجلات...',
          hintStyle: TextStyle(color: Colors.grey[500]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    context.read<LogsBloc>().add(const SearchLogs(''));
                  },
                ),
              BlocBuilder<LogsBloc, LogsState>(
                builder: (context, state) {
                  return IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.grey),
                    tooltip: 'تحديث',
                    onPressed: state is LogsLoading
                        ? null
                        : () => context.read<LogsBloc>().add(const RefreshLogs()),
                  );
                },
              ),
            ],
          ),
          filled: true,
          fillColor: const Color.fromARGB(104, 0, 0, 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: VaxpColors.secondary, width: 1.3),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    return BlocBuilder<LogsBloc, LogsState>(
      buildWhen: (previous, current) {
        if (previous is LogsLoaded && current is LogsLoaded) {
          return previous.filteredLogs.length != current.filteredLogs.length ||
              previous.searchQuery != current.searchQuery;
        }
        return true;
      },
      builder: (context, state) {
        if (state is! LogsLoaded) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.list, size: 18, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(
                '${state.filteredLogs.length} سجل',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 13,
                ),
              ),
              if (state.searchQuery.isNotEmpty) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: VaxpColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'بحث: ${state.searchQuery}',
                    style: const TextStyle(
                      color: VaxpColors.secondary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLogsList() {
    return BlocBuilder<LogsBloc, LogsState>(
      builder: (context, state) {
        if (state is LogsLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: VaxpColors.secondary),
                SizedBox(height: 16),
                Text(
                  'جاري تحميل السجلات...',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        if (state is LogsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: VaxpColors.errorColor),
                const SizedBox(height: 16),
                Text(
                  state.message,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.read<LogsBloc>().add(const LoadLogs()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (state is LogsLoaded) {
          if (state.filteredLogs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey[600]),
                  const SizedBox(height: 16),
                  Text(
                    state.searchQuery.isNotEmpty
                        ? 'لا توجد نتائج للبحث'
                        : 'لا توجد سجلات',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<LogsBloc>().add(const RefreshLogs());
              await Future.delayed(const Duration(seconds: 1));
            },
            color: const Color.fromARGB(110, 255, 182, 122),
            child: ListView.builder(
              controller: _scrollController,
              itemCount: state.filteredLogs.length,
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemBuilder: (context, index) {
                final log = state.filteredLogs[index];
                return LogListItem(
                  key: ValueKey(log.id),
                  log: log,
                  isSelected: state.selectedLog?.id == log.id,
                  onTap: () => _showLogDetail(context, log),
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showLogDetail(BuildContext context, LogEntry log) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LogDetailPage(log: log),
      ),
    );
  }
}
