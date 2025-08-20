import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/custom_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/custom_text_field.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:genet_church_portal/shared_widgets/secondary_button.dart';
import 'package:go_router/go_router.dart';

class AddChurchScreen extends HookConsumerWidget {
  const AddChurchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final officeController = useTextEditingController();
    final emailController = useTextEditingController();
    final locationController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    void clearForm() {
      nameController.clear();
      phoneController.clear();
      officeController.clear();
      emailController.clear();
      locationController.clear();
    }

    void addChurch() {
      final newChurch = Church(
        id: 'chu_${Random().nextInt(9999)}',
        name: nameController.text,
        phoneNumber: phoneController.text,
        officeNumber: officeController.text,
        email: emailController.text,
        locationName: locationController.text,
        pastorIds: [],
      );

      ref.read(churchesProvider.notifier).addChurch(newChurch);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newChurch.name} has been added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      clearForm();
      context.go('/report-churchs');
    }

    return Form(
      key: formKey,
      child: InfoCard(
        title: 'Add Church\'s Detail',
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            CustomTextField(controller: nameController, hintText: 'Church Name'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: CustomTextField(controller: phoneController, hintText: 'Phone Number')),
                const SizedBox(width: 16),
                Expanded(child: CustomTextField(controller: officeController, hintText: 'Office Number')),
              ],
            ),
            const SizedBox(height: 16),
            CustomTextField(controller: emailController, hintText: 'Email'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: CustomTextField(controller: locationController, hintText: 'Location Name')),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                PrimaryButton(text: 'ADD CHURCH', onPressed: addChurch),
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