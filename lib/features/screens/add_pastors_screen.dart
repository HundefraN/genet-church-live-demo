import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/data/models/pastor_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/custom_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/custom_text_field.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:genet_church_portal/shared_widgets/secondary_button.dart';
import 'package:go_router/go_router.dart';

class AddPastorsScreen extends HookConsumerWidget {
  const AddPastorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final addressController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    void clearForm() {
      nameController.clear();
      phoneController.clear();
      addressController.clear();
    }

    void addPastor() {
      final newPastor = Pastor(
        id: 'pas_${Random().nextInt(999)}',
        name: nameController.text,
        phone: phoneController.text,
        address: addressController.text,
        assignedChurch: 'Rohbot Guenet', // Default value
      );

      ref.read(pastorsProvider.notifier).addPastor(newPastor);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newPastor.name} has been added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      clearForm();
      context.go('/report-pastors');
    }

    return Form(
      key: formKey,
      child: InfoCard(
        title: 'Add Pastor\'s Detail',
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            CustomTextField(controller: nameController, hintText: 'Pastor Name'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: CustomTextField(controller: phoneController, hintText: 'Phone Number')),
                const SizedBox(width: 16),
                const Expanded(child: CustomTextField(hintText: 'Office Number')),
              ],
            ),
            const SizedBox(height: 16),
            const CustomTextField(hintText: 'Email'),
            const SizedBox(height: 16),
            CustomTextField(controller: addressController, hintText: 'Address'),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: CustomDropdown(hintText: 'Branch Church', items: ['Genet Church - Mekanisa', 'Genet Church - Ayat'])),
                SizedBox(width: 16),
                Expanded(child: CustomDropdown(hintText: 'Permission', items: ['Admin', 'Editor'])),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                PrimaryButton(text: 'ADD PASTOR', onPressed: addPastor),
                const SizedBox(width: 16),
                SecondaryButton(text: 'CLEAR', onPressed: clearForm),
              ],
            )
          ],
        ),
      ),
    );
  }
}