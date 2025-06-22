import 'package:flutter/material.dart';
import '../widgets/dorm_buddy_logo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isStudent = true;
  bool _isLoading = false;
  bool _rememberMe = false; // <-- Added remember me variable

  @override
  void initState() {
    super.initState();
    _loadRememberedEmail();
  }

  Future<void> _loadRememberedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmail = prefs.getString('remembered_email');
    final savedPassword = prefs.getString('remembered_password');
    if (savedEmail != null) {
      _emailController.text = savedEmail;
      setState(() {
        _rememberMe = true;
      });
    }
    if (savedPassword != null) {
      _passwordController.text = savedPassword;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea( 
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF800000), // Primary maroon
                Color(0xFFA52A2A), // Sienna
                Color(0xFFCD5C5C), // Indian red
              ],
              stops: [0.1, 0.5, 0.9],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  // ignore: deprecated_member_use
                  shadowColor: Colors.black.withOpacity(0.3),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center, 
                        children: [
                          const DormBuddyLogo(),
                          const SizedBox(height: 20),
                          Text(
                            'Welcome to DormBuddy',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[800],
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Sign in as:',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          // User Type Selection
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _UserTypeButton(
                                icon: Icons.school,
                                label: 'Student',
                                isSelected: _isStudent,
                                onTap: () => setState(() => _isStudent = true),
                              ),
                              const SizedBox(width: 20),
                              _UserTypeButton(
                                icon: Icons.home_work,
                                label: 'Landlord',
                                isSelected: !_isStudent,
                                onTap: () => setState(() => _isStudent = false),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText:
                                  _isStudent
                                      ? 'University Email'
                                      : 'Business Email',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.grey[700],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[400]!),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(color: Colors.grey[700]),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: Colors.grey[700],
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(color: Colors.grey[400]!),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey[700],
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
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15),
                          // Remember Me Checkbox
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() {
                                    _rememberMe = value ?? false;
                                  });
                                },
                                activeColor: const Color(0xFF800000),
                                checkColor: Colors.white,
                              ),
                              const Text(
                                'Remember Me',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF800000),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              onPressed: _isLoading ? null : _handleLogin,
                              child:
                                  _isLoading
                                      ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                      : const Text(
                                        'Sign In',
                                        style: TextStyle(fontSize: 16),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed:
                                _isLoading
                                    ? null
                                    : () =>
                                        Navigator.pushNamed(context, '/forgot'),
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Need an account? ',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                              TextButton(
                                onPressed:
                                    _isLoading
                                        ? null
                                        : () => Navigator.pushNamed(
                                          context,
                                          _isStudent
                                              ? '/register/student'
                                              : '/register/landlord',
                                        ),
                                child: Text(
                                  _isStudent ? 'Student' : 'Landlord',
                                  style: const TextStyle(
                                    color: Color(0xFF800000),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                ' Sign Up',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ],
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

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        // Fetch user role from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();
        final userRole = userDoc.data()?['role'];

        // Save or clear email based on Remember Me
        final prefs = await SharedPreferences.getInstance();
        if (_rememberMe) {
          await prefs.setString('remembered_email', _emailController.text.trim());
          await prefs.setString('remembered_password', _passwordController.text); // Not secure!
        } else {
          await prefs.remove('remembered_email');
          await prefs.remove('remembered_password');
        }

        // Role-based navigation and restriction
        if (userRole == null) {
          throw FirebaseAuthException(
            code: 'role-not-found',
            message: 'User role not found. Please contact support.',
          );
        }

        if ((_isStudent && userRole == 'student') || (!_isStudent && userRole == 'landlord')) {
          if (mounted) {
            setState(() => _isLoading = false);
            Navigator.pushReplacementNamed(
              context,
              _isStudent ? '/student-dashboard' : '/landlord-dashboard',
            );
          }
        } else {
          setState(() => _isLoading = false);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Login Error'),
              content: Text(
                _isStudent
                  ? 'This account is registered as a landlord. Please use the landlord login.'
                  : 'This account is registered as a student. Please use the student login.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        setState(() => _isLoading = false);
        String errorMessage;

        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          case 'invalid-email':
            errorMessage = 'Invalid email address.';
            break;
          case 'role-not-found':
            errorMessage = e.message ?? 'User role not found.';
            break;
          default:
            errorMessage = 'Login failed. Please try again.';
        }

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Login Error'),
            content: Text(errorMessage),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

}

class _UserTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UserTypeButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color:
              isSelected
                  // ignore: deprecated_member_use
                  ? const Color(0xFF800000).withOpacity(0.1)
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF800000) : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: const Color(0xFF800000)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF800000),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
