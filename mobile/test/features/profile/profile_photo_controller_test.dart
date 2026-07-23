import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/features/profile/data/services/profile_photo_service.dart';
import 'package:turota_mobile/features/profile/domain/services/profile_photo_user_key_resolver.dart';
import 'package:turota_mobile/features/profile/presentation/controllers/profile_photo_controller.dart';

void main() {
  test(
    'aynı kullanıcı için controller yeniden oluşunca fotoğraf yüklenir',
    () async {
      final service = _FakeService(paths: {'user-a': 'a.jpg'});
      final session = _UserSession(_user('user-a'));
      var container = _container(service, session);

      _watch(container);
      await _settle();
      expect(container.read(profilePhotoControllerProvider).photoPath, 'a.jpg');
      container.dispose();

      container = _container(service, session);
      addTearDown(container.dispose);
      _watch(container);
      await _settle();

      expect(container.read(profilePhotoControllerProvider).photoPath, 'a.jpg');
    },
  );

  test('logout runtime state temizler fakat kalıcı kaydı korur', () async {
    final service = _FakeService(paths: {'user-a': 'a.jpg'});
    final session = _UserSession(_user('user-a'));
    final container = _container(service, session);
    addTearDown(container.dispose);
    _watch(container);
    await _settle();

    session.user = null;
    container.invalidate(currentUserProvider);
    await _settle();

    expect(container.read(profilePhotoControllerProvider).hasPhoto, isFalse);
    expect(service.paths['user-a'], 'a.jpg');
    expect(service.removedUsers, isEmpty);
  });

  test('aynı kullanıcı tekrar login olduğunda fotoğraf geri gelir', () async {
    final service = _FakeService(paths: {'user-a': 'a.jpg'});
    final session = _UserSession(_user('user-a'));
    final container = _container(service, session);
    addTearDown(container.dispose);
    _watch(container);
    await _settle();

    session.user = null;
    container.invalidate(currentUserProvider);
    await _settle();
    session.user = _user('user-a');
    container.invalidate(currentUserProvider);
    await _settle();

    expect(container.read(profilePhotoControllerProvider).photoPath, 'a.jpg');
  });

  test('farklı kullanıcı eski kullanıcının fotoğrafını görmez', () async {
    final service = _FakeService(paths: {'user-a': 'a.jpg'});
    final session = _UserSession(_user('user-a'));
    final container = _container(service, session);
    addTearDown(container.dispose);
    _watch(container);
    await _settle();

    session.user = _user('user-b');
    container.invalidate(currentUserProvider);
    await _settle();

    expect(container.read(profilePhotoControllerProvider).hasPhoto, isFalse);
  });

  test('iki kullanıcının fotoğrafı ayrı tutulur', () async {
    final service = _FakeService(paths: {'user-a': 'a.jpg', 'user-b': 'b.jpg'});
    final session = _UserSession(_user('user-a'));
    final container = _container(service, session);
    addTearDown(container.dispose);
    _watch(container);
    await _settle();
    expect(container.read(profilePhotoControllerProvider).photoPath, 'a.jpg');

    session.user = _user('user-b');
    container.invalidate(currentUserProvider);
    await _settle();
    expect(container.read(profilePhotoControllerProvider).photoPath, 'b.jpg');

    session.user = _user('user-a');
    container.invalidate(currentUserProvider);
    await _settle();
    expect(container.read(profilePhotoControllerProvider).photoPath, 'a.jpg');
  });

  test('fotoğraf kaldırıldıktan sonra yeniden yüklenmez', () async {
    final service = _FakeService(paths: {'user-a': 'a.jpg'});
    final session = _UserSession(_user('user-a'));
    final container = _container(service, session);
    addTearDown(container.dispose);
    _watch(container);
    await _settle();

    final result = await container
        .read(profilePhotoControllerProvider.notifier)
        .remove();
    container.invalidate(profilePhotoControllerProvider);
    await _settle();

    expect(result.status, ProfilePhotoActionStatus.removed);
    expect(container.read(profilePhotoControllerProvider).hasPhoto, isFalse);
    expect(service.removedUsers, ['user-a']);
  });

  test('picker iptali mevcut fotoğrafı korur', () async {
    final service = _FakeService(paths: {'user-a': 'a.jpg'});
    final container = _container(service, _UserSession(_user('user-a')));
    addTearDown(container.dispose);
    _watch(container);
    await _settle();

    final result = await container
        .read(profilePhotoControllerProvider.notifier)
        .select(ProfilePhotoSource.gallery);

    expect(result.status, ProfilePhotoActionStatus.cancelled);
    expect(container.read(profilePhotoControllerProvider).photoPath, 'a.jpg');
  });

  test('eski async yükleme yeni kullanıcı stateini ezmez', () async {
    final delayedA = Completer<String?>();
    final service = _FakeService(
      paths: {'user-b': 'b.jpg'},
      delayedLoads: {'user-a': delayedA},
    );
    final session = _UserSession(_user('user-a'));
    final container = _container(service, session);
    addTearDown(container.dispose);
    _watch(container);
    await _settle();

    session.user = _user('user-b');
    container.invalidate(currentUserProvider);
    await _settle();
    expect(container.read(profilePhotoControllerProvider).photoPath, 'b.jpg');

    delayedA.complete('a.jpg');
    await _settle();
    expect(container.read(profilePhotoControllerProvider).photoPath, 'b.jpg');
  });

  test('kimlik boşsa normalize edilmiş email son çare olarak kullanılır', () {
    expect(
      const ProfilePhotoUserKeyResolver()
          .resolve(_user('', email: '  EDA@Example.COM '))
          ?.value,
      'eda%40example.com',
    );
  });

  test('backend kullanıcı kimliği trim ve lowercase ile sabitlenir', () {
    expect(
      const ProfilePhotoUserKeyResolver().resolve(_user('  USER-A  '))?.value,
      'user-a',
    );
  });
}

