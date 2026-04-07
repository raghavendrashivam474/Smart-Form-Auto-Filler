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
  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpRequested = false;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

Future<void> _sendOTP() async {
  final email = _emailController.text.trim();

if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
  ScaffoldMessenger.of(context).showSnackBar(
   const SnackBar(
  content: Text('Please enter a valid email address'),
)
  );
  return;
}

  final authProvider = context.read<AuthProvider>();
  final responseData = await authProvider.sendOTP(email);

  if (responseData != null && mounted) {

    setState(() {
      _otpRequested = true;
    });

    final devOtp = responseData['demo_otp']?.toString();

    if (devOtp != null) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Dev Mode"),
          content: Text("Your OTP is $devOtp"),
        ),
      );

      _otpController.text = devOtp;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("OTP sent successfully"),
        backgroundColor: AppConstants.successColor,
      ),
    );
  }
}

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.login(_emailController.text.trim(), _otpController.text.trim());

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
                    'Use email OTP to access smart auto-fill',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spacingXL * 2),

                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      hintText: 'you@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      if (!value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.spacingL),

                  if (_otpRequested) ...[
                    TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'OTP',
                        hintText: '123456',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the OTP';
                        }
                        if (value.trim().length < 6) {
                          return 'Please enter a valid 6-digit OTP';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.spacingL),
                  ],

                  // Login Button
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return CustomButton(
                        text: _otpRequested ? 'Verify & Login' : 'Send OTP',
                        onPressed: _otpRequested ? _login : _sendOTP,
                        isLoading: authProvider.isLoading,
                        icon: _otpRequested ? Icons.verified_user : Icons.send,
                      );
                    },
                  ),

                  if (_otpRequested) ...[
                    const SizedBox(height: AppConstants.spacingM),
                    TextButton(
                      onPressed: _sendOTP,
                      child: const Text('Resend OTP'),
                    ),
                  ],

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
                            'We will send a one-time password to your email via SMTP.',
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
