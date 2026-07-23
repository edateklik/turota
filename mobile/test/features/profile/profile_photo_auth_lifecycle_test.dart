import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';
import 'package:turota_mobile/features/authentication/domain/repositories/auth_repository.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/data/dto/taste_profile_dto.dart';
import 'package:turota_mobile/features/onboarding/taste_profile/data/dto/update_taste_profile_request_dto.dart';
import 'package:turota_mobile/features/profile/data/services/profile_photo_service.dart';
import 'package:turota_mobile/features/profile/domain/services/profile_photo_user_key_resolver.dart';
import 'package:turota_mobile/features/profile/presentation/controllers/profile_photo_controller.dart';

void main() {
  test(
    'save dispose logout ve aynı login gerçek dosyadan restore eder',
    () async {
      final supportDirectory = await Directory.systemTemp.createTemp(
        'turota-auth-profile-support-',
      );
      final cropDirectory = await Directory.systemTemp.createTemp(
        'turota-auth-profile-crop-',
      );
      addTearDown(() => supportDirectory.delete(recursive: true));
      addTearDown(() => cropDirectory.delete(recursive: true));
      final source = File('${cropDirectory.path}/picker-source.jpg');
      final cropped = File('${cropDirectory.path}/cropper-output.jpg');
      await source.writeAsBytes([1, 2, 3]);
      await cropped.writeAsBytes([4, 5, 6]);
      final preferences = _MemoryPreferences();
      ProfilePhotoService createService() => LocalProfilePhotoService(
        picker: _Picker(source.path),
        cropper: _Cropper(cropped.path),
        store: FileProfilePhotoStore(
          preferences: preferences,
          supportDirectoryProvider: () async => supportDirectory,
        ),
        clipboard: _Clipboard(),
        temporaryFileStore: _TemporaryStore(),
      );
      final repository = _FakeAuthRepository();
      var container = _container(repository, createService());
      _watch(container);
      final loginUser = await repository.login(
        email: 'a@example.com',
        password: 'password',
      );
      container.read(authSessionUserProvider.notifier).authenticated(loginUser);
      await _settle();

      final saveResult = await container
          .read(profilePhotoControllerProvider.notifier)
          .select(ProfilePhotoSource.gallery);
      final savedPath = container
          .read(profilePhotoControllerProvider)
          .photoPath;
      expect(saveResult.status, ProfilePhotoActionStatus.updated);
      expect(savedPath, isNotNull);
      expect(await File(savedPath!).exists(), isTrue);
      expect(await cropped.exists(), isFalse);

      await container
          .read(profilePhotoControllerProvider.notifier)
          .prepareForLogout();
      await repository.logout();
      container.read(authSessionUserProvider.notifier).signedOut();
      await _settle();
      expect(await File(savedPath).exists(), isTrue);
      expect(preferences.values, contains('profile_photo_path_user-a'));
      container.dispose();

      container = _container(repository, createService());
      addTearDown(container.dispose);
      _watch(container);
      final secondLogin = await repository.login(
        email: 'a@example.com',
        password: 'password',
      );
      container
          .read(authSessionUserProvider.notifier)
          .authenticated(secondLogin);
      await _settle();

      expect(
        container.read(profilePhotoControllerProvider).photoPath,
        savedPath,
      );
    },
  );

  test(
    'null kullanıcıdan login olan userA fotoğrafı otomatik restore eder',
    () async {
      final repository = _FakeAuthRepository(failCurrentUser: true);
      final service = _PersistentFakePhotoService({'user-a': 'a.jpg'});
      final container = _container(repository, service);
      addTearDown(container.dispose);
      _watch(container);
      await _settle();
      expect(container.read(profilePhotoControllerProvider).hasPhoto, isFalse);

      final loginUser = await repository.login(
        email: 'a@example.com',
        password: 'password',
      );
      container.read(authSessionUserProvider.notifier).authenticated(loginUser);
      await _settle();

      expect(container.read(profilePhotoControllerProvider).photoPath, 'a.jpg');
      expect(repository.getCurrentUserCalls, 0);
    },
  );

  test(
    'userA logout ve aynı hesap login sonrası fotoğraf geri gelir',
    () async {
      final repository = _FakeAuthRepository();
      final service = _PersistentFakePhotoService({'user-a': 'a.jpg'});
      final container = _container(repository, service);
      addTearDown(container.dispose);
      _watch(container);
      container
          .read(authSessionUserProvider.notifier)
          .authenticated(_user('user-a'));
      await _settle();

      await repository.logout();
      container.read(authSessionUserProvider.notifier).signedOut();
      await _settle();
      expect(container.read(profilePhotoControllerProvider).hasPhoto, isFalse);
      expect(service.paths['user-a'], 'a.jpg');

      final loginUser = await repository.login(
        email: 'a@example.com',
        password: 'password',
      );
      container.read(authSessionUserProvider.notifier).authenticated(loginUser);
      await _settle();

      expect(container.read(profilePhotoControllerProvider).photoPath, 'a.jpg');
      expect(service.removedKeys, isEmpty);
    },
  );

  test('userA logout ve userB login userA fotoğrafını göstermez', () async {
    final repository = _FakeAuthRepository();
    final service = _PersistentFakePhotoService({'user-a': 'a.jpg'});
    final container = _container(repository, service);
    addTearDown(container.dispose);
    _watch(container);
    container
        .read(authSessionUserProvider.notifier)
        .authenticated(_user('user-a'));
    await _settle();

    await repository.logout();
    container.read(authSessionUserProvider.notifier).signedOut();
    repository.nextLoginUser = _user('user-b');
    final userB = await repository.login(
      email: 'b@example.com',
      password: 'password',
    );
    container.read(authSessionUserProvider.notifier).authenticated(userB);
    await _settle();

    expect(container.read(profilePhotoControllerProvider).hasPhoto, isFalse);
    expect(service.paths['user-a'], 'a.jpg');
  });

  test(
    'uygulama restart yeni auth ve controller örneğiyle restore eder',
    () async {
      final repository = _FakeAuthRepository(
        storedToken: 'token',
        currentUser: _user('user-a'),
      );
      final service = _PersistentFakePhotoService({'user-a': 'a.jpg'});
      var container = _container(repository, service);
      _watch(container);
      await _settle();
      expect(container.read(profilePhotoControllerProvider).photoPath, 'a.jpg');
      container.dispose();

      container = _container(repository, service);
      addTearDown(container.dispose);
      _watch(container);
      await _settle();

      expect(container.read(profilePhotoControllerProvider).photoPath, 'a.jpg');
    },
  );
}

