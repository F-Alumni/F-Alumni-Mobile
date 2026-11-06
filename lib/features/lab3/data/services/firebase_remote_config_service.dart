import 'package:firebase_remote_config/firebase_remote_config.dart';

class FirebaseRemoteConfigService {
  FirebaseRemoteConfigService(this._config);

  final FirebaseRemoteConfig _config;

  static const defaults = <String, Object>{
    'is_promo_banner_enabled': true,
    'max_items_display': 10,
  };

  Future<void> initialize({bool forceRefresh = false}) async {
    await _config.setDefaults(defaults);
    await _config.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: forceRefresh
            ? Duration.zero
            : const Duration(hours: 1),
      ),
    );
    try {
      await _config.fetchAndActivate();
    } on Exception {
      // Keep the defaults/last activated values when the device is offline.
    }
  }

  bool get isPromoBannerEnabled => _config.getBool('is_promo_banner_enabled');

  int get maxItemsDisplay =>
      _config.getInt('max_items_display').clamp(1, 50).toInt();
}
