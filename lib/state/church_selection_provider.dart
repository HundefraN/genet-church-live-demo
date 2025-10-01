import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'church_selection_provider.g.dart';

@riverpod
class CurrentChurch extends _$CurrentChurch {
  @override
  String? build() {
    return null;
  }

  void selectChurch(String? churchId) {
    state = churchId;
  }
}