ProviderContainer _container(
  AuthRepository repository,
  ProfilePhotoService service,
) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      profilePhotoServiceProvider.overrideWithValue(service),
    ],
  );
}

void _watch(ProviderContainer container) {
  container.listen(
    profilePhotoControllerProvider,
    (_, _) {},
    fireImmediately: true,
  );
}

Future<void> _settle() =>
    Future<void>.delayed(const Duration(milliseconds: 30));

AuthUser _user(String id) => AuthUser(
  id: id,
  email: '$id@example.com',
  firstName: 'Eda',
  lastName: 'Teklik',
  role: 'User',
);

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({
    this.storedToken,
    AuthUser? currentUser,
    this.failCurrentUser = false,
  }) : currentUser = currentUser ?? _user('user-a'),
       nextLoginUser = currentUser ?? _user('user-a');

  String? storedToken;
  AuthUser currentUser;
  AuthUser nextLoginUser;
  final bool failCurrentUser;
  int getCurrentUserCalls = 0;

  @override
  Future<String?> getStoredToken() async => storedToken;

  @override
  Future<AuthUser> getCurrentUser() async {
    getCurrentUserCalls++;
    if (failCurrentUser) throw StateError('getCurrentUser failed');
    return currentUser;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    storedToken = 'token';
    currentUser = nextLoginUser;
    return nextLoginUser;
  }

  @override
  Future<void> logout() async => storedToken = null;

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) => throw UnimplementedError();

  @override
  Future<TasteProfileDto> getTasteProfile() => throw UnimplementedError();

  @override
  Future<TasteProfileDto> updateTasteProfile(
    UpdateTasteProfileRequestDto request,
  ) => throw UnimplementedError();
}

class _PersistentFakePhotoService implements ProfilePhotoService {
  _PersistentFakePhotoService(this.paths);

  final Map<String, String?> paths;
  final List<String> removedKeys = [];

  @override
  Future<String?> load(ProfilePhotoUserKey userKey) async =>
      paths[userKey.value];

  @override
  Future<String?> pasteAndSave(ProfilePhotoUserKey userKey) async => null;

  @override
  Future<String?> recoverLostAndSave(ProfilePhotoUserKey userKey) async => null;

  @override
  Future<void> remove(ProfilePhotoUserKey userKey) async {
    removedKeys.add(userKey.value);
    paths.remove(userKey.value);
  }

  @override
  Future<String?> recropAndSave(
    ProfilePhotoUserKey userKey,
    String currentPath,
  ) async => paths[userKey.value];

  @override
  Future<String?> selectAndSave(
    ProfilePhotoUserKey userKey,
    ProfilePhotoSource source,
  ) async => paths[userKey.value];
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

class _Picker implements ProfilePhotoPicker {
  const _Picker(this.path);

  final String path;

  @override
  Future<String?> pick(ProfilePhotoSource source) async => path;

  @override
  Future<String?> retrieveLostPhoto() async => null;
}

class _Cropper implements ProfilePhotoCropper {
  const _Cropper(this.path);

  final String path;

  @override
  Future<String?> crop(String sourcePath) async => path;
}

class _Clipboard implements ProfilePhotoClipboard {
  @override
  Future<Uint8List?> readImage() async => null;
}

class _TemporaryStore implements ProfilePhotoTemporaryFileStore {
  @override
  Future<void> delete(String path) async {}

  @override
  Future<String> writeClipboardImage(Uint8List bytes) async => '';
}
