import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/core/theme/app_colors.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/custom_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:iconsax/iconsax.dart';
import '../../shared_widgets/modern_date_picker.dart';

class AddMembersScreen extends HookConsumerWidget {
  const AddMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormState>());
    final isLoading = useState(false);

    final fullNameController = useTextEditingController();
    final phoneNumberController = useTextEditingController();
    final birthDate = useState<DateTime?>(null);
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
      final selectedChurchId = ref.read(currentChurchProvider);
      if (selectedChurchId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
                'Please select a church from the header before adding a member.'),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
        return;
      }

      if (!(formKey.currentState?.validate() ?? false)) return;
      if (gender.value == null ||
          marriageStatus.value == null ||
          educationLevel.value == null ||
          jobStatus.value == null ||
          incomeRange.value == null ||
          baptismStatus.value == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please fill all required dropdown fields.'),
            backgroundColor: Colors.orange.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
          ),
        );
        return;
      }

      isLoading.value = true;

      final newMember = Member(
        fullName: fullNameController.text,
        phoneNumber: phoneNumberController.text,
        birthDate: birthDate.value!.toIso8601String(),
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
        await ref.read(membersProvider.notifier).addMember(member: newMember);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Member added successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
          ));
          context.go('/dashboard');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Failed to add member: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(20),
          ));
        }
      } finally {
        if (context.mounted) {
          isLoading.value = false;
        }
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).scaffoldBackgroundColor,
            Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
          ],
        ),
      ),
      child: Form(
        key: formKey,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'page-header',
                child: Material(
                  color: Colors.transparent,
                  child: PageHeader(
                    title: 'Register New Church Member',
                    description: 'Please fill in all the required details accurately.',
                    action: PrimaryButton(
                      text: 'Save Member',
                      icon: Iconsax.save_2,
                      onPressed: addMember,
                      isLoading: isLoading.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                child: ContentCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildAnimatedSection(
                        index: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context, 'Personal & Contact', Iconsax.user),
                            const SizedBox(height: 24),
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
                            const SizedBox(height: 20),
                            _formRow([
                              ModernDatePicker(
                                hintText: 'Birth Date',
                                icon: Iconsax.calendar_1,
                                selectedDate: birthDate.value,
                                onDateSelected: (date) => birthDate.value = date,
                                validator: (_) =>
                                birthDate.value == null ? 'Please select a date' : null,
                              ),
                              ModernTextField(
                                  controller: birthPlaceController,
                                  hintText: 'Birth Place',
                                  icon: Iconsax.location,
                                  validator: (v) => v!.isEmpty ? 'Required' : null),
                            ]),
                            const SizedBox(height: 20),
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
                          ],
                        ),
                      ),
                      _buildModernDivider(context),
                      _buildAnimatedSection(
                        index: 1,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(context, 'Address Information', Iconsax.map),
                            const SizedBox(height: 24),
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
                            const SizedBox(height: 20),
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
                          ],
                        ),
                      ),
                      _buildModernDivider(context),
                      _buildAnimatedSection(
                        index: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionTitle(
                                context, 'Additional Information', Iconsax.more),
                            const SizedBox(height: 24),
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
                            const SizedBox(height: 20),
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
                            const SizedBox(height: 20),
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
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    final theme = Theme.of(context);
    final appColors = theme.extension<AppColors>()!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.primary.withOpacity(0.05),
            Colors.transparent,
          ],
          stops: const [0, 0.5, 1],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: theme.colorScheme.primary,
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: appColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernDivider(context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSection({required int index, required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 600 + (index * 200)),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
    );
  }

  Widget _formRow(List<Widget> children) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return Column(
          children: children
              .map((child) => Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.95, end: 1),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
            ),
          ))
              .toList()
            ..removeLast(),
        );
      }
      return Row(
        children: children
            .map((child) => Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 16),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.95, end: 1),
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              builder: (context, value, _) {
                return Transform.scale(
                  scale: value,
                  child: child,
                );
              },
            ),
          ),
        ))
            .toList()
          ..removeLast(),
      );
    });
  }
}