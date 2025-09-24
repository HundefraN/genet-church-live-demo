// import 'package:flutter/material.dart';
// import 'package:flutter_hooks/flutter_hooks.dart';
// import 'package:genet_church_portal/core/theme/app_theme.dart';
// import 'package:genet_church_portal/data/models/communication_model.dart';
// import 'package:genet_church_portal/shared_widgets/custom_dropdown.dart';
// import 'package:genet_church_portal/shared_widgets/modern_text_field.dart';
// import 'package:genet_church_portal/shared_widgets/page_header.dart';
// import 'package:genet_church_portal/shared_widgets/primary_button.dart';
// import 'package:genet_church_portal/shared_widgets/secondary_button.dart';
// import 'package:genet_church_portal/state/providers.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:iconsax/iconsax.dart';
// import 'package:intl/intl.dart';
// import 'package:uuid/uuid.dart';
//
// class CommunicationHubScreen extends HookConsumerWidget {
//   const CommunicationHubScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final subjectController = useTextEditingController();
//     final messageController = useTextEditingController();
//     final selectedRecipients = useState<String>('All Members');
//
//     final communications = ref.watch(communicationProvider);
//     final recentComms = communications.where((c) => !c.isDraft).take(3).toList();
//     final recipientGroups = ['All Members', 'Youth Group', 'Choir', 'Sunday School Volunteers'];
//
//     void clearForm() {
//       subjectController.clear();
//       messageController.clear();
//     }
//
//     void sendMessage() {
//       if (messageController.text.isEmpty) {
//         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message cannot be empty.'), backgroundColor: Colors.orange));
//         return;
//       }
//       ref.read(communicationProvider.notifier).sendMessage(subjectController.text, messageController.text, [selectedRecipients.value]);
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Message sent successfully!'), backgroundColor: Colors.green));
//       clearForm();
//     }
//
//     void saveDraft() {
//       if (messageController.text.isEmpty && subjectController.text.isEmpty) return;
//       ref.read(communicationProvider.notifier).saveDraft(subjectController.text, messageController.text, [selectedRecipients.value]);
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Draft saved.'), backgroundColor: AppTheme.primaryBlue));
//       clearForm();
//     }
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 2,
//           child: Column(
//             children: [
//               const PageHeader(
//                 title: 'Communication Hub',
//                 description: 'Send targeted emails to members, groups, and volunteers.',
//               ),
//               const SizedBox(height: 24),
//               CustomDropdown(
//                 hintText: 'Send To:',
//                 items: recipientGroups,
//                 value: selectedRecipients.value,
//                 onChanged: (val) {
//                   if (val != null) selectedRecipients.value = val;
//                 },
//               ),
//               const SizedBox(height: 16),
//               ModernTextField(
//                 controller: subjectController,
//                 hintText: 'Subject',
//                 icon: Iconsax.edit,
//               ),
//               const SizedBox(height: 16),
//               TextField(
//                 controller: messageController,
//                 maxLines: 10,
//                 decoration: const InputDecoration(
//                   hintText: 'Type your message here...',
//                 ),
//               ),
//               const SizedBox(height: 24),
//               Row(
//                 children: [
//                   PrimaryButton(text: 'SEND MESSAGE', onPressed: sendMessage, icon: Iconsax.send_1),
//                   const SizedBox(width: 16),
//                   SecondaryButton(text: 'SAVE DRAFT', onPressed: saveDraft, icon: Iconsax.document_upload),
//                 ],
//               )
//             ],
//           ),
//         ),
//         const SizedBox(width: 32),
//         Expanded(
//           flex: 1,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Recent Communications', style: Theme.of(context).textTheme.headlineMedium),
//               const SizedBox(height: 24),
//               if (recentComms.isEmpty)
//                 const Center(child: Text('No recent messages.'))
//               else
//                 ...recentComms.map((comm) => _RecentCommunicationTile(communication: comm)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _RecentCommunicationTile extends StatelessWidget {
//   final Communication communication;
//   const _RecentCommunicationTile({required this.communication});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: AppTheme.scaffoldBackground,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: AppTheme.border),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: AppTheme.primaryBlue.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               communication.recipients.join(', '),
//               style: const TextStyle(
//                 color: AppTheme.primaryBlue,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             communication.subject,
//             style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
//             overflow: TextOverflow.ellipsis,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Sent: ${DateFormat.yMMMd().format(communication.timestamp)}',
//             style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
//           ),
//         ],
//       ),
//     );
//   }
// }