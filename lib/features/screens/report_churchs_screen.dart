import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';

import '../../data/models/pastor_model.dart';

class ReportChurchsScreen extends ConsumerWidget {
  const ReportChurchsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final churches = ref.watch(churchesProvider);
    final pastors = ref.watch(pastorsProvider);

    String getPastorName(String pastorId) {
      return pastors.firstWhere((p) => p.id == pastorId, orElse: () => Pastor(id: '', name: 'N/A', phone: '', address: '', assignedChurch: '')).name;
    }

    return InfoCard(
      title: 'Church Reports',
      padding: EdgeInsets.zero,
      child: StyledDataTable(
        columns: const ['#', 'Church Name', 'Phone No', 'Address', 'Pastors', 'Actions'],
        rows: churches.asMap().entries.map((entry) {
          final index = entry.key;
          final church = entry.value;
          return DataRow(cells: [
            DataCell(Text((index + 1).toString())),
            DataCell(Text(church.name)),
            DataCell(Text(church.phoneNumber)),
            DataCell(Text(church.locationName)),
            DataCell(Text(church.pastorIds.map(getPastorName).join(', '))),
            DataCell(Row(
              children: [
                TableActionButton(
                  label: 'DELETE',
                  color: AppTheme.destructiveRed,
                  onPressed: () {
                    ref.read(churchesProvider.notifier).removeChurch(church.id);
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