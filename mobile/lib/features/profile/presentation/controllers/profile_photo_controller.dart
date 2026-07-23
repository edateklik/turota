import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';
import 'package:turota_mobile/core/providers/core_providers.dart';
import 'package:turota_mobile/features/profile/data/services/profile_photo_debug_log.dart';
import 'package:turota_mobile/features/profile/data/services/profile_photo_service.dart';
import 'package:turota_mobile/features/profile/domain/services/profile_photo_user_key_resolver.dart';

class ProfilePhotoState {
  const ProfilePhotoState({
    this.photoPath,
    this.profilePhotoUrl,
    this.isProcessing = false,
  });

  final String? photoPath;
  final String? profilePhotoUrl;
  final bool isProcessing;
  bool get hasPhoto => photoPath != null || profilePhotoUrl != null;
}

enum ProfilePhotoActionStatus { updated, removed, cancelled, failed }

class ProfilePhotoActionResult {
  const ProfilePhotoActionResult(this.status, [this.message]);
  final ProfilePhotoActionStatus status;
  final String? message;
}

final profilePhotoServiceProvider = Provider<ProfilePhotoService>((ref) {
  return LocalProfilePhotoService(
    picker: ImagePickerProfilePhotoPicker(ImagePicker()),
    cropper: ImageCropperProfilePhotoCropper(ImageCropper()),
    store: FileProfilePhotoStore(),
    clipboard: SystemProfilePhotoClipboard(),
    temporaryFileStore: FileProfilePhotoTemporaryStore(),
    remoteDataSource: ApiProfilePhotoRemoteDataSource(
      ref.watch(apiClientProvider),
    ),
  );
});

final profilePhotoUserKeyResolverProvider =
    Provider<ProfilePhotoUserKeyResolver>(
      (ref) => const ProfilePhotoUserKeyResolver(),
    );

final profilePhotoControllerProvider =
    NotifierProvider<ProfilePhotoController, ProfilePhotoState>(
      ProfilePhotoController.new,
    );

class ProfilePhotoController extends Notifier<ProfilePhotoState> {
  late ProfilePhotoService _service;
  ProfilePhotoUserKey? _activeUserKey;
  AuthUser? _activeUser;
  int _loadGeneration = 0;

  @override
  ProfilePhotoState build() {
    _service = ref.watch(profilePhotoServiceProvider);
    final resolver = ref.watch(profilePhotoUserKeyResolverProvider);
    final userState = ref.watch(currentUserProvider);
    final userKey = switch (userState) {
      AsyncData(:final value) => resolver.resolve(value),
      _ => null,
    };
    final user = switch (userState) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final previousLabel = _activeUserKey?.debugLabel ?? 'none';
    final nextLabel = userKey?.debugLabel ?? 'none';
    profilePhotoDebugLog(
      'provider create; auth user: ${userKey == null ? 'none' : 'present'}',
    );
    profilePhotoDebugLog('user changed: $previousLabel -> $nextLabel');
    ref.onDispose(
      () => profilePhotoDebugLog('provider disposed for $nextLabel'),
    );
    _activeUserKey = userKey;
    _activeUser = user;
    final generation = ++_loadGeneration;
    if (userKey == null) return const ProfilePhotoState();
    Future<void>.microtask(() => _initialize(userKey, generation));
    return ProfilePhotoState(
      profilePhotoUrl: user?.profilePhotoUrl,
      isProcessing: true,
    );
  }

  Future<void> _initialize(ProfilePhotoUserKey userKey, int generation) async {
    try {
      profilePhotoDebugLog('restore started for ${userKey.debugLabel}');
      final storedPath = await _service.load(userKey);
      final recoveredPath = await _service.recoverLostAndSave(userKey);
      if (!_isCurrent(userKey, generation)) {
        profilePhotoDebugLog('restore ignored for stale ${userKey.debugLabel}');
        return;
      }
      final user = _activeUser;
      state = ProfilePhotoState(
        photoPath: recoveredPath ?? storedPath,
        profilePhotoUrl: user?.profilePhotoUrl,
      );
      if (recoveredPath != null) await _refreshCurrentUser();
      profilePhotoDebugLog(
        'login restore: avatarUrlPresent=${user?.profilePhotoUrl != null}',
      );
      if (user != null &&
          user.profilePhotoUrl == null &&
          recoveredPath == null &&
          state.photoPath != null) {
        final migration = _service is LegacyProfilePhotoMigration
            ? _service as LegacyProfilePhotoMigration
            : null;
        if (migration == null) return;
        try {
          if (await migration.uploadExisting(state.photoPath!) &&
              _isCurrent(userKey, generation)) {
            await _refreshCurrentUser();
          }
        } catch (_) {
          profilePhotoDebugLog('legacy upload failed safely');
        }
      }
      profilePhotoDebugLog(
        'restore completed for ${userKey.debugLabel}; photo: ${state.hasPhoto}',
      );
    } catch (_) {
      if (!_isCurrent(userKey, generation)) return;
      state = const ProfilePhotoState();
      profilePhotoDebugLog('restore failed safely for ${userKey.debugLabel}');
    }
  }

