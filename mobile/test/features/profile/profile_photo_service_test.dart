import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';
import 'package:turota_mobile/features/profile/data/services/profile_photo_service.dart';
import 'package:turota_mobile/features/profile/domain/services/profile_photo_user_key_resolver.dart';

void main() {
  test('picker iptal edilince mevcut kayıt değiştirilmez', () async {
    final store = _FakeStore('existing.jpg');
    final service = LocalProfilePhotoService(
      picker: _FakePicker(),
      cropper: _FakeCropper(),
      store: store,
      clipboard: _FakeClipboard(),
      temporaryFileStore: _FakeTemporaryStore(),
    );

    final result = await service.selectAndSave(
      _key('user-1'),
      ProfilePhotoSource.gallery,
    );

    expect(result, isNull);
    expect(store.savedSourcePath, isNull);
    expect(await service.load(_key('user-1')), 'existing.jpg');
  });

  test('kamera kullanılamadığında anlaşılır hata döndürülür', () async {
    final service = LocalProfilePhotoService(
      picker: _FakePicker(
        error: PlatformException(code: 'no_available_camera'),
      ),
      cropper: _FakeCropper(),
      store: _FakeStore(null),
      clipboard: _FakeClipboard(),
      temporaryFileStore: _FakeTemporaryStore(),
    );

    expect(
      () => service.selectAndSave(_key('user-1'), ProfilePhotoSource.camera),
      throwsA(
        isA<ProfilePhotoFailure>().having(
          (failure) => failure.message,
          'message',
          contains('Kamera bu cihazda veya simülatörde kullanılamıyor'),
        ),
      ),
    );
  });

  test('seçilen fotoğraf kırpılıp kalıcı depoya kaydedilir', () async {
    final store = _FakeStore(null);
    final service = LocalProfilePhotoService(
      picker: _FakePicker(path: 'picked.heic'),
      cropper: _FakeCropper(result: 'cropped.jpg'),
      store: store,
      clipboard: _FakeClipboard(),
      temporaryFileStore: _FakeTemporaryStore(),
    );

    final result = await service.selectAndSave(
      _key('user-1'),
      ProfilePhotoSource.gallery,
    );

    expect(result, 'profile_photo.jpg');
    expect(store.savedSourcePath, 'cropped.jpg');
  });

  test(
    'backend upload tamamlandıktan sonra yerel cache değiştirilir',
    () async {
      final events = <String>[];
      final store = _FakeStore('existing.jpg', events: events);
      final remote = _FakeRemote(events: events);
      final service = LocalProfilePhotoService(
        picker: _FakePicker(path: 'picked.jpg'),
        cropper: _FakeCropper(result: 'cropped.jpg'),
        store: store,
        clipboard: _FakeClipboard(),
        temporaryFileStore: _FakeTemporaryStore(),
        remoteDataSource: remote,
      );

      await service.selectAndSave(_key('user-1'), ProfilePhotoSource.gallery);

      expect(events, ['upload', 'save']);
      expect(remote.uploadedPath, 'cropped.jpg');
    },
  );

  test('backend upload hatasında önceki yerel fotoğraf korunur', () async {
    final store = _FakeStore('existing.jpg');
    final service = LocalProfilePhotoService(
      picker: _FakePicker(path: 'picked.jpg'),
      cropper: _FakeCropper(result: 'cropped.jpg'),
      store: store,
      clipboard: _FakeClipboard(),
      temporaryFileStore: _FakeTemporaryStore(),
      remoteDataSource: _FakeRemote(error: Exception('network')),
    );

    await expectLater(
      service.selectAndSave(_key('user-1'), ProfilePhotoSource.gallery),
      throwsA(isA<ProfilePhotoFailure>()),
    );
    expect(store.savedSourcePath, isNull);
    expect(await store.load(_key('user-1')), 'existing.jpg');
  });

  test('panoda görsel varsa crop ve kalıcı kayıt akışına gider', () async {
    final store = _FakeStore(null);
    final temporaryStore = _FakeTemporaryStore();
    final cropper = _FakeCropper(result: 'clipboard-cropped.jpg');
    final service = LocalProfilePhotoService(
      picker: _FakePicker(),
      cropper: cropper,
      store: store,
      clipboard: _FakeClipboard(bytes: _validPngHeader()),
      temporaryFileStore: temporaryStore,
    );

    final result = await service.pasteAndSave(_key('user-1'));

    expect(result, 'profile_photo.jpg');
    expect(cropper.sourcePath, 'clipboard.png');
    expect(store.savedSourcePath, 'clipboard-cropped.jpg');
    expect(temporaryStore.deletedPath, 'clipboard.png');
  });

  test('panoda görsel yoksa uygun hata döner', () async {
    final service = LocalProfilePhotoService(
      picker: _FakePicker(),
      cropper: _FakeCropper(),
      store: _FakeStore('existing.jpg'),
      clipboard: _FakeClipboard(),
      temporaryFileStore: _FakeTemporaryStore(),
    );

    expect(
      () => service.pasteAndSave(_key('user-1')),
      throwsA(
        isA<ProfilePhotoFailure>().having(
          (failure) => failure.message,
          'message',
          'Panoda kullanılabilir bir görsel bulunamadı.',
        ),
      ),
    );
  });

  test('pano okuma hatası güvenli kullanıcı hatasına çevrilir', () async {
    final service = LocalProfilePhotoService(
      picker: _FakePicker(),
      cropper: _FakeCropper(),
      store: _FakeStore('existing.jpg'),
      clipboard: _FakeClipboard(error: Exception('platform detail')),
      temporaryFileStore: _FakeTemporaryStore(),
    );

    expect(
      () => service.pasteAndSave(_key('user-1')),
      throwsA(
        isA<ProfilePhotoFailure>().having(
          (failure) => failure.message,
          'message',
          isNot(contains('platform detail')),
        ),
      ),
    );
  });

  test('crop iptal edilince pano dosyası kaydedilmez', () async {
    final store = _FakeStore('existing.jpg');
    final service = LocalProfilePhotoService(
      picker: _FakePicker(),
      cropper: _FakeCropper(),
      store: store,
      clipboard: _FakeClipboard(bytes: _validPngHeader()),
      temporaryFileStore: _FakeTemporaryStore(),
    );

    final result = await service.pasteAndSave(_key('user-1'));

    expect(result, isNull);
    expect(store.savedSourcePath, isNull);
    expect(await store.load(_key('user-1')), 'existing.jpg');
  });

  test('kalıcı store iki kullanıcıyı ayrı tutar ve yeniden yükler', () async {
    final supportDirectory = await Directory.systemTemp.createTemp(
      'turota-profile-support-',
    );
    final sourceDirectory = await Directory.systemTemp.createTemp(
      'turota-profile-source-',
    );
    addTearDown(() => supportDirectory.delete(recursive: true));
    addTearDown(() => sourceDirectory.delete(recursive: true));
    final preferences = _MemoryPreferences();
    final firstSource = File('${sourceDirectory.path}/first.jpg');
    final secondSource = File('${sourceDirectory.path}/second.jpg');
    await firstSource.writeAsBytes([1, 2, 3]);
    await secondSource.writeAsBytes([4, 5, 6]);
    var store = FileProfilePhotoStore(
      preferences: preferences,
      supportDirectoryProvider: () async => supportDirectory,
    );

    final firstPath = await store.save(_key('user-a'), firstSource.path);
    final secondPath = await store.save(_key('user-b'), secondSource.path);
    store = FileProfilePhotoStore(
      preferences: preferences,
      supportDirectoryProvider: () async => supportDirectory,
    );

    expect(firstPath, contains('/profile_photos/user-a/profile.jpg'));
    expect(secondPath, contains('/profile_photos/user-b/profile.jpg'));
    expect(await store.load(_key('user-a')), firstPath);
    expect(await store.load(_key('user-b')), secondPath);
    expect(firstPath, isNot(firstSource.path));

    await store.remove(_key('user-a'));
    expect(await store.load(_key('user-a')), isNull);
    expect(await store.load(_key('user-b')), secondPath);
  });

  test(
    'dosyası bulunmayan kullanıcı kaydı güvenli biçimde temizlenir',
    () async {
      final supportDirectory = await Directory.systemTemp.createTemp(
        'turota-profile-broken-',
      );
      addTearDown(() => supportDirectory.delete(recursive: true));
      final preferences = _MemoryPreferences()
        ..values['profile_photo_path_user-a'] = '/missing/profile.jpg';
      final store = FileProfilePhotoStore(
        preferences: preferences,
        supportDirectoryProvider: () async => supportDirectory,
      );

      expect(await store.load(_key('user-a')), isNull);
      expect(preferences.values, isNot(contains('profile_photo_path_user-a')));
    },
  );
}

