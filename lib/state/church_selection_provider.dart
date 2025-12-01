import 'package:genet_church_portal/data/models/user_model.dart';
import 'package:genet_church_portal/data/repositories/auth_repository.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'church_selection_provider.g.dart';

@riverpod
class CurrentChurch extends _$CurrentChurch {
  @override
  String? build() {
    final user = ref.watch(authStateProvider);

    if (user != null && user.roleEnum == UserRole.PASTOR) {
      if (user.pastorDetails != null &&
          user.pastorDetails!['churchId'] != null) {
        return user.pastorDetails!['churchId'] as String;
      }
      final pastor = ref.watch(currentPastorProvider);
      return pastor.value?.churchId;
    }

    return null;
  }

  void selectChurch(String? churchId) {
    final user = ref.read(authStateProvider);

    if (user != null && user.roleEnum == UserRole.SUPER_ADMIN) {
      state = churchId;
    }
  }
}