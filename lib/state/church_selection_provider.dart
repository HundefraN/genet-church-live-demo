import 'package:genet_church_portal/data/models/church_model.dart';
import 'package:genet_church_portal/state/providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'church_selection_provider.g.dart';

@riverpod
class CurrentChurch extends _$CurrentChurch {
  @override
  String? build() {
    ref.listen(churchesProvider, (previous, next) {
      final availableChurchIds = next.valueOrNull?.map((c) => c.id).toSet();
      if (state != null &&
          availableChurchIds != null &&
          !availableChurchIds.contains(state)) {
        state = null;
      }
    });
    return null;
  }

  void selectChurch(String? churchId) {
    state = churchId;
  }
}