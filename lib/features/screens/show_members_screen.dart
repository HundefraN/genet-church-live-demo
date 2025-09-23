import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';

class ShowMembersScreen extends ConsumerWidget {
  const ShowMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const InfoCard(
      title: 'Member Records',
      description: 'This feature is currently under development and will be available soon.',
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Members Feature Coming Soon',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}