import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:genet_church_portal/data/models/member_model.dart';
import 'package:genet_church_portal/state/church_selection_provider.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:genet_church_portal/shared_widgets/modern_card.dart';
import 'package:genet_church_portal/shared_widgets/modern_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/modern_input.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
import 'package:genet_church_portal/shared_widgets/notification_system.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../shared_widgets/modern_date_picker.dart';

class MemberFormData {
  final String fullName;
  final String phoneNumber;
  final DateTime? birthDate;
  final String birthPlace;
  final String motherTongue;
  final Gender? gender;
  final String city;
  final String subCity;
  final String woreda;
  final String placeName;
  final MarriageStatus? marriageStatus;
  final EducationLevel? educationLevel;
  final JobStatus? jobStatus;
  final IncomeRange? incomeRange;
  final BaptismStatus? baptismStatus;
  final DateTime? bornAgainDate;
  final DateTime? baptizedAt;

  MemberFormData({
    this.fullName = '',
    this.phoneNumber = '',
    this.birthDate,
    this.birthPlace = '',
    this.motherTongue = '',
    this.gender,
    this.city = '',
    this.subCity = '',
    this.woreda = '',
    this.placeName = '',
    this.marriageStatus,
    this.educationLevel,
    this.jobStatus,
    this.incomeRange,
    this.baptismStatus,
    this.bornAgainDate,
    this.baptizedAt,
  });

  MemberFormData copyWith({
    String? fullName,
    String? phoneNumber,
    DateTime? birthDate,
    String? birthPlace,
    String? motherTongue,
    Gender? gender,
    String? city,
    String? subCity,
    String? woreda,
    String? placeName,
    MarriageStatus? marriageStatus,
    EducationLevel? educationLevel,
    JobStatus? jobStatus,
    IncomeRange? incomeRange,
    BaptismStatus? baptismStatus,
    DateTime? bornAgainDate,
    DateTime? baptizedAt,
  }) {
    return MemberFormData(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      motherTongue: motherTongue ?? this.motherTongue,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      subCity: subCity ?? this.subCity,
      woreda: woreda ?? this.woreda,
      placeName: placeName ?? this.placeName,
      marriageStatus: marriageStatus ?? this.marriageStatus,
      educationLevel: educationLevel ?? this.educationLevel,
      jobStatus: jobStatus ?? this.jobStatus,
      incomeRange: incomeRange ?? this.incomeRange,
      baptismStatus: baptismStatus ?? this.baptismStatus,
      bornAgainDate: bornAgainDate ?? this.bornAgainDate,
      baptizedAt: baptizedAt ?? this.baptizedAt,
    );
  }
}

final addMemberFormProvider = StateProvider.autoDispose(
      (ref) => MemberFormData(),
);

class AddMembersScreen extends HookConsumerWidget {
  const AddMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState(0);

    final formKeys = useMemoized(
          () => [
        GlobalKey<FormState>(),
        GlobalKey<FormState>(),
        GlobalKey<FormState>(),
      ],
    );

