import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/validators.dart';
import '../widgets/common/custom_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userModel;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phoneNumber ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            icon: Icon(_isEditing ? Icons.close : Icons.edit),
          ),
        ],
      ),
      body: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, child) {
          final user = authProvider.userModel;
          
          if (user == null) {
            return const Center(
              child: Text('No user data available'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Profile Picture
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage: user.profileImage != null
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child: user.profileImage == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    if (_isEditing)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            onPressed: () => _changeProfilePicture(),
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 24),

                // User Info Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        enabled: _isEditing,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: Validators.validateName,
                      ),
                      const SizedBox(height: 16),

                      // Email Field (Read-only)
                      TextFormField(
                        initialValue: user.email,
                        enabled: false,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Phone Field
                      TextFormField(
                        controller: _phoneController,
                        enabled: _isEditing,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Icon(Icons.phone),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            return Validators.validatePhoneNumber(value);
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Save Button
                      if (_isEditing)
                        PrimaryButton(
                          text: 'Save Changes',
                          width: double.infinity,
                          isLoading: authProvider.isLoading,
                          onPressed: () => _handleSaveProfile(authProvider),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Settings Section
                Card(
                  child: Column(
                    children: [
                      const ListTile(
                        title: Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(),
                      
                      // Theme Setting
                      ListTile(
                        leading: Icon(themeProvider.themeModeIcon),
                        title: const Text('Theme'),
                        subtitle: Text(themeProvider.themeModeName),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showThemeDialog(themeProvider),
                      ),
                      
                      // Notifications Setting
                      ListTile(
                        leading: const Icon(Icons.notifications),
                        title: const Text('Notifications'),
                        subtitle: const Text('Manage notification preferences'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showNotificationSettings(),
                      ),
                      
                      // Privacy Setting
                      ListTile(
                        leading: const Icon(Icons.privacy_tip),
                        title: const Text('Privacy'),
                        subtitle: const Text('Privacy and data settings'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showPrivacySettings(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Account Actions
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.logout, color: Colors.orange),
                        title: const Text('Sign Out'),
                        onTap: () => _showSignOutDialog(authProvider),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.delete_forever, color: Colors.red),
                        title: const Text('Delete Account'),
                        onTap: () => _showDeleteAccountDialog(authProvider),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // App Info
                Text(
                  'BuzzGo v1.0.0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSaveProfile(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final success = await authProvider.updateUserProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
      );

      if (mounted) {
        if (success) {
          setState(() {
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authProvider.errorMessage ?? 'Failed to update profile'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _changeProfilePicture() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture upload will be implemented'),
      ),
    );
  }

  void _showThemeDialog(ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Light'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Dark'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('System'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notification settings will be implemented'),
      ),
    );
  }

  void _showPrivacySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Privacy settings will be implemented'),
      ),
    );
  }

  void _showSignOutDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await authProvider.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await authProvider.deleteAccount();
              if (mounted) {
                if (success) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(authProvider.errorMessage ?? 'Failed to delete account'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}