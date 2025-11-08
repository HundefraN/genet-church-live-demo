import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:genet_church_portal/shared_widgets/secondary_button.dart';
import 'package:iconsax/iconsax.dart';

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

    Future<void> addPastor() async {
      if (formKey.currentState?.validate() ?? false) {
        try {
          await ref.read(pastorsProvider.notifier).addPastor(
            fullName: nameController.text,
            email: emailController.text,
            password: passwordController.text,
          );
          if (context.mounted) {
            clearForm();
            context.go('/report-pastors');
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Failed to add pastor. Please check the details and try again.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          throw e;
        }
      }
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          PageHeader(
            title: 'New Pastor Details',
            description:
            'Enter the information for the new pastor. An invitation will be sent to their email to complete their profile.',
            action: PrimaryButton(
              text: 'Add Pastor',
              onPressed: addPastor,
            ),
          ),
          const SizedBox(height: 24),
          ContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernTextField(
                  controller: nameController,
                  hintText: 'Pastor Full Name',
                  icon: Iconsax.user,
                  validator: (value) =>
                  value!.isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: emailController,
                  hintText: 'Email Address',
                  icon: Iconsax.direct_right,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email cannot be empty';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ModernTextField(
                  controller: passwordController,
                  hintText: 'Temporary Password',
                  icon: Iconsax.key,
                  obscureText: true,
                  validator: (value) => value!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 32),
                SecondaryButton(text: 'CLEAR FORM', onPressed: clearForm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}