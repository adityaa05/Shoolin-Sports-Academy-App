import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_provider.dart';
import '../services/firebase_service.dart';
import '../models/instructor.dart';
import 'instructor_dashboard.dart';
import 'package:google_fonts/google_fonts.dart';

class InstructorLoginScreen extends StatefulWidget {
  final bool isOnline;
  const InstructorLoginScreen({Key? key, this.isOnline = true}) : super(key: key);

  @override
  State<InstructorLoginScreen> createState() => _InstructorLoginScreenState();
}

class _InstructorLoginScreenState extends State<InstructorLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!widget.isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No internet connection. Please try again when online.'), backgroundColor: Colors.red),
        );
      }
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firebaseService = FirebaseService();
      final provider = Provider.of<AppProvider>(context, listen: false);
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      // Login
      final user = await firebaseService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (user != null) {
        // Check if user is instructor
        final isInstructor = await firebaseService.isInstructor(user.user!.uid);
        print('Instructor login debug: isInstructor = $isInstructor');
        if (!isInstructor) {
          throw Exception('This account is not registered as an instructor');
        }

        // Get instructor details
        final instructorDetails = await firebaseService.getInstructorDetails(user.user!.uid);
        print('Instructor login debug: instructorDetails = $instructorDetails');
        if (instructorDetails != null) {
          final instructor = Instructor.fromMap({...instructorDetails, 'id': user.user!.uid});
          provider.setCurrentInstructor(instructor);
          provider.setCurrentUserId(user.user!.uid);
          provider.setInstructorMode(true);
          
          // Ensure instructor document exists for persistence
          await firebaseService.ensureInstructorDocument(user.user!.uid, instructorDetails);
          print('Instructor login debug: instructor document ensured');
          
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const InstructorDashboard()),
            );
          }
        } else {
          throw Exception('Instructor details not found');
        }
      }
    } catch (e) {
      String errorMessage = 'Error: ${e.toString()}';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Email already in use';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email address';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(20 * scale);
    final double cardSpacing = 12 * scale;
    
    final emailController = TextEditingController(text: _emailController.text);
    bool isLoading = false;

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
                                
                                final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                if (!emailRegex.hasMatch(email)) {
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
                                  await FirebaseService().sendPasswordResetEmail(email);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Login'),
        backgroundColor: const Color(0xFFE74C3C),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports_martial_arts,
                size: 80,
                color: Color(0xFFE74C3C),
              ),
              const SizedBox(height: 24),
              Text(
                'Welcome Back, Instructor!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFE74C3C),
                ),
              ),
              const SizedBox(height: 32),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
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
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showForgotPasswordDialog(context),
                  child: const Text('Forgot Password?'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Back to Main Login',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 