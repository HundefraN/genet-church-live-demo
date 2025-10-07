import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/content_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:iconsax/iconsax.dart';
import '../../shared_widgets/modern_date_picker.dart';

class AddMembersScreen extends HookConsumerWidget {
  const AddMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState(0);
    final isLoading = useState(false);

    final formKeys = useMemoized(() => [
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
    ]);

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

    void navigateToPage(int page) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value = page;
    }

    void addMember() async {
      bool allFormsValid = true;
      for (int i = 0; i < formKeys.length; i++) {
        if (!(formKeys[i].currentState?.validate() ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please complete all required fields on all pages.')),
          );
          if (currentPage.value != i) {
            navigateToPage(i);
          }
          allFormsValid = false;
          break;
        }
      }

      if (!allFormsValid) return;

      final selectedChurchId = ref.read(currentChurchProvider);
      if (selectedChurchId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a church from the header before adding a member.')),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member added successfully!'), backgroundColor: Colors.green));
          context.go('/dashboard');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to add member: $e'), backgroundColor: Colors.red));
        }
      } finally {
        if (context.mounted) {
          isLoading.value = false;
        }
      }
    }

    void handleNextOrSubmit() {
      if (formKeys[currentPage.value].currentState?.validate() ?? false) {
        if (currentPage.value < formKeys.length - 1) {
          navigateToPage(currentPage.value + 1);
        } else {
          addMember();
        }
      }
    }

    final wizardSteps = [
      _WizardStep(formKey: formKeys[0], child: _PersonalForm(
        fullNameController: fullNameController,
        phoneNumberController: phoneNumberController,
        birthDate: birthDate,
        birthPlaceController: birthPlaceController,
        motherTongueController: motherTongueController,
        gender: gender,
      )),
      _WizardStep(formKey: formKeys[1], child: _AddressForm(
        cityController: cityController,
        subCityController: subCityController,
        woredaController: woredaController,
        placeNameController: placeNameController,
      )),
      _WizardStep(formKey: formKeys[2], child: _AdditionalInfoForm(
        marriageStatus: marriageStatus,
        educationLevel: educationLevel,
        jobStatus: jobStatus,
        incomeRange: incomeRange,
        baptismStatus: baptismStatus,
      )),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          const PageHeader(
            title: 'Register New Church Member',
            description: 'Please fill in all the required details accurately.',
          ),
          const SizedBox(height: 24),
          ContentCard(
            child: Column(
              children: [
                _WizardProgressIndicator(
                  stepCount: wizardSteps.length,
                  currentStep: currentPage.value,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    controller: pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: wizardSteps.length,
                    itemBuilder: (context, index) {
                      return Form(
                          key: wizardSteps[index].formKey,
                          child: wizardSteps[index].child
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (currentPage.value > 0)
                      TextButton.icon(
                        onPressed: () => navigateToPage(currentPage.value - 1),
                        icon: const Icon(Iconsax.arrow_left_2),
                        label: const Text('Back'),
                      ),
                    const Spacer(),
                    PrimaryButton(
                      text: currentPage.value == wizardSteps.length - 1 ? 'Save Member' : 'Next Step',
                      icon: currentPage.value == wizardSteps.length - 1 ? Iconsax.save_2 : Iconsax.arrow_right_3,
                      isLoading: isLoading.value,
                      onPressed: handleNextOrSubmit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WizardStep {
  final GlobalKey<FormState> formKey;
  final Widget child;
  _WizardStep({required this.formKey, required this.child});
}

class _WizardProgressIndicator extends StatelessWidget {
  final int stepCount;
  final int currentStep;
  const _WizardProgressIndicator({required this.stepCount, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = ['Personal', 'Address', 'Details'];
    return Row(
      children: List.generate(stepCount, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  if (index > 0)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2,
                        color: isActive ? theme.colorScheme.primary : theme.dividerColor,
                      ),
                    ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isActive ? theme.colorScheme.primary : theme.dividerColor,
                    child: isActive ?
                    (index < currentStep ? const Icon(Icons.check, color: Colors.white, size: 18) : Text('${index + 1}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))
                        : Text('${index + 1}', style: TextStyle(color: Theme.of(context).disabledColor)),
                  ),
                  if (index < stepCount - 1)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2,
                        color: index < currentStep ? theme.colorScheme.primary : theme.dividerColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(labels[index], style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? theme.colorScheme.primary : theme.disabledColor)),
            ],
          ),
        );
      }),
    );
  }
}

Widget _formRow(List<Widget> children) {
  return LayoutBuilder(builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return Column(
        children: children.map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: child,
        )).toList(),
      );
    }
    return Row(
      children: children.map((child) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: child,
        ),
      )).toList(),
    );
  });
}

// CONVERTED TO STATEFUL WIDGET WITH MIXIN
class _PersonalForm extends StatefulWidget {
  final TextEditingController fullNameController;
  final TextEditingController phoneNumberController;
  final ValueNotifier<DateTime?> birthDate;
  final TextEditingController birthPlaceController;
  final TextEditingController motherTongueController;
  final ValueNotifier<Gender?> gender;

