import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_service.dart';
import '../models/student.dart';
import '../constants/batches.dart';
import '../widgets/animated_button.dart';
import 'package:google_fonts/google_fonts.dart';

class StudentRegistrationScreen extends StatefulWidget {
  final bool isOnline;
  const StudentRegistrationScreen({Key? key, this.isOnline = true}) : super(key: key);

  @override
  State<StudentRegistrationScreen> createState() => _StudentRegistrationScreenState();
}

class _StudentRegistrationScreenState extends State<StudentRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _feeController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final Set<String> _selectedBatches = {};
  String _selectedClassType = 'kickboxing';
  int _paymentDurationMonths = 1;
  final TextEditingController _customDurationController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _feeController.dispose();
    _customDurationController.dispose();
    super.dispose();
  }

  void _setLoading(bool loading) {
    setState(() {
      _isLoading = loading;
    });
  }

  void _showBatchSelectionDialog() {
    final tempSelected = Set<String>.from(_selectedBatches);
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(20 * scale);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: const Color(0xFF13131A),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF13131A),
                    const Color(0xFF1976D2).withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(cardRadius),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Padding(
                padding: cardPadding,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dialog Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB2FF00).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14 * scale),
                            border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                          ),
                          child: Icon(Icons.schedule_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                        ),
                        SizedBox(width: 16 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Batches',
                                style: GoogleFonts.prompt(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18 * scale,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4 * scale),
                              Text(
                                'Choose the batches you want to join',
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
                    SizedBox(height: 20 * scale),
                    Container(
                      constraints: BoxConstraints(maxHeight: 300 * scale),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: kBatches.length,
                        itemBuilder: (context, index) {
                          final batch = kBatches[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 8 * scale),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0.04),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12 * scale),
                              border: Border.all(color: Colors.white.withOpacity(0.15)),
                            ),
                            child: CheckboxListTile(
                              title: Text(
                                batch,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              value: tempSelected.contains(batch),
                              onChanged: (value) {
                                setDialogState(() {
                                  if (value == true) {
                                    tempSelected.add(batch);
                                  } else {
                                    tempSelected.remove(batch);
                                  }
                                });
                              },
                              activeColor: const Color(0xFFB2FF00),
                              checkColor: const Color(0xFF13131A),
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 24 * scale),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w600,
                                fontSize: 14 * scale,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFB2FF00),
                                const Color(0xFFA3E635),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12 * scale),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB2FF00).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedBatches
                                  ..clear()
                                  ..addAll(tempSelected);
                              });
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              'Confirm',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF13131A),
                                fontWeight: FontWeight.w600,
                                fontSize: 14 * scale,
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
      ),
    );
  }

  Future<void> _register() async {
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

    if (_selectedBatches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select at least one batch',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Passwords do not match',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    _setLoading(true);

    try {
      final firebaseService = FirebaseService();
      
      // Sanitize input
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final fee = _feeController.text.trim();
      final password = _passwordController.text;

      // Create student object
      int duration = _paymentDurationMonths == -1 ? int.tryParse(_customDurationController.text) ?? 1 : _paymentDurationMonths;
      final student = Student(
        name: name,
        email: email,
        phone: phone,
        batches: _selectedBatches.toList(),
        isActive: true,
        createdAt: DateTime.now(),
        classType: _selectedBatches.isNotEmpty ? _selectedBatches.first : '',
        monthlyFee: double.tryParse(fee) ?? 0.0,
        paymentDurationMonths: duration,
        lastPaymentDate: DateTime.now(),
      );

      // Register student
      await firebaseService.registerStudent(
        student,
        email,
        password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Registration successful! You can now login.',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      String errorMessage = 'Registration failed';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Email is already registered';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email address';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak';
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
                            'Student Registration',
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
                                child: Icon(Icons.person_add_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Join Our Academy",
                                      style: GoogleFonts.prompt(
                                        fontSize: 24 * scale,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4 * scale),
                                    Text(
                                      'Create your student account and start your journey',
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
                                          'Student Details',
                                          style: GoogleFonts.prompt(
                                            fontWeight: FontWeight.w600, 
                                            fontSize: 18 * scale, 
                                            color: Colors.white
                                          ),
                                        ),
                                        SizedBox(height: 4 * scale),
                                        Text(
                                          'Fill in your personal information',
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
                              SizedBox(height: cardSpacing),
                              
                              // Phone Field
                              _buildInputField(
                                controller: _phoneController,
                                hintText: 'Enter your phone number',
                                icon: Icons.phone_rounded,
                                color: const Color(0xFF1976D2),
                                scale: scale,
                                cardRadius: cardRadius,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  final phone = value.trim();
                                  if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
                                    return 'Please enter a valid 10-digit phone number';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: cardSpacing * 1.5),
                              
                              // Batch Selection Section
                              _buildSectionHeader(
                                'Batch Selection',
                                Icons.schedule_rounded,
                                const Color(0xFFF59E0B),
                                scale,
                              ),
                              SizedBox(height: cardSpacing),
                              
                              // Batch Selection Field
                              GestureDetector(
                                onTap: () => _showBatchSelectionDialog(),
                                child: Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(minHeight: 56 * scale),
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
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 12.0 * scale),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          margin: EdgeInsets.all(8 * scale),
                                          padding: EdgeInsets.all(8 * scale),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10 * scale),
                                            border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                                          ),
                                          child: Icon(
                                            Icons.schedule_rounded,
                                            color: const Color(0xFFF59E0B),
                                            size: 18 * scale,
                                          ),
                                        ),
                                        SizedBox(width: 12 * scale),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (_selectedBatches.isNotEmpty) ...[
                                                Text(
                                                  'Selected Batches:',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 12 * scale,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                                SizedBox(height: 4 * scale),
                                                Wrap(
                                                  spacing: 4 * scale,
                                                  runSpacing: 4 * scale,
                                                  children: _selectedBatches.map((batch) {
                                                    return Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFB2FF00).withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(12 * scale),
                                                        border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                                                      ),
                                                      child: Text(
                                                        batch,
                                                        style: GoogleFonts.poppins(
                                                          color: const Color(0xFFB2FF00),
                                                          fontSize: 12 * scale,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ),
                                              ] else ...[
                                                Text(
                                                  'Select Batches',
                                                  style: GoogleFonts.poppins(
                                                    color: Colors.white.withOpacity(0.7),
                                                    fontSize: 16 * scale,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 8 * scale),
                                        Icon(Icons.arrow_drop_down_rounded, color: Colors.white, size: 20 * scale),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: cardSpacing),
                              
                              // Payment Duration Section
                              _buildSectionHeader(
                                'Payment Duration',
                                Icons.calendar_month_rounded,
                                const Color(0xFF8B5CF6),
                                scale,
                              ),
                              SizedBox(height: cardSpacing),
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButtonFormField<int>(
                                      value: _paymentDurationMonths,
                                      items: [
                                        DropdownMenuItem(value: 1, child: Text('Monthly (1 month)', style: GoogleFonts.poppins(fontSize: 14 * scale))),
                                        DropdownMenuItem(value: 3, child: Text('Quarterly (3 months)', style: GoogleFonts.poppins(fontSize: 14 * scale))),
                                        DropdownMenuItem(value: 6, child: Text('Half-yearly (6 months)', style: GoogleFonts.poppins(fontSize: 14 * scale))),
                                        DropdownMenuItem(value: 12, child: Text('Yearly (12 months)', style: GoogleFonts.poppins(fontSize: 14 * scale))),
                                        DropdownMenuItem(value: -1, child: Text('Custom', style: GoogleFonts.poppins(fontSize: 14 * scale))),
                                      ],
                                      onChanged: (val) {
                                        setState(() {
                                          if (val == -1) {
                                            _paymentDurationMonths = -1;
                                          } else {
                                            _paymentDurationMonths = val ?? 1;
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Select payment duration',
                                        hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5), fontSize: 14 * scale),
                                        filled: true,
                                        fillColor: Colors.white.withOpacity(0.05),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(cardRadius),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(cardRadius),
                                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(cardRadius),
                                          borderSide: BorderSide(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                                      ),
                                      dropdownColor: const Color(0xFF13131A),
                                      icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.7), size: 22 * scale),
                                      isExpanded: true,
                                      menuMaxHeight: 250 * scale,
                                    ),
                                  ),
                                  if (_paymentDurationMonths == -1) ...[
                                    SizedBox(width: 12 * scale),
                                    SizedBox(
                                      width: 80 * scale,
                                      child: TextFormField(
                                        controller: _customDurationController,
                                        keyboardType: TextInputType.number,
                                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                                        decoration: InputDecoration(
                                          hintText: 'Months',
                                          hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.5), fontSize: 14 * scale),
                                          filled: true,
                                          fillColor: Colors.white.withOpacity(0.05),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(cardRadius),
                                            borderSide: BorderSide.none,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(cardRadius),
                                            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(cardRadius),
                                            borderSide: BorderSide(color: const Color(0xFF8B5CF6).withOpacity(0.5)),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 12 * scale),
                                        ),
                                        validator: (value) {
                                          if (_paymentDurationMonths == -1) {
                                            final v = int.tryParse(value ?? '');
                                            if (v == null || v < 1) {
                                              return 'Enter months';
                                            }
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              SizedBox(height: cardSpacing),
                              // Fee Field (update label)
                              _buildInputField(
                                controller: _feeController,
                                hintText: _paymentDurationMonths == 1 ? 'Enter monthly fee amount' : 'Enter total fee for selected duration',
                                icon: Icons.attach_money_rounded,
                                color: const Color(0xFF1976D2),
                                scale: scale,
                                cardRadius: cardRadius,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please enter the fee';
                                  }
                                  final fee = double.tryParse(value.trim());
                                  if (fee == null || fee <= 0) {
                                    return 'Please enter a valid fee';
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
                              SizedBox(height: cardSpacing),
                              
                              // Confirm Password Field
                              _buildPasswordField(
                                controller: _confirmPasswordController,
                                hintText: 'Confirm your password',
                                icon: Icons.lock_rounded,
                                color: const Color(0xFF1976D2),
                                scale: scale,
                                cardRadius: cardRadius,
                                obscureText: _obscureConfirmPassword,
                                onToggleVisibility: () {
                                  setState(() {
                                    _obscureConfirmPassword = !_obscureConfirmPassword;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Please confirm your password';
                                  }
                                  if (value.trim() != _passwordController.text.trim()) {
                                    return 'Passwords do not match';
                                  }
                                  return null;
                                },
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
                                          onTap: _register,
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.person_add_rounded,
                                                  color: const Color(0xFF13131A),
                                                  size: 20 * scale,
                                                ),
                                                SizedBox(width: 8 * scale),
                                                Text(
                                                  "Create Account",
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