import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alumni_connect/features/lab3/presentation/providers/firebase_service_providers.dart';

class AvatarUploadState {
  const AvatarUploadState({
    this.isUploading = false,
    this.progress = 0,
    this.error,
  });

  final bool isUploading;
  final double progress;
  final String? error;
}

class AvatarUploadViewModel extends Notifier<AvatarUploadState> {
  final ImagePicker _picker = ImagePicker();

  @override
  AvatarUploadState build() => const AvatarUploadState();

  Future<String?> pickAndUploadAvatar({
    ImageSource source = ImageSource.gallery,
  }) async {
    state = const AvatarUploadState();
    try {
      final picker = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picker == null) return null;

      final auth = ref.read(firebaseAuthServiceProvider);
      final storage = ref.read(firebaseStorageServiceProvider);
      final user = auth?.currentUser;
      if (user == null || storage == null) {
        state = const AvatarUploadState(
          error: 'Đăng nhập Firebase trước khi tải ảnh lên.',
        );
        return null;
      }

      state = const AvatarUploadState(isUploading: true);
      String? downloadUrl;
      await for (final progress in storage.uploadReport(
        uid: user.uid,
        file: File(picker.path),
        fileName: picker.name,
      )) {
        downloadUrl = progress.downloadUrl ?? downloadUrl;
        state = AvatarUploadState(
          isUploading: progress.downloadUrl == null,
          progress: progress.fraction,
        );
      }
      if (downloadUrl == null) {
        throw StateError('Storage upload completed without a download URL.');
      }
      final analytics = ref.read(firebaseAnalyticsServiceProvider);
      if (analytics != null) {
        await analytics.logAvatarUploadComplete();
      }
      return downloadUrl;
    } on Object catch (_, stackTrace) {
      final crashlytics = ref.read(firebaseCrashlyticsServiceProvider);
      if (crashlytics != null) {
        try {
          await crashlytics.recordHandledError(
            StateError('Avatar upload failed.'),
            stackTrace,
            reason: 'avatar_upload_failed',
          );
        } on Object {
          // Crash reporting must not prevent the upload error reaching the UI.
        }
      }
      state = const AvatarUploadState(
        error: 'Không thể tải ảnh lên. Kiểm tra kết nối và quyền Storage.',
      );
      return null;
    }
  }
}

final avatarUploadViewModelProvider =
    NotifierProvider<AvatarUploadViewModel, AvatarUploadState>(
      AvatarUploadViewModel.new,
    );
