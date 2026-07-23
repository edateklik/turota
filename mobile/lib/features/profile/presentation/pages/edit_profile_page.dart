import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/widgets/current_user_avatar.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/features/profile/data/services/profile_photo_service.dart';
import 'package:turota_mobile/features/profile/presentation/controllers/profile_photo_controller.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

enum _PhotoAction { gallery, camera, clipboard, edit, remove, cancel }

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _cityController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Initially empty, will be populated in build or listener if needed
    _fullNameController = TextEditingController();
    _usernameController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    // TODO: Integrate with backend API when available.
    await Future<void>.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() => _isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil başarıyla güncellendi!'),
        backgroundColor: AppColors.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Populate data once when loaded
    final userState = ref.watch(currentUserProvider);
    if (userState.value != null && _fullNameController.text.isEmpty) {
      _fullNameController.text =
          '${userState.value!.firstName} ${userState.value!.lastName}';
      _usernameController.text =
          userState.value!.email; // using email as username fallback
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Profili Düzenle',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.screen),
            child: const CurrentUserAvatar(radius: 16),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screen,
            vertical: AppSpacing.xl,
          ),
          child: Column(
            children: [
              // ─── Profile Photo Section ──────────────────────────
              _buildProfilePhoto(),
              const SizedBox(height: 48),

              // ─── Form Section ───────────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Full Name
                    _buildLabel('Ad Soyad'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _fullNameController,
                      placeholder: 'Adınızı ve soyadınızı girin',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Username
                    _buildLabel('Kullanıcı Adı'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _usernameController,
                      placeholder: 'kullanıcıadı',
                      prefixText: '@',
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Email (read-only)
                    _buildLabel('E-posta Adresi'),
                    const SizedBox(height: 8),
                    _buildReadOnlyEmail(userState.value?.email ?? ''),
                    const SizedBox(height: 6),
                    const Padding(
                      padding: EdgeInsets.only(left: 4),
                      child: Text(
                        'E-posta güvenliğiniz için değiştirilemez.',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.03 * 12,
                          color: AppColors.outline,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    // Home City
                    _buildLabel('Yaşadığınız Şehir'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _cityController,
                      placeholder: 'Şehir, Ülke',
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 40),

                    // ─── Taste Profile Edit ───────────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLow,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer.withValues(
                                    alpha: 0.5,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tat Profili',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Yapay zeka önerilerini iyileştir.',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(
                                  context,
                                ).pushNamed('/profile/edit-taste');
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(
                                  color: AppColors.primary,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.md,
                                  ),
                                ),
                                textStyle: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Text('Tat Profilimi Düzenle'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 48),

                    // ─── Action Buttons ───────────────────────────
                    _buildSaveButton(),
                    const SizedBox(height: AppSpacing.md),
                    _buildCancelButton(),
                  ],
                ),
              ),

              // Extra space for bottom nav
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Profile Photo ──────────────────────────────────────────────────────────

  Widget _buildProfilePhoto() {
    final photoState = ref.watch(profilePhotoControllerProvider);
    return Center(
      child: Stack(
        children: [
          Semantics(
            button: true,
            label: photoState.hasPhoto
                ? 'Profil fotoğrafını değiştir'
                : 'Profil fotoğrafı ekle',
            child: GestureDetector(
              onTap: photoState.isProcessing ? null : _showPhotoActions,
              child: Container(
                width: 128,
                height: 128,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surfaceLow,
                  border: Border.all(color: AppColors.surface, width: 4),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 20,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(child: _buildPhotoContent(photoState)),
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: Semantics(
              button: true,
              label: 'Profil fotoğrafı seçenekleri',
              child: GestureDetector(
                onTap: photoState.isProcessing ? null : _showPhotoActions,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: photoState.isProcessing
                        ? AppColors.outlineVariant
                        : AppColors.primary,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: photoState.isProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.onPrimary,
                          ),
                        )
                      : const Icon(
                          Icons.photo_camera,
                          color: AppColors.onPrimary,
                          size: 20,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoContent(ProfilePhotoState state) {
    final path = state.photoPath;
    if (path == null) {
      return const Icon(
        key: ValueKey('profile-photo-placeholder'),
        Icons.person,
        size: 64,
        color: AppColors.outlineVariant,
      );
    }
    return Image.file(
      File(path),
      key: const ValueKey('profile-photo-image'),
      fit: BoxFit.cover,
      width: 128,
      height: 128,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.person, size: 64, color: AppColors.outlineVariant),
    );
  }

  Future<void> _showPhotoActions() async {
    final hasPhoto = ref.read(profilePhotoControllerProvider).hasPhoto;
    final action = await showModalBottomSheet<_PhotoAction>(
      context: context,
      backgroundColor: AppColors.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 4, 24, 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Profil Fotoğrafı',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              _photoActionTile(
                sheetContext,
                icon: Icons.photo_library_outlined,
                label: 'Galeriden Seç',
                action: _PhotoAction.gallery,
              ),
              _photoActionTile(
                sheetContext,
                icon: Icons.photo_camera_outlined,
                label: 'Kamerayla Çek',
                action: _PhotoAction.camera,
              ),
              _photoActionTile(
                sheetContext,
                icon: Icons.content_paste_rounded,
                label: 'Panodan Yapıştır',
                action: _PhotoAction.clipboard,
              ),
              if (hasPhoto) ...[
                _photoActionTile(
                  sheetContext,
                  icon: Icons.crop,
                  label: 'Fotoğrafı Düzenle',
                  action: _PhotoAction.edit,
                ),
                _photoActionTile(
                  sheetContext,
                  icon: Icons.delete_outline,
                  label: 'Fotoğrafı Kaldır',
                  action: _PhotoAction.remove,
                  color: AppColors.error,
                ),
              ],
              const Divider(height: 1),
              _photoActionTile(
                sheetContext,
                icon: Icons.close,
                label: 'İptal',
                action: _PhotoAction.cancel,
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || action == null || action == _PhotoAction.cancel) return;

    final controller = ref.read(profilePhotoControllerProvider.notifier);
    final result = switch (action) {
      _PhotoAction.gallery => controller.select(ProfilePhotoSource.gallery),
      _PhotoAction.camera => controller.select(ProfilePhotoSource.camera),
      _PhotoAction.clipboard => controller.pasteFromClipboard(),
      _PhotoAction.edit => controller.recrop(),
      _PhotoAction.remove => controller.remove(),
      _PhotoAction.cancel => Future.value(
        const ProfilePhotoActionResult(ProfilePhotoActionStatus.cancelled),
      ),
    };
    await _showPhotoResult(await result);
  }

  Widget _photoActionTile(
    BuildContext sheetContext, {
    required IconData icon,
    required String label,
    required _PhotoAction action,
    Color color = AppColors.textPrimary,
  }) {
    return ListTile(
      minTileHeight: 52,
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      onTap: () => Navigator.of(sheetContext).pop(action),
    );
  }

  Future<void> _showPhotoResult(ProfilePhotoActionResult result) async {
    if (!mounted || result.status == ProfilePhotoActionStatus.cancelled) return;
    if (result.status == ProfilePhotoActionStatus.updated) {
      final path = ref.read(profilePhotoControllerProvider).photoPath;
      if (path != null) await FileImage(File(path)).evict();
      if (!mounted) return;
      setState(() {});
    }
    final message = switch (result.status) {
      ProfilePhotoActionStatus.updated => 'Profil fotoğrafı güncellendi.',
      ProfilePhotoActionStatus.removed => 'Profil fotoğrafı kaldırıldı.',
      ProfilePhotoActionStatus.failed =>
        result.message ?? 'Fotoğraf işlemi tamamlanamadı.',
      ProfilePhotoActionStatus.cancelled => '',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  // ─── Labels ─────────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 20 / 14,
          letterSpacing: 0.01 * 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ─── Text Fields ────────────────────────────────────────────────────────────

  Widget _buildTextField({
    required TextEditingController controller,
    required String placeholder,
    String? prefixText,
    IconData? prefixIcon,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 24 / 16,
          color: AppColors.outline.withValues(alpha: 0.6),
        ),
        filled: true,
        fillColor: AppColors.surfaceLow,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16, right: 8),
                child: Icon(
                  prefixIcon,
                  color: AppColors.outlineVariant,
                  size: 20,
                ),
              )
            : prefixText != null
            ? Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Text(
                  prefixText,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.outlineVariant,
                  ),
                ),
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // ─── Read-only Email ────────────────────────────────────────────────────────

  Widget _buildReadOnlyEmail(String email) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              email,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 24 / 16,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const Icon(
            Icons.lock_outline,
            size: 18,
            color: AppColors.outlineVariant,
          ),
        ],
      ),
    );
  }

  // ─── Save Button ────────────────────────────────────────────────────────────

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            letterSpacing: 0.01 * 14,
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.onPrimary,
                ),
              )
            : const Text('Değişiklikleri Kaydet'),
      ),
    );
  }

  // ─── Cancel Button ──────────────────────────────────────────────────────────

  Widget _buildCancelButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: () => Navigator.of(context).pop(),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
            letterSpacing: 0.01 * 14,
          ),
        ),
        child: const Text('İptal'),
      ),
    );
  }
}