    void navigateToPage(int page) {
      pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    pageController.addListener(() {
      if (pageController.page?.round() != currentPage.value) {
        currentPage.value = pageController.page!.round();
      }
    });

    Future<void> addMember() async {
      bool allFormsValid = true;
      for (int i = 0; i < formKeys.length; i++) {
        if (!(formKeys[i].currentState?.validate() ?? false)) {
          context.showWarningNotification(
            title: 'Incomplete Form',
            message: 'Please complete all required fields on all pages.',
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
        context.showWarningNotification(
          title: 'Church Required',
          message:
          'Please select a church from the header before adding a member.',
        );
        return;
      }
      final formData = ref.read(addMemberFormProvider);

      if (formData.bornAgainDate == null) {
        context.showWarningNotification(
          title: 'Incomplete Form',
          message: 'Please provide the date the member was born again.',
        );
        return;
      }

      final newMember = Member(
        fullName: formData.fullName,
        phoneNumber: formData.phoneNumber,
        birthDate: formData.birthDate!.toUtc().toIso8601String(),
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
        bornAgainDate: formData.bornAgainDate!.toUtc().toIso8601String(),
        baptizedAt: formData.baptizedAt?.toUtc().toIso8601String(),
        memberStatus: MemberStatus.ACTIVE,
        statusChangedAt: DateTime.now().toUtc().toIso8601String(),
        // FIX: Explicitly sending false as backend seems to require it based on 400 error
        deleted: false,
      );

      try {
        await ref.read(membersProvider.notifier).addMember(member: newMember);
        if (context.mounted) {
          context.showSuccessNotification(
            title: 'Success!',
            message: 'Member added successfully to the database.',
          );
          ref.invalidate(addMemberFormProvider);
          context.go('/show-members');
        }
      } catch (e) {
        if (context.mounted) {
          context.showErrorNotification(
            title: 'Error',
            message: 'Failed to add member: ${e.toString()}',
          );
        }
      }
    }

    Future<void> handleNextOrSubmit() async {
      if (formKeys[currentPage.value].currentState?.validate() ?? false) {
        if (currentPage.value < formKeys.length - 1) {
          navigateToPage(currentPage.value + 1);
        } else {
          await addMember();
        }
      }
    }

    final wizardSteps = [
      _WizardStep(formKey: formKeys[0], child: const _PersonalForm()),
      _WizardStep(formKey: formKeys[1], child: const _AddressForm()),
      _WizardStep(formKey: formKeys[2], child: const _AdditionalInfoForm()),
    ];

    return SingleChildScrollView(
      child: Column(
        children: [
          const PageHeader(
            title: 'Register New Church Member',
            description: 'Please fill in all the required details accurately.',
          ),
          const SizedBox(height: 24),
          ModernCard(
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
                        child: wizardSteps[index].child,
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
                      text: currentPage.value == wizardSteps.length - 1
                          ? 'Save Member'
                          : 'Next Step',
                      icon: currentPage.value == wizardSteps.length - 1
                          ? Iconsax.save_2
                          : Iconsax.arrow_right_3,
                      onPressedAsync: handleNextOrSubmit,
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
  const _WizardProgressIndicator({
    required this.stepCount,
    required this.currentStep,
  });

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
                        ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                        : Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ))
                        : Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: Theme.of(context).disabledColor,
                      ),
                    ),
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
              Text(
                labels[index],
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.disabledColor,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

Widget _formRow(List<Widget> children) {
  return LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 600) {
        return Column(
          children: children
              .map(
                (child) => Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: child,
            ),
          )
              .toList(),
        );
      }
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget widget = entry.value;

          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: idx == 0 ? 0 : 8.0,
                right: idx == children.length - 1 ? 0 : 8.0,
              ),
              child: widget,
            ),
          );
        }).toList(),
      );
    },
  );
}

class _PersonalForm extends ConsumerStatefulWidget {
  const _PersonalForm();

  @override
  ConsumerState<_PersonalForm> createState() => _PersonalFormState();
}

