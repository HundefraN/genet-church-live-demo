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
      padding: EdgeInsets.zero,
      child: StyledDataTable(
        columns: const ['#', 'Pastor Name', 'Phone No', 'Address', 'Assigned Church', 'Actions'],
        rows: pastors.asMap().entries.map((entry) {
          final index = entry.key;
          final pastor = entry.value;
          return DataRow(cells: [
            DataCell(Text((index + 1).toString())),
            DataCell(Text(pastor.name)),
            DataCell(Text(pastor.phone)),
            DataCell(Text(pastor.address)),
            DataCell(Text(pastor.assignedChurch)),
            DataCell(Row(
              children: [
                TableActionButton(
                  label: 'DELETE',
                  color: AppTheme.destructiveRed,
                  onPressed: () {
                    ref.read(pastorsProvider.notifier).removePastor(pastor.id);
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