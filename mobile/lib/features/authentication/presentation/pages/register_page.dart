import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:turota_mobile/app/router/app_router.dart';
import 'package:turota_mobile/core/constants/app_constants.dart';
import 'package:turota_mobile/core/networking/api_exception.dart';
import 'package:turota_mobile/core/theme/app_colors.dart';
import 'package:turota_mobile/core/theme/app_radius.dart';
import 'package:turota_mobile/core/theme/app_spacing.dart';
import 'package:turota_mobile/core/theme/app_typography.dart';
import 'package:turota_mobile/core/widgets/app_button.dart';
import 'package:turota_mobile/core/widgets/app_card.dart';
import 'package:turota_mobile/core/widgets/app_scaffold.dart';
import 'package:turota_mobile/features/authentication/presentation/providers/auth_providers.dart';
import 'package:turota_mobile/features/authentication/presentation/widgets/auth_text_field.dart';
import 'package:turota_mobile/features/authentication/presentation/widgets/social_login_button.dart';
import 'package:turota_mobile/features/authentication/presentation/widgets/terms_acceptance_row.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _hasAcceptedTerms = false;
  bool _showTermsError = false;
  bool _isSubmitting = false;
  bool _hasNavigated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _returnToLogin() {
    if (!mounted || _hasNavigated) {
      return;
    }
    _hasNavigated = true;

    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  Future<void> _submitRegistration() async {
    FocusScope.of(context).unfocus();
    if (_isSubmitting || _hasNavigated) {
      return;
    }

    final isFormValid = _formKey.currentState!.validate();
    setState(() => _showTermsError = !_hasAcceptedTerms);
    if (!isFormValid || !_hasAcceptedTerms) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final nameParts = _nameController.text.trim().split(RegExp(r'\s+'));
      final repository = ref.read(authRepositoryProvider);
      await repository.register(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: nameParts.first,
        lastName: nameParts.skip(1).join(' '),
      );

      if (!mounted) return;
      _hasNavigated = true;
      ref.invalidate(currentUserProvider);
      Navigator.of(context).pushReplacementNamed(AppRouter.tasteProfileCategory);
    } on ApiException catch (e) {
      _showMessage(_registrationErrorMessage(e));
    } catch (_) {
      _showMessage('Kayıt olurken beklenmeyen bir hata oluştu.');
    } finally {
      if (mounted && !_hasNavigated) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _registrationErrorMessage(ApiException exception) {
    if (exception.isConflict) {
      return 'Bu e-posta adresi zaten kayıtlı.';
    }
    if (exception.errorCode == 'NETWORK_ERROR') {
      return 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
    }
    if (exception.statusCode >= 500) {
      return 'Şu anda hesap oluşturulamıyor. Lütfen daha sonra tekrar deneyin.';
    }
    return 'Hesap oluşturulamadı. Bilgilerinizi kontrol edip tekrar deneyin.';
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Ad soyad alanı zorunludur.';
    }
    if (name.length < 2) {
      return 'Ad soyad en az 2 karakter olmalıdır.';
    }
    if (!name.contains(RegExp(r'\s'))) {
      return 'Ad ve soyadınızı girin.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'E-posta adresi zorunludur.';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Geçerli bir e-posta adresi girin.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre alanı zorunludur.';
    }
    if (value.length < 8) {
      return 'Şifre en az 8 karakter olmalıdır.';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifre onayı zorunludur.';
    }
    if (value != _passwordController.text) {
      return 'Şifreler eşleşmiyor.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.registrationBackground,
      padding: EdgeInsets.zero,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            const _RegistrationBackgroundDecoration(),
            Column(
              children: [
                _RegistrationTopBar(onBackPressed: _returnToLogin),
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.md,
                      AppSpacing.screen,
                      AppSpacing.lg,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          children: [
                            Text(
                              "TUROTA'ya Katıl",
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(color: AppColors.primary),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Hesabını oluştur ve sana özel mekanları keşfetmeye başla.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            AppCard(
                              borderRadius: AppRadius.xl,
                              boxShadow: const [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 28,
                                  offset: Offset(0, 10),
                                ),
                              ],
                              child: AutofillGroup(
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    children: [
                                      AuthTextField(
                                        fieldKey: const ValueKey(
                                          'register-name-field',
                                        ),
                                        label: 'Ad Soyad',
                                        hintText: 'John Doe',
                                        controller: _nameController,
                                        prefixIcon: Icons.person_outline,
                                        fillColor: AppColors.surfaceLow,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.name,
                                        ],
                                        validator: _validateName,
                                        onFieldSubmitted: (_) =>
                                            _emailFocusNode.requestFocus(),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      AuthTextField(
                                        fieldKey: const ValueKey(
                                          'register-email-field',
                                        ),
                                        label: 'E-posta Adresi',
                                        hintText: 'ornek@eposta.com',
                                        controller: _emailController,
                                        focusNode: _emailFocusNode,
                                        prefixIcon: Icons.email_outlined,
                                        fillColor: AppColors.surfaceLow,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.email,
                                        ],
                                        validator: _validateEmail,
                                        onFieldSubmitted: (_) =>
                                            _passwordFocusNode.requestFocus(),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      AuthTextField(
                                        fieldKey: const ValueKey(
                                          'register-password-field',
                                        ),
                                        label: 'Şifre',
                                        hintText: '••••••••',
                                        controller: _passwordController,
                                        focusNode: _passwordFocusNode,
                                        prefixIcon: Icons.lock_outline,
                                        fillColor: AppColors.surfaceLow,
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.newPassword,
                                        ],
                                        obscureText: !_isPasswordVisible,
                                        validator: _validatePassword,
                                        onFieldSubmitted: (_) =>
                                            _confirmPasswordFocusNode
                                                .requestFocus(),
                                        suffixIcon: IconButton(
                                          key: const ValueKey(
                                            'register-password-toggle',
                                          ),
                                          onPressed: () => setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          }),
                                          tooltip: _isPasswordVisible
                                              ? 'Şifreyi gizle'
                                              : 'Şifreyi göster',
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      AuthTextField(
                                        fieldKey: const ValueKey(
                                          'register-confirm-password-field',
                                        ),
                                        label: 'Şifreyi Onayla',
                                        hintText: '••••••••',
                                        controller: _confirmPasswordController,
                                        focusNode: _confirmPasswordFocusNode,
                                        prefixIcon: Icons.lock_outline,
                                        fillColor: AppColors.surfaceLow,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.newPassword,
                                        ],
                                        obscureText: !_isConfirmPasswordVisible,
                                        validator: _validateConfirmPassword,
                                        onFieldSubmitted: (_) =>
                                            _submitRegistration(),
                                        suffixIcon: IconButton(
                                          key: const ValueKey(
                                            'register-confirm-password-toggle',
                                          ),
                                          onPressed: () => setState(() {
                                            _isConfirmPasswordVisible =
                                                !_isConfirmPasswordVisible;
                                          }),
                                          tooltip: _isConfirmPasswordVisible
                                              ? 'Şifre onayını gizle'
                                              : 'Şifre onayını göster',
                                          icon: Icon(
                                            _isConfirmPasswordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.md),
                                      TermsAcceptanceRow(
                                        value: _hasAcceptedTerms,
                                        errorText: _showTermsError
                                            ? 'Devam etmek için şartları kabul etmelisiniz.'
                                            : null,
                                        onChanged: (value) => setState(() {
                                          _hasAcceptedTerms = value;
                                          if (value) {
                                            _showTermsError = false;
                                          }
                                        }),
                                        onTermsPressed: () => _showMessage(
                                          'Kullanım şartları yakında eklenecek.',
                                        ),
                                        onPrivacyPressed: () => _showMessage(
                                          'Gizlilik politikası yakında eklenecek.',
                                        ),
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      AppButton(
                                        key: const ValueKey('register-submit'),
                                        label: 'Hesap Oluştur',
                                        icon: Icons.arrow_forward_rounded,
                                        iconPosition:
                                            AppButtonIconPosition.trailing,
                                        onPressed: _submitRegistration,
                                        isLoading: _isSubmitting,
                                        isFullWidth: true,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      const _RegistrationSeparator(),
                                      const SizedBox(height: AppSpacing.md),
                                      SocialLoginButton(
                                        label: 'Google ile devam et',
                                        onPressed: () => _showMessage(
                                          'Google ile kayıt yakında eklenecek.',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            _ExistingAccountAction(
                              onLoginPressed: _returnToLogin,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RegistrationTopBar extends StatelessWidget {
  const _RegistrationTopBar({required this.onBackPressed});

  final VoidCallback onBackPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: IconButton(
              key: const ValueKey('register-back'),
              onPressed: onBackPressed,
              tooltip: 'Giriş ekranına dön',
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const Expanded(
            child: Text(
              AppConstants.brandName,
              textAlign: TextAlign.center,
              style: AppTypography.splashBrand,
            ),
          ),
          const SizedBox(width: 56),
        ],
      ),
    );
  }
}

class _RegistrationSeparator extends StatelessWidget {
  const _RegistrationSeparator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Expanded(
          flex: 3,
          child: Text(
            'ŞUNUNLA KAYDOL',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _ExistingAccountAction extends StatelessWidget {
  const _ExistingAccountAction({required this.onLoginPressed});

  final VoidCallback onLoginPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Zaten bir hesabın var mı? ',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        TextButton(
          key: const ValueKey('register-login-action'),
          onPressed: onLoginPressed,
          child: const Text('Giriş Yap'),
        ),
      ],
    );
  }
}

class _RegistrationBackgroundDecoration extends StatelessWidget {
  const _RegistrationBackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -120,
            right: -90,
            child: _GlowCircle(
              size: 280,
              color: AppColors.primary.withValues(alpha: 0.08),
            ),
          ),
          Positioned(
            bottom: -130,
            left: -100,
            child: _GlowCircle(
              size: 300,
              color: AppColors.primary.withValues(alpha: 0.06),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowCircle extends StatelessWidget {
  const _GlowCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
