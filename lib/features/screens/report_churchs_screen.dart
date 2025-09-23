import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';

class ReportChurchsScreen extends ConsumerWidget {
  const ReportChurchsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churches = ref.watch(churchesProvider);

    return InfoCard(
      title: 'Church Reports',
      padding: EdgeInsets.zero,
      child: StyledDataTable(
        columns: const [
          '#',
          'Church Name',
          'Head Office ID',
          'Location Link',
          'Actions'
        ],
        rows: churches.asMap().entries.map((entry) {
          final index = entry.key;
          final church = entry.value;
          return DataRow(cells: [
            DataCell(Text((index + 1).toString())),
            DataCell(Text(church.name)),
            DataCell(Text(church.headOfficeId ?? 'N/A')),
            DataCell(Text(church.locationLink ?? 'N/A')),
            DataCell(Row(
              children: [
                TableActionButton(
                  label: 'DELETE',
                  color: AppTheme.destructiveRed,
                  onPressed: () async {
                    try {
                      await ref.read(churchesProvider.notifier).removeChurch(church.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Church deleted successfully.'), backgroundColor: Colors.green),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete church: Server error.'), backgroundColor: Colors.red),
                      );
                    }
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