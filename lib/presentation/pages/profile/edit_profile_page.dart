import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';
import '../../../app_dependencies.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../widgets/unfocus_wrapper.dart';
import '../../widgets/custom_text_field.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;
  late TextEditingController _ssnController;
  late TextEditingController _addressController;
  bool _isEmailValid = true;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _emailController = TextEditingController(text: user.email);
    _ssnController = TextEditingController(text: user.ssn);
    _addressController = TextEditingController(text: user.address);

    // Listen to email changes and validate
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    final email = _emailController.text.trim();
    final isValid = email.isEmpty || EmailValidator.validate(email);
    if (_isEmailValid != isValid) {
      setState(() {
        _isEmailValid = isValid;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _ssnController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      final data = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'ssn': _ssnController.text.trim(),
        'address': _addressController.text.trim(),
      };

      await ref.read(authNotifierProvider.notifier).updateProfile(data);

      if (mounted) {
        final state = ref.read(authNotifierProvider);
        if (state.updateProfileStatus.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.updateProfileStatus.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.error,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Profile updated successfully',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authNotifierProvider);
    final isLoading = state.updateProfileStatus.isLoading;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: UnfocusWrapper(
        child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Edit Profile',
            style: AppTextStyles.headlineMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter first name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter last name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter email';
                          }
                          if (!EmailValidator.validate(value.trim())) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _ssnController,
                        label: 'SSN',
                        icon: Icons.confirmation_number_outlined,
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.location_on_outlined,
                        keyboardType: TextInputType.streetAddress,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Fixed bottom button
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: (isLoading || !_isEmailValid) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          'Save Changes',
                          style: AppTextStyles.titleLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }

}
