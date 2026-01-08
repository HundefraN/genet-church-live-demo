import 'dart:convert';
import 'package:web/web.dart' as web;
import 'package:csv/csv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gdev_frontend/state/providers.dart';
import 'package:intl/intl.dart';
import 'dart:js_interop';

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
        'Pastor ID',
        'User ID',
        'Full Name',
        'Email',
        'Role',
        'Is Active',
        'Created At',
        'Assigned Church ID',
      ]);
      for (var pastor in pastors) {
        rows.add([
          pastor.id,
          pastor.userId,
          pastor.user?.fullName ?? '',
          pastor.user?.email ?? '',
          pastor.user?.role ?? '',
          pastor.user?.isActive ?? '',
          pastor.user?.createdAt ?? '',
          pastor.churchId ?? 'N/A',
        ]);
      }
      fileName = 'pastors_report_$now.csv';
    } else if (reportType == ReportType.churches) {
      final churches = await _ref.read(churchesProvider.future);
      rows.add([
        'Church ID',
        'Church Name',
        'Location Link',
        'Establishment Date',
        'Date Created',
        'Head Office ID',
      ]);
      for (var church in churches) {
        rows.add([
          church.id,
          church.name,
          church.locationLink ?? '',
          church.establishmentDate ?? '',
          church.dateCreated ?? '',
          church.headOfficeId ?? '',
        ]);
      }
      fileName = 'churches_report_$now.csv';
    } else if (reportType == ReportType.members) {
      final membersState = await _ref.read(membersListProvider.future);
      final members = membersState.members;
      rows.add([
        'Member ID',
        'Full Name',
        'Phone Number',
        'Gender',
        'Birth Date',
        'Status',
        'Date Created',
      ]);
      for (var member in members) {
        rows.add([
          member.id,
          member.fullName,
          member.phoneNumber,
          member.gender,
          member.birthDate,
          member.memberStatus,
          member.dateCreated,
        ]);
      }
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
    final blob = web.Blob([bytes.toJS].toJS);
    final url = web.URL.createObjectURL(blob);
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement
      ..href = url
      ..download = fileName;
    
    anchor.click();
    web.URL.revokeObjectURL(url);
  }
}
