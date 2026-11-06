import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class StorageUploadProgress {
  const StorageUploadProgress({
    required this.transferredBytes,
    required this.totalBytes,
    this.downloadUrl,
  });

  final int transferredBytes;
  final int totalBytes;
  final String? downloadUrl;

  double get fraction => totalBytes == 0 ? 0 : transferredBytes / totalBytes;
}

class FirebaseStorageService {
  FirebaseStorageService(this._storage);

  final FirebaseStorage _storage;

  Stream<StorageUploadProgress> uploadReport({
    required String uid,
    required File file,
    required String fileName,
  }) async* {
    yield* _upload(path: 'reports', uid: uid, file: file, fileName: fileName);
  }

  Stream<StorageUploadProgress> uploadPostImage({
    required String uid,
    required File file,
    required String fileName,
  }) async* {
    yield* _upload(path: 'posts', uid: uid, file: file, fileName: fileName);
  }

  Stream<StorageUploadProgress> _upload({
    required String path,
    required String uid,
    required File file,
    required String fileName,
  }) async* {
    if (uid.isEmpty || uid.contains('/') || uid.contains('..')) {
      throw ArgumentError.value(uid, 'uid', 'A valid user ID is required.');
    }
    final safeName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    if (safeName.isEmpty || safeName == '.' || safeName == '..') {
      throw ArgumentError.value(
        fileName,
        'fileName',
        'A valid file name is required.',
      );
    }

    final extension = safeName.split('.').last.toLowerCase();
    final contentType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'pdf' => 'application/pdf',
      'csv' => 'text/csv',
      _ => throw ArgumentError.value(
        fileName,
        'fileName',
        'Only JPG, PNG, WebP, PDF, and CSV files are supported.',
      ),
    };
    final reference = _storage.ref('$path/$uid/$safeName');
    final task = reference.putFile(
      file,
      SettableMetadata(contentType: contentType),
    );
    await for (final snapshot in task.snapshotEvents) {
      String? downloadUrl;
      if (snapshot.state == TaskState.success) {
        downloadUrl = await reference.getDownloadURL();
      }
      yield StorageUploadProgress(
        transferredBytes: snapshot.bytesTransferred,
        totalBytes: snapshot.totalBytes,
        downloadUrl: downloadUrl,
      );
    }
  }
}
