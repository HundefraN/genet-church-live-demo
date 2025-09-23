import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Child {
  final TextEditingController firstNameController;
  final TextEditingController fatherNameController;
  final TextEditingController lastNameController;
  final TextEditingController ageController;
  final TextEditingController educationLevelController;
  String? gender;
  String? religion;

  Child({
    required this.firstNameController,
    required this.fatherNameController,
    required this.lastNameController,
    required this.ageController,
    required this.educationLevelController,
    this.gender,
    this.religion,
  });
}

class AddMembersScreen extends HookConsumerWidget {
  const AddMembersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentStep = useState(0);
    final scrollController = useScrollController();
    final stepKeys = useMemoized(() => List.generate(7, (_) => GlobalKey()), []);

    final isStep1Valid = useState(false);

    final imageBytes = useState<Uint8List?>(null);
    final firstNameController = useTextEditingController();
    final fatherNameController = useTextEditingController();
    final grandfatherNameController = useTextEditingController();
    final birthDate = useState<DateTime?>(null);
    final birthPlaceController = useTextEditingController();
    final salvationDate = useState<DateTime?>(null);
    final salvationPlaceController = useTextEditingController();
    final previousChurchController = useTextEditingController();
    final reasonForTransferController = useTextEditingController();
    final educationTypeController = useTextEditingController();
    final educationLevelController = useTextEditingController();
    final employmentStatusController = useTextEditingController();
    final workAddressController = useTextEditingController();
    final phoneNumberController = useTextEditingController();
    final maritalStatus = useState<String?>(null);
    final otherMaritalStatusController = useTextEditingController();
    final spouseFirstNameController = useTextEditingController();
    final spouseFatherNameController = useTextEditingController();
    final spouseGrandfatherNameController = useTextEditingController();
    final spouseReligion = useState<String?>(null);
    final otherSpouseReligionController = useTextEditingController();
    final marriageDate = useState<DateTime?>(null);
    final marriagePlaceController = useTextEditingController();
    final children = useState<List<Child>>([]);
    final additionalFamilyInfoController = useTextEditingController();
    final livingSituationSingleController = useTextEditingController();
    final serviceTypeController = useTextEditingController();
    final serviceDate = useState<DateTime?>(null);
    final serviceResponsibilityController = useTextEditingController();
    final currentServiceController = useTextEditingController();
    final currentResponsibilityController = useTextEditingController();
    final spiritualGiftsController = useTextEditingController();
    final futureServiceInterestController = useTextEditingController();
    final additionalServiceInfoController = useTextEditingController();
    final fellowshipStartDate = useState<DateTime?>(null);
    final fellowshipNameController = useTextEditingController();
    final fellowshipResponsibilityController = useTextEditingController();
    final fellowshipMentorController = useTextEditingController();
    final fellowshipMenteeController = useTextEditingController();
    final additionalFellowshipInfoController = useTextEditingController();
    final memberSignatureController = useTextEditingController();
    final formCompletionDate = useState<DateTime?>(null);
    final fellowshipLeaderSignatureController = useTextEditingController();
    final zoneLeaderSignatureController = useTextEditingController();
    final spiritualRepSignatureController = useTextEditingController();
    final incomeLevelController = useTextEditingController();
    final motherTongue = useState<String?>(null);
    final memberStatus = useState<String?>(null);

    void validateStep1() {
      isStep1Valid.value = firstNameController.text.isNotEmpty &&
          fatherNameController.text.isNotEmpty &&
          grandfatherNameController.text.isNotEmpty &&
          birthPlaceController.text.isNotEmpty &&
          birthDate.value != null;
    }

    useEffect(() {
      final controllers = [firstNameController, fatherNameController, grandfatherNameController, birthPlaceController];
      for (var controller in controllers) {
        controller.addListener(validateStep1);
      }

      return () {
        for (var controller in controllers) {
          controller.removeListener(validateStep1);
        }
      };
    }, [firstNameController, fatherNameController, grandfatherNameController, birthPlaceController, birthDate]);

