import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:genet_church_portal/data/models/session_model.dart';
import 'package:genet_church_portal/data/repositories/api_repository.dart';
import 'package:genet_church_portal/shared_widgets/modern_button.dart';
import 'package:genet_church_portal/shared_widgets/notification_system.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:genet_church_portal/shared_widgets/table_shimmer_loader.dart';
import 'package:iconsax/iconsax.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:timeago/timeago.dart' as timeago;

part 'sessions_screen.g.dart';

@riverpod
Future<List<Session>> userSessions(UserSessionsRef ref) {
  return ref.watch(apiRepositoryProvider).getSessions();
}

class SessionsScreen extends ConsumerWidget {
  const SessionsScreen({super.key});

  static IconData _getDeviceIcon(String userAgent) {
    final ua = userAgent.toLowerCase();
    if (ua.contains('mobile') ||
        ua.contains('android') ||
        ua.contains('iphone')) {
      return Iconsax.mobile;
    } else if (ua.contains('ipad') || ua.contains('tablet')) {
      return Iconsax.device_message;
    } else {
      return Iconsax.monitor;
    }
  }

  static String _getDeviceName(String userAgent) {
    if (userAgent.contains('Macintosh')) return 'Mac';
    if (userAgent.contains('Windows')) return 'Windows';
    if (userAgent.contains('iPhone')) return 'iPhone';
    if (userAgent.contains('Android')) return 'Android';
    if (userAgent.contains('Linux')) return 'Linux';
    return 'Unknown Device';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(userSessionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Active Sessions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            DestructiveButton(
              text: 'Log out all other devices',
              icon: Iconsax.logout,
              size: ButtonSize.small,
              onPressedAsync: () async {
                try {
                  await ref
                      .read(apiRepositoryProvider)
                      .revokeAllSessions(keepCurrent: true);
                  ref.invalidate(userSessionsProvider);
                  if (context.mounted) {
                    context.showSuccessNotification(
                      title: 'Success',
                      message: 'All other sessions have been revoked.',
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    context.showErrorNotification(
                      title: 'Error',
                      message: 'Failed to revoke sessions.',
                    );
                  }
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        sessionsAsync.when(
          data: (sessions) {
            return Expanded(
              child: StyledDataTable(
                columns: const [
                  'Device',
                  'User Agent',
                  'Last Active',
                  'Status',
                  'Action',
                ],
                rows: sessions.map((session) {
                  return DataRow(
                    cells: [
                      DataCell(
                        Row(
                          children: [
                            Icon(
                              _getDeviceIcon(session.userAgent),
                              size: 20,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(_getDeviceName(session.userAgent)),
                          ],
                        ),
                      ),
                      DataCell(
                        SizedBox(
                          width: 200,
                          child: Text(
                            session.userAgent,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      DataCell(Text(timeago.format(session.updatedAt))),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: session.isCurrent
                                ? Colors.green.withOpacity(0.1)
                                : Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: session.isCurrent
                                  ? Colors.green.withOpacity(0.5)
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            session.isCurrent ? 'Current' : 'Active',
                            style: TextStyle(
                              fontSize: 12,
                              color: session.isCurrent
                                  ? Colors.green
                                  : Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      DataCell(
                        session.isCurrent
                            ? const Text('Current Session')
                            : ModernButton(
                          text: 'Revoke',
                          size: ButtonSize.small,
                          variant: ButtonVariant.outline,
                          customColor:
                          Theme.of(context).colorScheme.error,
                          onPressedAsync: () async {
                            try {
                              await ref
                                  .read(apiRepositoryProvider)
                                  .revokeSession(session.id);
                              ref.invalidate(userSessionsProvider);
                              if (context.mounted) {
                                context.showSuccessNotification(
                                  title: 'Success',
                                  message: 'Session revoked.',
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                context.showErrorNotification(
                                  title: 'Error',
                                  message: 'Failed to revoke session.',
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            );
          },
          loading: () => const TableShimmerLoader(columnCount: 5),
          error: (e, s) => Center(child: Text('Error loading sessions: $e')),
        ),
      ],
    );
  }
}