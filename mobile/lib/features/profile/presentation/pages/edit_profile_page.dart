import 'package:flutter/material.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController(text: 'Elena Rodriguez');
  final _usernameController = TextEditingController(text: 'elenatravels');
  final _cityController = TextEditingController(text: 'Barcelona, Spain');

  bool _isSaving = false;

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
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.surfaceLow,
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                color: AppColors.outline,
                size: 22,
              ),
            ),
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
                    _buildReadOnlyEmail('elena.rodriguez@example.com'),
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
    return Center(
      child: Stack(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceLow,
              border: Border.all(
                color: AppColors.surface,
                width: 4,
              ),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 20,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const ClipOval(
              child: Icon(
                Icons.person,
                size: 64,
                color: AppColors.outlineVariant,
              ),
            ),
          ),
          Positioned(
            bottom: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                // TODO: Implement photo picker.
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.photo_camera,
                  color: AppColors.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
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
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
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
          borderSide: const BorderSide(
            color: AppColors.primary,
            width: 1.5,
          ),
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
          side: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.2),
          ),
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
