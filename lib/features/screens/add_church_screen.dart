import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/custom_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/custom_text_field.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import '../../shared_widgets/primary_button.dart';
import '../../shared_widgets/secondary_button.dart';

// Create a new provider that returns the Future directly, which we can use with FutureBuilder.
// This is a common pattern for handling loading/error states for one-time fetches.
final churchesFutureProvider = FutureProvider.autoDispose<List<Church>>((ref) {
  return ref.watch(churchesProvider.notifier).loadChurches();
});

class AddChurchScreen extends HookConsumerWidget {
  const AddChurchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final locationLinkController = useTextEditingController();
    final establishmentDateController = useTextEditingController();

    // State for the selected head office ID from the dropdown
    final selectedHeadOfficeId = useState<String?>(null);

    final formKey = useMemoized(() => GlobalKey<FormState>());

    // Use the new future provider to get loading and error states
    final churchesAsyncValue = ref.watch(churchesFutureProvider);

    void clearForm() {
      nameController.clear();
      locationLinkController.clear();
      establishmentDateController.clear();
      selectedHeadOfficeId.value = null;
    }

    void addChurch() {
      if (formKey.currentState?.validate() ?? false) {
        if (selectedHeadOfficeId.value == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a Head Office.'),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }

        final newChurch = Church(
          id: '',
          name: nameController.text,
          locationLink: locationLinkController.text,
          establishmentDate: establishmentDateController.text.isNotEmpty
              ? DateTime.parse(establishmentDateController.text).toIso8601String()
              : null,
          headOfficeId: selectedHeadOfficeId.value,
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
    }

    return Form(
      key: formKey,
      child: InfoCard(
        title: 'Add Church\'s Detail',
        child: churchesAsyncValue.when(
          data: (churchList) {
            // Create a list of church names for the dropdown
            final churchNames = churchList.map((church) => church.name).toList();

            return ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: [
                CustomTextField(controller: nameController, hintText: 'New Church Name'),
                const SizedBox(height: 16),
                CustomDropdown(
                  hintText: 'Select Head Office',
                  items: churchNames,
                  onChanged: (churchName) {
                    if (churchName != null) {
                      // Find the church object that matches the selected name
                      final selectedChurch = churchList.firstWhere((church) => church.name == churchName);
                      selectedHeadOfficeId.value = selectedChurch.id;
                    }
                  },
                  value: selectedHeadOfficeId.value != null
                  // Find the name of the church that matches the currently selected ID
                      ? churchList.firstWhere((church) => church.id == selectedHeadOfficeId.value).name
                      : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                    controller: locationLinkController,
                    hintText: 'Google Maps Link (Optional)'),
                const SizedBox(height: 16),
                CustomTextField(
                    controller: establishmentDateController,
                    hintText: 'Establishment Date (e.g., 2020-02-15) (Optional)'),
                const SizedBox(height: 32),
                Row(
                  children: [
                    PrimaryButton(text: 'ADD CHURCH', onPressed: addChurch),
                    const SizedBox(width: 16),
                    SecondaryButton(text: 'CLEAR', onPressed: clearForm),
                  ],
                )
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text('Error loading churches for dropdown: $err')),
        ),
      ),
    );
  }
}