Uint8List _validPngHeader() {
  return base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+A8AAQUBAScY42YAAAAASUVORK5CYII=',
  );
}

class _FakePicker implements ProfilePhotoPicker {
  _FakePicker({this.path, this.error});

  final String? path;
  final Object? error;

  @override
  Future<String?> pick(ProfilePhotoSource source) async {
    if (error != null) throw error!;
    return path;
  }

  @override
  Future<String?> retrieveLostPhoto() async => null;
}

class _FakeCropper implements ProfilePhotoCropper {
  _FakeCropper({this.result});
  final String? result;
  String? sourcePath;

  @override
  Future<String?> crop(String sourcePath) async {
    this.sourcePath = sourcePath;
    return result;
  }
}

class _FakeClipboard implements ProfilePhotoClipboard {
  _FakeClipboard({this.bytes, this.error});

  final Uint8List? bytes;
  final Object? error;

  @override
  Future<Uint8List?> readImage() async {
    if (error != null) throw error!;
    return bytes;
  }
}

class _FakeTemporaryStore implements ProfilePhotoTemporaryFileStore {
  String? deletedPath;

  @override
  Future<void> delete(String path) async => deletedPath = path;

  @override
  Future<String> writeClipboardImage(Uint8List bytes) async => 'clipboard.png';
}

