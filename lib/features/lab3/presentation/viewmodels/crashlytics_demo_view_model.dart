import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alumni_connect/features/lab3/presentation/providers/firebase_service_providers.dart';

class CrashlyticsDemoViewModel extends Notifier<void> {
  @override
  void build() {}

  void triggerTestCrash() {
    if (!kDebugMode) return;
    ref.read(firebaseCrashlyticsServiceProvider)?.crashForDemo();
  }
}

final crashlyticsDemoViewModelProvider =
    NotifierProvider<CrashlyticsDemoViewModel, void>(
      CrashlyticsDemoViewModel.new,
    );
