import 'dart:io';
import 'dart:ui' as ui;
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:turota_mobile/features/profile/data/services/profile_photo_debug_log.dart';
import 'package:turota_mobile/features/profile/domain/services/profile_photo_user_key_resolver.dart';
import 'package:turota_mobile/core/networking/api_client.dart';

enum ProfilePhotoSource { gallery, camera }

class ProfilePhotoFailure implements Exception {
  const ProfilePhotoFailure(this.message);

  final String message;
}

abstract interface class ProfilePhotoPicker {
  Future<String?> pick(ProfilePhotoSource source);
  Future<String?> retrieveLostPhoto();
}

abstract interface class ProfilePhotoCropper {
  Future<String?> crop(String sourcePath);
}

abstract interface class ProfilePhotoStore {
  Future<String?> load(ProfilePhotoUserKey userKey);
  Future<String> save(ProfilePhotoUserKey userKey, String sourcePath);
  Future<void> remove(ProfilePhotoUserKey userKey);
}

abstract interface class ProfilePhotoPreferences {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

abstract interface class ProfilePhotoClipboard {
  Future<Uint8List?> readImage();
}

abstract interface class ProfilePhotoTemporaryFileStore {
  Future<String> writeClipboardImage(Uint8List bytes);
  Future<void> delete(String path);
}

abstract interface class ProfilePhotoRemoteDataSource {
  Future<String> upload(String filePath);
  Future<void> remove();
}

class ApiProfilePhotoRemoteDataSource implements ProfilePhotoRemoteDataSource {
  ApiProfilePhotoRemoteDataSource(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<String> upload(String filePath) async {
    final response = await _apiClient.putFile(
      '/api/identity/me/profile-photo',
      field: 'file',
      filePath: filePath,
    );
    final url =
        (response as Map<String, dynamic>)['profilePhotoUrl'] as String?;
    if (url == null || url.trim().isEmpty) {
      throw const ProfilePhotoFailure(
        'Profil fotoğrafı sunucuya kaydedilemedi. Lütfen tekrar deneyin.',
      );
    }
    return url;
  }

  @override
  Future<void> remove() => _apiClient.delete('/api/identity/me/profile-photo');
}

abstract interface class LegacyProfilePhotoMigration {
  Future<bool> uploadExisting(String localPath);
}

abstract interface class ProfilePhotoService {
  Future<String?> load(ProfilePhotoUserKey userKey);
  Future<String?> selectAndSave(
    ProfilePhotoUserKey userKey,
    ProfilePhotoSource source,
  );
  Future<String?> pasteAndSave(ProfilePhotoUserKey userKey);
  Future<String?> recropAndSave(
    ProfilePhotoUserKey userKey,
    String currentPath,
  );
  Future<String?> recoverLostAndSave(ProfilePhotoUserKey userKey);
  Future<void> remove(ProfilePhotoUserKey userKey);
}

class LocalProfilePhotoService
    implements ProfilePhotoService, LegacyProfilePhotoMigration {
  LocalProfilePhotoService({
    required ProfilePhotoPicker picker,
    required ProfilePhotoCropper cropper,
    required ProfilePhotoStore store,
    required ProfilePhotoClipboard clipboard,
    required ProfilePhotoTemporaryFileStore temporaryFileStore,
    ProfilePhotoRemoteDataSource? remoteDataSource,
  }) : _picker = picker,
       _cropper = cropper,
       _store = store,
       _clipboard = clipboard,
       _temporaryFileStore = temporaryFileStore,
       _remoteDataSource = remoteDataSource;

  final ProfilePhotoPicker _picker;
  final ProfilePhotoCropper _cropper;
  final ProfilePhotoStore _store;
  final ProfilePhotoClipboard _clipboard;
  final ProfilePhotoTemporaryFileStore _temporaryFileStore;
  final ProfilePhotoRemoteDataSource? _remoteDataSource;

  static const _maximumClipboardBytes = 15 * 1024 * 1024;
  static const _maximumClipboardPixels = 50 * 1000 * 1000;

  @override
  Future<String?> load(ProfilePhotoUserKey userKey) => _store.load(userKey);

  @override
  Future<String?> selectAndSave(
    ProfilePhotoUserKey userKey,
    ProfilePhotoSource source,
  ) async {
    try {
      final selectedPath = await _picker.pick(source);
      if (selectedPath == null) return null;
      return _cropAndSave(userKey, selectedPath);
    } on ProfilePhotoFailure {
      rethrow;
    } on PlatformException catch (error) {
      throw _mapPlatformFailure(error, source: source);
    } on UnsupportedError {
      throw _unsupportedFormatFailure;
    } on FormatException {
      throw _unsupportedFormatFailure;
    } catch (_) {
      if (source == ProfilePhotoSource.camera) {
        throw _cameraUnavailableFailure;
      }
      throw const ProfilePhotoFailure(
        'Fotoğraf seçilemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  @override
  Future<String?> pasteAndSave(ProfilePhotoUserKey userKey) async {
    String? temporaryPath;
    try {
      final bytes = await _clipboard.readImage();
      if (bytes == null || bytes.isEmpty) throw _emptyClipboardFailure;
      if (!_hasSafePngHeader(bytes) || !await _canDecodeImage(bytes)) {
        throw _unsupportedClipboardFailure;
      }

      temporaryPath = await _temporaryFileStore.writeClipboardImage(bytes);
      return await _cropAndSave(userKey, temporaryPath);
    } on ProfilePhotoFailure {
      rethrow;
    } catch (_) {
      throw const ProfilePhotoFailure(
        'Panodaki görsel okunamadı. Lütfen tekrar deneyin.',
      );
    } finally {
      if (temporaryPath != null) {
        try {
          await _temporaryFileStore.delete(temporaryPath);
        } catch (_) {
          // The managed temporary file can be cleaned on a later attempt.
        }
      }
    }
  }

  bool _hasSafePngHeader(Uint8List bytes) {
    if (bytes.lengthInBytes > _maximumClipboardBytes ||
        bytes.lengthInBytes < 24) {
      return false;
    }
    const signature = [137, 80, 78, 71, 13, 10, 26, 10];
    for (var index = 0; index < signature.length; index++) {
      if (bytes[index] != signature[index]) return false;
    }
    if (String.fromCharCodes(bytes.sublist(12, 16)) != 'IHDR') return false;
    final data = ByteData.sublistView(bytes);
    final width = data.getUint32(16);
    final height = data.getUint32(20);
    if (width == 0 || height == 0) return false;
    return width <= 12000 &&
        height <= 12000 &&
        width * height <= _maximumClipboardPixels;
  }

  Future<bool> _canDecodeImage(Uint8List bytes) async {
    ui.Codec? codec;
    try {
      codec = await ui.instantiateImageCodec(
        bytes,
        targetWidth: 1,
        targetHeight: 1,
      );
      final frame = await codec.getNextFrame();
      frame.image.dispose();
      return true;
    } catch (_) {
      return false;
    } finally {
      codec?.dispose();
    }
  }

  @override
  Future<String?> recropAndSave(
    ProfilePhotoUserKey userKey,
    String currentPath,
  ) async {
    try {
      if (!await File(currentPath).exists()) return null;
      return _cropAndSave(userKey, currentPath);
    } on ProfilePhotoFailure {
      rethrow;
    } on UnsupportedError {
      throw _unsupportedFormatFailure;
    } on FormatException {
      throw _unsupportedFormatFailure;
    } catch (_) {
      throw const ProfilePhotoFailure(
        'Fotoğraf düzenlenemedi. Lütfen farklı bir fotoğraf deneyin.',
      );
    }
  }

  @override
  Future<String?> recoverLostAndSave(ProfilePhotoUserKey userKey) async {
    try {
      final recoveredPath = await _picker.retrieveLostPhoto();
      if (recoveredPath == null) return null;
      return _cropAndSave(userKey, recoveredPath);
    } on ProfilePhotoFailure {
      rethrow;
    } catch (_) {
      throw const ProfilePhotoFailure(
        'Yarım kalan fotoğraf işlemi kurtarılamadı. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<String?> _cropAndSave(
    ProfilePhotoUserKey userKey,
    String sourcePath,
  ) async {
    final croppedPath = await _cropper.crop(sourcePath);
    if (croppedPath == null) return null;
    try {
      profilePhotoDebugLog('save called for ${userKey.debugLabel}');
      if (_remoteDataSource != null) {
        profilePhotoDebugLog('upload started');
        String url;
        try {
          url = await _remoteDataSource.upload(croppedPath);
        } on ProfilePhotoFailure {
          rethrow;
        } catch (_) {
          throw const ProfilePhotoFailure(
            'Profil fotoğrafı yüklenemedi. Önceki fotoğrafınız korundu.',
          );
        }
        profilePhotoDebugLog('upload completed: urlPresent=${url.isNotEmpty}');
      }
      return await _store.save(userKey, croppedPath);
    } finally {
      if (croppedPath != sourcePath) {
        try {
          final croppedFile = File(croppedPath);
          if (await croppedFile.exists()) await croppedFile.delete();
        } catch (_) {
          // Cropper output is temporary; a later platform cleanup may remove it.
        }
      }
    }
  }

  @override
  Future<void> remove(ProfilePhotoUserKey userKey) async {
    try {
      profilePhotoDebugLog('remove called for ${userKey.debugLabel}');
      await _remoteDataSource?.remove();
      await _store.remove(userKey);
    } catch (_) {
      throw const ProfilePhotoFailure(
        'Profil fotoğrafı kaldırılamadı. Lütfen tekrar deneyin.',
      );
    }
  }

  @override
  Future<bool> uploadExisting(String localPath) async {
    final remote = _remoteDataSource;
    if (remote == null || !await File(localPath).exists()) return false;
    profilePhotoDebugLog('legacy upload started');
    final url = await remote.upload(localPath);
    profilePhotoDebugLog(
      'legacy upload completed: urlPresent=${url.isNotEmpty}',
    );
    return url.isNotEmpty;
  }

  ProfilePhotoFailure _mapPlatformFailure(
    PlatformException error, {
    required ProfilePhotoSource source,
  }) {
    if (source == ProfilePhotoSource.camera) return _cameraUnavailableFailure;
    if (error.code.contains('photo_access_denied')) {
      return const ProfilePhotoFailure(
        'Fotoğraf arşivine erişim izni verilmedi. Ayarlardan izin verebilirsiniz.',
      );
    }
    return const ProfilePhotoFailure(
      'Fotoğraf seçilemedi. Lütfen tekrar deneyin.',
    );
  }
}

const _cameraUnavailableFailure = ProfilePhotoFailure(
  'Kamera bu cihazda veya simülatörde kullanılamıyor. Galeriden fotoğraf seçebilirsiniz.',
);
const _unsupportedFormatFailure = ProfilePhotoFailure(
  'Bu fotoğraf formatı desteklenmiyor veya dönüştürülemiyor. JPG, JPEG ya da PNG deneyin.',
);
const _emptyClipboardFailure = ProfilePhotoFailure(
  'Panoda kullanılabilir bir görsel bulunamadı.',
);
const _unsupportedClipboardFailure = ProfilePhotoFailure(
  'Panodaki veri desteklenen bir görsel değil veya görsel çok büyük.',
);

class SystemProfilePhotoClipboard implements ProfilePhotoClipboard {
  @override
  Future<Uint8List?> readImage() => FlutterClipboard.pasteImage();
}

class FileProfilePhotoTemporaryStore implements ProfilePhotoTemporaryFileStore {
  static const _fileName = 'profile_photo_clipboard.png';

  @override
  Future<String> writeClipboardImage(Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$_fileName');
    if (await file.exists()) await file.delete();
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<void> delete(String path) async {
    final directory = await getTemporaryDirectory();
    final expectedPath = '${directory.path}/$_fileName';
    if (path != expectedPath) return;
    final file = File(path);
    if (await file.exists()) await file.delete();
  }
}

class ImagePickerProfilePhotoPicker implements ProfilePhotoPicker {
  ImagePickerProfilePhotoPicker(this._picker);

  final ImagePicker _picker;

  @override
  Future<String?> pick(ProfilePhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == ProfilePhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: 2048,
      maxHeight: 2048,
      imageQuality: 92,
      requestFullMetadata: false,
    );
    return file?.path;
  }

  @override
  Future<String?> retrieveLostPhoto() async {
    final response = await _picker.retrieveLostData();
    if (response.isEmpty) return null;
    if (response.exception != null) {
      throw ProfilePhotoFailure(
        response.exception!.message ??
            'Yarım kalan fotoğraf işlemi kurtarılamadı.',
      );
    }
    final files = response.files;
    return files == null || files.isEmpty ? null : files.first.path;
  }
}

class ImageCropperProfilePhotoCropper implements ProfilePhotoCropper {
  ImageCropperProfilePhotoCropper(this._cropper);

  final ImageCropper _cropper;

  @override
  Future<String?> crop(String sourcePath) async {
    final result = await _cropper.cropImage(
      sourcePath: sourcePath,
      maxWidth: 1024,
      maxHeight: 1024,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 85,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Fotoğrafı Kırp',
          toolbarColor: const Color(0xFF006B67),
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: const Color(0xFF006B67),
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: 'Fotoğrafı Kırp',
          doneButtonTitle: 'Bitti',
          cancelButtonTitle: 'İptal',
          aspectRatioLockEnabled: true,
          resetAspectRatioEnabled: false,
        ),
      ],
    );
    return result?.path;
  }
}

class FileProfilePhotoStore implements ProfilePhotoStore {
  FileProfilePhotoStore({
    ProfilePhotoPreferences? preferences,
    Future<Directory> Function()? supportDirectoryProvider,
  }) : _preferences = preferences ?? SharedPreferencesProfilePhotoPreferences(),
       _supportDirectoryProvider =
           supportDirectoryProvider ?? getApplicationSupportDirectory;

  static const _pathKeyPrefix = 'profile_photo_path_';
  static const _directoryName = 'profile_photos';
  static const _fileName = 'profile.jpg';

  final ProfilePhotoPreferences _preferences;
  final Future<Directory> Function() _supportDirectoryProvider;

  String _pathKey(ProfilePhotoUserKey userKey) =>
      '$_pathKeyPrefix${userKey.value}';

  Future<Directory> _userDirectory(ProfilePhotoUserKey userKey) async {
    final root = await _supportDirectoryProvider();
    return Directory('${root.path}/$_directoryName/${userKey.value}');
  }

  @override
  Future<String?> load(ProfilePhotoUserKey userKey) async {
    final key = _pathKey(userKey);
    final storedPath = await _preferences.getString(key);
    profilePhotoDebugLog(
      'stored path found for ${userKey.debugLabel}: ${storedPath != null}',
    );
    final fileExists = storedPath != null && await File(storedPath).exists();
    profilePhotoDebugLog(
      'stored file exists for ${userKey.debugLabel}: $fileExists',
    );
    if (!fileExists) {
      if (storedPath != null) await _preferences.remove(key);
      return null;
    }
    return storedPath;
  }

  @override
  Future<String> save(ProfilePhotoUserKey userKey, String sourcePath) async {
    final directory = await _userDirectory(userKey);
    await directory.create(recursive: true);
    final destination = File('${directory.path}/$_fileName');
    final temporary = File('${directory.path}/$_fileName.tmp');
    final backup = File('${directory.path}/$_fileName.bak');
    if (await temporary.exists()) await temporary.delete();
    if (await backup.exists()) await backup.delete();
    await File(sourcePath).copy(temporary.path);
    if (await destination.exists()) await destination.rename(backup.path);
    try {
      await temporary.rename(destination.path);
      if (await backup.exists()) await backup.delete();
    } catch (_) {
      if (await backup.exists() && !await destination.exists()) {
        await backup.rename(destination.path);
      }
      rethrow;
    }
    await _preferences.setString(_pathKey(userKey), destination.path);
    profilePhotoDebugLog(
      'save completed for ${userKey.debugLabel}; file exists: ${await destination.exists()}',
    );
    return destination.path;
  }

  @override
  Future<void> remove(ProfilePhotoUserKey userKey) async {
    final key = _pathKey(userKey);
    final storedPath = await _preferences.getString(key);
    if (storedPath != null) {
      final file = File(storedPath);
      if (await file.exists()) await file.delete();
    }
    await _preferences.remove(key);
  }
}

class SharedPreferencesProfilePhotoPreferences
    implements ProfilePhotoPreferences {
  SharedPreferencesAsync get _preferences => SharedPreferencesAsync();

  @override
  Future<String?> getString(String key) => _preferences.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> remove(String key) => _preferences.remove(key);
}