class _FakeStore implements ProfilePhotoStore {
  _FakeStore(this.path, {this.events});

  String? path;
  String? savedSourcePath;
  final List<String>? events;

  @override
  Future<String?> load(ProfilePhotoUserKey userKey) async => path;

  @override
  Future<void> remove(ProfilePhotoUserKey userKey) async => path = null;

  @override
  Future<String> save(ProfilePhotoUserKey userKey, String sourcePath) async {
    events?.add('save');
    savedSourcePath = sourcePath;
    return path = 'profile_photo.jpg';
  }
}

class _FakeRemote implements ProfilePhotoRemoteDataSource {
  _FakeRemote({this.events, this.error});

  final List<String>? events;
  final Object? error;
  String? uploadedPath;

  @override
  Future<void> remove() async {
    if (error != null) throw error!;
  }

  @override
  Future<String> upload(String filePath) async {
    events?.add('upload');
    uploadedPath = filePath;
    if (error != null) throw error!;
    return '/uploads/profile-photos/photo.jpg';
  }
}

ProfilePhotoUserKey _key(String id) {
  return const ProfilePhotoUserKeyResolver().resolve(
    AuthUser(
      id: id,
      email: '$id@example.com',
      firstName: 'Test',
      lastName: 'User',
      role: 'User',
    ),
  )!;
}

class _MemoryPreferences implements ProfilePhotoPreferences {
  final Map<String, String> values = {};

  @override
  Future<String?> getString(String key) async => values[key];

  @override
  Future<void> remove(String key) async => values.remove(key);

  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }
}
