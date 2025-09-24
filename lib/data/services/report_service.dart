import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:intl/intl.dart';

enum ReportType { pastors, churches }

final reportServiceProvider = Provider((ref) => ReportService(ref));

class ReportService {
  final Ref _ref;
  ReportService(this._ref);

  Future<void> generateAndDownloadCsv(ReportType reportType) async {
    List<List<dynamic>> rows = [];
    String fileName = '';
    final now = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());

    if (reportType == ReportType.pastors) {
      final pastors = _ref.read(pastorsProvider).valueOrNull ?? [];

      // Define professional, comprehensive headers
      rows.add([
        'Pastor ID',
        'User ID',
        'Full Name',
        'Email',
        'Role',
        'Is Active',
        'Created At',
        'Assigned Church ID'
      ]);

      // Map every data point from the model to a cell
      for (var pastor in pastors) {
        rows.add([
          pastor.id,
          pastor.userId,
          pastor.user.fullName,
          pastor.user.email,
          pastor.user.role,
          pastor.user.isActive,
          pastor.user.createdAt,
          pastor.churchId ?? 'N/A'
        ]);
      }
      fileName = 'pastors_report_$now.csv';

    } else if (reportType == ReportType.churches) {
      final churches = _ref.read(churchesProvider).valueOrNull ?? [];

      // Define professional, comprehensive headers
      rows.add([
        'Church ID',
        'Church Name',
        'Location Link',
        'Establishment Date',
        'Date Created',
        'Head Office ID'
      ]);

      // Map every data point from the model to a cell
      for (var church in churches) {
        rows.add([
          church.id,
          church.name,
          church.locationLink ?? '',
          church.establishmentDate ?? '',
          church.dateCreated ?? '',

          church.headOfficeId ?? ''
        ]);
      }
      fileName = 'churches_report_$now.csv';
    }

    if (rows.length <= 1) { // Check if only headers are present
      print("No data available to export for $reportType.");
      return;
    }

    String csv = const ListToCsvConverter().convert(rows);
    _triggerDownload(csv, fileName);
  }

  void _triggerDownload(String csvData, String fileName) {
    final bytes = utf8.encode(csvData);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}