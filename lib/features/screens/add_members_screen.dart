// lib/features/screens/add_members_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/custom_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:iconsax/iconsax.dart';

import '../../core/theme/app_theme.dart';

class AddMembersScreen extends HookConsumerWidget {
  const AddMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);

    final fullNameController = useTextEditingController();
    final phoneNumberController = useTextEditingController();
    final birthDateController = useTextEditingController();
    final birthPlaceController = useTextEditingController();
    final motherTongueController = useTextEditingController();
    final cityController = useTextEditingController();
    final subCityController = useTextEditingController();
    final woredaController = useTextEditingController();
    final placeNameController = useTextEditingController();

    final gender = useState<Gender?>(null);
    final marriageStatus = useState<MarriageStatus?>(null);
    final educationLevel = useState<EducationLevel?>(null);
    final jobStatus = useState<JobStatus?>(null);
    final incomeRange = useState<IncomeRange?>(null);
    final baptismStatus = useState<BaptismStatus?>(null);

    void addMember() async {
      if (!(formKey.currentState?.validate() ?? false)) return;
      if (gender.value == null ||
          marriageStatus.value == null ||
          educationLevel.value == null ||
          jobStatus.value == null ||
          incomeRange.value == null ||
          baptismStatus.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all required dropdown fields.'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      isLoading.value = true;

      final newMember = Member(
        fullName: fullNameController.text,
        phoneNumber: phoneNumberController.text,
        birthDate: birthDateController.text,
        birthPlace: birthPlaceController.text,
        motherTongue: motherTongueController.text,
        gender: gender.value!,
        marriageStatus: marriageStatus.value!,
        address: Address(
          city: cityController.text,
          subCity: subCityController.text,
          woreda: woredaController.text,
          placeName: placeNameController.text,
        ),
        educationLevel: educationLevel.value!,
        jobStatus: jobStatus.value!,
        incomeRange: incomeRange.value!,
        baptismStatus: baptismStatus.value!,
        memberStatus: MemberStatus.ACTIVE,
      );

      try {
        const hardcodedChurchId = "c75631fc-861d-4cf3-94bb-9212fa542b9f";

        await ref
            .read(membersProvider.notifier)
            .addMember(member: newMember, churchId: hardcodedChurchId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Member added successfully!'),
            backgroundColor: Colors.green,
          ));
          context.go('/dashboard');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add member: $e'),
            backgroundColor: Colors.red,
          ));
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PageHeader(
            title: 'Register New Church Member',
            description: 'Please fill in all the required details accurately.',
            action: PrimaryButton(
              text: 'Save Member',
              icon: Iconsax.save_2,
              onPressed: addMember,
              isLoading: isLoading.value,
            ),
          ),
          const SizedBox(height: 24),
          ContentCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Personal & Contact', Iconsax.user),
                const SizedBox(height: 16),
                _formRow([
                  ModernTextField(
                      controller: fullNameController,
                      hintText: 'Full Name',
                      icon: Iconsax.user_octagon,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  ModernTextField(
                      controller: phoneNumberController,
                      hintText: 'Phone Number',
                      icon: Iconsax.call,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                ]),
                const SizedBox(height: 16),
                _formRow([
                  ModernTextField(
                      controller: birthDateController,
                      hintText: 'Birth Date (YYYY-MM-DD)',
                      icon: Iconsax.calendar_1,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  ModernTextField(
                      controller: birthPlaceController,
                      hintText: 'Birth Place',
                      icon: Iconsax.location,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                ]),
                const SizedBox(height: 16),
                _formRow([
                  ModernTextField(
                      controller: motherTongueController,
                      hintText: 'Mother Tongue',
                      icon: Iconsax.translate,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  CustomDropdown(
                      hintText: 'Gender',
                      items: Gender.values.map((e) => e.name).toList(),
                      onChanged: (val) => gender.value =
                          Gender.values.firstWhere((e) => e.name == val)),
                ]),
                const Divider(height: 48),
                _buildSectionTitle('Address Information', Iconsax.map),
                const SizedBox(height: 16),
                _formRow([
                  ModernTextField(
                      controller: cityController,
                      hintText: 'City',
                      icon: Iconsax.buildings,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  ModernTextField(
                      controller: subCityController,
                      hintText: 'Sub-City',
                      icon: Iconsax.building_3,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                ]),
                const SizedBox(height: 16),
                _formRow([
                  ModernTextField(
                      controller: woredaController,
                      hintText: 'Woreda',
                      icon: Iconsax.routing,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                  ModernTextField(
                      controller: placeNameController,
                      hintText: 'Specific Place Name',
                      icon: Iconsax.location_tick,
                      validator: (v) => v!.isEmpty ? 'Required' : null),
                ]),
                const Divider(height: 48),
                _buildSectionTitle('Additional Information', Iconsax.more),
                const SizedBox(height: 16),
                _formRow([
                  CustomDropdown(
                      hintText: 'Education Level',
                      items:
                      EducationLevel.values.map((e) => e.name).toList(),
                      onChanged: (val) => educationLevel.value =
                          EducationLevel.values
                              .firstWhere((e) => e.name == val)),
                  CustomDropdown(
                      hintText: 'Job Status',
                      items: JobStatus.values.map((e) => e.name).toList(),
                      onChanged: (val) => jobStatus.value =
                          JobStatus.values.firstWhere((e) => e.name == val)),
                ]),
                const SizedBox(height: 16),
                _formRow([
                  CustomDropdown(
                      hintText: 'Marriage Status',
                      items:
                      MarriageStatus.values.map((e) => e.name).toList(),
                      onChanged: (val) => marriageStatus.value =
                          MarriageStatus.values
                              .firstWhere((e) => e.name == val)),
                  CustomDropdown(
                      hintText: 'Income Range',
                      items: IncomeRange.values.map((e) => e.name).toList(),
                      onChanged: (val) => incomeRange.value =
                          IncomeRange.values.firstWhere((e) => e.name == val)),
                ]),
                const SizedBox(height: 16),
                _formRow([
                  CustomDropdown(
                      hintText: 'Baptism Status',
                      items:
                      BaptismStatus.values.map((e) => e.name).toList(),
                      onChanged: (val) => baptismStatus.value =
                          BaptismStatus.values
                              .firstWhere((e) => e.name == val)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryBlue, size: 22),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _formRow(List<Widget> children) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return Column(
          children: children
              .expand((child) => [child, const SizedBox(height: 16)])
              .toList()
            ..removeLast(),
        );
      }
      return Row(
        children: children
            .map((child) => Expanded(child: child))
            .expand((child) => [child, const SizedBox(width: 16)])
            .toList()
          ..removeLast(),
      );
    });
  }
}