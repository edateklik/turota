import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/config/api_config.dart';
import 'package:turota_mobile/core/utils/user_avatar_initial.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/features/profile/data/services/profile_photo_debug_log.dart';
import 'package:turota_mobile/features/profile/presentation/controllers/profile_photo_controller.dart';

class CurrentUserAvatar extends ConsumerWidget {
  const CurrentUserAvatar({
    this.radius = 18,
    this.borderWidth = 2,
    this.backgroundColor = AppColors.surfaceLow,
    this.foregroundColor = AppColors.primary,
    this.borderColor = AppColors.primary,
    this.semanticLabel = 'Kullanıcı profili',
    super.key,
  });

  final double radius;
  final double borderWidth;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color borderColor;
  final String semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoState = ref.watch(profilePhotoControllerProvider);
    final photoPath = photoState.photoPath;
    final userState = ref.watch(currentUserProvider);
    final user = switch (userState) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final initial = userAvatarInitial(
      fullName: user == null ? null : '${user.firstName} ${user.lastName}',
      email: user?.email,
    );
    profilePhotoDebugLog(
      'avatar updated; auth user: ${user == null ? 'none' : 'present'}; photo: ${photoPath != null}',
    );
    final backendPhotoUrl = _absolutePhotoUrl(user?.profilePhotoUrl);
    if (backendPhotoUrl != null) {
      profilePhotoDebugLog('avatar source: backend');
    }

    return Semantics(
      image: true,
      label: semanticLabel,
      child: Container(
        padding: EdgeInsets.all(borderWidth),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: borderWidth),
        ),
        child: CircleAvatar(
          radius: radius,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          child: ClipOval(
            child: backendPhotoUrl != null
                ? Image.network(
                    backendPhotoUrl,
                    key: ValueKey('current-user-avatar-$backendPhotoUrl'),
                    width: radius * 2,
                    height: radius * 2,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _LocalAvatarOrFallback(
                      photoPath: photoPath,
                      initial: initial,
                      radius: radius,
                    ),
                  )
                : _LocalAvatarOrFallback(
                    photoPath: photoPath,
                    initial: initial,
                    radius: radius,
                  ),
          ),
        ),
      ),
    );
  }

  String? _absolutePhotoUrl(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = Uri.tryParse(value.trim());
    if (parsed == null) return null;
    if (parsed.hasScheme) return parsed.toString();
    return Uri.parse(ApiConfig.baseUrl).resolveUri(parsed).toString();
  }
}

class _LocalAvatarOrFallback extends StatelessWidget {
  const _LocalAvatarOrFallback({
    required this.photoPath,
    required this.initial,
    required this.radius,
  });

  final String? photoPath;
  final String initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (photoPath == null) {
      return _AvatarFallback(initial: initial, radius: radius);
    }
    return Image.file(
      File(photoPath!),
      key: ValueKey('current-user-avatar-$photoPath'),
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          _AvatarFallback(initial: initial, radius: radius),
    );
  }
}

class _AvatarFallback extends StatelessWidget {
  const _AvatarFallback({required this.initial, required this.radius});

  final String initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (initial.isEmpty) {
      return Icon(Icons.person, size: radius, color: AppColors.outlineVariant);
    }
    return Center(
      child: Text(
        initial,
        style: TextStyle(fontSize: radius * 0.9, fontWeight: FontWeight.w700),
      ),
    );
  }
}
