import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../app_dependencies.dart';
import '../../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimensions.dart';
import '../../theme/app_text_styles.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedCredentials() async {
    try {
      if (!Hive.isBoxOpen(AppConstants.settingsBoxName)) {
        return;
      }

      final box = Hive.box<dynamic>(AppConstants.settingsBoxName);
      final rememberMe = box.get(AppConstants.rememberMeKey, defaultValue: false) as bool;

      if (rememberMe) {
        final savedUsername = box.get(AppConstants.savedUsernameKey) as String?;
        final savedPassword = box.get(AppConstants.savedPasswordKey) as String?;

        if (savedUsername != null && savedPassword != null) {
          setState(() {
            _usernameController.text = savedUsername;
            _passwordController.text = savedPassword;
            _rememberMe = true;
          });
        }
      }
    } catch (e) {
      // Ignore error
    }
  }

  Future<void> _saveCredentials(String username, String password) async {
    try {
      if (!Hive.isBoxOpen(AppConstants.settingsBoxName)) {
        return;
      }

      final box = Hive.box<dynamic>(AppConstants.settingsBoxName);
      await box.put(AppConstants.rememberMeKey, _rememberMe);

      if (_rememberMe) {
        await box.put(AppConstants.savedUsernameKey, username);
        await box.put(AppConstants.savedPasswordKey, password);
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
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // Save credentials if remember me is checked
      await _saveCredentials(username, password);

      await ref.read(authNotifierProvider.notifier).login(username, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.loginStatus.isLoading;

    // Show error if login failed
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      next.loginStatus.whenOrNull(
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error.toString()),
              backgroundColor: AppColors.error,
            ),
          );
        },
      );
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppColors.mainBackgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingL),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppDimensions.maxContentWidth,
                ),
                child: Card(
                  elevation: AppDimensions.cardElevation,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppDimensions.borderRadius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.spacingL),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.spa,
                            size: 60,
                            color: AppColors.primary,
                          ),
                          const SizedBox(height: AppDimensions.spacingL),
                          Text(
                            'Welcome Back',
                            style: AppTextStyles.headlineLarge,
                          ),
                          const SizedBox(height: AppDimensions.spacingS),
                          Text(
                            'Sign in to continue',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: AppDimensions.spacingXl),
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: AppDimensions.spacingM),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
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
                              Text(
                                'Remember Me',
                                style: AppTextStyles.bodyMedium,
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
                                                Colors.white),
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
    );
  }
}
