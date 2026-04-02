import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/auth_provider.dart';
import '../../home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(_phoneController.text.trim());

      if (success && mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.error ?? 'Login failed'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacingL),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo/Icon
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      gradient: AppConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXL),

                  // Title
                  Text(
                    AppConstants.appName,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingS),

                  // Subtitle
                  Text(
                    'Fill forms faster with smart auto-fill',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingXL * 2),

                  // Phone Input
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      hintText: '+919876543210',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!value.startsWith('+')) {
                        return 'Phone number must start with +';
                      }
                      if (value.length < 10) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  // Login Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return CustomButton(
                        text: 'Login',
                        onPressed: _login,
                        isLoading: authProvider.isLoading,
                        icon: Icons.login,
                      );
                    },
                  ),

                  const SizedBox(height: AppConstants.spacingL),

                  // Info Text
                  Container(
                    padding: const EdgeInsets.all(AppConstants.spacingM),
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppConstants.primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: AppConstants.spacingS),
                        Expanded(
                          child: Text(
                            'For demo: Enter any phone number with country code',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
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
      ),
    );
  }
}
