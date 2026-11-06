import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alumni_connect/features/lab3/presentation/providers/firebase_service_providers.dart';

class RemoteConfigUiSettings {
  const RemoteConfigUiSettings({
    required this.isPromoBannerEnabled,
    required this.maxItemsDisplay,
  });

  static const defaults = RemoteConfigUiSettings(
    isPromoBannerEnabled: true,
    maxItemsDisplay: 10,
  );

  final bool isPromoBannerEnabled;
  final int maxItemsDisplay;
}

class RemoteConfigViewModel extends AsyncNotifier<RemoteConfigUiSettings> {
  @override
  Future<RemoteConfigUiSettings> build() => _loadSettings();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadSettings(forceRefresh: true));
  }

  Future<RemoteConfigUiSettings> _loadSettings({
    bool forceRefresh = false,
  }) async {
    final service = forceRefresh
        ? ref.read(firebaseRemoteConfigServiceProvider)
        : ref.watch(firebaseRemoteConfigServiceProvider);
    if (service == null) return RemoteConfigUiSettings.defaults;
    try {
      await service.initialize(forceRefresh: forceRefresh);
      return RemoteConfigUiSettings(
        isPromoBannerEnabled: service.isPromoBannerEnabled,
        maxItemsDisplay: service.maxItemsDisplay,
      );
    } on Object {
      return RemoteConfigUiSettings.defaults;
    }
  }
}

final remoteConfigViewModelProvider =
    AsyncNotifierProvider<RemoteConfigViewModel, RemoteConfigUiSettings>(
      RemoteConfigViewModel.new,
    );
