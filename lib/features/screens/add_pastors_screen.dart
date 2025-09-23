import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/custom_text_field.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:genet_church_portal/shared_widgets/secondary_button.dart';

class AddPastorsScreen extends HookConsumerWidget {
  const AddPastorsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());

    void clearForm() {
      nameController.clear();
      emailController.clear();
      passwordController.clear();
    }

    void addPastor() {
      if (formKey.currentState?.validate() ?? false) {
        ref.read(pastorsProvider.notifier).addPastor(
          fullName: nameController.text,
          email: emailController.text,
          password: passwordController.text,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${nameController.text} has been added successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        clearForm();
        context.go('/report-pastors');
      }
    }

    return Form(
      key: formKey,
      child: InfoCard(
        title: 'Add Pastor\'s Detail',
        child: ListView(
          shrinkWrap: true,
          physics: const ClampingScrollPhysics(),
          children: [
            CustomTextField(
                controller: nameController, hintText: 'Pastor Full Name'),
            const SizedBox(height: 16),
            CustomTextField(controller: emailController, hintText: 'Email'),
            const SizedBox(height: 16),
            CustomTextField(
              controller: passwordController,
              hintText: 'Password',
              obscureText: true,
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