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

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isSubmitting = false;
  bool _hasNavigated = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showRegistrationPlaceholder() {
    Navigator.of(context).pushNamed(AppRouter.register);
  }

  void _showForgotPasswordPlaceholder() {
    _showMessage('Şifre yenileme akışı yakında eklenecek.');
  }

  void _showGooglePlaceholder() {
    _showMessage('Google ile giriş yakında eklenecek.');
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate() || _hasNavigated || _isSubmitting) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final repository = ref.read(authRepositoryProvider);
      await repository.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      _hasNavigated = true;
      ref.invalidate(currentUserProvider);
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } on ApiException catch (e) {
      _showMessage(_loginErrorMessage(e));
    } catch (_) {
      _showMessage('Giriş yaparken beklenmeyen bir hata oluştu.');
    } finally {
      if (mounted && !_hasNavigated) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String _loginErrorMessage(ApiException exception) {
    if (exception.isUnauthorized) {
      return 'E-posta adresi veya şifre hatalı.';
    }
    if (exception.errorCode == 'NETWORK_ERROR') {
      return 'İnternet bağlantınızı kontrol edip tekrar deneyin.';
    }
    if (exception.statusCode >= 500) {
      return 'Şu anda giriş yapılamıyor. Lütfen daha sonra tekrar deneyin.';
    }
    return 'Giriş yapılamadı. Bilgilerinizi kontrol edip tekrar deneyin.';
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'E-posta adresinizi girin.';
    }
    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
      return 'Geçerli bir e-posta adresi girin.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Şifrenizi girin.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: AppColors.authBackground,
      padding: EdgeInsets.zero,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            const _BackgroundDecoration(),
            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.lg,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 48,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              AppConstants.brandName,
                              textAlign: TextAlign.center,
                              style: AppTypography.authBrand,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Text(
                              'Bir sonraki maceranı keşfet.',
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _AuthModeSwitch(
                                    onRegistrationPressed:
                                        _showRegistrationPlaceholder,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  AutofillGroup(
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        children: [
                                          AuthTextField(
                                            fieldKey: const ValueKey(
                                              'email-field',
                                            ),
                                            label: 'E-posta',
                                            hintText: 'merhaba@ornek.com',
                                            controller: _emailController,
                                            prefixIcon: Icons.email_outlined,
                                            keyboardType:
                                                TextInputType.emailAddress,
                                            textInputAction:
                                                TextInputAction.next,
                                            autofillHints: const [
                                              AutofillHints.email,
                                            ],
                                            validator: _validateEmail,
                                          ),
                                          const SizedBox(height: AppSpacing.md),
                                          AuthTextField(
                                            fieldKey: const ValueKey(
                                              'password-field',
                                            ),
                                            label: 'Şifre',
                                            hintText: '••••••••',
                                            controller: _passwordController,
                                            prefixIcon: Icons.lock_outline,
                                            textInputAction:
                                                TextInputAction.done,
                                            autofillHints: const [
                                              AutofillHints.password,
                                            ],
                                            obscureText: !_isPasswordVisible,
                                            validator: _validatePassword,
                                            onFieldSubmitted: (_) =>
                                                _submitLogin(),
                                            labelAction: TextButton(
                                              onPressed:
                                                  _showForgotPasswordPlaceholder,
                                              child: const Text('Unuttum?'),
                                            ),
                                            suffixIcon: IconButton(
                                              key: const ValueKey(
                                                'password-visibility-toggle',
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
                                          const SizedBox(height: AppSpacing.lg),
                                          AppButton(
                                            key: const ValueKey('login-submit'),
                                            label: 'Giriş Yap',
                                            icon: Icons.arrow_forward_rounded,
                                            iconPosition:
                                                AppButtonIconPosition.trailing,
                                            onPressed: _submitLogin,
                                            isLoading: _isSubmitting,
                                            isFullWidth: true,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  const _AuthSeparator(),
                                  const SizedBox(height: AppSpacing.md),
                                  SocialLoginButton(
                                    label: 'Google ile devam et',
                                    onPressed: _showGooglePlaceholder,
                                  ),
                                  const SizedBox(height: AppSpacing.lg),
                                  _LegalNotice(
                                    onTermsPressed: () => _showMessage(
                                      'Şartlarımız yakında eklenecek.',
                                    ),
                                    onPrivacyPressed: () => _showMessage(
                                      'Gizlilik Politikamız yakında eklenecek.',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthModeSwitch extends StatelessWidget {
  const _AuthModeSwitch({required this.onRegistrationPressed});

  final VoidCallback onRegistrationPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              TextButton(onPressed: () {}, child: const Text('Giriş Yap')),
              Container(
                key: const ValueKey('login-active-indicator'),
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            children: [
              TextButton(
                onPressed: onRegistrationPressed,
                child: const Text('Kayıt Ol'),
              ),
              const SizedBox(height: 3),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthSeparator extends StatelessWidget {
  const _AuthSeparator();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text(
              'veya şununla devam et',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class _LegalNotice extends StatelessWidget {
  const _LegalNotice({
    required this.onTermsPressed,
    required this.onPrivacyPressed,
  });

  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final linkStyle = textStyle?.copyWith(
      color: AppColors.primaryContainer,
      fontWeight: FontWeight.w600,
    );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Devam ederek, ', style: textStyle),
        TextButton(
          onPressed: onTermsPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 2),
          ),
          child: Text('Şartlarımızı', style: linkStyle),
        ),
        Text(' ve ', style: textStyle),
        TextButton(
          onPressed: onPrivacyPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 2),
          ),
          child: Text('Gizlilik Politikamızı', style: linkStyle),
        ),
        Text(' kabul etmiş olursunuz.', style: textStyle),
      ],
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            top: -100,
            right: -90,
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -110,
            left: -100,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