ProviderContainer _container(
  ProfilePhotoService service,
  _UserSession session,
) {
  return ProviderContainer(
    overrides: [
      profilePhotoServiceProvider.overrideWithValue(service),
      currentUserProvider.overrideWith((ref) async {
        final user = session.user;
        if (user == null) throw StateError('signed out');
        return user;
      }),
    ],
  );
}

Future<void> _settle() async {
  await Future<void>.delayed(const Duration(milliseconds: 20));
}

void _watch(ProviderContainer container) {
  container.listen(
    profilePhotoControllerProvider,
    (_, _) {},
    fireImmediately: true,
  );
}

AuthUser _user(String id, {String email = 'eda@example.com'}) => AuthUser(
  id: id,
  email: email,
  firstName: 'Eda',
  lastName: 'Teklik',
  role: 'User',
);

class _UserSession {
  _UserSession(this.user);

  AuthUser? user;
}

class _FakeService implements ProfilePhotoService {
  _FakeService({
    Map<String, String?>? paths,
    Map<String, Completer<String?>>? delayedLoads,
  }) : paths = paths ?? {},
       delayedLoads = delayedLoads ?? {};

  final Map<String, String?> paths;
  final Map<String, Completer<String?>> delayedLoads;
  final List<String> removedUsers = [];

  @override
  Future<String?> load(ProfilePhotoUserKey userKey) =>
      delayedLoads[userKey.value]?.future ?? Future.value(paths[userKey.value]);

  @override
  Future<String?> pasteAndSave(ProfilePhotoUserKey userKey) async => null;

  @override
  Future<String?> recoverLostAndSave(ProfilePhotoUserKey userKey) async => null;

  @override
  Future<void> remove(ProfilePhotoUserKey userKey) async {
    removedUsers.add(userKey.value);
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
  ) async => null;
}
