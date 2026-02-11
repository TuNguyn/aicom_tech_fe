import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import '../../../app_dependencies.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/toast_utils.dart';
import '../../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/unfocus_wrapper.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passcodeController = TextEditingController();
  bool _obscurePasscode = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _passcodeController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      if (!Hive.isBoxOpen(AppConstants.settingsBoxName)) {
        return;
      }

      final box = Hive.box<dynamic>(AppConstants.settingsBoxName);
      final rememberMe =
          box.get(AppConstants.rememberMeKey, defaultValue: false) as bool;

      if (rememberMe) {
        final savedPhone = box.get(AppConstants.savedUsernameKey) as String?;
        final savedPasscode = box.get(AppConstants.savedPasswordKey) as String?;

        if (savedPhone != null && savedPasscode != null) {
          setState(() {
            _phoneController.text = savedPhone;
            _passcodeController.text = savedPasscode;
            _rememberMe = true;
          });
        }
      }
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _saveCredentials(String phone, String passcode) async {
    try {
      if (!Hive.isBoxOpen(AppConstants.settingsBoxName)) {
        return;
      }

      final box = Hive.box<dynamic>(AppConstants.settingsBoxName);
      await box.put(AppConstants.rememberMeKey, _rememberMe);

      if (_rememberMe) {
        await box.put(AppConstants.savedUsernameKey, phone);
        await box.put(AppConstants.savedPasswordKey, passcode);
      } else {
        await box.delete(AppConstants.savedUsernameKey);
        await box.delete(AppConstants.savedPasswordKey);
      }
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final phone = _phoneController.text.trim();
      final passcode = _passcodeController.text;

      // Save credentials if remember me is checked
      await _saveCredentials(phone, passcode);

      await ref
          .read(authNotifierProvider.notifier)
          .verifyEmployee(phone, passcode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.verifyStatus.isLoading;

    // Navigate to store selection when employees are verified
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      // Only process if verify status changed from loading to data/error
      final wasLoading = previous?.verifyStatus.isLoading ?? false;
      final isNowLoading = next.verifyStatus.isLoading;

      if (wasLoading && !isNowLoading) {
        // Verify status just completed (success or error)
        next.verifyStatus.whenOrNull(
          data: (_) {
            // Success response received
            if (next.verifiedEmployees.isNotEmpty) {
              // Found stores - navigate to selection
              context.push(AppRoutes.storeSelection);
            } else {
              // Success but no stores found - show message
              ToastUtils.showError(
                'No store found for this phone number. Please check your credentials.',
              );
            }
          },
          error: (error, stack) {
            // Skip toast when offline - banner already shows connectivity status
            if (ref.read(connectivityNotifierProvider).isOffline) return;
            ToastUtils.showError(error.toString());
          },
        );
      }
    });

    return UnfocusWrapper(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: AppColors.mainBackgroundGradient),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingL),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppDimensions.maxContentWidth,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadius,
                    ),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadius,
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.4),
                              Colors.white.withValues(alpha: 0.2),
                            ],
                          ),
                          border: Border.all(
                            width: 1.5,
                            color: Colors.transparent,
                          ),
                        ),
                        foregroundDecoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            AppDimensions.borderRadius,
                          ),
                          border: Border.all(
                            width: 1.5,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.2),
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.1),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppDimensions.spacingL),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // AICOM Logo - Circular
                                Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: 0.1,
                                        ),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/logo/aicom_logo.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.spacingXl),
                                Text(
                                  'Tech Login',
                                  style: AppTextStyles.headlineLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: AppDimensions.spacingS),
                                Text(
                                  'Sign in with your phone and passcode',
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppDimensions.spacingXl),
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: 'Phone',
                                    prefixIcon: const Icon(Icons.phone),
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.5,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppDimensions.spacingM),
                                TextFormField(
                                  controller: _passcodeController,
                                  obscureText: _obscurePasscode,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Passcode',
                                    prefixIcon: const Icon(Icons.pin),
                                    filled: true,
                                    fillColor: Colors.white.withValues(
                                      alpha: 0.5,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppColors.primary.withValues(
                                          alpha: 0.5,
                                        ),
                                        width: 1.5,
                                      ),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePasscode
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePasscode = !_obscurePasscode;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your passcode';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppDimensions.spacingM),
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                      },
                                      activeColor: AppColors.primary,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _rememberMe = !_rememberMe;
                                        });
                                      },
                                      child: Text(
                                        'Remember Me',
                                        style: AppTextStyles.bodyMedium,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppDimensions.spacingL),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: isLoading ? null : _handleLogin,
                                    child: isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : const Text('Sign In'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