    void _animateToStep(int stepIndex) {
      currentStep.value = stepIndex;
      final context = stepKeys[stepIndex].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(
          context,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeInOutCubic,
          alignment: 0.05,
        );
      }
    }

    Future<void> pickImage() async {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 800);
      if (pickedFile != null) {
        imageBytes.value = await pickedFile.readAsBytes();
      }
    }

    final religions = ['ፕሮቴስታንት', 'ኦርቶዶክስ', 'ካቶሊክ', 'ሙስሊም', 'ይሖዋ ምስክር', 'ሐዋርያት', 'አግኖስቲክ', 'ኤቲስት', 'ሌላ'];
    final ethiopianLanguages = ['አማርኛ', 'ኦሮምኛ', 'ትግርኛ', 'ሶማልኛ', 'ሲዳምኛ', 'ወላይትኛ', 'ጉራግኛ', 'አፋርኛ', 'ሃዲይኛ', 'ጋሞኛ'];

    void addChild() {
      children.value = [...children.value, Child(firstNameController: TextEditingController(), fatherNameController: TextEditingController(), lastNameController: TextEditingController(), ageController: TextEditingController(), educationLevelController: TextEditingController())];
    }

    void removeChild(int index) {
      final newChildren = List<Child>.from(children.value)..removeAt(index);
      children.value = newChildren;
    }

    void submitForm() {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Member registration submitted successfully! (Simulation)'), backgroundColor: Colors.green));
    }

    final stepData = [
      _StepInfo(
        title: 'የግል መረጃ',
        subtitle: 'Personal Information',
        isValid: isStep1Valid.value,
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('ፎቶ (Profile Picture)'),
            const SizedBox(height: 16),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(radius: 60, backgroundColor: AppTheme.border, backgroundImage: imageBytes.value != null ? MemoryImage(imageBytes.value!) : null, child: imageBytes.value == null ? const Icon(Iconsax.user, size: 50, color: Colors.white70) : null),
                  Positioned(bottom: 0, right: 0, child: InkWell(onTap: pickImage, child: Container(padding: const EdgeInsets.all(8), decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryBlue), child: const Icon(Iconsax.camera, color: Colors.white, size: 20)))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _ThreePartNameField('ሙሉ ስም (Full Name)', c1: firstNameController, h1: 'ስም', v1: firstNameController.text.isNotEmpty, c2: fatherNameController, h2: 'የአባት ስም', v2: fatherNameController.text.isNotEmpty, c3: grandfatherNameController, h3: 'የአያት ስም', v3: grandfatherNameController.text.isNotEmpty),
            const SizedBox(height: 16),
            _CustomDatePicker(label: 'የትውልድ ዘመን (Date of Birth)', selectedDate: birthDate.value, onDateSelected: (date) { birthDate.value = date; validateStep1(); }, isValid: birthDate.value != null),
            const SizedBox(height: 16),
            _CustomTextField(controller: birthPlaceController, label: 'የትውልድ ቦታ (Place of Birth)', isValid: birthPlaceController.text.isNotEmpty),
          ],
        ),
      ),
      _StepInfo(
        title: 'መንፈሳዊ ሕይወት',
        subtitle: 'Spiritual Journey',
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle('ጌታን የተቀበሉበት (Salvation Experience)'),
            const SizedBox(height: 16),
            _CustomDatePicker(label: 'ጊዜ (Date)', selectedDate: salvationDate.value, onDateSelected: (date) => salvationDate.value = date),
            const SizedBox(height: 16),
            _CustomTextField(controller: salvationPlaceController, label: 'ቦታ (Place)'),
            const SizedBox(height: 24),
            _SectionTitle('የቤተክርስቲያን ዝውውር (Church Transfer)'),
            const SizedBox(height: 16),
            _CustomTextField(controller: previousChurchController, label: 'ከእዚህ ቀደም የነበረበት/ችበት ቤተክርስቲያን (Previous Church, if any)'),
            const SizedBox(height: 16),
            _CustomTextField(controller: reasonForTransferController, label: 'የዝውውር ምክኒያት (Reason for Transfer)'),
          ],
        ),
      ),
      _StepInfo(title: 'ትምህርት እና ሥራ', subtitle: 'Education & Career', content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _CustomTextField(controller: educationTypeController, label: 'የትምህርት አይነት (Field of Study)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: educationLevelController, label: 'የትምህርት ደረጃ (Education Level)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: employmentStatusController, label: 'የስራ ሁኔታ (Employment Status)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: workAddressController, label: 'የመስሪያ ቤት አድራሻ (Workplace Address)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: phoneNumberController, label: 'ስልክ ቁጥር (Phone Number)'),
      ],
      )),
      _StepInfo(title: 'የቤተሰብ ሁኔታ', subtitle: 'Family Information', content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _CustomDropdown(label: 'የጋብቻ ሁኔታ (Marital Status)', value: maritalStatus.value, items: ['ያገባ', 'ያላገባ', 'ሌላ'], onChanged: (val) => maritalStatus.value = val),
        if (maritalStatus.value == 'ሌላ') Padding(padding: const EdgeInsets.only(top: 16.0), child: _CustomTextField(controller: otherMaritalStatusController, label: 'የጋብቻ ሁኔታን ይግለፁ (Specify Marital Status)')),
        if (maritalStatus.value == 'ያገባ') ...[
          const SizedBox(height: 24),
          _SectionTitle('የባለቤት/ሚስት/ባል መረጃ (Spouse Information)'),
          const SizedBox(height: 16),
          _ThreePartNameField('የባለቤት/ሚስት/ባል ስም (Spouse\'s Full Name)', c1: spouseFirstNameController, h1: 'ስም', c2: spouseFatherNameController, h2: 'የአባት ስም', c3: spouseGrandfatherNameController, h3: 'የአያት ስም'),
          const SizedBox(height: 16),
          _CustomDropdown(label: 'እምነት (Religion)', value: spouseReligion.value, items: religions, onChanged: (val) => spouseReligion.value = val),
          if (spouseReligion.value == 'ሌላ') Padding(padding: const EdgeInsets.only(top: 16.0), child: _CustomTextField(controller: otherSpouseReligionController, label: 'የእምነት አይነት ይግለፁ (Specify Religion)')),
          const SizedBox(height: 16),
          _CustomDatePicker(label: 'ጋብቻው የተፈፀመበት ጊዜ (Marriage Date)', selectedDate: marriageDate.value, onDateSelected: (date) => marriageDate.value = date),
          const SizedBox(height: 16),
          _CustomTextField(controller: marriagePlaceController, label: 'ጋብቻው የተፈፀመበት ቦታ (Marriage Place)'),
        ],
        if (maritalStatus.value == 'ያገባ' || maritalStatus.value == 'ያላገባ') ...[
          const SizedBox(height: 24),
          _SectionTitle('የልጆች መረጃ (Children Information)'),
          if (maritalStatus.value == 'ያላገባ') ...[const SizedBox(height: 4), const Text('ልጅ ካለዎት መረጃውን እዚህ ያስገቡ (If you have children, enter their information here.)', style: TextStyle(color: Colors.grey))],
          const SizedBox(height: 8),
          ...List.generate(children.value.length, (index) => _ChildInfoCard(child: children.value[index], index: index + 1, religions: religions, onRemove: () => removeChild(index))),
          const SizedBox(height: 16),
          TextButton.icon(onPressed: addChild, icon: const Icon(Iconsax.add_square), label: const Text('ልጅ ያክሉ (Add Child)')),
          const SizedBox(height: 24),
        ],
        _CustomTextField(controller: additionalFamilyInfoController, label: 'የቤተሰብ ተጨማሪ ሁኔታ ካለ (Additional Family Notes)'),
        if (maritalStatus.value == 'ያላገባ') ...[const SizedBox(height: 16), _CustomTextField(controller: livingSituationSingleController, label: 'ያላገባ ከሆነ የሚኖርበት ሁኔታ (Living Situation if Single)')]
      ],
      )),
      _StepInfo(title: 'የአገልግሎት ሁኔታ', subtitle: 'Ministry Involvement', content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _CustomTextField(controller: serviceTypeController, label: 'የአገልግሎት ዓይነት (Type of Service)'),
        const SizedBox(height: 16),
        _CustomDatePicker(label: 'አገልግሎቱ የተሰጠበት ጊዜ (Service Date)', selectedDate: serviceDate.value, onDateSelected: (date) => serviceDate.value = date),
        const SizedBox(height: 16),
        _CustomTextField(controller: serviceResponsibilityController, label: 'ኃላፊነት (Responsibility)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: currentServiceController, label: '아ሁን ያለው/ላት አገልግሎት (Current Service)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: currentResponsibilityController, label: 'ኃላፊነት (Current Responsibility)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: spiritualGiftsController, label: 'የሚታይበት/ባት ፀጋ | የተለየ ችሎታ (Spiritual Gifts | Special Talents)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: futureServiceInterestController, label: 'ወደፊት ሊሳተፉበት የሚፈልጉት አገልግሎት (Future Service Interests)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: additionalServiceInfoController, label: 'ተጨማሪ መግለጫ (Additional Service Notes)', maxLines: 3),
      ]),
      ),
      _StepInfo(title: 'የኅብረት መረጃ', subtitle: 'Fellowship Info', content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _CustomDatePicker(label: 'የቤተሰብ ኅብረት የጀመረበት/ችበት ጊዜ (Fellowship Start Date)', selectedDate: fellowshipStartDate.value, onDateSelected: (date) => fellowshipStartDate.value = date),
        const SizedBox(height: 16),
        _CustomTextField(controller: fellowshipNameController, label: 'የቤተሰብ ኅብረቱ ስም (Fellowship Name)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: fellowshipResponsibilityController, label: 'በኅብረት ውስጥ ያለው/ላት ኅላፊነት (Responsibility in Fellowship)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: fellowshipMentorController, label: 'የአሰልጣኝ/መንፈሳዊ አባት ስም (Mentor/Spiritual Father)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: fellowshipMenteeController, label: 'የሚከታተለው መንፈሳዊ ልጅ (Mentee/Spiritual Child)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: additionalFellowshipInfoController, label: 'ተጨማሪ መግለጫ (Additional Fellowship Notes)', maxLines: 3),
      ]),
      ),
      _StepInfo(title: 'የአስተዳደር መረጃ', subtitle: 'Administrative', content: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _CustomTextField(controller: incomeLevelController, label: 'የገቢ መጠን (Income Level)'),
        const SizedBox(height: 16),
        _CustomDropdown(label: 'የአፍ መፍቻ ቋንቋ (Mother Tongue)', value: motherTongue.value, items: ethiopianLanguages, onChanged: (val) => motherTongue.value = val),
        const SizedBox(height: 16),
        _CustomDropdown(label: '아ባሉ አሁን ያሉበት ሁኔታ (Member\'s Current Status)', value: memberStatus.value, items: ['አሉ', 'ተዛውረዋል', 'በህይወት የሉም'], onChanged: (val) => memberStatus.value = val),
        const SizedBox(height: 24),
        _SectionTitle('ማረጋገጫ (Confirmation)'),
        const SizedBox(height: 16),
        _CustomDatePicker(label: 'ቅፁ የተሞላበት ጊዜ (Form Completion Date)', selectedDate: formCompletionDate.value, onDateSelected: (date) => formCompletionDate.value = date),
        const SizedBox(height: 16),
        _CustomTextField(controller: memberSignatureController, label: 'የአባሉ/ሏ ስምና ፊርማ (Member\'s Name & Signature)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: fellowshipLeaderSignatureController, label: 'የቤተሰብ ኅብረት መሪው ፊርማ (Fellowship Leader Signature)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: zoneLeaderSignatureController, label: 'የዞን ተጠሪው ስምና ፊርማ (Zone Leader Signature)'),
        const SizedBox(height: 16),
        _CustomTextField(controller: spiritualRepSignatureController, label: 'የመንፈሳዊ ዘርፍ ተወካይ ፊርማ (Spiritual Rep. Signature)'),
      ]),
      ),
    ];

    Widget controls = Row(
      children: <Widget>[
        if (currentStep.value == stepData.length - 1)
          PrimaryButton(text: 'REGISTER MEMBER', onPressed: submitForm, icon: Iconsax.user_add)
        else
          _ContinueButton(onPressed: () => _animateToStep(currentStep.value + 1)),
        if (currentStep.value > 0)
          TextButton(onPressed: () => _animateToStep(currentStep.value - 1), child: const Text('BACK')),
      ],
    );

    return InfoCard(
      title: 'New Member Registration Form',
      description: 'Please fill out all sections completely and accurately.',
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          children: List.generate(stepData.length, (index) {
            return _CustomStep(
              key: stepKeys[index],
              title: stepData[index].title,
              subtitle: stepData[index].subtitle,
              index: index,
              isActive: currentStep.value == index,
              isComplete: currentStep.value > index,
              isValid: stepData[index].isValid,
              onStepTapped: () => _animateToStep(index),
              controls: currentStep.value == index ? controls : null,
              child: stepData[index].content,
            );
          }),
        ),
      ),
    );
  }
}