class _PersonalFormState extends ConsumerState<_PersonalForm>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _fullNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _birthPlaceController;
  late final TextEditingController _motherTongueController;

  @override
  void initState() {
    super.initState();
    final formData = ref.read(addMemberFormProvider);
    _fullNameController = TextEditingController(text: formData.fullName);
    _phoneNumberController = TextEditingController(text: formData.phoneNumber);
    _birthPlaceController = TextEditingController(text: formData.birthPlace);
    _motherTongueController = TextEditingController(
      text: formData.motherTongue,
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneNumberController.dispose();
    _birthPlaceController.dispose();
    _motherTongueController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final formData = ref.watch(addMemberFormProvider);
    final formNotifier = ref.read(addMemberFormProvider.notifier);

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _formRow([
          ModernInput(
            controller: _fullNameController,
            label: 'Full Name',
            prefixIcon: Iconsax.user_octagon,
            onChanged: (v) =>
                formNotifier.update((s) => s.copyWith(fullName: v)),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          ModernInput(
            controller: _phoneNumberController,
            label: 'Phone Number',
            prefixIcon: Iconsax.call,
            keyboardType: TextInputType.phone, // FIX: Use correct keyboard
            onChanged: (v) =>
                formNotifier.update((s) => s.copyWith(phoneNumber: v)),
            validator: (v) {
              if (v?.isEmpty ?? true) return 'Required';
              // FIX: Strict regex for numbers only to avoid 500 error on backend
              if (!RegExp(r'^\d+$').hasMatch(v!)) {
                return 'Phone must contain only numbers';
              }
              return null;
            },
          ),
        ])
            .animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.1, curve: Curves.easeOut),
        _formRow([
          ModernDatePicker(
            hintText: 'Birth Date',
            icon: Iconsax.calendar_1,
            selectedDate: formData.birthDate,
            onDateSelected: (date) =>
                formNotifier.update((s) => s.copyWith(birthDate: date)),
            validator: (_) =>
            formData.birthDate == null ? 'Please select a date' : null,
          ),
          ModernInput(
            controller: _birthPlaceController,
            label: 'Birth Place',
            prefixIcon: Iconsax.location,
            onChanged: (v) =>
                formNotifier.update((s) => s.copyWith(birthPlace: v)),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
        ]),
        _formRow([
          ModernInput(
            controller: _motherTongueController,
            label: 'Mother Tongue',
            prefixIcon: Iconsax.translate,
            onChanged: (v) =>
                formNotifier.update((s) => s.copyWith(motherTongue: v)),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          ModernDropdown<Gender>(
            hintText: 'Gender',
            icon: Iconsax.user,
            value: formData.gender,
            items: Gender.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) =>
                formNotifier.update((s) => s.copyWith(gender: val)),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ]),
      ],
    );
  }
}

class _AddressForm extends ConsumerStatefulWidget {
  const _AddressForm();

  @override
  ConsumerState<_AddressForm> createState() => __AddressFormState();
}

class __AddressFormState extends ConsumerState<_AddressForm>
    with AutomaticKeepAliveClientMixin {
  late final TextEditingController _cityController;
  late final TextEditingController _subCityController;
  late final TextEditingController _woredaController;
  late final TextEditingController _placeNameController;

  @override
  void initState() {
    super.initState();
    final formData = ref.read(addMemberFormProvider);
    _cityController = TextEditingController(text: formData.city);
    _subCityController = TextEditingController(text: formData.subCity);
    _woredaController = TextEditingController(text: formData.woreda);
    _placeNameController = TextEditingController(text: formData.placeName);
  }

  @override
  void dispose() {
    _cityController.dispose();
    _subCityController.dispose();
    _woredaController.dispose();
    _placeNameController.dispose();
    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final formNotifier = ref.read(addMemberFormProvider.notifier);

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _formRow([
          ModernInput(
            controller: _cityController,
            label: 'City',
            prefixIcon: Iconsax.buildings,
            onChanged: (v) => formNotifier.update((s) => s.copyWith(city: v)),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          ModernInput(
            controller: _subCityController,
            label: 'Sub-City',
            prefixIcon: Iconsax.building_3,
            onChanged: (v) =>
                formNotifier.update((s) => s.copyWith(subCity: v)),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
        ])
            .animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: 0.1, curve: Curves.easeOut),
        _formRow([
          ModernInput(
            controller: _woredaController,
            label: 'Woreda',
            prefixIcon: Iconsax.routing,
            onChanged: (v) => formNotifier.update((s) => s.copyWith(woreda: v)),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
          ModernInput(
            controller: _placeNameController,
            label: 'Specific Place Name',
            prefixIcon: Iconsax.location_tick,
            onChanged: (v) =>
                formNotifier.update((s) => s.copyWith(placeName: v)),
            validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
          ),
        ])
            .animate()
            .fadeIn(duration: 400.ms, delay: 200.ms)
            .slideY(begin: 0.1, curve: Curves.easeOut),
      ],
    );
  }
}

