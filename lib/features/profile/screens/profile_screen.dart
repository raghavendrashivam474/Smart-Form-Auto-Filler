import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/loading_indicator.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/profile_provider.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<ProfileProvider>().loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        if (profileProvider.isLoading) {
          return const LoadingIndicator(message: 'Loading profile...');
        }

        final profile = profileProvider.profile;

        if (profile == null) {
          return EmptyState(
            icon: Icons.person_off_outlined,
            title: 'No Profile Yet',
            subtitle: 'Create your profile to enable smart auto-fill',
            action: CustomButton(
              text: 'Create Profile',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EditProfileScreen(),
                  ),
                );
              },
              icon: Icons.add,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingL),
                decoration: BoxDecoration(
                  gradient: AppConstants.primaryGradient,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        profile.fullName?.substring(0, 1).toUpperCase() ?? '?',
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingM),
                    Text(
                      profile.fullName ?? 'No Name',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spacingS),
                    Text(
                      profile.email ?? 'No Email',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppConstants.spacingL),

              // Profile Details
              _buildInfoCard(
                'Personal Information',
                [
                  _buildInfoRow(
                    Icons.cake,
                    'Date of Birth',
                    profile.dateOfBirth != null
                        ? DateFormat('MMM dd, yyyy').format(profile.dateOfBirth!)
                        : 'Not set',
                  ),
                  _buildInfoRow(
                    Icons.email,
                    'Email',
                    profile.email ?? 'Not set',
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingM),

              // Address Details
              if (profile.address != null)
                _buildInfoCard(
                  'Address',
                  [
                    _buildInfoRow(
                      Icons.home,
                      'Street',
                      profile.address!.street ?? 'Not set',
                    ),
                    _buildInfoRow(
                      Icons.location_city,
                      'City',
                      profile.address!.city ?? 'Not set',
                    ),
                    _buildInfoRow(
                      Icons.map,
                      'State',
                      profile.address!.state ?? 'Not set',
                    ),
                    _buildInfoRow(
                      Icons.pin_drop,
                      'Pincode',
                      profile.address!.pincode ?? 'Not set',
                    ),
                  ],
                ),

              const SizedBox(height: AppConstants.spacingL),

              // Edit Button
              CustomButton(
                text: 'Edit Profile',
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  );
                  if (result == true) {
                    profileProvider.loadProfile();
                  }
                },
                icon: Icons.edit,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.primaryColor,
              ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: AppConstants.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
