import 'package:flutter/material.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoCard(
      title: 'Manage Categories',
      description: 'Add, edit, or remove member categories and groups from this section.',
      child: Center(
        child: Text(
          'Categories Management - Content Coming Soon',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      ),
    );
  }
}