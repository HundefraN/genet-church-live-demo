import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/data/models/search_command_model.dart';
import 'package:genet_church_portal/data/services/search_service.dart';
import 'package:iconsax/iconsax.dart';

class SearchOverlay extends ConsumerWidget {
  final Function(SearchCommand command) onCommandSelected;
  const SearchOverlay({super.key, required this.onCommandSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(searchResultsProvider);
    final query = ref.watch(searchQueryProvider);

    if (query.isEmpty) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: results.isEmpty
            ? _buildEmptyState(query)
            : ListView.separated(
          padding: const EdgeInsets.all(8),
          shrinkWrap: true,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final command = results[index];
            return _SearchResultTile(
              command: command,
              query: query,
              onTap: () => onCommandSelected(command),
            );
          },
          separatorBuilder: (context, index) =>
          const Divider(height: 1, indent: 56),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Iconsax.search_zoom_out,
              color: AppTheme.textSecondary, size: 40),
          const SizedBox(height: 16),
          Text(
            'No results found for "$query"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Try searching for a different page or action.',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final SearchCommand command;
  final String query;
  final VoidCallback onTap;

  const _SearchResultTile({
    required this.command,
    required this.query,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.scaffoldBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(command.icon, color: AppTheme.textSecondary, size: 20),
      ),
      title: _HighlightedText(
        text: command.title,
        highlight: query,
      ),
      trailing: Text(
        command.category,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final String highlight;

  const _HighlightedText({required this.text, required this.highlight});

  @override
  Widget build(BuildContext context) {
    final lowerText = text.toLowerCase();
    final lowerHighlight = highlight.toLowerCase();

    if (highlight.isEmpty || !lowerText.contains(lowerHighlight)) {
      return Text(text, style: const TextStyle(fontWeight: FontWeight.w500));
    }

    final startIndex = lowerText.indexOf(lowerHighlight);
    final endIndex = startIndex + highlight.length;

    final before = text.substring(0, startIndex);
    final highlighted = text.substring(startIndex, endIndex);
    final after = text.substring(endIndex);

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style.copyWith(
            fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: highlighted,
            style: const TextStyle(
              backgroundColor: AppTheme.primaryBlue,
              color: Colors.white,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }
}