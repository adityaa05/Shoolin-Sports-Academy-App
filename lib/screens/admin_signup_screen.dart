import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../constants/colors.dart';

import '../widgets/animated_button.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminSignupScreen extends StatefulWidget {
  final bool isOnline;
  const AdminSignupScreen({Key? key, this.isOnline = true}) : super(key: key);

  @override
  State<AdminSignupScreen> createState() => _AdminSignupScreenState();
}

class _AdminSignupScreenState extends State<AdminSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  Future<void> _signup() async {
    if (!widget.isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'No internet connection. Please try again when online.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
      return;
    }
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _setLoading(true);
    try {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      print('Admin signup attempt - Name: $name, Email: $email');
      
      await _firebaseService.registerAdmin(
        name: name,
        email: email,
        password: password,
      );
      
      print('Admin registration successful, navigating to admin dashboard');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Admin registration successful!',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pushReplacementNamed(context, '/admin');
      }
    } catch (e) {
      print('Admin signup error: $e');
      String errorMessage = 'Signup failed';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Email already in use';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email address';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your connection.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              errorMessage,
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFEF4444),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      _setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(20 * scale);
    final double sectionSpacing = 20 * scale;
    final double cardSpacing = 12 * scale;

    return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF13131A),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF13131A), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 20.0 * scale),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Header Section
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22 * scale),
                              tooltip: 'Go Back',
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'Admin Signup',
                            style: GoogleFonts.prompt(
                              fontWeight: FontWeight.w600,
                              fontSize: 20 * scale,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(width: 48 * scale), // Balance the back button
                        ],
                      ),
                      SizedBox(height: sectionSpacing),
                      
                      // Welcome Section Header
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFEF4444).withOpacity(0.15),
                              const Color(0xFFEF4444).withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: cardPadding,
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12 * scale),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEF4444).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14 * scale),
                                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                                ),
                                child: Icon(Icons.admin_panel_settings_rounded, color: const Color(0xFFEF4444), size: 24 * scale),
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Admin Access",
                                      style: GoogleFonts.prompt(
                                        fontSize: 24 * scale,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4 * scale),
                                    Text(
                                      'Create your administrator account',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14 * scale,
                                        color: Colors.white.withOpacity(0.8),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: sectionSpacing * 1.5),
                      
                      // Registration Form Card
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.15),
                              Colors.white.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: cardPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Form Section Header
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(12 * scale),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1976D2).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(14 * scale),
                                      border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                                    ),
                                    child: Icon(Icons.person_rounded, color: const Color(0xFF1976D2), size: 24 * scale),
                                  ),
                                  SizedBox(width: 16 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Admin Details',
                                          style: GoogleFonts.prompt(
                                            fontWeight: FontWeight.w600, 
                                            fontSize: 18 * scale, 
                                            color: Colors.white
                                          ),
                                        ),
                                        SizedBox(height: 4 * scale),
                                        Text(
                                          'Fill in your administrator information',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 14 * scale,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: cardSpacing * 1.5),
                              
                              // Personal Information Section
                              _buildSectionHeader(
                                'Personal Information',
                                Icons.info_rounded,
                                const Color(0xFFB2FF00),
                                scale,
                              ),
                              SizedBox(height: cardSpacing),
                              
                              // Name Field
                              _buildInputField(
                                controller: _nameController,
                                hintText: 'Enter your full name',
                                icon: Icons.person_rounded,
                                color: const Color(0xFF1976D2),
                                scale: scale,
                                cardRadius: cardRadius,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: cardSpacing),
                              
                              // Email Field
                              _buildInputField(
                                controller: _emailController,
                                hintText: 'Enter your email address',
                                icon: Icons.email_rounded,
                                color: const Color(0xFF1976D2),
                                scale: scale,
                                cardRadius: cardRadius,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value.trim())) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: cardSpacing * 1.5),
                              
                              // Security Section
                              _buildSectionHeader(
                                'Security',
                                Icons.security_rounded,
                                const Color(0xFFEF4444),
                                scale,
                              ),
                              SizedBox(height: cardSpacing),
                              
                              // Password Field
                              _buildPasswordField(
                                controller: _passwordController,
                                hintText: 'Enter your password',
                                icon: Icons.lock_rounded,
                                color: const Color(0xFF1976D2),
                                scale: scale,
                                cardRadius: cardRadius,
                                obscureText: _obscurePassword,
                                onToggleVisibility: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter a password';
                                  }
                                  if (value.trim().length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: cardSpacing * 1.5),
                              
                              // Signup Button
                              _isLoading
                                  ? Container(
                                      height: 56 * scale,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFB2FF00).withOpacity(0.3),
                                            const Color(0xFFB2FF00).withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(cardRadius),
                                        border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                                      ),
                                      child: Center(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 20 * scale,
                                              height: 20 * scale,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5 * scale,
                                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB2FF00)),
                                              ),
                                            ),
                                            SizedBox(width: 12 * scale),
                                            Text(
                                              'Creating Account...',
                                              style: GoogleFonts.poppins(
                                                color: const Color(0xFFB2FF00),
                                                fontSize: 16 * scale,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 56 * scale,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            const Color(0xFFB2FF00),
                                            const Color(0xFFA3E635),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(cardRadius),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFB2FF00).withOpacity(0.3),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(cardRadius),
                                          onTap: _signup,
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.admin_panel_settings_rounded,
                                                  color: const Color(0xFF13131A),
                                                  size: 20 * scale,
                                                ),
                                                SizedBox(width: 8 * scale),
                                                Text(
                                                  "Create Admin Account",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16 * scale,
                                                    fontWeight: FontWeight.w600,
                                                    color: const Color(0xFF13131A),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      
                      // Login Link
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.04),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: cardPadding,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an admin account? ",
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14 * scale,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        const Color(0xFF8B5CF6).withOpacity(0.2),
                                        const Color(0xFF7C3AED).withOpacity(0.15),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(16 * scale),
                                    border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF8B5CF6),
                                      fontSize: 14 * scale,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color, double scale) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10 * scale),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 16 * scale),
        ),
        SizedBox(width: 10 * scale),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600, 
            fontSize: 16 * scale, 
            color: Colors.white
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color color,
    required double scale,
    required double cardRadius,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16 * scale,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.5),
          fontSize: 16 * scale,
        ),
        prefixIcon: Container(
          margin: EdgeInsets.all(8 * scale),
          padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10 * scale),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18 * scale,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: const Color(0xFFB2FF00), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: const Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: const Color(0xFFEF4444), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
        errorStyle: GoogleFonts.poppins(
          color: const Color(0xFFEF4444),
          fontSize: 12 * scale,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required Color color,
    required double scale,
    required double cardRadius,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16 * scale,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.5),
          fontSize: 16 * scale,
        ),
        prefixIcon: Container(
          margin: EdgeInsets.all(8 * scale),
          padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10 * scale),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(
            icon,
            color: color,
            size: 18 * scale,
          ),
        ),
        suffixIcon: GestureDetector(
          onTap: onToggleVisibility,
          child: Container(
            margin: EdgeInsets.all(8 * scale),
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10 * scale),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Icon(
              obscureText ? Icons.visibility_rounded : Icons.visibility_off_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 18 * scale,
            ),
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: const Color(0xFFB2FF00), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: const Color(0xFFEF4444), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          borderSide: BorderSide(color: const Color(0xFFEF4444), width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
        errorStyle: GoogleFonts.poppins(
          color: const Color(0xFFEF4444),
          fontSize: 12 * scale,
        ),
      ),
      validator: validator,
    );
  }
} 