class _AdditionalInfoForm extends ConsumerStatefulWidget {
  const _AdditionalInfoForm();

  @override
  ConsumerState<_AdditionalInfoForm> createState() =>
      _AdditionalInfoFormState();
}

class _AdditionalInfoFormState extends ConsumerState<_AdditionalInfoForm>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final formData = ref.watch(addMemberFormProvider);
    final formNotifier = ref.read(addMemberFormProvider.notifier);

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        _formRow([
          ModernDropdown<EducationLevel>(
            hintText: 'Education Level',
            icon: Iconsax.book,
            value: formData.educationLevel,
            items: EducationLevel.values
                .map((e) => DropdownMenuItem(
              value: e,
              child: Text(e.name[0] + e.name.substring(1).toLowerCase()),
            ))
                .toList(),
            onChanged: (val) =>
                formNotifier.update((s) => s.copyWith(educationLevel: val)),
            validator: (v) => v == null ? 'Required' : null,
          ),
          ModernDropdown<JobStatus>(
            hintText: 'Job Status',
            icon: Iconsax.briefcase,
            value: formData.jobStatus,
            items: JobStatus.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) =>
                formNotifier.update((s) => s.copyWith(jobStatus: val)),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ]),
        _formRow([
          ModernDropdown<MarriageStatus>(
            hintText: 'Marriage Status',
            icon: Iconsax.like,
            value: formData.marriageStatus,
            items: MarriageStatus.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) =>
                formNotifier.update((s) => s.copyWith(marriageStatus: val)),
            validator: (v) => v == null ? 'Required' : null,
          ),
          ModernDropdown<IncomeRange>(
            hintText: 'Income Range',
            icon: Iconsax.wallet_money,
            value: formData.incomeRange,
            items: IncomeRange.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) =>
                formNotifier.update((s) => s.copyWith(incomeRange: val)),
            validator: (v) => v == null ? 'Required' : null,
          ),
        ]),
        _formRow([
          ModernDropdown<BaptismStatus>(
            hintText: 'Baptism Status',
            icon: Icons.church,
            value: formData.baptismStatus,
            items: BaptismStatus.values
                .map((e) => DropdownMenuItem(value: e, child: Text(e.name)))
                .toList(),
            onChanged: (val) {
              if (val != BaptismStatus.BAPTIZED) {
                formNotifier.update(
                      (s) => s.copyWith(baptismStatus: val, baptizedAt: null),
                );
              } else {
                formNotifier.update((s) => s.copyWith(baptismStatus: val));
              }
            },
            validator: (v) => v == null ? 'Required' : null,
          ),
          ModernDatePicker(
            hintText: 'Born Again Date',
            icon: Iconsax.health,
            selectedDate: formData.bornAgainDate,
            onDateSelected: (date) =>
                formNotifier.update((s) => s.copyWith(bornAgainDate: date)),
            validator: (_) =>
            formData.bornAgainDate == null ? 'Required' : null,
          ),
        ]),
        if (formData.baptismStatus == BaptismStatus.BAPTIZED)
          _formRow([
            ModernDatePicker(
              hintText: 'Baptism Date',
              icon: Iconsax.calendar_tick,
              selectedDate: formData.baptizedAt,
              onDateSelected: (date) =>
                  formNotifier.update((s) => s.copyWith(baptizedAt: date)),
              validator: (_) {
                if (formData.baptismStatus == BaptismStatus.BAPTIZED &&
                    formData.baptizedAt == null) {
                  return 'Baptism Date is required';
                }
                return null;
              },
            ),
          ])
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.1, curve: Curves.easeOut),
      ],
    );
  }
}