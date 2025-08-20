import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/custom_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/custom_text_field.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:genet_church_portal/shared_widgets/secondary_button.dart';
import 'package:go_router/go_router.dart';

class AddMembersScreen extends HookConsumerWidget {
  const AddMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstNameController = useTextEditingController();
    final fatherNameController = useTextEditingController();
    final phoneController = useTextEditingController();
    final addressController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    void clearForm() {
      firstNameController.clear();
      fatherNameController.clear();
      phoneController.clear();
      addressController.clear();
    }

    void addMember() {
      final newMember = Member(
        id: 'mem_${Random().nextInt(9999)}',
        firstName: firstNameController.text,
        fatherName: fatherNameController.text,
        phone: phoneController.text,
        address: addressController.text,
        churchBranch: 'Genet Church - Mekanisa', // Default value
      );

      ref.read(membersProvider.notifier).addMember(newMember);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${newMember.fullName} has been registered successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      clearForm();
      context.go('/show-members');
    }

    return Form(
      key: formKey,
      child: InfoCard(
        title: 'Register New Member',
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            Row(
              children: [
                Expanded(child: CustomTextField(controller: firstNameController, hintText: 'First Name')),
                const SizedBox(width: 16),
                Expanded(child: CustomTextField(controller: fatherNameController, hintText: 'Father\'s Name')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Expanded(child: CustomDropdown(hintText: 'Gender', items: ['Male', 'Female'])),
                const SizedBox(width: 16),
                Expanded(child: CustomTextField(controller: phoneController, hintText: 'Phone Number')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: CustomTextField(controller: addressController, hintText: 'Full Address')),
                const SizedBox(width: 16),
                const Expanded(child: CustomDropdown(hintText: 'Marital Status', items: ['Single', 'Married', 'Divorced', 'Widowed'])),
              ],
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                PrimaryButton(text: 'REGISTER MEMBER', onPressed: addMember),
                const SizedBox(width: 16),
                SecondaryButton(text: 'CLEAR FORM', onPressed: clearForm),
              ],
            )
          ],
        ),
      ),
    );
  }
}