import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/app_routes.dart';
import '../utils/validators.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6750A4),
              Color(0xFF7F39FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo and Title
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.event,
                      size: 50,
                      color: Color(0xFF6750A4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Welcome to BuzzGo',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover amazing local events',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 48),
                  
                  // Login Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Email Field
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 16),
                          
                          // Password Field
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
                            validator: Validators.validatePassword,
                          ),
                          const SizedBox(height: 24),
                          
                          // Login Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return PrimaryButton(
                                text: 'Sign In',
                                width: double.infinity,
                                isLoading: authProvider.isLoading,
                                onPressed: () => _handleLogin(authProvider),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Google Sign In Button
                          Consumer<AuthProvider>(
                            builder: (context, authProvider, child) {
                              return OutlineButton(
                                text: 'Continue with Google',
                                width: double.infinity,
                                icon: Icons.g_mobiledata,
                                isLoading: authProvider.isLoading,
                                onPressed: () => _handleGoogleSignIn(authProvider),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Forgot Password
                          TextButton(
                            onPressed: () => _showForgotPasswordDialog(),
                            child: const Text('Forgot Password?'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account? ",
                        style: TextStyle(color: Colors.white70),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRoutes.register);
                        },
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogin(AuthProvider authProvider) async {
    if (_formKey.currentState!.validate()) {
      final success = await authProvider.signInWithEmailAndPassword(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      } else if (mounted && authProvider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleGoogleSignIn(AuthProvider authProvider) async {
    try {
      final success = await authProvider.signInWithGoogle();
      if (success && mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In is not available in this environment'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _showForgotPasswordDialog() {
    final emailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your email address to receive a password reset link.'),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return TextButton(
                onPressed: authProvider.isLoading
                    ? null
                    : () async {
                        if (emailController.text.isNotEmpty) {
                          final success = await authProvider.resetPassword(
                            emailController.text.trim(),
                          );
                          if (mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Password reset email sent!'
                                      : 'Failed to send reset email',
                                ),
                                backgroundColor: success ? Colors.green : Colors.red,
                              ),
                            );
                          }
                        }
                      },
                child: authProvider.isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Send Reset Link'),
              );
            },
          ),
        ],
      ),
    );
  }
}