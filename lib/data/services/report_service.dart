import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:intl/intl.dart';

enum ReportType { pastors, churches, members }

final reportServiceProvider = Provider((ref) => ReportService(ref));

class ReportService {
  final Ref _ref;
  ReportService(this._ref);

  Future<void> generateAndDownloadCsv(ReportType reportType) async {
    List<List<dynamic>> rows = [];
    String fileName = '';
    final now = DateFormat('yyyy-MM-dd_HH-mm').format(DateTime.now());

    if (reportType == ReportType.pastors) {
      final pastors = await _ref.read(pastorsProvider.future);
      rows.add([
        'Pastor ID', 'User ID', 'Full Name', 'Email', 'Role', 'Is Active', 'Created At', 'Assigned Church ID'
      ]);
      for (var pastor in pastors) {
        rows.add([
          pastor.id, pastor.userId, pastor.user.fullName, pastor.user.email,
          pastor.user.role, pastor.user.isActive, pastor.user.createdAt, pastor.churchId ?? 'N/A'
        ]);
      }
      fileName = 'pastors_report_$now.csv';
    } else if (reportType == ReportType.churches) {
      final churches = await _ref.read(churchesProvider.future);
      rows.add([
        'Church ID', 'Church Name', 'Location Link', 'Establishment Date', 'Date Created', 'Head Office ID'
      ]);
      for (var church in churches) {
        rows.add([
          church.id, church.name, church.locationLink ?? '',
          church.establishmentDate ?? '', church.dateCreated ?? '', church.headOfficeId ?? ''
        ]);
      }
      fileName = 'churches_report_$now.csv';
    } else if (reportType == ReportType.members) {
      // This is a placeholder until the backend is ready.
      rows.add(['Member ID', 'Full Name', 'Phone Number', 'Status']);
      rows.add(['mem_001', 'Kebede Somebody (Sample)', '555-0101', 'ACTIVE']);
      rows.add(['mem_002', 'Ayele Somebidy (Sample)', '555-0102', 'INACTIVE']);
      fileName = 'members_report_$now.csv';
    }

    if (rows.length <= 1) {
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