class _StepInfo {
  final String title;
  final String subtitle;
  final Widget content;
  final bool isValid;
  _StepInfo({required this.title, required this.subtitle, required this.content, this.isValid = false});
}

class _CustomStep extends StatelessWidget {
  final String title;
  final String subtitle;
  final int index;
  final bool isActive;
  final bool isComplete;
  final bool isValid;
  final VoidCallback onStepTapped;
  final Widget? controls;
  final Widget child;

  const _CustomStep({
    super.key,
    required this.title,
    required this.subtitle,
    required this.index,
    required this.isActive,
    required this.isComplete,
    required this.isValid,
    required this.onStepTapped,
    required this.child,
    this.controls,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onStepTapped,
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              _StepIcon(index: index + 1, isActive: isActive, isComplete: isComplete, isValid: isValid),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 18, fontWeight: isActive ? FontWeight.bold : FontWeight.normal, color: isActive ? AppTheme.primaryBlue : Colors.black87)),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 19.5),
            SizedBox(
              width: 1,
              child: isComplete && index < 6 ? Container(height: 30, color: AppTheme.primaryBlue) : const SizedBox(height: 30),
            ),
            const SizedBox(width: 35.5),
            Expanded(
              child: AnimatedSize(
                duration: 300.ms,
                curve: Curves.easeInOut,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isActive) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                        child: child,
                      ).animate().fadeIn(duration: 400.ms, delay: 150.ms),
                      if (controls != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: controls,
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepIcon extends StatelessWidget {
  final int index;
  final bool isActive;
  final bool isComplete;
  final bool isValid;

  const _StepIcon({required this.index, required this.isActive, required this.isComplete, required this.isValid});

  @override
  Widget build(BuildContext context) {
    final bool isDone = isComplete || isValid;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppTheme.primaryBlue : (isDone ? Colors.green.shade50 : Colors.grey.shade200),
        border: Border.all(color: isActive ? Colors.transparent : (isDone ? Colors.green : Colors.grey.shade400)),
      ),
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
          child: isDone
              ? Icon(Iconsax.tick_circle, key: const ValueKey('icon_done'), color: isComplete && !isActive ? Colors.green : Colors.white)
              : Text('$index', key: ValueKey('icon_index_$index'), style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}

class _ContinueButton extends StatefulWidget {
  final VoidCallback onPressed;
  const _ContinueButton({required this.onPressed});

  @override
  State<_ContinueButton> createState() => _ContinueButtonState();
}

class _ContinueButtonState extends State<_ContinueButton> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.reverse(),
      onTapUp: (_) {
        _animationController.forward().then((_) {
          if (mounted) {
            widget.onPressed();
          }
        });
      },
      onTapCancel: () => _animationController.forward(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Iconsax.arrow_right_3),
          label: const Text('CONTINUE'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Theme.of(context).colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool isValid;

  const _CustomTextField({required this.controller, required this.label, this.maxLines = 1, this.isValid = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: isValid ? const Icon(Iconsax.tick_circle, color: Colors.green, key: ValueKey('valid')) : const SizedBox(key: ValueKey('invalid')),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool isValid;

  const _CustomDropdown({required this.label, this.value, required this.items, required this.onChanged, this.isValid = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixIcon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: isValid ? const Icon(Iconsax.tick_circle, color: Colors.green, key: ValueKey('valid')) : const SizedBox(key: ValueKey('invalid')),
            ),
          ),
        ),
      ],
    );
  }
}

