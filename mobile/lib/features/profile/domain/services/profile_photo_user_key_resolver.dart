import 'package:turota_mobile/features/authentication/domain/models/auth_user.dart';

class ProfilePhotoUserKey {
  const ProfilePhotoUserKey._(this.value, this.debugLabel);

  final String value;
  final String debugLabel;
}

class ProfilePhotoUserKeyResolver {
  const ProfilePhotoUserKeyResolver();

  ProfilePhotoUserKey? resolve(AuthUser? user) {
    if (user == null) return null;
    final immutableId = _normalize(user.id);
    final identity = immutableId.isNotEmpty
        ? immutableId
        : _normalize(user.email);
    if (identity.isEmpty) return null;
    final safeValue = Uri.encodeComponent(identity);
    return ProfilePhotoUserKey._(safeValue, 'user#${_shortHash(identity)}');
  }

  String _normalize(String value) => value.trim().toLowerCase();

  String _shortHash(String value) {
    var hash = 0x811c9dc5;
    for (final byte in value.codeUnits) {
      hash ^= byte;
      hash = (hash * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0').substring(0, 4).toUpperCase();
  }
}