  Future<void> _refreshCurrentUser() async {
    try {
      final user = await ref.read(authRepositoryProvider).getCurrentUser();
      if (!ref.mounted) return;
      ref.read(authSessionUserProvider.notifier).authenticated(user);
      profilePhotoDebugLog(
        'current user loaded: avatarUrlPresent=${user.profilePhotoUrl != null}',
      );
    } catch (_) {
      profilePhotoDebugLog('current user refresh failed safely');
    }
  }

  bool _isCurrent(ProfilePhotoUserKey userKey, [int? generation]) =>
      ref.mounted &&
      _activeUserKey?.value == userKey.value &&
      (generation == null || generation == _loadGeneration);

  ProfilePhotoActionResult? _missingUserResult() {
    if (_activeUserKey != null) return null;
    return const ProfilePhotoActionResult(
      ProfilePhotoActionStatus.failed,
      'Kullanıcı bilgisi hazır olmadığı için fotoğraf işlemi yapılamadı.',
    );
  }

  Future<void> prepareForLogout() async {
    final userKey = _activeUserKey;
    state = const ProfilePhotoState();
    if (userKey == null) {
      profilePhotoDebugLog('logout runtime clear; active user: none');
      return;
    }
    final persistedPath = await _service.load(userKey);
    profilePhotoDebugLog(
      'logout runtime clear for ${userKey.debugLabel}; persistent file exists: ${persistedPath != null}',
    );
    profilePhotoDebugLog('logout: persistent backend photo untouched');
  }

