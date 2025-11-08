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

class MemberFormData {
  String fullName = '';
  String phoneNumber = '';
  DateTime? birthDate;
  String birthPlace = '';
  String motherTongue = '';
  Gender? gender;
  String city = '';
  String subCity = '';
  String woreda = '';
  String placeName = '';
  MarriageStatus? marriageStatus;
  EducationLevel? educationLevel;
  JobStatus? jobStatus;
  IncomeRange? incomeRange;
  BaptismStatus? baptismStatus;
}

final addMemberFormProvider = Provider((ref) => MemberFormData());

class AddMembersScreen extends HookConsumerWidget {
  const AddMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState(0);
    final formData = ref.read(addMemberFormProvider);

    final formKeys = useMemoized(() => [
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
      GlobalKey<FormState>(),
    ]);

    void navigateToPage(int page) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value = page;
    }

    Future<void> addMember() async {
      bool allFormsValid = true;
      for (int i = 0; i < formKeys.length; i++) {
        if (!(formKeys[i].currentState?.validate() ?? false)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                Text('Please complete all required fields on all pages.')),
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
          const SnackBar(
              content: Text(
                  'Please select a church from the header before adding a member.')),
        );
        return;
      }

      final newMember = Member(
        fullName: formData.fullName,
        phoneNumber: formData.phoneNumber,
        birthDate: formData.birthDate!.toIso8601String(),
        birthPlace: formData.birthPlace,
        motherTongue: formData.motherTongue,
        gender: formData.gender!,
        marriageStatus: formData.marriageStatus!,
        address: Address(
          city: formData.city,
          subCity: formData.subCity,
          woreda: formData.woreda,
          placeName: formData.placeName,
        ),
        educationLevel: formData.educationLevel!,
        jobStatus: formData.jobStatus!,
        incomeRange: formData.incomeRange!,
        baptismStatus: formData.baptismStatus!,
        memberStatus: MemberStatus.ACTIVE,
      );

      try {
        await ref.read(membersProvider.notifier).addMember(member: newMember);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Member added successfully!'),
              backgroundColor: Colors.green));
          context.go('/dashboard');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to add member: $e'),
              backgroundColor: Colors.red));
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
      _WizardStep(formKey: formKeys[0], child: _PersonalForm(formData: formData)),
      _WizardStep(formKey: formKeys[1], child: _AddressForm(formData: formData)),
      _WizardStep(
          formKey: formKeys[2], child: _AdditionalInfoForm(formData: formData)),
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
                          child: wizardSteps[index].child);
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
                      text: currentPage.value == wizardSteps.length - 1
                          ? 'Save Member'
                          : 'Next Step',
                      icon: currentPage.value == wizardSteps.length - 1
                          ? Iconsax.save_2
                          : Iconsax.arrow_right_3,
                      onPressed: () async => handleNextOrSubmit(),
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
  const _WizardProgressIndicator(
      {required this.stepCount, required this.currentStep});

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
                        color: isActive
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                      ),
                    ),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: isActive
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                    child: isActive
                        ? (index < currentStep
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 18)
                        : Text('${index + 1}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold)))
                        : Text('${index + 1}',
                        style: TextStyle(color: Theme.of(context).disabledColor)),
                  ),
                  if (index < stepCount - 1)
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 2,
                        color: index < currentStep
                            ? theme.colorScheme.primary
                            : theme.dividerColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(labels[index],
                  style: TextStyle(
                      fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.disabledColor)),
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
        children: children
            .map((child) => Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: child,
        ))
            .toList(),
      );
    }
    return Row(
      children: children
          .map((child) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: child,
        ),
      ))
          .toList(),
    );
  });
}

class _PersonalForm extends StatefulHookWidget {
  final MemberFormData formData;

  const _PersonalForm({required this.formData});

  @override
  State<_PersonalForm> createState() => _PersonalFormState();
}

