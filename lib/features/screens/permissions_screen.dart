import 'package:flutter/material.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';

class PermissionsScreen extends StatelessWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Add Permition Detail',
      padding: EdgeInsets.zero,
      child: StyledDataTable(
        columns: const ['Permission', 'Date & Time', 'Activity'],
        rows: List.generate(5, (index) {
          final actions = ['Delete', 'Add', 'Show Result', 'Edit', 'View'];
          return DataRow(cells: [
            DataCell(Text(actions[index % actions.length])),
            const DataCell(Text('07:25:08, 12/11/78')),
            DataCell(Row(
              children: [
                TableActionButton(label: 'ACTIVE', color: AppTheme.primaryBlue, onPressed: () {}),
                const SizedBox(width: 8),
                TableActionButton(label: 'CLEAR', color: AppTheme.destructiveRed, onPressed: () {}),
              ],
            )),
          ]);
        }),
      ),
    );
  }
}