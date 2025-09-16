import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../constants/colors.dart';
import '../widgets/animated_button.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructorRegistrationScreen extends StatefulWidget {
  const InstructorRegistrationScreen({Key? key}) : super(key: key);

  @override
  State<InstructorRegistrationScreen> createState() => _InstructorRegistrationScreenState();
}

class _InstructorRegistrationScreenState extends State<InstructorRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await FirebaseService().registerInstructor(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Instructor registered successfully! Please login.'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      String errorMessage = 'Registration failed';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Email already in use';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email address';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back Button and Header
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
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      SizedBox(height: sectionSpacing),
                      
                      // Welcome Section Header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB2FF00).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                            ),
                            child: Icon(Icons.person_add_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                          ),
                          SizedBox(width: 16 * scale),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Instructor Registration",
                                  style: GoogleFonts.prompt(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 24 * scale,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4 * scale),
                                Text(
                                  'Join our academy as an instructor',
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
                      SizedBox(height: sectionSpacing * 1.5),
                      
                      // Registration Form Card
                      Container(
                        margin: EdgeInsets.all(sectionSpacing),
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
                              blurRadius: 10,
                              offset: const Offset(0, 4),
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
                                      borderRadius: BorderRadius.circular(12 * scale),
                                      border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                                    ),
                                    child: Icon(Icons.edit_note_rounded, color: const Color(0xFF1976D2), size: 24 * scale),
                                  ),
                                  SizedBox(width: 16 * scale),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Registration Details',
                                          style: GoogleFonts.prompt(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18 * scale,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(height: 4 * scale),
                                        Text(
                                          'Fill in your information to get started',
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
                              
                              // Full Name Field
                              _buildTextField(
                                controller: _nameController,
                                label: 'Full Name',
                                icon: Icons.person_rounded,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your full name';
                                  }
                                  return null;
                                },
                                scale: scale,
                                cardRadius: cardRadius,
                              ),
                              SizedBox(height: cardSpacing),
                              
                              // Email Field
                              _buildTextField(
                                controller: _emailController,
                                label: 'Email Address',
                                icon: Icons.email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your email';
                                  }
                                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                  if (!emailRegex.hasMatch(value.trim())) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                                scale: scale,
                                cardRadius: cardRadius,
                              ),
                              SizedBox(height: cardSpacing),
                              
                              // Phone Field
                              _buildTextField(
                                controller: _phoneController,
                                label: 'Phone Number (Optional)',
                                icon: Icons.phone_rounded,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value != null && value.trim().isNotEmpty) {
                                    final phone = value.trim();
                                    if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
                                      return 'Please enter a valid 10-digit phone number';
                                    }
                                  }
                                  return null;
                                },
                                scale: scale,
                                cardRadius: cardRadius,
                              ),
                              SizedBox(height: cardSpacing),
                              
                              // Password Field
                              _buildPasswordField(
                                controller: _passwordController,
                                scale: scale,
                                cardRadius: cardRadius,
                              ),
                              SizedBox(height: cardSpacing * 1.5),
                              
                              // Register Button
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
                                        child: SizedBox(
                                          width: 24 * scale,
                                          height: 24 * scale,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5 * scale,
                                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB2FF00)),
                                          ),
                                        ),
                                      ),
                                    )
                                  : ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFB2FF00),
                                        foregroundColor: const Color(0xFF13131A),
                                        padding: EdgeInsets.symmetric(vertical: 16 * scale),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(cardRadius),
                                        ),
                                        elevation: 4,
                                        shadowColor: const Color(0xFFB2FF00).withOpacity(0.3),
                                      ),
                                      onPressed: _register,
                                      child: SizedBox(
                                        width: double.infinity,
                                        child: Text(
                                          "Register as Instructor",
                                          style: GoogleFonts.poppins(
                                            fontSize: 16 * scale,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      
                      // Login Link Card
                      Container(
                        margin: EdgeInsets.all(sectionSpacing),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.12),
                              Colors.white.withOpacity(0.06),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: cardPadding,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Already have an account? ",
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
                                    color: const Color(0xFFB2FF00).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(16 * scale),
                                    border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                                  ),
                                  child: Text(
                                    'Login',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFB2FF00),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?)? validator,
    TextInputType? keyboardType,
    required double scale,
    required double cardRadius,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16 * scale,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.5),
          fontSize: 16 * scale,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.white.withOpacity(0.7),
          size: 22 * scale,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
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
          borderSide: BorderSide(color: Colors.cyan.shade300, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required double scale,
    required double cardRadius,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: _obscurePassword,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 16 * scale,
      ),
      decoration: InputDecoration(
        labelText: 'Password',
        labelStyle: GoogleFonts.poppins(
          color: Colors.white.withOpacity(0.5),
          fontSize: 16 * scale,
        ),
        prefixIcon: Icon(
          Icons.lock_rounded,
          color: Colors.white.withOpacity(0.7),
          size: 22 * scale,
        ),
        suffixIcon: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: Icon(
            _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
            color: Colors.white.withOpacity(0.7),
            size: 22 * scale,
          ),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
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
          borderSide: BorderSide(color: Colors.cyan.shade300, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a password';
        }
        if (value.trim().length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
    );
  }
} 