  const _PersonalForm({
    required this.fullNameController,
    required this.phoneNumberController,
    required this.birthDate,
    required this.birthPlaceController,
    required this.motherTongueController,
    required this.gender
  });

  @override
  State<_PersonalForm> createState() => _PersonalFormState();
}

class _PersonalFormState extends State<_PersonalForm> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _formRow([
          ModernTextField(
              controller: widget.fullNameController, hintText: 'Full Name', icon: Iconsax.user_octagon,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          ModernTextField(
              controller: widget.phoneNumberController, hintText: 'Phone Number', icon: Iconsax.call,
              validator: (v) => v!.isEmpty ? 'Required' : null),
        ]),
        _formRow([
          ModernDatePicker(
            hintText: 'Birth Date', icon: Iconsax.calendar_1, selectedDate: widget.birthDate.value,
            onDateSelected: (date) => widget.birthDate.value = date,
            validator: (_) => widget.birthDate.value == null ? 'Please select a date' : null,
          ),
          ModernTextField(
              controller: widget.birthPlaceController, hintText: 'Birth Place', icon: Iconsax.location,
              validator: (v) => v!.isEmpty ? 'Required' : null),
        ]),
        _formRow([
          ModernTextField(
              controller: widget.motherTongueController, hintText: 'Mother Tongue', icon: Iconsax.translate,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          ModernDropdown<Gender>(
            hintText: 'Gender',
            icon: Iconsax.user,
            value: widget.gender.value,
            items: Gender.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
            onChanged: (val) => setState(() => widget.gender.value = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ]),
      ],
    );
  }
}

// CONVERTED TO STATEFUL WIDGET WITH MIXIN
class _AddressForm extends StatefulWidget {
  final TextEditingController cityController;
  final TextEditingController subCityController;
  final TextEditingController woredaController;
  final TextEditingController placeNameController;

  const _AddressForm({
    required this.cityController,
    required this.subCityController,
    required this.woredaController,
    required this.placeNameController,
  });

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _formRow([
          ModernTextField(
              controller: widget.cityController, hintText: 'City', icon: Iconsax.buildings,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          ModernTextField(
              controller: widget.subCityController, hintText: 'Sub-City', icon: Iconsax.building_3,
              validator: (v) => v!.isEmpty ? 'Required' : null),
        ]),
        _formRow([
          ModernTextField(
              controller: widget.woredaController, hintText: 'Woreda', icon: Iconsax.routing,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          ModernTextField(
              controller: widget.placeNameController, hintText: 'Specific Place Name', icon: Iconsax.location_tick,
              validator: (v) => v!.isEmpty ? 'Required' : null),
        ]),
      ],
    );
  }
}

// CONVERTED TO STATEFUL WIDGET WITH MIXIN
class _AdditionalInfoForm extends StatefulWidget {
  final ValueNotifier<MarriageStatus?> marriageStatus;
  final ValueNotifier<EducationLevel?> educationLevel;
  final ValueNotifier<JobStatus?> jobStatus;
  final ValueNotifier<IncomeRange?> incomeRange;
  final ValueNotifier<BaptismStatus?> baptismStatus;

  const _AdditionalInfoForm({
    required this.marriageStatus,
    required this.educationLevel,
    required this.jobStatus,
    required this.incomeRange,
    required this.baptismStatus,
  });

  @override
  State<_AdditionalInfoForm> createState() => _AdditionalInfoFormState();
}

class _AdditionalInfoFormState extends State<_AdditionalInfoForm> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _formRow([
          ModernDropdown<EducationLevel>(
            hintText: 'Education Level', icon: Iconsax.book, value: widget.educationLevel.value,
            items: EducationLevel.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
            onChanged: (val) => setState(() => widget.educationLevel.value = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
          ModernDropdown<JobStatus>(
            hintText: 'Job Status', icon: Iconsax.briefcase, value: widget.jobStatus.value,
            items: JobStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
            onChanged: (val) => setState(() => widget.jobStatus.value = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ]),
        _formRow([
          ModernDropdown<MarriageStatus>(
            hintText: 'Marriage Status', icon: Iconsax.like, value: widget.marriageStatus.value,
            items: MarriageStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
            onChanged: (val) => setState(() => widget.marriageStatus.value = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
          ModernDropdown<IncomeRange>(
            hintText: 'Income Range', icon: Iconsax.wallet_money, value: widget.incomeRange.value,
            items: IncomeRange.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
            onChanged: (val) => setState(() => widget.incomeRange.value = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ]),
        _formRow([
          ModernDropdown<BaptismStatus>(
            hintText: 'Baptism Status', icon: Icons.church, value: widget.baptismStatus.value,
            items: BaptismStatus.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
            onChanged: (val) => setState(() => widget.baptismStatus.value = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox.shrink(),
        ]),
      ],
    );
  }
}