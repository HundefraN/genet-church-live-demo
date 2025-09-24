import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:genet_church_portal/shared_widgets/secondary_button.dart';
import 'package:iconsax/iconsax.dart';

class AddChurchScreen extends HookConsumerWidget {
  const AddChurchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final locationLinkController = useTextEditingController();
    final establishmentDateController = useTextEditingController();
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);

    // This is the hardcoded Head Office ID for the Addis Ababa region.
    const addisAbabaHeadOfficeId = "030fb270-bf4c-431c-aa0c-927c8eafd76d";

    void clearForm() {
      nameController.clear();
      locationLinkController.clear();
      establishmentDateController.clear();
    }

    void addChurch() async {
      if (!(formKey.currentState?.validate() ?? false)) return;

      isLoading.value = true;
      final newChurch = Church(
        id: '',
        name: nameController.text,
        locationLink: locationLinkController.text.isNotEmpty ? locationLinkController.text : null,
        establishmentDate: establishmentDateController.text.isNotEmpty
            ? DateTime.tryParse(establishmentDateController.text)?.toIso8601String()
            : null,
        headOfficeId: addisAbabaHeadOfficeId, // Use the hardcoded ID
      );

      try {
        await ref.read(churchesProvider.notifier).addChurch(newChurch);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${newChurch.name} has been added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          clearForm();
          context.go('/report-churchs');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add church. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (context.mounted) {
          isLoading.value = false;
        }
      }
    }

    return Form(
      key: formKey,
      child: Column(
        children: [
          PageHeader(
            title: 'New Church Details',
            description: 'Add a new church branch to the database. It will be automatically assigned to the Addis Ababa Head Office.',
            action: PrimaryButton(
              text: 'Save Church',
              onPressed: addChurch,
              isLoading: isLoading.value,
              icon: Iconsax.save_2,
            ),
          ),
          const SizedBox(height: 24),
          ContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ModernTextField(
                  controller: nameController,
                  hintText: 'New Church Name',
                  icon: Iconsax.building,
                  validator: (value) =>
                  value!.isEmpty ? 'Name cannot be empty' : null,
                ),
                const SizedBox(height: 16),
                ModernTextField(
                    controller: locationLinkController,
                    hintText: 'Google Maps Link (Optional)',
                    icon: Iconsax.map_1),
                const SizedBox(height: 16),
                ModernTextField(
                    controller: establishmentDateController,
                    hintText: 'Establishment Date (e.g., 2020-02-15) (Optional)',
                    icon: Iconsax.calendar_1),
                const SizedBox(height: 32),
                Row(
                  children: [
                    // The PrimaryButton is now in the PageHeader
                    SecondaryButton(text: 'CLEAR FORM', onPressed: clearForm),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}