import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_provider.dart';
import '../services/firebase_service.dart';
import '../models/instructor.dart';
import 'student_registration_screen.dart';
import 'instructor_login.dart';
import 'instructor_registration_screen.dart';
import '../constants/colors.dart';
import '../constants/texts.dart';

import '../widgets/animated_button.dart';
import 'admin_signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final String selectedRole;
  const LoginScreen({Key? key, required this.selectedRole}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _setLoading(true);

    try {
      // Sign in with Firebase
      await _firebaseService.signInWithEmailAndPassword(
        _emailController.text,
        _passwordController.text,
      );

      final currentUser = _firebaseService.getCurrentUser();
      if (currentUser != null) {
        final provider = Provider.of<AppProvider>(context, listen: false);
        
        if (widget.selectedRole == 'admin') {
          // Check if user is admin
          final isAdmin = await _firebaseService.isAdmin(currentUser.uid);
          if (!isAdmin) {
            throw Exception('This account is not registered as an admin');
          }
          provider.setAdminMode(true);
          Navigator.pushReplacementNamed(context, '/admin');
        } else if (widget.selectedRole == 'instructor') {
          // Check if user is instructor
          final isInstructor = await _firebaseService.isInstructor(currentUser.uid);
          if (!isInstructor) {
            throw Exception('This account is not registered as an instructor');
          }
          
          // Get instructor details
          final instructorDetails = await _firebaseService.getInstructorDetails(currentUser.uid);
          if (instructorDetails != null) {
            final instructor = Instructor.fromMap({...instructorDetails, 'id': currentUser.uid});
            provider.setCurrentInstructor(instructor);
            provider.setCurrentUserId(currentUser.uid);
            provider.setInstructorMode(true);
            Navigator.pushReplacementNamed(context, '/instructor');
          }
        } else {
          // Student login
          provider.setAdminMode(false);
          Navigator.pushReplacementNamed(context, '/student');
        }
      }
    } catch (e) {
      String errorMessage = 'Login failed';
      print('Login error: ' + e.toString()); // Print full error to console
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'No user found with this email';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Wrong password';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email address';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many failed attempts. Try again later';
      } else if (e.toString().contains('not registered as')) {
        errorMessage = e.toString().replaceAll('Exception: ', '');
      } else {
        errorMessage = e.toString(); // Show full error for unknown issues
      }
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
    } finally {
      _setLoading(false);
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            message,
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
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.isNotEmpty;
  }

  void _showForgotPasswordDialog(BuildContext context, double scale, double cardRadius, EdgeInsets cardPadding) {
    final emailController = TextEditingController();
    bool isLoading = false;
    final double cardSpacing = 12 * scale;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 400 * scale,
                  maxHeight: 500 * scale,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF13131A),
                      Color(0xFF1976D2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: cardPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14 * scale),
                              border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                            ),
                            child: Icon(
                              Icons.lock_reset_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 24 * scale,
                            ),
                          ),
                          SizedBox(width: 16 * scale),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Reset Password',
                                  style: GoogleFonts.prompt(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20 * scale,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4 * scale),
                                Text(
                                  'Enter your email to receive a reset link',
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

                      // Description Text
                      Container(
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF59E0B).withOpacity(0.1),
                              const Color(0xFFF59E0B).withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.2)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: const Color(0xFFF59E0B),
                              size: 20 * scale,
                            ),
                            SizedBox(width: 12 * scale),
                            Expanded(
                              child: Text(
                                'We\'ll send you a secure link to reset your password',
                                style: GoogleFonts.poppins(
                                  fontSize: 14 * scale,
                                  color: Colors.white.withOpacity(0.9),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: cardSpacing * 1.5),

                      // Email Input Field
                      TextField(
                        controller: emailController,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16 * scale,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 16 * scale,
                          ),
                          prefixIcon: Icon(
                            Icons.email_rounded,
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
                            borderSide: BorderSide(color: const Color(0xFFF59E0B).withOpacity(0.8), width: 2),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                        ),
                      ),
                      SizedBox(height: cardSpacing * 2),

                      // Action Buttons
                      Row(
                        children: [
                          // Cancel Button (Secondary)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                padding: EdgeInsets.symmetric(vertical: 16 * scale),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(cardRadius),
                                ),
                              ),
                              child: Text(
                                'Cancel',
                                style: GoogleFonts.poppins(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: cardSpacing),

                          // Send Reset Link Button (Primary)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isLoading ? null : () async {
                                final email = emailController.text.trim();
                                if (email.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please enter your email address',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: const Color(0xFFEF4444),
                                    ),
                                  );
                                  return;
                                }
                                
                                if (!_isValidEmail(email)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please enter a valid email address',
                                        style: GoogleFonts.poppins(),
                                      ),
                                      backgroundColor: const Color(0xFFEF4444),
                                    ),
                                  );
                                  return;
                                }

                                setState(() {
                                  isLoading = true;
                                });

                                try {
                                  await _firebaseService.sendPasswordResetEmail(email);
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Password reset email sent! Check your inbox.',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor: const Color(0xFF10B981),
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  String errorMessage = 'Failed to send reset email';
                                  if (e.toString().contains('user-not-found')) {
                                    errorMessage = 'No account found with this email address';
                                  } else if (e.toString().contains('invalid-email')) {
                                    errorMessage = 'Invalid email address';
                                  } else if (e.toString().contains('too-many-requests')) {
                                    errorMessage = 'Too many requests. Try again later';
                                  }
                                  
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          errorMessage,
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor: const Color(0xFFEF4444),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFF59E0B),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(vertical: 16 * scale),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(cardRadius),
                                ),
                                elevation: 4,
                                shadowColor: const Color(0xFFF59E0B).withOpacity(0.3),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      width: 24 * scale,
                                      height: 24 * scale,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3 * scale,
                                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : Text(
                                      'Send Reset Link',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16 * scale,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(20 * scale);
    final double sectionSpacing = 20 * scale;
    final double cardSpacing = 12 * scale;
    
    String roleLabel = widget.selectedRole[0].toUpperCase() + widget.selectedRole.substring(1);
    
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
                      // Back button and header
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(color: Colors.white.withOpacity(0.2)),
                            ),
                            child: IconButton(
                              onPressed: () {
                                // Navigate back to role selection screen properly
                                Navigator.of(context).pop();
                              },
                              icon: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22 * scale),
                              tooltip: 'Go Back',
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      SizedBox(height: sectionSpacing),
                      
                      // Welcome Section Header
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFB2FF00).withOpacity(0.15),
                              const Color(0xFFB2FF00).withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFB2FF00).withOpacity(0.1),
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
                                  color: const Color(0xFFB2FF00).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14 * scale),
                                  border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                                ),
                                child: Icon(Icons.login_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Welcome Back",
                                      style: GoogleFonts.prompt(
                                        fontSize: 28 * scale,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4 * scale),
                                    Text(
                                      'Sign in as $roleLabel',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16 * scale,
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
                      
                      // Login Form Card
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
                                    padding: EdgeInsets.all(10 * scale),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1976D2).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12 * scale),
                                      border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                                    ),
                                    child: Icon(Icons.person_rounded, color: const Color(0xFF1976D2), size: 20 * scale),
                                  ),
                                  SizedBox(width: 12 * scale),
                                  Text(
                                    'Login Details',
                                    style: GoogleFonts.prompt(
                                      fontWeight: FontWeight.w600, 
                                      fontSize: 18 * scale, 
                                      color: Colors.white
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: cardSpacing * 1.5),
                              
                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16 * scale,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter your email address',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 16 * scale,
                                  ),
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(8 * scale),
                                    padding: EdgeInsets.all(8 * scale),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1976D2).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10 * scale),
                                      border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.mail,
                                      color: const Color(0xFF1976D2),
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
                                    borderSide: BorderSide(color: const Color(0xFF1976D2), width: 2),
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
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!_isValidEmail(value)) {
                                    return 'Invalid email format';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: cardSpacing),
                              
                              // Password Field
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16 * scale,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Enter your password',
                                  hintStyle: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 16 * scale,
                                  ),
                                  prefixIcon: Container(
                                    margin: EdgeInsets.all(8 * scale),
                                    padding: EdgeInsets.all(8 * scale),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1976D2).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10 * scale),
                                      border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                                    ),
                                    child: Icon(
                                      CupertinoIcons.lock,
                                      color: const Color(0xFF1976D2),
                                      size: 18 * scale,
                                    ),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _obscurePassword = !_obscurePassword;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.all(8 * scale),
                                      padding: EdgeInsets.all(8 * scale),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10 * scale),
                                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                                      ),
                                      child: Icon(
                                        _obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
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
                                    borderSide: BorderSide(color: const Color(0xFF1976D2), width: 2),
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
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (!_isValidPassword(value)) {
                                    return 'Invalid password';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: cardSpacing),
                              
                              // Forgot Password
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () => _showForgotPasswordDialog(context, scale, cardRadius, cardPadding),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF59E0B).withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(16 * scale),
                                        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.help_outline_rounded,
                                            color: const Color(0xFFF59E0B),
                                            size: 14 * scale,
                                          ),
                                          SizedBox(width: 6 * scale),
                                          Text(
                                            "Forgot Password?",
                                            style: GoogleFonts.poppins(
                                              fontSize: 12 * scale,
                                              color: const Color(0xFFF59E0B),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: cardSpacing * 1.5),
                              
                              // Login Button
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
                                              'Signing In...',
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
                                          onTap: _login,
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.login_rounded,
                                                  color: const Color(0xFF13131A),
                                                  size: 20 * scale,
                                                ),
                                                SizedBox(width: 8 * scale),
                                                Text(
                                                  "Sign In",
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
                      
                      // Sign Up Link
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
                                "Don't have an account? ",
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14 * scale,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (widget.selectedRole == 'student') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => StudentRegistrationScreen()),
                                    );
                                  } else if (widget.selectedRole == 'instructor') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => InstructorRegistrationScreen()),
                                    );
                                  } else if (widget.selectedRole == 'admin') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (_) => AdminSignupScreen()),
                                    );
                                  }
                                },
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
                                    'Sign Up',
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
} 