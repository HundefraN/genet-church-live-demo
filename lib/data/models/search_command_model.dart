import 'package:flutter/material.dart';
import 'package:genet_church_portal/shared_widgets/side_menu.dart';

class SearchCommand {
  final String title;
  final String path;
  final IconData icon;
  final String category;
  final List<UserRole> roles;

  SearchCommand({
    required this.title,
    required this.path,
    required this.icon,
    required this.category,
    this.roles = const [
      UserRole.superAdmin,
      UserRole.pastor,
      UserRole.servant,
      UserRole.servantSupporter,
    ],
  });
}