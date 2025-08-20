import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/core/theme/app_theme.dart';
import 'package:genet_church_portal/shared_widgets/custom_dropdown.dart';
import 'package:genet_church_portal/shared_widgets/custom_text_field.dart';
import 'package:genet_church_portal/shared_widgets/info_card.dart';
import 'package:genet_church_portal/shared_widgets/primary_button.dart';
import 'package:genet_church_portal/shared_widgets/secondary_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';

class CommunicationHubScreen extends HookConsumerWidget {
  const CommunicationHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectController = useTextEditingController();
    final messageController = useTextEditingController();

    void sendMessage() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message sent successfully! (Simulation)'),
          backgroundColor: Colors.green,
        ),
      );
      subjectController.clear();
      messageController.clear();
    }

    return InfoCard(
      title: 'Communication Hub',
      description: 'Send targeted emails to members, groups, and volunteers.',
      child: ListView(
        shrinkWrap: true,
        physics: const ClampingScrollPhysics(),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Compose Message', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    const CustomDropdown(
                      hintText: 'Send To:',
                      items: ['All Members', 'Youth Group', 'Choir', 'Sunday School Volunteers'],
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: subjectController,
                      hintText: 'Subject',
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: messageController,
                      hintText: 'Type your message here...',
                      maxLines: 10,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        PrimaryButton(text: 'SEND MESSAGE', onPressed: sendMessage, icon: Iconsax.send_1),
                        const SizedBox(width: 16),
                        SecondaryButton(text: 'SAVE DRAFT', onPressed: () {}, icon: Iconsax.edit),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recent Communications', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    const _RecentCommunicationTile(
                      group: 'All Members',
                      subject: 'Sunday Service Reminder',
                      date: 'Oct 20, 2023',
                    ),
                    const _RecentCommunicationTile(
                      group: 'Youth Group',
                      subject: 'Youth Conference Registration',
                      date: 'Oct 18, 2023',
                    ),
                    const _RecentCommunicationTile(
                      group: 'Choir',
                      subject: 'Practice Canceled',
                      date: 'Oct 15, 2023',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecentCommunicationTile extends StatelessWidget {
  final String group;
  final String subject;
  final String date;

  const _RecentCommunicationTile({
    required this.group,
    required this.subject,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.scaffoldBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              group,
              style: TextStyle(
                color: AppTheme.primaryBlue,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subject,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Sent: $date',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }
}