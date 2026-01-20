import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app_dependencies.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

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

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).user;
    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _emailController = TextEditingController(text: user.email);
    _ssnController = TextEditingController(text: user.ssn);
    _addressController = TextEditingController(text: user.address);
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
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(
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
                  const SizedBox(height: 16),
                  _buildTextField(
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
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _ssnController,
                    label: 'SSN',
                    icon: Icons.confirmation_number_outlined,
                    keyboardType: TextInputType.text,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _addressController,
                    label: 'Address',
                    icon: Icons.location_on_outlined,
                    keyboardType: TextInputType.streetAddress,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Save Changes',
                              style: AppTextStyles.titleLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
          prefixIcon: Icon(
            icon,
            color: AppColors.primary.withValues(alpha: 0.7),
            size: 22,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}
