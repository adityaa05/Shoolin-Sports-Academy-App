import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_provider.dart';
import '../models/student.dart';
import '../models/attendance.dart';
import '../models/holiday.dart';
import '../models/instructor.dart';
import '../constants/batches.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/animated_button.dart';
import '../utils/attendance_permissions.dart';
import 'package:table_calendar/table_calendar.dart';

// 1. Add color constants at the top of the file (if not already present)
const kOrange = Color(0xFFF59E0B);
const kGreen = Color(0xFF10B981);
const kRed = Color(0xFFEF4444);
const kBlue = Color(0xFF1976D2);
const kPurple = Color(0xFF8B5CF6);
const kLime = Color(0xFFB2FF00);
const kGray = Color(0xFF6B7280);
const kCyan = Color(0xFF00BCD4);

class InstructorDashboard extends StatefulWidget {
  const InstructorDashboard({super.key});

  @override
  State<InstructorDashboard> createState() => _InstructorDashboardState();
}

class _InstructorDashboardState extends State<InstructorDashboard> {
  int _selectedIndex = 0;
  String? _selectedBatch;
  bool _isLoading = false;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final currentUser = FirebaseAuth.instance.currentUser;
      
      print('InstructorDashboard debug: Initializing dashboard');
      print('InstructorDashboard debug: Current user = ${currentUser?.uid}');
      print('InstructorDashboard debug: Current instructor = ${provider.currentInstructor?.name}');
      
      // Load current instructor data if not already loaded
      if (currentUser != null && provider.currentInstructor == null) {
        print('InstructorDashboard debug: Loading current instructor data');
        await provider.loadCurrentInstructor(currentUser.uid);
        print('InstructorDashboard debug: Instructor loaded = ${provider.currentInstructor?.name}');
      }
      
      await provider.initializeData();
      print('InstructorDashboard debug: Data initialization complete');
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(20 * scale);
    final double sectionSpacing = 20 * scale;
    final double cardSpacing = 12 * scale;
    
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState(scale, cardRadius, cardPadding);
        }

        final instructor = provider.currentInstructor;
        if (instructor == null) {
          return _buildErrorState(scale, cardRadius, cardPadding);
        }

        // Get assigned batches
        final assignedBatches = instructor.assignedBatches;
        print('InstructorDashboard Debug:');
        print('Instructor: ${instructor.name}');
        print('Assigned batches: $assignedBatches');
        print('Selected batch: $_selectedBatch');
        
        if (assignedBatches.isEmpty) {
          return Scaffold(
            extendBody: true,
            backgroundColor: const Color(0xFF13131A),
            appBar: AppBar(
              backgroundColor: const Color(0xFF13131A),
              elevation: 0,
              title: Text(
                'Instructor Dashboard',
                style: GoogleFonts.prompt(
                  fontWeight: FontWeight.w600,
                  fontSize: 20 * scale,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.white, size: 22 * scale),
                  tooltip: 'Logout',
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => route.settings.name == '/');
                    }
                  },
                ),
              ],
            ),
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
                    child: Container(
                      padding: cardPadding,
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
              child: Column(
                        mainAxisSize: MainAxisSize.min,
                children: [
                          Container(
                            padding: EdgeInsets.all(16 * scale),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14 * scale),
                              border: Border.all(color: Colors.orange.withOpacity(0.3)),
                            ),
                            child: Icon(
                              Icons.assignment_ind_rounded,
                              color: Colors.orange,
                              size: 32 * scale,
                            ),
                          ),
                          SizedBox(height: 16 * scale),
                  Text(
                    'No batches assigned yet',
                            style: GoogleFonts.prompt(
                              fontWeight: FontWeight.w600,
                              fontSize: 18 * scale,
                              color: Colors.white,
                  ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8 * scale),
                  Text(
                    'Please contact the admin to get assigned to batches',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14 * scale,
                            ),
                    textAlign: TextAlign.center,
                  ),
                          SizedBox(height: 16 * scale),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                            decoration: BoxDecoration(
                              color: Colors.cyan.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20 * scale),
                              border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                            ),
                            child: Text(
                              'Contact Admin',
                              style: GoogleFonts.poppins(
                                color: kCyan,
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w600,
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
          );
        }

        // Set default selected batch if none selected
        if (_selectedBatch == null && assignedBatches.isNotEmpty) {
          _selectedBatch = assignedBatches.first;
        }

        // Initialize screens list only once
        if (_screens.isEmpty) {
          _screens.addAll([
            InstructorHomeScreen(
              instructor: instructor,
              selectedBatch: _selectedBatch,
            ),
            InstructorAttendanceScreen(
              instructor: instructor,
              selectedBatch: _selectedBatch,
            ),
            InstructorHolidaysScreen(
              instructor: instructor,
              selectedBatch: _selectedBatch,
            ),
            InstructorProfileScreen(instructor: instructor),
          ]);
        } else {
          // Update the selectedBatch in existing screens
          _screens.clear();
          _screens.addAll([
            InstructorHomeScreen(
              instructor: instructor,
              selectedBatch: _selectedBatch,
            ),
            InstructorAttendanceScreen(
              instructor: instructor,
              selectedBatch: _selectedBatch,
            ),
            InstructorHolidaysScreen(
              instructor: instructor,
              selectedBatch: _selectedBatch,
            ),
            InstructorProfileScreen(instructor: instructor),
          ]);
        }

        return Scaffold(
          extendBody: true,
          backgroundColor: const Color(0xFF13131A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF13131A),
            elevation: 0,
            title: Text(
              'Instructor Dashboard',
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.w600,
                fontSize: 20 * scale,
                color: Colors.white,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.white, size: 22 * scale),
                tooltip: 'Logout',
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => route.settings.name == '/');
                  }
                },
              ),
            ],
          ),
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
            child: Column(
              children: [
                // Batch Selector Card - only show if there are assigned batches and not on profile screen
                if (assignedBatches.isNotEmpty && _selectedIndex != 3)
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
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.cyan.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12 * scale),
                                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                                ),
                                child: Icon(Icons.group_rounded, color: Colors.cyan, size: 20 * scale),
                              ),
                              SizedBox(width: 12 * scale),
                              Text(
                                'Select Batch',
                                style: GoogleFonts.prompt(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16 * scale,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16 * scale),
                          DropdownButtonFormField<String>(
                            value: _selectedBatch,
                            isExpanded: true,
                            items: assignedBatches.map((batch) => DropdownMenuItem<String>(
                              value: batch,
                              child: Text(
                                batch,
                                style: GoogleFonts.poppins(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )).toList(),
                            selectedItemBuilder: (context) => assignedBatches.map((batch) => Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                batch,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedBatch = value;
                              });
                            },
                            dropdownColor: const Color(0xFF13131A),
                            style: GoogleFonts.poppins(color: Colors.white, fontSize: 16 * scale, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                              labelText: 'Choose your batch',
                              labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 16 * scale, fontWeight: FontWeight.w500),
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
                              filled: true,
                              fillColor: Colors.white.withOpacity(0.1),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                            ),
                            icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: _screens.isNotEmpty ? _screens[_selectedIndex] : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF13131A).withOpacity(0.95),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24 * scale),
                topRight: Radius.circular(24 * scale),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
              selectedItemColor: const Color(0xFFB2FF00),
              unselectedItemColor: Colors.grey[400],
              selectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 11 * scale),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11 * scale),
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard_rounded, size: 22 * scale),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.checklist_rounded, size: 22 * scale),
                  label: 'Attendance',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.event_busy_rounded, size: 22 * scale),
                  label: 'Holidays',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_rounded, size: 22 * scale),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(double scale, double cardRadius, EdgeInsets cardPadding) {
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
              child: Container(
                padding: cardPadding,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14 * scale),
                        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                      ),
                      child: CircularProgressIndicator(
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.cyan),
                        strokeWidth: 3 * scale,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      'Loading your dashboard...',
                      style: GoogleFonts.prompt(
                        color: Colors.white,
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Please wait while we fetch your data',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14 * scale,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(double scale, double cardRadius, EdgeInsets cardPadding) {
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
              child: Container(
                padding: cardPadding,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14 * scale),
                        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: const Color(0xFFEF4444),
                        size: 32 * scale,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      'Instructor not found',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.w600,
                        fontSize: 18 * scale,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Please check your account details or contact support.',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14 * scale,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16 * scale),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                      decoration: BoxDecoration(
                        color: Colors.cyan.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20 * scale),
                        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                      ),
                      child: Text(
                        'Contact Support',
                        style: GoogleFonts.poppins(
                                                        color: kCyan,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w600,
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
    );
  }
}