class _PersonalFormState extends State<_PersonalForm>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final fullNameController =
    useTextEditingController(text: widget.formData.fullName);
    final phoneNumberController =
    useTextEditingController(text: widget.formData.phoneNumber);
    final birthPlaceController =
    useTextEditingController(text: widget.formData.birthPlace);
    final motherTongueController =
    useTextEditingController(text: widget.formData.motherTongue);

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _formRow([
          ModernTextField(
              controller: fullNameController,
              hintText: 'Full Name',
              icon: Iconsax.user_octagon,
              onChanged: (v) => widget.formData.fullName = v,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          ModernTextField(
              controller: phoneNumberController,
              hintText: 'Phone Number',
              icon: Iconsax.call,
              onChanged: (v) => widget.formData.phoneNumber = v,
              validator: (v) => v!.isEmpty ? 'Required' : null),
        ]),
        _formRow([
          ModernDatePicker(
            hintText: 'Birth Date',
            icon: Iconsax.calendar_1,
            selectedDate: widget.formData.birthDate,
            onDateSelected: (date) =>
                setState(() => widget.formData.birthDate = date),
            validator: (_) =>
            widget.formData.birthDate == null ? 'Please select a date' : null,
          ),
          ModernTextField(
              controller: birthPlaceController,
              hintText: 'Birth Place',
              icon: Iconsax.location,
              onChanged: (v) => widget.formData.birthPlace = v,
              validator: (v) => v!.isEmpty ? 'Required' : null),
        ]),
        _formRow([
          ModernTextField(
              controller: motherTongueController,
              hintText: 'Mother Tongue',
              icon: Iconsax.translate,
              onChanged: (v) => widget.formData.motherTongue = v,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          ModernDropdown<Gender>(
            hintText: 'Gender',
            icon: Iconsax.user,
            value: widget.formData.gender,
            items: Gender.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) => setState(() => widget.formData.gender = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ]),
      ],
    );
  }
}

class _AddressForm extends HookWidget {
  final MemberFormData formData;

  const _AddressForm({required this.formData});

  @override
  Widget build(BuildContext context) {
    final cityController = useTextEditingController(text: formData.city);
    final subCityController = useTextEditingController(text: formData.subCity);
    final woredaController = useTextEditingController(text: formData.woreda);
    final placeNameController =
    useTextEditingController(text: formData.placeName);
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _formRow([
          ModernTextField(
              controller: cityController,
              hintText: 'City',
              icon: Iconsax.buildings,
              onChanged: (v) => formData.city = v,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          ModernTextField(
              controller: subCityController,
              hintText: 'Sub-City',
              icon: Iconsax.building_3,
              onChanged: (v) => formData.subCity = v,
              validator: (v) => v!.isEmpty ? 'Required' : null),
        ]),
        _formRow([
          ModernTextField(
              controller: woredaController,
              hintText: 'Woreda',
              icon: Iconsax.routing,
              onChanged: (v) => formData.woreda = v,
              validator: (v) => v!.isEmpty ? 'Required' : null),
          ModernTextField(
              controller: placeNameController,
              hintText: 'Specific Place Name',
              icon: Iconsax.location_tick,
              onChanged: (v) => formData.placeName = v,
              validator: (v) => v!.isEmpty ? 'Required' : null),
        ]),
      ],
    );
  }
}

class _AdditionalInfoForm extends StatefulWidget {
  final MemberFormData formData;

  const _AdditionalInfoForm({required this.formData});

  @override
  State<_AdditionalInfoForm> createState() => _AdditionalInfoFormState();
}

class _AdditionalInfoFormState extends State<_AdditionalInfoForm>
    with AutomaticKeepAliveClientMixin {
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
            hintText: 'Education Level',
            icon: Iconsax.book,
            value: widget.formData.educationLevel,
            items: EducationLevel.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) =>
                setState(() => widget.formData.educationLevel = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
          ModernDropdown<JobStatus>(
            hintText: 'Job Status',
            icon: Iconsax.briefcase,
            value: widget.formData.jobStatus,
            items: JobStatus.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) => setState(() => widget.formData.jobStatus = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ]),
        _formRow([
          ModernDropdown<MarriageStatus>(
            hintText: 'Marriage Status',
            icon: Iconsax.like,
            value: widget.formData.marriageStatus,
            items: MarriageStatus.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) =>
                setState(() => widget.formData.marriageStatus = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
          ModernDropdown<IncomeRange>(
            hintText: 'Income Range',
            icon: Iconsax.wallet_money,
            value: widget.formData.incomeRange,
            items: IncomeRange.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) =>
                setState(() => widget.formData.incomeRange = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ]),
        _formRow([
          ModernDropdown<BaptismStatus>(
            hintText: 'Baptism Status',
            icon: Icons.church,
            value: widget.formData.baptismStatus,
            items: BaptismStatus.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) =>
                setState(() => widget.formData.baptismStatus = val),
            validator: (v) => v == null ? 'Required' : null,
          ),
          const SizedBox.shrink(),
        ]),
      ],
    );
  }
}