import 'dart:math';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';

class MockDatabase {
  final List<Member> _members = [
    Member(id: 'mem_1', firstName: 'Abebe', fatherName: 'Kebede', phone: '0911234567', address: 'Bole Sub-city, Woreda 03', churchBranch: 'Genet Church - Mekanisa'),
    Member(id: 'mem_2', firstName: 'Aster', fatherName: 'Tadesse', phone: '0922345678', address: 'Kazanchis, Kirkos area', churchBranch: 'Genet Church - Mekanisa'),
    Member(id: 'mem_3', firstName: 'Biniam', fatherName: 'Samuel', phone: '0933456789', address: 'CMC, near St. Michael', churchBranch: 'Genet Church - Ayat'),
    Member(id: 'mem_4', firstName: 'Chaltu', fatherName: 'Lemma', phone: '0944567890', address: 'Piazza, Arada Sub-city', churchBranch: 'Genet Church - Ayat'),
    Member(id: 'mem_5', firstName: 'Dawit', fatherName: 'Gebremariam', phone: '0912345679', address: 'Mekanisa, near Abo Church', churchBranch: 'Genet Church - Mekanisa'),
    Member(id: 'mem_6', firstName: 'Freweyni', fatherName: 'Worku', phone: '0923456780', address: 'Lebu area, Varnero site', churchBranch: 'Genet Church - Lebu'),
    Member(id: 'mem_7', firstName: 'Hanna', fatherName: 'Haile', phone: '0934567891', address: 'Ayat Condominium, Site 4', churchBranch: 'Genet Church - Ayat'),
    Member(id: 'mem_8', firstName: 'Liya', fatherName: 'Mekonnen', phone: '0945678902', address: 'Summit, Figa area', churchBranch: 'Genet Church - Lebu'),
    Member(id: 'mem_9', firstName: 'Samuel', fatherName: 'Bekele', phone: '0913456780', address: 'Goro, near the Grand Palace', churchBranch: 'Genet Church - Mekanisa'),
    Member(id: 'mem_10', firstName: 'Tsegaye', fatherName: 'Abebe', phone: '0924567891', address: 'Gerji, Imperial Hotel area', churchBranch: 'Genet Church - Ayat'),
  ];

  final List<Pastor> _pastors = [
    Pastor(id: 'pas_1', name: 'Pastor Aynalem', phone: '+251911111111', address: '06, Burka Gudina', assignedChurch: 'Rohbot Guenet'),
    Pastor(id: 'pas_2', name: 'Pastor Kebede', phone: '+251922222222', address: '08, Arada', assignedChurch: 'Shashemene Guenet'),
    Pastor(id: 'pas_3', name: 'Pastor John', phone: '+251933333333', address: '10, Bole', assignedChurch: 'Genet Church - Mekanisa'),
    Pastor(id: 'pas_4', name: 'Pastor Jane', phone: '+251944444444', address: '12, Ayat', assignedChurch: 'Genet Church - Ayat'),
  ];

  final List<Church> _churches = [
    Church(id: 'chu_1', name: 'Genet Church - Mekanisa', phoneNumber: '0113214567', officeNumber: '101', email: 'mekanisa@genetchurch.org', locationName: 'Mekanisa, Addis Ababa', pastorIds: ['pas_3']),
    Church(id: 'chu_2', name: 'Genet Church - Ayat', phoneNumber: '0116657890', officeNumber: '202', email: 'ayat@genetchurch.org', locationName: 'Ayat, Addis Ababa', pastorIds: ['pas_4']),
    Church(id: 'chu_3', name: 'Shashemene Guenet', phoneNumber: '+251461101213', officeNumber: '303', email: 'shashemene@genetchurch.org', locationName: '08, Arada', pastorIds: ['pas_2']),
    Church(id: 'chu_4', name: 'Rohbot Guenet', phoneNumber: '+251462201415', officeNumber: '404', email: 'rohbot@genetchurch.org', locationName: '06, Burka Gudina', pastorIds: ['pas_1']),
  ];

  Future<List<Member>> getMembers() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _members;
  }

  Future<void> addMember(Member member) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _members.add(member);
  }

  Future<void> removeMember(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _members.removeWhere((m) => m.id == id);
  }

  Future<List<Pastor>> getPastors() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _pastors;
  }

  Future<void> addPastor(Pastor pastor) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _pastors.add(pastor);
  }

  Future<void> removePastor(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _pastors.removeWhere((p) => p.id == id);
  }

  Future<List<Church>> getChurches() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _churches;
  }

  Future<void> addChurch(Church church) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _churches.add(church);
  }

  Future<void> removeChurch(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _churches.removeWhere((c) => c.id == id);
  }
}