class _CustomDatePicker extends StatelessWidget {
  final String label;
  final DateTime? selectedDate;
  final ValueChanged<DateTime> onDateSelected;
  final bool isValid;

  const _CustomDatePicker({required this.label, this.selectedDate, required this.onDateSelected, this.isValid = false});

  @override
  Widget build(BuildContext context) {
    Future<void> selectDate() async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate ?? DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primaryBlue,
                onPrimary: Colors.white,
                onSurface: Colors.black87,
              ),
              dialogTheme: DialogThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryBlue,
                ),
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null && picked != selectedDate) {
        onDateSelected(picked);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black54)),
        const SizedBox(height: 8),
        InkWell(
          onTap: selectDate,
          child: InputDecorator(
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              isDense: true,
              contentPadding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              suffixIcon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: isValid ? const Icon(Iconsax.tick_circle, color: Colors.green, key: ValueKey('valid')) : const SizedBox(key: ValueKey('invalid')),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(selectedDate != null ? DateFormat.yMMMMd().format(selectedDate!) : 'Select Date'),
                const Icon(Iconsax.calendar_1, color: Colors.black54),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ThreePartNameField extends StatelessWidget {
  final String label;
  final TextEditingController c1, c2, c3;
  final String h1, h2, h3;
  final bool v1, v2, v3;

  const _ThreePartNameField(this.label, {required this.c1, required this.h1, this.v1 = false, required this.c2, required this.h2, this.v2 = false, required this.c3, required this.h3, this.v3 = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, constraints) {
          bool useColumn = constraints.maxWidth < 600;
          return useColumn
              ? Column(children: [
            _CustomTextField(controller: c1, label: h1, isValid: v1),
            const SizedBox(height: 16),
            _CustomTextField(controller: c2, label: h2, isValid: v2),
            const SizedBox(height: 16),
            _CustomTextField(controller: c3, label: h3, isValid: v3),
          ])
              : Row(children: [
            Expanded(child: _CustomTextField(controller: c1, label: h1, isValid: v1)),
            const SizedBox(width: 8),
            Expanded(child: _CustomTextField(controller: c2, label: h2, isValid: v2)),
            const SizedBox(width: 8),
            Expanded(child: _CustomTextField(controller: c3, label: h3, isValid: v3)),
          ]);
        }),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue.withOpacity(0.8))));
  }
}

