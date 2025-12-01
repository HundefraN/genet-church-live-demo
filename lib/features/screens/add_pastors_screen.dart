import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/notification_system.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/modern_input.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
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
          await ref
              .read(pastorsProvider.notifier)
              .addPastor(
                fullName: nameController.text,
                email: emailController.text,
                password: passwordController.text,
              );
          if (context.mounted) {
            context.showSuccessNotification(
              title: 'Success',
              message: '${nameController.text} has been added as a pastor.',
            );
            clearForm();
            context.go('/report-pastors');
          }
        } catch (e) {
          if (context.mounted) {
            context.showErrorNotification(
              title: 'Error',
              message:
                  'Failed to add pastor. Please check the details and try again.',
            );
          }
          rethrow;
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
              onPressedAsync: addPastor,
            ),
          ),
          const SizedBox(height: 24),
          ModernCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernInput(
                  controller: nameController,
                  label: 'Pastor Full Name',
                  prefixIcon: Iconsax.user,
                  validator: (value) =>
                      value!.isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                EmailInput(controller: emailController),
                const SizedBox(height: 16),
                PasswordInput(
                  controller: passwordController,
                  label: 'Temporary Password',
                  validator: (value) => value!.length < 6
                      ? 'Password must be at least 6 characters'
                      : null,
                ),
                const SizedBox(height: 32),
                SecondaryButton(text: 'Clear Form', onPressed: clearForm),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
