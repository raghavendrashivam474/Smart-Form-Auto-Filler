import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../auth/providers/auth_provider.dart';
import '../profile/providers/profile_provider.dart';
import '../forms/providers/forms_provider.dart';
import '../submissions/providers/submissions_provider.dart';
import '../profile/screens/profile_screen.dart';
import '../forms/screens/forms_list_screen.dart';
import '../submissions/screens/submissions_screen.dart';
import '../auth/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load initial data
    _loadData();
  }

  void _loadData() {
    Future.microtask(() {
      context.read<FormsProvider>().loadForms();
      context.read<ProfileProvider>().loadProfile();
      context.read<SubmissionsProvider>().loadSubmissions();
    });
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Refresh data when switching tabs
    Future.microtask(() {
      switch (index) {
        case 0:
          context.read<FormsProvider>().loadForms();
          break;
        case 1:
          context.read<SubmissionsProvider>().loadSubmissions();
          break;
        case 2:
          context.read<ProfileProvider>().loadProfile();
          break;
      }
    });
  }

  final List<Widget> _screens = [
    const FormsListScreen(),
    const SubmissionsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Refreshed'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Logout'),
                  content: const Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                final authProvider = context.read<AuthProvider>();
                await authProvider.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabChanged,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Forms',
          ),
          NavigationDestination(
            icon: Icon(Icons.history_outlined),
            selectedIcon: Icon(Icons.history),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Available Forms';
      case 1:
        return 'My Submissions';
      case 2:
        return 'My Profile';
      default:
        return AppConstants.appName;
    }
  }
}