class _ChildInfoCard extends HookWidget {
  final Child child;
  final int index;
  final List<String> religions;
  final VoidCallback onRemove;

  const _ChildInfoCard({required this.child, required this.index, required this.religions, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final gender = useState(child.gender);
    final religion = useState(child.religion);
    final otherReligionController = useTextEditingController();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('ልጅ $index (Child $index)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), IconButton(icon: Icon(Iconsax.trash, color: Colors.red.shade400), onPressed: onRemove, tooltip: 'Remove Child')]),
            const SizedBox(height: 16),
            _ThreePartNameField('የልጅ ስም (Child\'s Name)', c1: child.firstNameController, h1: 'ስም', c2: child.fatherNameController, h2: 'የአባት ስም', c3: child.lastNameController, h3: 'የአያት ስም'),
            const SizedBox(height: 16),
            LayoutBuilder(builder: (context, constraints) {
              bool useColumn = constraints.maxWidth < 450;
              return useColumn
                  ? Column(children: [
                _CustomDropdown(label: 'ፆታ (Gender)', value: gender.value, items: ['ወንድ', 'ሴት'], onChanged: (val) => gender.value = val),
                const SizedBox(height: 16),
                _CustomTextField(controller: child.ageController, label: 'ዕድሜ (Age)'),
              ])
                  : Row(children: [
                Expanded(child: _CustomDropdown(label: 'ፆታ (Gender)', value: gender.value, items: ['ወንድ', 'ሴት'], onChanged: (val) => gender.value = val)),
                const SizedBox(width: 16),
                Expanded(child: _CustomTextField(controller: child.ageController, label: 'ዕድሜ (Age)')),
              ]);
            }),
            const SizedBox(height: 16),
            _CustomTextField(controller: child.educationLevelController, label: 'የት/ደረጃ (Education Level)'),
            const SizedBox(height: 16),
            _CustomDropdown(label: 'እምነት (Religion)', value: religion.value, items: religions, onChanged: (val) => religion.value = val),
            if (religion.value == 'ሌላ') Padding(padding: const EdgeInsets.only(top: 16.0), child: _CustomTextField(controller: otherReligionController, label: 'የእምነት አይነት ይግለፁ (Specify Religion)')),
          ],
        ),
      ),
    );
  }
}