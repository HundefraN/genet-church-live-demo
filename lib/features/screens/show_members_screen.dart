import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';

class ShowMembersScreen extends ConsumerWidget {
  const ShowMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final members = ref.watch(membersProvider);

    return InfoCard(
      title: 'Member Records',
      padding: EdgeInsets.zero,
      child: StyledDataTable(
        columns: const ['#', 'Full Name', 'Phone No', 'Address', 'Church Branch', 'Actions'],
        rows: members.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          return DataRow(cells: [
            DataCell(Text((index + 1).toString())),
            DataCell(Text(member.fullName)),
            DataCell(Text(member.phone)),
            DataCell(Text(member.address)),
            DataCell(Text(member.churchBranch)),
            DataCell(Row(
              children: [
                TableActionButton(label: 'EDIT', color: AppTheme.primaryBlue, onPressed: () {}),
                const SizedBox(width: 8),
                TableActionButton(
                  label: 'DELETE',
                  color: AppTheme.destructiveRed,
                  onPressed: () {
                    ref.read(membersProvider.notifier).removeMember(member.id);
                  },
                ),
                const SizedBox(width: 8),
                TableActionButton(label: 'VIEW', color: Colors.grey.shade600, onPressed: () {}),
              ],
            )),
          ]);
        }).toList(),
      ),
    );
  }
}