class InstructorHomeScreen extends StatelessWidget {
  final Instructor instructor;
  final String? selectedBatch;

  const InstructorHomeScreen({super.key, required this.instructor, this.selectedBatch});

  @override
  Widget build(BuildContext context) {
    return _InstructorHomeScreenContent(
      instructor: instructor,
      selectedBatch: selectedBatch,
    );
  }
}

class _InstructorHomeScreenContent extends StatefulWidget {
  final Instructor instructor;
  final String? selectedBatch;

  const _InstructorHomeScreenContent({required this.instructor, this.selectedBatch});

  @override
  State<_InstructorHomeScreenContent> createState() => _InstructorHomeScreenContentState();
}

class _InstructorHomeScreenContentState extends State<_InstructorHomeScreenContent> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    
    final cardRadius = 18 * scale;
    final cardPadding = EdgeInsets.all(20 * scale);
    final sectionSpacing = 20 * scale;
    final cardSpacing = 12 * scale;
    
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final batchStudents = provider.students
            .where((s) => s.isInBatch(widget.selectedBatch!))
            .toList();
        
        // Get today's attendance for the batch
        final today = DateTime.now();
        final todayAttendance = provider.attendance.where((a) {
          return a.batch == widget.selectedBatch && 
                 a.date.year == today.year &&
                 a.date.month == today.month &&
                 a.date.day == today.day;
        }).toList();

        // Show skeleton loading if data is loading
        if (provider.isLoading) {
          return Container(
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
                    child: _buildSkeletonLoading(scale, cardRadius, cardPadding, cardSpacing),
                  ),
                ),
              ),
            ),
          );
        }

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF13131A), Color(0xFF1976D2)],
            ),
          ),
          child: RefreshIndicator(
            color: Colors.white,
            backgroundColor: const Color(0xFF13131A),
          onRefresh: () async {
              try {
            await provider.loadStudents();
            await provider.loadAttendanceByDate(DateTime.now());
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Failed to refresh data. Please try again.',
                        style: GoogleFonts.poppins(),
                      ),
                      backgroundColor: const Color(0xFFEF4444),
                    ),
                  );
                }
              }
            },
            child: SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 20.0 * scale),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: sectionSpacing),
                        // Welcome Card
                        _buildWelcomeCard(context, scale, cardRadius, cardPadding),
                        SizedBox(height: sectionSpacing),

                        // Holiday Alert
                        ...(() {
                          final holidayAlert = _buildHolidayAlert(context, provider, scale, cardRadius);
                          return holidayAlert != null 
                            ? [holidayAlert, SizedBox(height: sectionSpacing)]
                            : <Widget>[];
                        })(),

                        // Today's Overview Section
                        _buildOverviewSection(context, provider, batchStudents, todayAttendance, scale, cardRadius, cardPadding, cardSpacing),
                        SizedBox(height: sectionSpacing),

                        // Statistics Cards Section
                        _buildStatisticsSection(context, provider, batchStudents, todayAttendance, scale, cardRadius, cardPadding, cardSpacing),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeCard(BuildContext context, double scale, double cardRadius, EdgeInsets cardPadding) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);

    return Semantics(
      label: 'Welcome card for ${widget.instructor.name}',
      child: Container(
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
          border: Border.all(color: Colors.white.withOpacity(0.1)),
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
                        Row(
                          children: [
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: Colors.cyan.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14 * scale),
                      border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                    ),
                    child: Icon(Icons.person_rounded, color: Colors.cyan, size: 24 * scale),
                  ),
                  SizedBox(width: 16 * scale),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                          greeting,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16 * scale,
                            color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  Text(
                                    widget.instructor.name,
                          style: GoogleFonts.prompt(
                            fontWeight: FontWeight.w700,
                            fontSize: 24 * scale,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                                      ),
                                    ),
                                ],
              ),
              SizedBox(height: 16 * scale),
              // Instructor Info Chips
              Wrap(
                spacing: 8 * scale,
                runSpacing: 8 * scale,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Instructor ID: ${widget.instructor.id?.substring(0, 8).toUpperCase()}...',
                      style: GoogleFonts.poppins(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                                                      color: kBlue,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16 * scale),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Text(
                      'Active Instructor',
                      style: GoogleFonts.poppins(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                                                      color: kGreen,
                      ),
                    ),
                  ),
                  if (widget.selectedBatch != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16 * scale),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.selectedBatch!,
                        style: GoogleFonts.poppins(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: kOrange,
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
  }



  Widget? _buildHolidayAlert(BuildContext context, AppProvider provider, double scale, double cardRadius) {
    final today = DateTime.now();
    final upcomingHolidays = provider.holidays.where((h) {
      final diff = h.date.difference(today).inDays;
      return diff >= 0 && diff <= 2;
    }).toList();
    upcomingHolidays.sort((a, b) => a.date.compareTo(b.date));
    
    if (upcomingHolidays.isEmpty) return null;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withOpacity(0.15),
            Colors.red.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: Colors.orange.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20 * scale),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14 * scale),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Icon(Icons.event_busy_rounded, color: Colors.orange, size: 26 * scale),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                    'Upcoming Holiday!',
                    style: GoogleFonts.prompt(
                      color: kOrange,
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * scale,
                    ),
                  ),
                  SizedBox(height: 6 * scale),
                  ...upcomingHolidays.map((h) => Padding(
                    padding: EdgeInsets.only(bottom: 3 * scale),
                    child: Text(
                      '${DateFormat('EEE, MMM d').format(h.date)}: ${h.reason} (${h.batch == null ? 'All batches' : 'Batch: ${h.batch}'})',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13 * scale,
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context, AppProvider provider, List<Student> batchStudents, List<Attendance> todayAttendance, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8 * scale),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: 20 * scale,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12 * scale),
            Flexible(
              child: Text(
                  'Today\'s Overview',
                style: GoogleFonts.prompt(
                  fontSize: 20 * scale,
                    fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: cardSpacing),
        
        // Stats Cards
                Row(
                  children: [
                    Expanded(
              child: Container(
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
                padding: cardPadding,
                          child: Column(
                            children: [
                    Container(
                      padding: EdgeInsets.all(8 * scale),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                      child: Icon(
                        Icons.people_rounded,
                        size: 24 * scale,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                              Text(
                                '${batchStudents.length}',
                      style: GoogleFonts.prompt(
                        fontSize: 28 * scale,
                                  fontWeight: FontWeight.bold,
                        color: Colors.white,
                                ),
                              ),
                              Text(
                                'Total Students',
                      style: GoogleFonts.poppins(
                        fontSize: 14 * scale,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
            SizedBox(width: cardSpacing),
                    Expanded(
              child: Container(
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
                padding: cardPadding,
                          child: Column(
                            children: [
                    Container(
                      padding: EdgeInsets.all(8 * scale),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 24 * scale,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8 * scale),
                              Text(
                                '${todayAttendance.where((a) => a.isPresent).length}',
                      style: GoogleFonts.prompt(
                        fontSize: 28 * scale,
                                  fontWeight: FontWeight.bold,
                        color: Colors.white,
                                ),
                              ),
                              Text(
                                'Present Today',
                      style: GoogleFonts.poppins(
                        fontSize: 14 * scale,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatisticsSection(BuildContext context, AppProvider provider, List<Student> batchStudents, List<Attendance> todayAttendance, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    // Calculate statistics
    final totalStudents = batchStudents.length;
    final presentToday = todayAttendance.where((a) => a.isPresent).length;
    final absentToday = todayAttendance.where((a) => !a.isPresent).length;
    final attendanceRate = totalStudents > 0 ? (presentToday / totalStudents * 100).round() : 0;
    
    // Get this month's attendance data
    final thisMonth = DateTime.now();
    final thisMonthAttendance = provider.attendance.where((a) {
      return a.batch == widget.selectedBatch && 
             a.date.year == thisMonth.year &&
             a.date.month == thisMonth.month;
    }).toList();
    
    final totalSessionsThisMonth = thisMonthAttendance.length > 0 ? 
        thisMonthAttendance.map((a) => a.date.day).toSet().length : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8 * scale),
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 20 * scale,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12 * scale),
            Flexible(
              child: Text(
                'Statistics',
                style: GoogleFonts.prompt(
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: cardSpacing),
        
        // Statistics Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: cardSpacing,
          mainAxisSpacing: cardSpacing,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              context,
              'Attendance Rate',
              '$attendanceRate%',
              Icons.trending_up_rounded,
              Colors.green,
              scale,
              cardRadius,
            ),
            _buildStatCard(
              context,
              'Absent Today',
              '$absentToday',
              Icons.cancel_rounded,
              kRed,
              scale,
              cardRadius,
            ),
            _buildStatCard(
              context,
              'This Month Sessions',
              '$totalSessionsThisMonth',
              Icons.calendar_month_rounded,
              Colors.blue,
              scale,
              cardRadius,
            ),
            _buildStatCard(
              context,
              'Batch Students',
              '$totalStudents',
              Icons.group_rounded,
              Colors.orange,
              scale,
              cardRadius,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, double scale, double cardRadius) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final baseFontSize = availableHeight < 80 ? 16.0 : 20.0;
        final titleFontSize = availableHeight < 80 ? 10.0 : 12.0;
        final iconSize = availableHeight < 80 ? 20.0 : 26.0;
        final iconPadding = availableHeight < 80 ? 8.0 : 12.0;
        final cardPadding = availableHeight < 80 ? 12.0 : 20.0;
        final spacing = availableHeight < 80 ? 6.0 : 12.0;
        return Container(
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
            padding: EdgeInsets.all(cardPadding * scale),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(iconPadding * scale),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.25), color.withOpacity(0.15)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular((iconPadding + 2) * scale),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Icon(icon, size: iconSize * scale, color: color),
                ),
                SizedBox(height: spacing * scale),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      fontSize: baseFontSize * scale,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: titleFontSize * scale,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  String _getGreeting(int hour) {
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  Widget _buildSkeletonLoading(double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Welcome card skeleton
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
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          padding: cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  children: [
                  Container(
                    width: 48 * scale,
                    height: 48 * scale,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                    Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 100 * scale,
                          height: 16 * scale,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8 * scale),
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        Container(
                          width: 150 * scale,
                          height: 24 * scale,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8 * scale),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16 * scale),
              Wrap(
                spacing: 8 * scale,
                runSpacing: 8 * scale,
                children: List.generate(3, (index) => Container(
                  width: 80 * scale,
                  height: 24 * scale,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16 * scale),
                  ),
                )),
              ),
            ],
          ),
        ),
        SizedBox(height: 20 * scale),
        
        // Search field skeleton
        Container(
          height: 60 * scale,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(cardRadius),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
        ),
        SizedBox(height: 20 * scale),
        
        // Stats cards skeleton
        Row(
          children: [
                    Expanded(
              child: Container(
                height: 120 * scale,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),
            SizedBox(width: cardSpacing),
            Expanded(
              child: Container(
                height: 120 * scale,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
              ),
                ),
              ],
            ),
        SizedBox(height: 20 * scale),
        
        // Action buttons skeleton
        Row(
          children: [
            Expanded(
              child: Container(
                height: 60 * scale,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),
            SizedBox(width: cardSpacing),
            Expanded(
              child: Container(
                height: 60 * scale,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }


}

class InstructorAttendanceScreen extends StatefulWidget {
  final Instructor instructor;
  final String? selectedBatch;

  const InstructorAttendanceScreen({super.key, required this.instructor, this.selectedBatch});

  @override
  State<InstructorAttendanceScreen> createState() => _InstructorAttendanceScreenState();
}

class _InstructorAttendanceScreenState extends State<InstructorAttendanceScreen> {
  bool _isLoading = false;
  final Map<String, bool> _attendanceMap = {};
  final Set<String> _selectedStudents = {};
  bool _isBulkMode = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTodayAttendance();
  }

  Future<void> _loadTodayAttendance() async {
    setState(() => _isLoading = true);
    
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final today = DateTime.now();
      
      // Load today's attendance for the batch
      await provider.loadAttendanceByDate(today);
      
      // Initialize attendance map
      final batchStudents = provider.students.where((s) => s.isInBatch(widget.selectedBatch!)).toList();
      final todayAttendance = provider.attendance.where((a) {
        return a.batch == widget.selectedBatch && 
               a.date.year == today.year &&
               a.date.month == today.month &&
               a.date.day == today.day;
      }).toList();

      for (final student in batchStudents) {
        final existingAttendance = todayAttendance.where((a) => a.studentId == student.id).firstOrNull;
        _attendanceMap[student.id!] = existingAttendance?.isPresent ?? false;
      }
    } catch (e) {
      print('Error loading attendance: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveAttendance() async {
    if (widget.selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a batch first')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      final today = DateTime.now();
      for (final entry in _attendanceMap.entries) {
        final attendance = Attendance(
          id: null,
          studentId: entry.key,
          date: today,
          isPresent: entry.value,
          batch: widget.selectedBatch!,
          status: entry.value ? AttendanceStatus.present : AttendanceStatus.absent,
          markedByType: AttendanceMarkedBy.instructor,
          markedAt: today,
          markedByUserId: widget.instructor.id!,
          markedBy: widget.instructor.name,
        );
        await provider.markAttendance(attendance);
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Attendance saved successfully!')),
        );
        _exitBulkMode();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to save attendance: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _toggleBulkMode() {
    setState(() {
      _isBulkMode = !_isBulkMode;
      if (!_isBulkMode) {
        _selectedStudents.clear();
      }
    });
  }

  void _exitBulkMode() {
    setState(() {
      _isBulkMode = false;
      _selectedStudents.clear();
    });
  }

  void _selectAllStudents() {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final batchStudents = provider.students.where((s) => s.isInBatch(widget.selectedBatch!)).toList();
    setState(() {
      _selectedStudents.addAll(batchStudents.map((s) => s.id!));
    });
  }

  void _deselectAllStudents() {
    setState(() {
      _selectedStudents.clear();
    });
  }

  void _markSelectedAsPresent() {
    setState(() {
      for (final studentId in _selectedStudents) {
        _attendanceMap[studentId] = true;
      }
    });
  }

  void _markSelectedAsAbsent() {
    setState(() {
      for (final studentId in _selectedStudents) {
        _attendanceMap[studentId] = false;
      }
    });
  }

  void _toggleStudentSelection(String studentId) {
    setState(() {
      if (_selectedStudents.contains(studentId)) {
        _selectedStudents.remove(studentId);
      } else {
        _selectedStudents.add(studentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(20 * scale);
    final double sectionSpacing = 20 * scale;
    final double cardSpacing = 12 * scale;
    
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final batchStudents = provider.students
            .where((s) => s.isInBatch(widget.selectedBatch!) &&
                (s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                 s.email.toLowerCase().contains(_searchQuery.toLowerCase())))
            .toList();
        
        if (_isLoading) {
          return _buildLoadingState(scale, cardRadius, cardPadding);
        }

        if (widget.selectedBatch == null) {
          return _buildNoBatchSelectedState(scale, cardRadius, cardPadding);
        }

        if (batchStudents.isEmpty) {
          return _buildNoStudentsState(scale, cardRadius, cardPadding);
        }

        return Scaffold(
          extendBody: true,
          backgroundColor: const Color(0xFF13131A),
          // Removed appBar for consistency with main dashboard
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
            child: Column(
              children: [
                SizedBox(height: sectionSpacing),
                      // Header Section with integrated search
                      _buildAttendanceHeaderSection(context, scale, cardRadius, cardPadding, cardSpacing, sectionSpacing),
                      
                      // Students List Section
                      SizedBox(height: sectionSpacing),
                      Expanded(
                        child: _buildStudentsListSection(context, batchStudents, scale, cardRadius, cardPadding, cardSpacing, sectionSpacing),
                      ),
                      
                      // Action Buttons Section
                      SizedBox(height: sectionSpacing),
                      _buildActionButtonsSection(context, scale, cardRadius, cardPadding, cardSpacing, sectionSpacing),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState(double scale, double cardRadius, EdgeInsets cardPadding) {
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
              child: Container(
                padding: cardPadding,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
              children: [
                    SizedBox(
                      width: 48 * scale,
                      height: 48 * scale,
                      child: CircularProgressIndicator(
                        strokeWidth: 4 * scale,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan.shade300),
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                      Text(
                      'Loading attendance data...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoBatchSelectedState(double scale, double cardRadius, EdgeInsets cardPadding) {
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
              child: Container(
                padding: cardPadding,
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
                    child: Column(
                  mainAxisSize: MainAxisSize.min,
                      children: [
                    Container(
                      padding: EdgeInsets.all(16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14 * scale),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red.shade300,
                        size: 32 * scale,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                        Text(
                      'No batch selected',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.w600,
                        fontSize: 18 * scale,
                        color: Colors.white,
                      ),
                          textAlign: TextAlign.center,
                        ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Please select a batch to manage attendance',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14 * scale,
                      ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
          ),
        ),
            ),
          );
        }

  Widget _buildNoStudentsState(double scale, double cardRadius, EdgeInsets cardPadding) {
        return Scaffold(
      extendBody: true,
      backgroundColor: const Color(0xFF13131A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13131A),
        elevation: 0,
        title: Text(
          'Attendance Management',
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.w600,
            fontSize: 20 * scale,
            color: Colors.white,
          ),
        ),
      ),
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
              child: Container(
                padding: cardPadding,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Container(
                      padding: EdgeInsets.all(16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14 * scale),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.people_outline_rounded,
                        color: Colors.orange.shade300,
                        size: 32 * scale,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                                Text(
                      'No students in batch',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.w600,
                        fontSize: 18 * scale,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Batch: ${widget.selectedBatch}',
                      style: GoogleFonts.poppins(
                        color: Colors.cyan.shade300,
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Students need to be assigned to this batch by admin',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14 * scale,
                      ),
                      textAlign: TextAlign.center,
                                ),
                              ],
                            ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceHeaderSection(BuildContext context, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing, double sectionSpacing) {
    return Container(
      margin: EdgeInsets.all(sectionSpacing),
      padding: cardPadding,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: kBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14 * scale),
              border: Border.all(color: kBlue.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.checklist_rounded,
              color: kBlue,
              size: 24 * scale,
            ),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Attendance Management',
                  style: GoogleFonts.prompt(
                    fontWeight: FontWeight.w700,
                    fontSize: 18 * scale,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  'Mark and review attendance for your batch',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14 * scale,
                  ),
                ),
                SizedBox(height: 12 * scale),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: kLime.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(color: kLime.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.selectedBatch ?? 'All Batches',
                    style: GoogleFonts.poppins(
                      color: kLime,
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }





  Widget _buildStudentsListSection(BuildContext context, List<Student> batchStudents, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing, double sectionSpacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sectionSpacing),
                      child: RefreshIndicator(
                        onRefresh: _loadTodayAttendance,
        color: Colors.cyan.shade300,
        backgroundColor: const Color(0xFF13131A),
                        child: ListView.builder(
                          itemCount: batchStudents.length,
                          itemBuilder: (context, index) {
                            final student = batchStudents[index];
                            final isPresent = _attendanceMap[student.id] ?? false;
                            final isSelected = _selectedStudents.contains(student.id);
                          
            return Container(
              margin: EdgeInsets.only(bottom: cardSpacing),
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
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.all(16 * scale),
                child: Row(
                  children: [
                    // Avatar
                    Container(
                      width: 48 * scale,
                      height: 48 * scale,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.cyan.shade300, Colors.cyan.shade500],
                        ),
                        borderRadius: BorderRadius.circular(24 * scale),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.cyan.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                                        child: Text(
                                          student.name[0].toUpperCase(),
                          style: GoogleFonts.prompt(
                            color: Colors.white,
                            fontSize: 18 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16 * scale),
                    // Student info
                    Expanded(
                      child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Text(
                            student.name,
                            style: GoogleFonts.prompt(
                              fontWeight: FontWeight.w600,
                              fontSize: 16 * scale,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            student.email,
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14 * scale,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16 * scale),
                    // Attendance toggle
                    GestureDetector(
                      onTap: () {
                                          setState(() {
                          _attendanceMap[student.id!] = !isPresent;
                                          });
                                        },
                      child: Container(
                        padding: EdgeInsets.all(12 * scale),
                        decoration: BoxDecoration(
                          color: isPresent ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: Border.all(
                            color: isPresent ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Icon(
                          isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: isPresent ? Colors.green.shade300 : Colors.red.shade300,
                          size: 24 * scale,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtonsSection(BuildContext context, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing, double sectionSpacing) {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final isHoliday = widget.selectedBatch != null && provider.isTodayHolidayForBatch(widget.selectedBatch!);
    final isSessionDay = widget.selectedBatch != null && provider.isTodaySessionDayForBatch(widget.selectedBatch!);
    final attendanceBlocked = isHoliday || !isSessionDay;
    String? blockReason;
    if (isHoliday) {
      blockReason = 'Attendance cannot be marked today as it is a holiday for this batch.';
    } else if (!isSessionDay) {
      blockReason = 'Attendance can only be marked on session days for this batch.';
    }
    return Column(
      children: [
        if (attendanceBlocked && blockReason != null)
          Padding(
            padding: EdgeInsets.only(bottom: 8 * scale),
            child: Text(
              blockReason,
              style: GoogleFonts.poppins(
                color: Colors.redAccent,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        Container(
          margin: EdgeInsets.all(sectionSpacing),
          child: SizedBox(
            width: double.infinity,
            height: 56 * scale,
            child: ElevatedButton(
              onPressed: _isLoading || attendanceBlocked ? null : _saveAttendance,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(cardRadius),
                ),
                elevation: 4,
                shadowColor: Colors.cyan.withOpacity(0.3),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 24 * scale,
                      height: 24 * scale,
                      child: CircularProgressIndicator(
                        strokeWidth: 2 * scale,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.save_rounded,
                          size: 20 * scale,
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          'Save Attendance',
                          style: GoogleFonts.poppins(
                            fontSize: 16 * scale,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

class InstructorHolidaysScreen extends StatelessWidget {
  final Instructor instructor;
  final String? selectedBatch;

  const InstructorHolidaysScreen({super.key, required this.instructor, this.selectedBatch});

  @override
  Widget build(BuildContext context) {
    return _InstructorHolidaysScreenContent(
      instructor: instructor,
      selectedBatch: selectedBatch,
    );
  }
}

class _InstructorHolidaysScreenContent extends StatefulWidget {
  final Instructor instructor;
  final String? selectedBatch;

  const _InstructorHolidaysScreenContent({required this.instructor, this.selectedBatch});

  @override
  State<_InstructorHolidaysScreenContent> createState() => _InstructorHolidaysScreenContentState();
}

class _InstructorHolidaysScreenContentState extends State<_InstructorHolidaysScreenContent> {
  String _searchQuery = '';
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(20 * scale);
    final double sectionSpacing = 20 * scale;
    final double cardSpacing = 12 * scale;
    
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final batchHolidays = provider.holidays.where((h) =>
          (h.batch == widget.selectedBatch || h.batch == null) &&
          (h.reason.toLowerCase().contains(_searchQuery.toLowerCase()) ||
           DateFormat('EEE, MMM d, y').format(h.date).toLowerCase().contains(_searchQuery.toLowerCase()))
        ).toList();
        
        // Show loading if provider is loading
        if (provider.isLoading) {
          return _buildLoadingState(scale, cardRadius, cardPadding);
        }

        print('InstructorHolidaysScreen Debug:');
        print('Selected batch: $widget.selectedBatch');
        print('All holidays: ${provider.holidays.length}');
        print('Instructor ID: ${widget.instructor.id}');
        
        try {
          batchHolidays.sort((a, b) => b.date.compareTo(a.date));

          return Scaffold(
            extendBody: true,
            backgroundColor: const Color(0xFF13131A),
            // Removed internal AppBar here
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
                    child: Column(
              children: [
                SizedBox(height: sectionSpacing),
                        // Header Section
                        _buildHeaderSection(context, scale, cardRadius, cardPadding, cardSpacing, sectionSpacing),
                        
                        // Search Section
                        _buildSearchSection(context, scale, cardRadius, cardPadding, cardSpacing, sectionSpacing),
                        
                        // Add Holiday Button Section
                        _buildAddHolidaySection(context, provider, scale, cardRadius, cardPadding, cardSpacing, sectionSpacing),
                        
                        // Holidays List Section
                        Expanded(
                          child: _buildHolidaysListSection(context, batchHolidays, provider, scale, cardRadius, cardPadding, cardSpacing, sectionSpacing),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        } catch (e) {
          print('Error in InstructorHolidaysScreen: $e');
          return _buildErrorState(scale, cardRadius, cardPadding);
        }
      },
    );
  }

  Widget _buildLoadingState(double scale, double cardRadius, EdgeInsets cardPadding) {
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
              child: Container(
                padding: cardPadding,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 48 * scale,
                      height: 48 * scale,
                      child: CircularProgressIndicator(
                        strokeWidth: 4 * scale,
                        valueColor: AlwaysStoppedAnimation<Color>(kOrange),
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      'Loading holidays...',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(double scale, double cardRadius, EdgeInsets cardPadding) {
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
              child: Container(
                padding: cardPadding,
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                Container(
                      padding: EdgeInsets.all(16 * scale),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14 * scale),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Icon(
                        Icons.error_outline_rounded,
                        color: kRed,
                        size: 32 * scale,
                      ),
                    ),
                    SizedBox(height: 16 * scale),
                    Text(
                      'Error loading holidays',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.w600,
                        fontSize: 18 * scale,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8 * scale),
                    Text(
                      'Please try again later',
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14 * scale,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing, double sectionSpacing) {
    return Container(
      margin: EdgeInsets.all(sectionSpacing),
      padding: cardPadding,
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12 * scale),
            decoration: BoxDecoration(
              color: kOrange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14 * scale),
              border: Border.all(color: kOrange.withOpacity(0.3)),
            ),
            child: Icon(
              Icons.event_busy_rounded,
              color: kOrange,
              size: 24 * scale,
            ),
          ),
          SizedBox(width: 16 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Holiday Management',
                  style: GoogleFonts.prompt(
                    fontWeight: FontWeight.w700,
                    fontSize: 18 * scale,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                  'Manage holidays for your batches',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14 * scale,
                  ),
                ),
                SizedBox(height: 12 * scale),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: kLime.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(color: kLime.withOpacity(0.3)),
                  ),
                  child: Text(
                    widget.selectedBatch ?? 'All Batches',
                    style: GoogleFonts.poppins(
                      color: kLime,
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing, double sectionSpacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sectionSpacing),
                  child: TextField(
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 16 * scale,
        ),
        decoration: InputDecoration(
          hintText: 'Search holidays by reason or date...',
          hintStyle: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.5),
            fontSize: 16 * scale,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
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
            borderSide: BorderSide(color: kBlue, width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
    );
  }

  Widget _buildAddHolidaySection(BuildContext context, AppProvider provider, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing, double sectionSpacing) {
    return Container(
      margin: EdgeInsets.all(sectionSpacing),
      child: AnimatedButton(
        width: double.infinity,
        height: 56 * scale,
        backgroundColor: const Color(0xFFB2FF00),
        text: "Declare Holiday",
        onPressed: () => _showDeclareHolidayDialog(context, provider),
        logoImage: null,
        addBorder: null,
        foregroundColor: const Color(0xFF13131A),
        fontSize: 16 * scale,
      ),
    );
  }
                
  Widget _buildHolidaysListSection(BuildContext context, List<Holiday> batchHolidays, AppProvider provider, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing, double sectionSpacing) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: sectionSpacing),
                  child: RefreshIndicator(
                    onRefresh: () => provider.loadHolidays(batch: widget.selectedBatch),
        color: kLime,
        backgroundColor: const Color(0xFF13131A),
                    child: batchHolidays.isEmpty
          ? _buildEmptyState(scale, cardRadius, cardPadding)
          : ListView.builder(
              itemCount: batchHolidays.length,
              itemBuilder: (context, index) {
                final holiday = batchHolidays[index];
                return _buildHolidayCard(context, holiday, scale, cardRadius, cardPadding, cardSpacing);
              },
            ),
      ),
    );
  }

  Widget _buildEmptyState(double scale, double cardRadius, EdgeInsets cardPadding) {
    return Center(
      child: Container(
        padding: cardPadding,
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
                          child: Column(
          mainAxisSize: MainAxisSize.min,
                            children: [
            Container(
              padding: EdgeInsets.all(16 * scale),
              decoration: BoxDecoration(
                color: kOrange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14 * scale),
                border: Border.all(color: kOrange.withOpacity(0.3)),
              ),
              child: Icon(
                Icons.event_busy_rounded,
                color: kOrange,
                size: 32 * scale,
              ),
            ),
            SizedBox(height: 16 * scale),
                              Text(
                                'No holidays declared',
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.w600,
                fontSize: 18 * scale,
                color: Colors.white,
                              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8 * scale),
                              Text(
                                'Click "Declare Holiday" to add a new holiday',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14 * scale,
              ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
      ),
    );
  }

  Widget _buildHolidayCard(BuildContext context, Holiday holiday, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    final isToday = holiday.date.year == DateTime.now().year &&
        holiday.date.month == DateTime.now().month &&
        holiday.date.day == DateTime.now().day;
    final isPast = holiday.date.isBefore(DateTime.now());
    final isFuture = holiday.date.isAfter(DateTime.now());

    Color statusColor;
    String statusText;
    if (isToday) {
      statusColor = kOrange;
      statusText = 'Today';
    } else if (isPast) {
      statusColor = kGray;
      statusText = 'Past';
    } else {
      statusColor = kGreen;
      statusText = 'Upcoming';
    }

    return Container(
      margin: EdgeInsets.only(bottom: cardSpacing),
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
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: kOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14 * scale),
                    border: Border.all(color: kOrange.withOpacity(0.3)),
                  ),
                  child: Icon(
                    Icons.event_busy_rounded,
                    color: kOrange,
                    size: 24 * scale,
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d, y').format(holiday.date),
                        style: GoogleFonts.prompt(
                          fontWeight: FontWeight.w700,
                          fontSize: 16 * scale,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        holiday.reason,
                        style: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14 * scale,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    statusText,
                    style: GoogleFonts.poppins(
                      color: statusColor,
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12 * scale),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
              decoration: BoxDecoration(
                color: kBlue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16 * scale),
                border: Border.all(color: kBlue.withOpacity(0.3)),
              ),
              child: Text(
                holiday.batch == null ? 'All Batches' : 'Batch: ${holiday.batch}',
                style: GoogleFonts.poppins(
                  color: kBlue,
                  fontSize: 12 * scale,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeclareHolidayDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => DeclareHolidayDialog(instructorId: widget.instructor.id!),
    ).then((holiday) async {
      if (holiday != null) {
        // Set the batch to the instructor's selected batch
        final holidayWithBatch = Holiday(
          id: holiday.id,
          date: holiday.date,
          batch: widget.selectedBatch,
          reason: holiday.reason,
          createdBy: widget.instructor.id!,
          createdAt: holiday.createdAt,
        );
        try {
          await provider.addHoliday(holidayWithBatch);
          // Reload holidays with the current batch filter to ensure the new holiday appears
          await provider.loadHolidays(batch: widget.selectedBatch);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().contains('holiday already exists')
                  ? 'A holiday already exists for this batch or all batches on this date.'
                  : 'Failed to declare holiday: ${e.toString()}',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }
}

class InstructorProfileScreen extends StatelessWidget {
  final Instructor instructor;

  const InstructorProfileScreen({super.key, required this.instructor});

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
      // Removed appBar for consistency with main dashboard
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
                padding: EdgeInsets.all(16 * scale),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Profile Header Card
                    Container(
                      margin: EdgeInsets.only(bottom: sectionSpacing),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(cardRadius),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
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
                          children: [
                            // Profile Avatar
                            Container(
                              width: 80 * scale,
                              height: 80 * scale,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [kOrange, kRed],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  instructor.name[0].toUpperCase(),
                                  style: GoogleFonts.prompt(
                                    fontSize: 32 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 16 * scale),
                            Text(
                              instructor.name,
                              style: GoogleFonts.prompt(
                                fontSize: 24 * scale,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4 * scale),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                              decoration: BoxDecoration(
                                color: kOrange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16 * scale),
                                border: Border.all(color: kOrange.withOpacity(0.3)),
                              ),
                              child: Text(
                                'Instructor',
                                style: GoogleFonts.poppins(
                                  fontSize: 14 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: kOrange,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Contact Information Section
                    _buildSectionHeader(
                      'Contact Information',
                      instructor.email ?? '', // subtitle
                      Icons.contact_mail,
                      kBlue,
                      scale,
                    ),
                    SizedBox(height: cardSpacing),
                    _buildContactInfoCard(instructor, scale, cardRadius, cardPadding),

                    SizedBox(height: sectionSpacing),

                    // Assigned Batches Section
                    _buildSectionHeader(
                      'Assigned Batches',
                      instructor.assignedBatches.isNotEmpty ? instructor.assignedBatches.join(', ') : 'No batches assigned',
                      Icons.group_work,
                      kGreen,
                      scale,
                    ),
                    SizedBox(height: cardSpacing),
                    _buildBatchesCard(instructor, scale, cardRadius, cardPadding),

                    SizedBox(height: sectionSpacing),

                    // Account Information Section
                    _buildSectionHeader(
                      'Account Information',
                      '', // no subtitle
                      Icons.account_circle,
                      kPurple,
                      scale,
                    ),
                    SizedBox(height: cardSpacing),
                    _buildAccountInfoCard(instructor, scale, cardRadius, cardPadding),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon, Color color, double scale) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(14 * scale),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 24 * scale),
        ),
        SizedBox(width: 16 * scale),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.prompt(
                  fontWeight: FontWeight.w600,
                  fontSize: 18 * scale,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 4 * scale),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14 * scale,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoCard(Instructor instructor, double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: cardPadding,
        child: Column(
          children: [
            _buildContactItem('Email', instructor.email, Icons.email, Colors.blue, scale),
            if (instructor.phone != null)
              _buildContactItem('Phone', instructor.phone!, Icons.phone, Colors.green, scale),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchesCard(Instructor instructor, double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: cardPadding,
        child: instructor.assignedBatches.isEmpty
            ? Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.assignment_ind,
                      color: Colors.grey,
                      size: 24 * scale,
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Batch Assignment',
                          style: GoogleFonts.poppins(
                            fontSize: 14 * scale,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          'No batches assigned yet',
                          style: GoogleFonts.poppins(
                            fontSize: 14 * scale,
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Text(
                          'Contact admin to get assigned to batches',
                          style: GoogleFonts.poppins(
                            fontSize: 12 * scale,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                children: instructor.assignedBatches.map((batch) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8 * scale),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8 * scale),
                          decoration: BoxDecoration(
                            color: kGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8 * scale),
                          ),
                          child: Icon(
                            Icons.class_,
                            color: kGreen,
                            size: 18 * scale,
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                            decoration: BoxDecoration(
                              color: kGreen.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20 * scale),
                              border: Border.all(color: kGreen.withOpacity(0.3)),
                            ),
                            child: Text(
                              batch,
                              style: GoogleFonts.poppins(
                                fontSize: 14 * scale,
                                fontWeight: FontWeight.w600,
                                color: kGreen,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ),
    );
  }

  Widget _buildAccountInfoCard(Instructor instructor, double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cardRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: cardPadding,
        child: Column(
          children: [
            _buildAccountItem('Joined', DateFormat('MMM d, y').format(instructor.createdAt), Icons.calendar_today, Colors.orange, scale),
            _buildStatusItem(instructor, scale),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(String label, String value, IconData icon, Color color, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12 * scale,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  value,
                  style: GoogleFonts.prompt(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(String label, String value, IconData icon, Color color, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.poppins(
                    fontSize: 12 * scale,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Text(
                  value,
                  style: GoogleFonts.prompt(
                    fontSize: 16 * scale,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(Instructor instructor, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8 * scale),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: instructor.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Icon(
              instructor.isActive ? Icons.check_circle : Icons.cancel,
              color: instructor.isActive ? Colors.green : Colors.red,
              size: 18 * scale,
            ),
          ),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status',
                  style: GoogleFonts.poppins(
                    fontSize: 12 * scale,
                    color: Colors.white60,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2 * scale),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: instructor.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20 * scale),
                    border: Border.all(
                      color: instructor.isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    instructor.isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.poppins(
                      fontSize: 14 * scale,
                      fontWeight: FontWeight.w600,
                      color: instructor.isActive ? Colors.green : Colors.red,
                    ),
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

class DeclareHolidayDialog extends StatefulWidget {
  final String instructorId;

  const DeclareHolidayDialog({super.key, required this.instructorId});

  @override
  State<DeclareHolidayDialog> createState() => _DeclareHolidayDialogState();
}

class _DeclareHolidayDialogState extends State<DeclareHolidayDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(20 * scale);
    final double sectionSpacing = 20 * scale;
    final double cardSpacing = 12 * scale;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(maxWidth: 400 * scale),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF13131A), Color(0xFF1976D2)],
          ),
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section
              Padding(
                padding: cardPadding,
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12 * scale),
                      ),
                      child: Icon(Icons.event_busy_rounded, color: const Color(0xFF1976D2), size: 20 * scale),
                    ),
                    SizedBox(width: 12 * scale),
                    Text(
                      'Declare Holiday',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.w600,
                        fontSize: 18 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              // Content Section
              Padding(
                padding: cardPadding,
                child: Column(
                  children: [
                    // TableCalendar Section
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2100),
                        focusedDay: _selectedDate,
                        selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                        onDaySelected: (selected, _) {
                          setState(() => _selectedDate = selected);
                        },
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: const Color(0xFFB2FF00).withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                          ),
                          selectedDecoration: BoxDecoration(
                            color: const Color(0xFF1976D2),
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFB2FF00), width: 2),
                          ),
                          defaultTextStyle: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 14 * scale,
                          ),
                          weekendTextStyle: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 14 * scale,
                          ),
                          todayTextStyle: GoogleFonts.poppins(
                            color: const Color(0xFFB2FF00),
                            fontWeight: FontWeight.w700,
                            fontSize: 14 * scale,
                          ),
                          selectedTextStyle: GoogleFonts.prompt(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15 * scale,
                          ),
                          outsideTextStyle: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.3),
                            fontSize: 13 * scale,
                          ),
                          cellMargin: EdgeInsets.all(2 * scale),
                        ),
                        headerStyle: HeaderStyle(
                          titleTextStyle: GoogleFonts.prompt(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 16 * scale,
                          ),
                          formatButtonVisible: false,
                          leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white, size: 22 * scale),
                          rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white, size: 22 * scale),
                          titleCentered: true,
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13 * scale,
                          ),
                          weekendStyle: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 13 * scale,
                          ),
                        ),
                        calendarFormat: CalendarFormat.month,
                        availableGestures: AvailableGestures.horizontalSwipe,
                        rowHeight: 38 * scale,
                      ),
                    ),
                    SizedBox(height: sectionSpacing),
                    // Reason Field Section
                    TextFormField(
                      controller: _reasonController,
                      decoration: InputDecoration(
                        labelText: 'Reason for Holiday',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14 * scale,
                        ),
                        hintText: 'e.g., Festival, Maintenance, etc.',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 14 * scale,
                        ),
                        prefixIcon: Container(
                          margin: EdgeInsets.all(8 * scale),
                          padding: EdgeInsets.all(8 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10 * scale),
                          ),
                          child: Icon(
                            Icons.edit_note_rounded,
                            color: const Color(0xFF1976D2),
                            size: 18 * scale,
                          ),
                        ),
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
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.05),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                      ),
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16 * scale,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a reason';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              // Actions Section
              Padding(
                padding: cardPadding,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                              fontSize: 14 * scale,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: AnimatedButton(
                        width: double.infinity,
                        height: 48 * scale,
                        backgroundColor: const Color(0xFFB2FF00),
                        text: "Declare Holiday",
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            final holiday = Holiday(
                              date: _selectedDate,
                              reason: _reasonController.text.trim(),
                              createdBy: widget.instructorId,
                              createdAt: DateTime.now(),
                            );
                            Navigator.pop(context, holiday);
                          }
                        },
                        logoImage: null,
                        addBorder: null,
                        foregroundColor: const Color(0xFF13131A),
                        fontSize: 16 * scale,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 