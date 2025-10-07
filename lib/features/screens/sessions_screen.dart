import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:genet_church_portal/data/repositories/api_repository.dart';
import 'package:genet_church_portal/shared_widgets/api_error_widget.dart';
import 'package:genet_church_portal/shared_widgets/page_header.dart';
import 'package:genet_church_portal/shared_widgets/styled_data_table.dart';
import 'package:genet_church_portal/shared_widgets/table_action_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../data/models/session_model.dart';

class SessionsScreen extends HookConsumerWidget {
  const SessionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsState = useState<AsyncValue<List<Session>>>(const AsyncValue.loading());
    final isRevoking = useState<String?>(null);

    Future<void> fetchSessions() async {
      sessionsState.value = const AsyncValue.loading();
      try {
        final sessions = await ref.read(apiRepositoryProvider).getSessions();
        sessionsState.value = AsyncValue.data(sessions);
      } catch (e, s) {
        sessionsState.value = AsyncValue.error(e, s);
      }
    }

    useEffect(() {
      fetchSessions();
      return null;
    }, []);

    return Column(
      children: [
        const PageHeader(
          title: 'Active Sessions',
          description: 'Manage devices that are logged into your account. You can revoke sessions you don\'t recognize.',
        ),
        const SizedBox(height: 24),
        sessionsState.value.when(
          data: (sessions) {
            return StyledDataTable(
              columns: const ['Created', 'Expires', 'Device / User Agent', 'Actions'],
              rows: sessions.map((session) {
                return DataRow(
                  cells: [
                    DataCell(Text(timeago.format(session.createdAt))),
                    DataCell(Text(timeago.format(session.expiresAt))),
                    DataCell(Text(session.userAgent, maxLines: 2, overflow: TextOverflow.ellipsis)),
                    DataCell(
                      session.isCurrent
                          ? const Chip(label: Text('Current Device'), avatar: Icon(Iconsax.tick_circle))
                          : TableActionButton(
                        label: 'REVOKE',
                        color: Theme.of(context).colorScheme.error,
                        isLoading: isRevoking.value == session.id,
                        onPressed: () async {
                          isRevoking.value = session.id;
                          await ref.read(apiRepositoryProvider).revokeSession(session.id);
                          await fetchSessions();
                          isRevoking.value = null;
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => ApiErrorWidget(error: err),
        ),
      ],
    );
  }
}