import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

enum ActivityType { pastor, church, member, department, servant }

class ActivityLog {
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final ActivityType type;
  final String path;

  ActivityLog({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.type,
    required this.path,
  });

  IconData get icon {
    switch (type) {
      case ActivityType.pastor: return Iconsax.user_add;
      case ActivityType.church: return Iconsax.building;
      default: return Iconsax.activity;
    }
  }
}