  Future<ProfilePhotoActionResult> select(ProfilePhotoSource source) async {
    final missingUser = _missingUserResult();
    if (missingUser != null) return missingUser;
    if (state.isProcessing) {
      return const ProfilePhotoActionResult(ProfilePhotoActionStatus.cancelled);
    }
    final userKey = _activeUserKey!;
    final currentPath = state.photoPath;
    final currentUrl = state.profilePhotoUrl;
    state = ProfilePhotoState(
      photoPath: currentPath,
      profilePhotoUrl: currentUrl,
      isProcessing: true,
    );
    try {
      final path = await _service.selectAndSave(userKey, source);
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = ProfilePhotoState(
        photoPath: path ?? currentPath,
        profilePhotoUrl: currentUrl,
      );
      if (path != null) await _refreshCurrentUser();
      return ProfilePhotoActionResult(
        path == null
            ? ProfilePhotoActionStatus.cancelled
            : ProfilePhotoActionStatus.updated,
      );
    } on ProfilePhotoFailure catch (error) {
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = ProfilePhotoState(
        photoPath: currentPath,
        profilePhotoUrl: currentUrl,
      );
      return ProfilePhotoActionResult(
        ProfilePhotoActionStatus.failed,
        error.message,
      );
    } catch (_) {
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = ProfilePhotoState(
        photoPath: currentPath,
        profilePhotoUrl: currentUrl,
      );
      return const ProfilePhotoActionResult(
        ProfilePhotoActionStatus.failed,
        'Fotoğraf işlemi tamamlanamadı. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<ProfilePhotoActionResult> recrop() async {
    final missingUser = _missingUserResult();
    if (missingUser != null) return missingUser;
    final currentPath = state.photoPath;
    if (state.isProcessing || currentPath == null) {
      return const ProfilePhotoActionResult(ProfilePhotoActionStatus.cancelled);
    }
    final userKey = _activeUserKey!;
    final currentUrl = state.profilePhotoUrl;
    state = ProfilePhotoState(
      photoPath: currentPath,
      profilePhotoUrl: currentUrl,
      isProcessing: true,
    );
    try {
      final path = await _service.recropAndSave(userKey, currentPath);
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = ProfilePhotoState(
        photoPath: path ?? currentPath,
        profilePhotoUrl: currentUrl,
      );
      if (path != null) await _refreshCurrentUser();
      return ProfilePhotoActionResult(
        path == null
            ? ProfilePhotoActionStatus.cancelled
            : ProfilePhotoActionStatus.updated,
      );
    } on ProfilePhotoFailure catch (error) {
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = ProfilePhotoState(
        photoPath: currentPath,
        profilePhotoUrl: currentUrl,
      );
      return ProfilePhotoActionResult(
        ProfilePhotoActionStatus.failed,
        error.message,
      );
    } catch (_) {
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = ProfilePhotoState(
        photoPath: currentPath,
        profilePhotoUrl: currentUrl,
      );
      return const ProfilePhotoActionResult(
        ProfilePhotoActionStatus.failed,
        'Fotoğraf düzenlenemedi. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<ProfilePhotoActionResult> pasteFromClipboard() async {
    final missingUser = _missingUserResult();
    if (missingUser != null) return missingUser;
    if (state.isProcessing) {
      return const ProfilePhotoActionResult(ProfilePhotoActionStatus.cancelled);
    }
    final userKey = _activeUserKey!;
    final currentPath = state.photoPath;
    final currentUrl = state.profilePhotoUrl;
    state = ProfilePhotoState(
      photoPath: currentPath,
      profilePhotoUrl: currentUrl,
      isProcessing: true,
    );
    try {
      final path = await _service.pasteAndSave(userKey);
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = ProfilePhotoState(
        photoPath: path ?? currentPath,
        profilePhotoUrl: currentUrl,
      );
      if (path != null) await _refreshCurrentUser();
      return ProfilePhotoActionResult(
        path == null
            ? ProfilePhotoActionStatus.cancelled
            : ProfilePhotoActionStatus.updated,
      );
    } on ProfilePhotoFailure catch (error) {
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = ProfilePhotoState(
        photoPath: currentPath,
        profilePhotoUrl: currentUrl,
      );
      return ProfilePhotoActionResult(
        ProfilePhotoActionStatus.failed,
        error.message,
      );
    } catch (_) {
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = ProfilePhotoState(
        photoPath: currentPath,
        profilePhotoUrl: currentUrl,
      );
      return const ProfilePhotoActionResult(
        ProfilePhotoActionStatus.failed,
        'Panodaki görsel okunamadı. Lütfen tekrar deneyin.',
      );
    }
  }

  Future<ProfilePhotoActionResult> remove() async {
    final missingUser = _missingUserResult();
    if (missingUser != null) return missingUser;
    final currentPath = state.photoPath;
    if (state.isProcessing || !state.hasPhoto) {
      return const ProfilePhotoActionResult(ProfilePhotoActionStatus.cancelled);
    }
    final userKey = _activeUserKey!;
    final currentUrl = state.profilePhotoUrl;
    state = ProfilePhotoState(
      photoPath: currentPath,
      profilePhotoUrl: currentUrl,
      isProcessing: true,
    );
    try {
      await _service.remove(userKey);
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = const ProfilePhotoState();
      final user = ref.read(authSessionUserProvider);
      if (user != null) {
        ref
            .read(authSessionUserProvider.notifier)
            .authenticated(user.copyWith(clearProfilePhoto: true));
      }
      return const ProfilePhotoActionResult(ProfilePhotoActionStatus.removed);
    } on ProfilePhotoFailure catch (error) {
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = ProfilePhotoState(
        photoPath: currentPath,
        profilePhotoUrl: currentUrl,
      );
      return ProfilePhotoActionResult(
        ProfilePhotoActionStatus.failed,
        error.message,
      );
    } catch (_) {
      if (!_isCurrent(userKey)) {
        return const ProfilePhotoActionResult(
          ProfilePhotoActionStatus.cancelled,
        );
      }
      state = ProfilePhotoState(
        photoPath: currentPath,
        profilePhotoUrl: currentUrl,
      );
      return const ProfilePhotoActionResult(
        ProfilePhotoActionStatus.failed,
        'Profil fotoğrafı kaldırılamadı. Lütfen tekrar deneyin.',
      );
    }
  }
}
