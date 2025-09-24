import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/data/services/report_service.dart';
import 'package:iconsax/iconsax.dart';

class ExportReportDialog extends ConsumerWidget {
  const ExportReportDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Iconsax.document_download, color: AppTheme.primaryBlue),
          SizedBox(width: 8),
          Text('Export Report'),
        ],
      ),
      content: const Text('Please select the type of report you would like to export as a CSV file.'),
      actions: <Widget>[
        _ExportOptionTile(
          icon: Iconsax.user_octagon,
          title: 'Pastors Report',
          subtitle: 'Export a list of all pastors.',
          onTap: () {
            ref.read(reportServiceProvider).generateAndDownloadCsv(ReportType.pastors);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Pastor report download has started.'), backgroundColor: Colors.green),
            );
          },
        ),
        const SizedBox(height: 8),
        _ExportOptionTile(
          icon: Iconsax.building,
          title: 'Churches Report',
          subtitle: 'Export a list of all church branches.',
          onTap: () {
            ref.read(reportServiceProvider).generateAndDownloadCsv(ReportType.churches);
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Church report download has started.'), backgroundColor: Colors.green),
            );
          },
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

class _ExportOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ExportOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.scaffoldBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primaryBlue, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const Icon(Iconsax.arrow_right_3, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}