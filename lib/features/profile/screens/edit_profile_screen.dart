import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      _fullNameController.text = profile.fullName ?? '';
      _emailController.text = profile.email ?? '';
      _selectedDate = profile.dateOfBirth;
      if (profile.address != null) {
        _streetController.text = profile.address!.street ?? '';
        _cityController.text = profile.address!.city ?? '';
        _stateController.text = profile.address!.state ?? '';
        _pincodeController.text = profile.address!.pincode ?? '';
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final profileData = {
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        if (_selectedDate != null) 'dateOfBirth': _selectedDate!.toIso8601String(),
        'address': {
          'street': _streetController.text.trim(),
          'city': _cityController.text.trim(),
          'state': _stateController.text.trim(),
          'pincode': _pincodeController.text.trim(),
        },
      };

      final success = await context.read<ProfileProvider>().updateProfile(profileData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: AppConstants.successColor,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.read<ProfileProvider>().error ?? 'Failed to update'),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          children: [
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: AppConstants.spacingM),

            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Required';
                if (!value!.contains('@')) return 'Invalid email';
                return null;
              },
            ),
            const SizedBox(height: AppConstants.spacingM),

            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth',
                  prefixIcon: Icon(Icons.cake),
                ),
                child: Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select date',
                  style: TextStyle(
                    color: _selectedDate != null ? Colors.black : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spacingL),

            const Text(
              'Address',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),

            TextFormField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: 'Street',
                prefixIcon: Icon(Icons.home),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),

            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),

            TextFormField(
              controller: _stateController,
              decoration: const InputDecoration(
                labelText: 'State',
                prefixIcon: Icon(Icons.map),
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),

            TextFormField(
              controller: _pincodeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pincode',
                prefixIcon: Icon(Icons.pin_drop),
              ),
            ),
            const SizedBox(height: AppConstants.spacingXL),

            Consumer<ProfileProvider>(
              builder: (context, provider, _) {
                return CustomButton(
                  text: 'Save Profile',
                  onPressed: _saveProfile,
                  isLoading: provider.isLoading,
                  icon: Icons.save,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
