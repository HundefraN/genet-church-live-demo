import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';

class ReportPastorsScreen extends ConsumerWidget {
  const ReportPastorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pastors = ref.watch(pastorsProvider);

    return InfoCard(
      title: 'Pastor Reports',
      description: "Note: Pastor's full name will be displayed here in a future update.",
      padding: EdgeInsets.zero,
      child: StyledDataTable(
        columns: const [
          '#',
          'Full Name',
          'Email',
          'Assigned Church ID',
          'Actions'
        ],
        rows: pastors.asMap().entries.map((entry) {
          final index = entry.key;
          final pastor = entry.value;
          return DataRow(cells: [
            DataCell(Text((index + 1).toString())),
            DataCell(Text(pastor.user.fullName)),
            DataCell(Text(pastor.user.email)),
            DataCell(Text(pastor.churchId ?? 'N/A')),
            DataCell(Row(
              children: [
                TableActionButton(
                  label: 'DELETE',
                  color: AppTheme.destructiveRed,
                  onPressed: () {
                    ref.read(pastorsProvider.notifier).removePastor(pastor.userId);
                  },
                ),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }
}