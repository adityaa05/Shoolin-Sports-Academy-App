import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_provider.dart';
import '../services/firebase_service.dart';
import '../services/location_service.dart';
import '../models/attendance.dart';
import '../models/payment.dart';
import '../constants/batches.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../models/student.dart';
import '../models/holiday.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/colors.dart';
import '../constants/texts.dart';
import '../constants/dimensions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/animated_button.dart';
import '../utils/attendance_permissions.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;
  String? _selectedStudentId;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final firebaseService = FirebaseService();
      final currentUser = firebaseService.getCurrentUser();
      if (currentUser != null) {
        setState(() {
          _selectedStudentId = currentUser.uid;
          _screens.addAll([
            StudentHomeScreen(studentId: _selectedStudentId!),
            StudentAttendanceScreen(studentId: _selectedStudentId!),
            StudentPaymentsScreen(studentId: _selectedStudentId!),
            StudentProfileScreen(studentId: _selectedStudentId!),
          ]);
        });
        Provider.of<AppProvider>(context, listen: false).initializeData();
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
        final student = _selectedStudentId != null ? provider.getStudentById(_selectedStudentId!) : null;
        final today = DateTime.now();
        final upcomingHolidays = provider.holidays.where((h) {
          final diff = h.date.difference(today).inDays;
          return diff >= 0 && diff <= 2 && (h.batch == null || (student != null && student.isInBatch(h.batch!)));
        }).toList();
        upcomingHolidays.sort((a, b) => a.date.compareTo(b.date));
        
        // Payment reminder logic (updated)
        bool showPaymentReminder = false;
        String reminderText = '';
        if (student != null) {
          // Only show reminder if student is in the reminder list and joined before this month
          final studentsToRemind = provider.getStudentsToRemindForPayment(DateTime.now());
          final joinedBeforeThisMonth = student.createdAt.isBefore(DateTime(DateTime.now().year, DateTime.now().month, 1));
          if (studentsToRemind.any((s) => s.id == student.id) && joinedBeforeThisMonth) {
            // Find the first unpaid batch for this month
            String? unpaidBatch;
            for (final batch in student.batches) {
              if (!provider.hasPaidForMonth(student.id!, batch)) {
                unpaidBatch = batch;
                break;
              }
            }
            if (unpaidBatch != null) {
              showPaymentReminder = true;
              reminderText = 'Your payment for batch "$unpaidBatch" is due for this month. Please pay to avoid interruption.';
            }
          }
        }
        return Scaffold(
          extendBody: true,
          backgroundColor: const Color(0xFF13131A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF13131A),
            elevation: 0,
            title: Text(
              'Student Dashboard',
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
                if (showPaymentReminder)
                  Container(
                    margin: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFEF4444).withOpacity(0.15),
                          const Color(0xFFDC2626).withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.25)),
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
                            ),
                            child: Icon(Icons.warning_rounded, color: const Color(0xFFEF4444), size: 26 * scale),
                          ),
                          SizedBox(width: 16 * scale),
                          Expanded(
                            child: Text(
                              reminderText,
                              style: GoogleFonts.prompt(
                                color: const Color(0xFFEF4444),
                                fontWeight: FontWeight.w600,
                                fontSize: 14 * scale,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (upcomingHolidays.isNotEmpty)
                  Container(
                    margin: EdgeInsets.all(16 * scale),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF59E0B).withOpacity(0.15),
                          const Color(0xFFEF4444).withOpacity(0.08),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.25)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF59E0B).withOpacity(0.1),
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
                              color: const Color(0xFFF59E0B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14 * scale),
                            ),
                            child: Icon(Icons.event_busy_rounded, color: const Color(0xFFF59E0B), size: 26 * scale),
                          ),
                          SizedBox(width: 16 * scale),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Upcoming Holiday!',
                                  style: GoogleFonts.prompt(
                                    color: const Color(0xFFF59E0B),
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
                  icon: Icon(Icons.payment_rounded, size: 22 * scale),
                  label: 'Payments',
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
}

class StudentHomeScreen extends StatefulWidget {
  final String studentId;

  const StudentHomeScreen({super.key, required this.studentId});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen> {
  String? _selectedBatch;
  bool _checkingAttendance = false;
  bool _attendanceMarked = false;

  Future<void> _checkAttendance() async {
    if (_selectedBatch == null) return;
    setState(() => _checkingAttendance = true);
    final marked = await FirebaseService().isAttendanceMarkedToday(widget.studentId, batch: _selectedBatch!);
    setState(() {
      _attendanceMarked = marked;
      _checkingAttendance = false;
    });
  }

  void _makePayment(BuildContext context, AppProvider provider, Student student) {
    showDialog(
      context: context,
      builder: (context) => PaymentDialog(student: student, provider: provider),
    );
  }

  IconData _getAttendanceIcon(AttendanceStatus status) {
    switch (status) {
      case AttendanceStatus.present:
        return Icons.check_circle_rounded;
      case AttendanceStatus.absent:
        return Icons.cancel_rounded;
      case AttendanceStatus.late:
        return Icons.access_time_rounded;
      case AttendanceStatus.excused:
        return Icons.info_rounded;
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
    
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return _buildLoadingState(scale);
        }

        final student = provider.getStudentById(widget.studentId);
        if (student == null) {
          return _buildErrorState(scale);
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
            onRefresh: () async {
              try {
                await provider.loadAttendanceForStudent(widget.studentId);
                await provider.loadPayments();
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
                        // Welcome Card
                        _buildWelcomeCard(context, student, scale, cardRadius, cardPadding),
                        SizedBox(height: sectionSpacing),

                        // Holiday Alert
                        ...(() {
                          final holidayAlert = _buildHolidayAlert(context, provider, scale, cardRadius);
                          return holidayAlert != null 
                            ? [holidayAlert, SizedBox(height: sectionSpacing)]
                            : <Widget>[];
                        })(),

                        // Self Attendance Section
                        _buildSelfAttendanceSection(context, student, provider),
                        SizedBox(height: sectionSpacing),

                        // Statistics Section
                        _buildStatisticsSection(context, provider, scale, cardRadius, cardSpacing),
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

  Widget _buildLoadingState(double scale) {
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
            child: Container(
              padding: EdgeInsets.all(20 * scale),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18 * scale),
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
    );
  }

  Widget _buildErrorState(double scale) {
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
            child: Container(
              padding: EdgeInsets.all(24 * scale),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18 * scale),
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
                    'Student not found',
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
                        color: Colors.cyan.shade300,
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
    );
  }

  Widget _buildWelcomeCard(BuildContext context, Student student, double scale, double cardRadius, EdgeInsets cardPadding) {
    final now = DateTime.now();
    final greeting = _getGreeting(now.hour);
    
    return Container(
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
                        student.name,
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
            // Student Info Chips
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
                    'Student ID: ${student.id?.substring(0, 8).toUpperCase()}...',
                    style: GoogleFonts.poppins(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade300,
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
                    'Active Student',
                    style: GoogleFonts.poppins(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade300,
                    ),
                  ),
                ),
                ...student.batches.map((batch) => Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Text(
                    batch,
                    style: GoogleFonts.poppins(
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade300,
                    ),
                  ),
                )).toList(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection(BuildContext context, Student student, AppProvider provider, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    return Container(
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
            // Section Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Icon(Icons.flash_on_rounded, color: const Color(0xFF8B5CF6), size: 20 * scale),
                ),
                SizedBox(width: 12 * scale),
                Text(
                  'Quick Actions',
                  style: GoogleFonts.prompt(
                    fontWeight: FontWeight.w600, 
                    fontSize: 18 * scale, 
                    color: Colors.white
                  ),
                ),
              ],
            ),
            SizedBox(height: cardSpacing * 1.5),
            
            // Quick Action Buttons
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: cardSpacing,
              mainAxisSpacing: cardSpacing,
              childAspectRatio: 1.5,
              children: [
                _buildQuickActionButton(
                  context,
                  'Check Attendance',
                  Icons.check_circle_rounded,
                  const Color(0xFF10B981),
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StudentAttendanceScreen(studentId: widget.studentId),
                    ),
                  ),
                  scale,
                  cardRadius,
                ),
                _buildQuickActionButton(
                  context,
                  'Make Payment',
                  Icons.payment_rounded,
                  const Color(0xFFF59E0B),
                  () => _makePayment(context, provider, student),
                  scale,
                  cardRadius,
                ),
                _buildQuickActionButton(
                  context,
                  'View Schedule',
                  Icons.schedule_rounded,
                  const Color(0xFF1976D2),
                  () => _viewSchedule(context),
                  scale,
                  cardRadius,
                ),
                _buildQuickActionButton(
                  context,
                  'Contact Support',
                  Icons.support_agent_rounded,
                  const Color(0xFF8B5CF6),
                  () => _contactSupport(context),
                  scale,
                  cardRadius,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, double scale, double cardRadius) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withOpacity(0.1),
              color.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Padding(
          padding: EdgeInsets.all(16 * scale),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12 * scale),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12 * scale),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24 * scale,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 12 * scale,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, AppProvider provider, double scale, double cardRadius, double cardSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Icon(Icons.analytics_rounded, color: Colors.blue, size: 20 * scale),
            ),
            SizedBox(width: 12 * scale),
            Text(
              'Your Statistics',
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.w600, 
                fontSize: 18 * scale, 
                color: Colors.white
              ),
            ),
          ],
        ),
        SizedBox(height: cardSpacing),
        
        // Statistics Grid
        Builder(
          builder: (context) {
            final sessionStats = provider.getStudentStats(widget.studentId);
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: cardSpacing,
              mainAxisSpacing: cardSpacing,
              childAspectRatio: 1.2,
              children: [
                _buildStatCard(
                  context,
                  'Classes Attended',
                  '${sessionStats['classesAttended']}',
                  Icons.check_circle_rounded,
                  Colors.green,
                  scale,
                  cardRadius,
                ),
                _buildStatCard(
                  context,
                  'Total Classes',
                  '${sessionStats['totalClasses']}',
                  Icons.schedule_rounded,
                  Colors.blue,
                  scale,
                  cardRadius,
                ),
                _buildStatCard(
                  context,
                  'Payments Made',
                  '${sessionStats['totalPayments'] ?? 0}',
                  Icons.payment_rounded,
                  Colors.orange,
                  scale,
                  cardRadius,
                ),
                _buildStatCard(
                  context,
                  'Total Paid',
                  '₹${(sessionStats['totalAmountPaid'] ?? 0.0).toStringAsFixed(2)}',
                  Icons.attach_money_rounded,
                  Colors.purple,
                  scale,
                  cardRadius,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _getGreeting(int hour) {
    if (hour < 12) return 'Good morning,';
    if (hour < 17) return 'Good afternoon,';
    return 'Good evening,';
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
              child: Icon(Icons.event_busy, color: Colors.orange, size: 26 * scale),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Holiday!',
                    style: GoogleFonts.prompt(
                      color: Colors.orange.shade300,
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



  void _viewSchedule(BuildContext context) {
    // Navigate to schedule screen
    // This would be implemented based on your navigation structure
  }

  void _contactSupport(BuildContext context) {
    // Show contact support dialog or navigate to support screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF13131A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Contact Support',
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        content: Text(
          'For support, please contact:\n\nEmail: support@example.com\nPhone: +1-234-567-8900',
          style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(
                color: const Color(0xFFB2FF00),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfAttendanceSection(BuildContext context, Student student, AppProvider provider) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(20 * scale);
    final double cardSpacing = 12 * scale;
    
    // Get today's attendance records for the student
    final todaySessions = provider.getTodayAttendance(student.id!);
    final nextSession = provider.getNextAttendance(student.id!);
    final currentMonth = DateTime.now();
    final sessionStats = provider.getStudentStats(student.id!);

    if (todaySessions.isEmpty && nextSession == null) {
      return const SizedBox.shrink();
    }

    return Container(
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
            // Section Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10 * scale),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 20 * scale),
                ),
                SizedBox(width: 12 * scale),
                Text(
                  'Session Management',
                  style: GoogleFonts.prompt(
                    fontWeight: FontWeight.w600, 
                    fontSize: 18 * scale, 
                    color: Colors.white
                  ),
                ),
              ],
            ),
            SizedBox(height: cardSpacing * 1.5),

            // Session Quota Progress
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.blue.withOpacity(0.1),
                    Colors.blue.withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(cardRadius),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Padding(
                padding: cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8 * scale),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10 * scale),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Icon(Icons.trending_up_rounded, color: Colors.blue, size: 16 * scale),
                        ),
                        SizedBox(width: 10 * scale),
                    Text(
                      'Monthly Progress',
                          style: GoogleFonts.prompt(
                            fontWeight: FontWeight.w600, 
                            fontSize: 16 * scale, 
                            color: Colors.white
                    ),
                        ),
                      ],
                    ),
                    SizedBox(height: cardSpacing),
                    LinearProgressIndicator(
                      value: (sessionStats['classesAttended'] as int) / 18,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
                      borderRadius: BorderRadius.circular(10 * scale),
                      minHeight: 8 * scale,
                    ),
                    SizedBox(height: cardSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(color: Colors.green.withOpacity(0.3)),
                          ),
                          child: Text(
                          '${sessionStats['classesAttended']} / 18 sessions',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, 
                              fontSize: 14 * scale, 
                              color: Colors.green.shade300
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Text(
                          sessionStats['totalClasses'] > 0
                              ? '${((sessionStats['classesAttended'] / sessionStats['totalClasses']) * 100).toStringAsFixed(1)}% attendance'
                              : '0% attendance',
                            style: GoogleFonts.poppins(
                              fontSize: 12 * scale, 
                              color: Colors.white.withOpacity(0.7)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: cardSpacing * 1.5),

            // Today's Sessions
            if (todaySessions.isNotEmpty) ...[
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    child: Icon(Icons.today_rounded, color: const Color(0xFF10B981), size: 16 * scale),
                  ),
                  SizedBox(width: 10 * scale),
                  Text(
                    'Today\'s Sessions',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, 
                      fontSize: 16 * scale, 
                      color: Colors.white
                    ),
                  ),
                ],
              ),
              SizedBox(height: cardSpacing),
              ...todaySessions.map((session) => _buildSessionCard(context, provider, session, scale, cardRadius, cardSpacing)),
            ] else ...[
              // No sessions today
              Container(
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: Colors.blue.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_rounded, color: Colors.blue, size: 20 * scale),
                    SizedBox(width: 12 * scale),
                    Expanded(
                      child: Text(
                        'No sessions scheduled for today',
                        style: GoogleFonts.poppins(
                          color: Colors.blue,
                          fontSize: 14 * scale,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Next Session
            if (nextSession != null) ...[
              SizedBox(height: cardSpacing * 1.5),
              Row(
      children: [
        Container(
                    padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10 * scale),
                    ),
                    child: Icon(Icons.schedule_rounded, color: const Color(0xFFF59E0B), size: 16 * scale),
                  ),
                  SizedBox(width: 10 * scale),
        Text(
                    'Next Session',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, 
                      fontSize: 16 * scale, 
                      color: Colors.white
          ),
        ),
      ],
              ),
              SizedBox(height: cardSpacing),
              _buildNextSessionCard(context, student, nextSession, provider),
            ],
          ],
        ),
      ),
    );
  }



  Widget _buildNextSessionCard(BuildContext context, Student student, Attendance session, AppProvider provider) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(16 * scale);

    return Container(
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
      child: Padding(
        padding: cardPadding,
        child: Row(
          children: [
            Container(
              width: 48 * scale,
              height: 48 * scale,
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(14 * scale),
              ),
              child: Icon(
                _getAttendanceIcon(session.status),
                color: const Color(0xFFF59E0B),
                size: 24 * scale,
              ),
            ),
            SizedBox(width: 14 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.batch,
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.w600, 
                      fontSize: 16 * scale, 
                      color: Colors.white
                  ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    '${DateFormat('EEE, MMM d').format(session.date)} - ${session.getStatusText()}',
                    style: GoogleFonts.poppins(
                      fontSize: 13 * scale, 
                      color: Colors.white.withOpacity(0.7)
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
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

  Widget _buildSessionCard(BuildContext context, AppProvider provider, Attendance session, double scale, double cardRadius, double cardSpacing) {
    final currentUser = FirebaseService().getCurrentUser();
    final canMark = currentUser != null && canMarkAttendance(
      userRole: 'student',
      userId: currentUser.uid,
      studentId: widget.studentId,
      batchName: session.batch,
    );
    
    return Container(
      margin: EdgeInsets.only(bottom: cardSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF059669).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Icon(Icons.fitness_center_rounded, color: const Color(0xFF10B981), size: 20 * scale),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.batch,
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * scale,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    DateFormat('EEE, MMM d • h:mm a').format(session.date),
                    style: GoogleFonts.poppins(
                      fontSize: 13 * scale,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: canMark ? () => _markAttendance(context, provider, session.batch) : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: canMark ? const Color(0xFF10B981) : Colors.grey,
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
                child: Text(
                  canMark ? 'Mark Attendance' : 'Outside Time Window',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markAttendance(BuildContext context, AppProvider provider, String batchName) async {
    try {
      final currentUser = FirebaseService().getCurrentUser();
      if (currentUser == null) {
        _showErrorSnackBar(context, 'User not authenticated');
        return;
      }

      // Check permissions
      if (!canMarkAttendance(
        userRole: 'student',
        userId: currentUser.uid,
        studentId: widget.studentId,
        batchName: batchName,
      )) {
        _showErrorSnackBar(context, 'You can only mark attendance during class time');
        return;
      }

      // Check if attendance already marked today
      final marked = await FirebaseService().isAttendanceMarkedToday(widget.studentId, batch: batchName);
      if (marked) {
        _showErrorSnackBar(context, 'Attendance already marked for today in this batch');
        return;
      }

      // Show confirmation dialog
      final confirmed = await _showAttendanceConfirmationDialog(context, batchName);
      if (!confirmed) return;

      // Mark attendance
      final attendance = Attendance(
        studentId: widget.studentId,
        date: DateTime.now(),
        isPresent: true,
        batch: batchName,
        status: AttendanceStatus.present,
        markedByType: AttendanceMarkedBy.student,
        markedAt: DateTime.now(),
        markedByUserId: currentUser.uid,
        markedBy: 'Self',
      );

      await provider.markAttendance(attendance);
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Attendance marked successfully for $batchName',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to mark attendance: ${e.toString()}');
      }
    }
  }

  Future<bool> _showAttendanceConfirmationDialog(BuildContext context, String batchName) async {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF13131A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * scale)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              size: 24 * scale,
            ),
            SizedBox(width: 12 * scale),
            Text(
              'Mark Attendance',
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 18 * scale,
              ),
            ),
          ],
        ),
        content: Text(
          'Mark yourself as present for $batchName today?',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14 * scale,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Mark Present',
              style: GoogleFonts.poppins(
                color: const Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }
}

class StudentAttendanceScreen extends StatefulWidget {
  final String studentId;

  const StudentAttendanceScreen({super.key, required this.studentId});

  @override
  State<StudentAttendanceScreen> createState() => _StudentAttendanceScreenState();
}

class _StudentAttendanceScreenState extends State<StudentAttendanceScreen> {
  String _searchQuery = '';
  bool _isLoading = false;

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
        final student = provider.getStudentById(widget.studentId);
        if (student == null) {
          return _buildErrorState(scale, cardRadius, cardPadding);
        }

        final todaySessions = _getTodaySessions(provider, student);
        final attendanceMarked = _isAttendanceMarkedToday(provider, student);
        final attendanceStats = _getAttendanceStats(provider, student);

        return Container(
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
                child: RefreshIndicator(
                  onRefresh: () async {
                    setState(() => _isLoading = true);
                    try {
                      await provider.loadAttendanceForStudent(widget.studentId);
                    } finally {
                      setState(() => _isLoading = false);
                    }
                  },
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 20.0 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        // Header Section
                        _buildHeaderSection(context, student, scale, cardRadius, cardPadding),
                        SizedBox(height: sectionSpacing),

                        // Search Section
                        _buildSearchSection(context, scale, cardRadius, cardPadding),
                        SizedBox(height: sectionSpacing),

                        // Today's Status Section
                        _buildTodayStatusSection(context, provider, student, todaySessions, attendanceMarked, scale, cardRadius, cardPadding, cardSpacing),
                        SizedBox(height: sectionSpacing),

                        // Statistics Section
                        _buildStatisticsSection(context, attendanceStats, scale, cardRadius, cardSpacing),
                        SizedBox(height: sectionSpacing),

                        // Attendance History Section
                        _buildAttendanceHistorySection(context, provider, scale, cardRadius, cardPadding, cardSpacing),
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

  Widget _buildHeaderSection(BuildContext context, Student student, double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1976D2).withOpacity(0.15),
            const Color(0xFF1565C0).withOpacity(0.08),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(14 * scale),
              ),
              child: Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981), size: 24 * scale),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Management',
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.w600,
                      fontSize: 18 * scale,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    'Track your class attendance and progress',
                    style: GoogleFonts.poppins(
                      fontSize: 14 * scale,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: cardPadding,
              child: TextField(
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14 * scale,
          ),
                decoration: InputDecoration(
            hintText: 'Search by batch, date, or status...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14 * scale,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 20 * scale,
            ),
                  filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: BorderSide(color: const Color(0xFF1976D2).withOpacity(0.5)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
    );
  }

  Widget _buildTodayStatusSection(BuildContext context, AppProvider provider, Student student, List<Attendance> todaySessions, bool attendanceMarked, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    return Container(
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
            // Section Header
            Row(
              children: [
                    Container(
                  padding: EdgeInsets.all(10 * scale),
                      decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Icon(Icons.today_rounded, color: const Color(0xFFF59E0B), size: 20 * scale),
                ),
                SizedBox(width: 12 * scale),
                Text(
                  'Today\'s Status',
                  style: GoogleFonts.prompt(
                    fontWeight: FontWeight.w600,
                    fontSize: 16 * scale,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: cardSpacing * 1.5),

            // Status Content
            if (todaySessions.isEmpty)
              _buildStatusChip(
                'No sessions scheduled for today',
                Icons.event_busy_rounded,
                const Color(0xFF6B7280),
                scale,
                    )
                  else if (attendanceMarked)
              _buildStatusChip(
                        'Attendance already marked for today',
                Icons.check_circle_rounded,
                const Color(0xFF10B981),
                scale,
                    )
                  else
                    Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                  Text(
                    'Available Sessions:',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 14 * scale,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: cardSpacing),
                  ...todaySessions.map((session) => _buildAttendanceSessionCard(context, provider, session, scale, cardRadius, cardSpacing)),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String message, IconData icon, Color color, double scale) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12 * scale),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18 * scale),
          SizedBox(width: 12 * scale),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.poppins(
                color: color,
                fontSize: 14 * scale,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceSessionCard(BuildContext context, AppProvider provider, Attendance session, double scale, double cardRadius, double cardSpacing) {
    final currentUser = FirebaseService().getCurrentUser();
    final now = DateTime.now();
    
    // Check if attendance is already marked for this session
    final isPresent = session.isPresent;
    
    // Check if this session can be marked now (within time window)
    final canMark = currentUser != null && canMarkAttendance(
      userRole: 'student',
      userId: currentUser.uid,
      studentId: widget.studentId,
      batchName: session.batch,
    );
    
    // Determine status text and color
    late String statusText;
    late Color statusColor;
    
    if (isPresent) {
      statusText = 'Present';
      statusColor = const Color(0xFF10B981); // Green
    } else if (canMark) {
      statusText = 'Available';
      statusColor = const Color(0xFFF59E0B); // Orange/Yellow
    } else {
      // Check if it's the right day for this batch
      final batchTime = getBatchTime(session.batch);
      if (batchTime != null && batchTime.daysOfWeek.contains(now.weekday)) {
        statusText = 'Outside Window';
        statusColor = const Color(0xFF6B7280); // Gray
      } else {
        statusText = 'Not Today';
        statusColor = const Color(0xFF6B7280); // Gray
      }
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: cardSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1976D2).withOpacity(0.1),
            const Color(0xFF1565C0).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.2)),
      ),
      child: Padding(
        padding: EdgeInsets.all(16 * scale),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10 * scale),
              ),
              child: Icon(Icons.schedule_rounded, color: const Color(0xFF1976D2), size: 20 * scale),
            ),
            SizedBox(width: 12 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.batch,
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * scale,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    DateFormat('EEE, MMM d • h:mm a').format(session.date),
                    style: GoogleFonts.poppins(
                      fontSize: 13 * scale,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: canMark ? () => _markAttendanceFromCard(context, provider, session.batch) : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(20 * scale),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, Map<String, dynamic> stats, double scale, double cardRadius, double cardSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Icon(Icons.analytics_rounded, color: const Color(0xFF1976D2), size: 20 * scale),
            ),
            SizedBox(width: 12 * scale),
            Text(
              'Attendance Statistics',
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.w600,
                fontSize: 16 * scale,
                color: Colors.white,
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
              'Classes Attended',
              '${stats['classesAttended']}',
              Icons.check_circle_rounded,
              const Color(0xFF10B981),
              scale,
              cardRadius,
            ),
            _buildStatCard(
              context,
              'Total Classes',
              '${stats['totalClasses']}',
              Icons.schedule_rounded,
              const Color(0xFF1976D2),
              scale,
              cardRadius,
            ),
            _buildStatCard(
              context,
              'Attendance Rate',
              '${stats['attendanceRate']}%',
              Icons.trending_up_rounded,
              const Color(0xFFF59E0B),
              scale,
              cardRadius,
            ),
            _buildStatCard(
              context,
              'This Month',
              '${stats['thisMonth']}',
              Icons.calendar_month_rounded,
              const Color(0xFF8B5CF6),
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

  Widget _buildAttendanceHistorySection(BuildContext context, AppProvider provider, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Icon(Icons.history_rounded, color: const Color(0xFF8B5CF6), size: 20 * scale),
            ),
            SizedBox(width: 12 * scale),
            Text(
              'Attendance History',
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.w600,
                fontSize: 16 * scale,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: cardSpacing),

        // Attendance History List
        FutureBuilder<List<Attendance>>(
          future: provider.loadAttendanceForStudent(widget.studentId).then((_) => provider.attendance),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingState(scale, cardRadius, cardPadding);
            }
            if (snapshot.hasError) {
              return _buildErrorState(scale, cardRadius, cardPadding);
            }

                    final attendanceList = (snapshot.data ?? []).where((a) =>
                      a.batch.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      DateFormat('EEE, MMM d, y').format(a.date).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                      (a.isPresent ? 'present' : 'absent').contains(_searchQuery.toLowerCase())
                    ).toList();

            if (attendanceList.isEmpty) {
              return _buildEmptyState(scale, cardRadius, cardPadding);
            }

            return Column(
              children: attendanceList.map((attendance) => _buildAttendanceCard(context, attendance, scale, cardRadius, cardPadding, cardSpacing)).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAttendanceCard(BuildContext context, Attendance attendance, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    final isPresent = attendance.isPresent;
    final color = isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final icon = isPresent ? Icons.check_circle_rounded : Icons.cancel_rounded;
    final status = isPresent ? 'Present' : 'Absent';

    return Container(
      margin: EdgeInsets.only(bottom: cardSpacing),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * scale),
              ),
              child: Icon(icon, color: color, size: 24 * scale),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    attendance.batch,
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.w600,
                      fontSize: 16 * scale,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    DateFormat('EEEE, MMMM d, y').format(attendance.date),
                    style: GoogleFonts.poppins(
                      fontSize: 13 * scale,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16 * scale),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Text(
                    status,
                    style: GoogleFonts.poppins(
                      color: color,
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 4 * scale),
                Text(
                              DateFormat('h:mm a').format(attendance.date),
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.6),
                    fontSize: 12 * scale,
                  ),
                ),
              ],
            ),
          ],
                            ),
                          ),
                        );
  }

  Widget _buildLoadingState(double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: cardPadding,
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB2FF00)),
                strokeWidth: 3 * scale,
              ),
              SizedBox(height: 16 * scale),
              Text(
                'Loading attendance history...',
                style: GoogleFonts.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14 * scale,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: cardPadding,
        child: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: const Color(0xFFEF4444),
                  size: 32 * scale,
                ),
              ),
              SizedBox(height: 16 * scale),
              Text(
                'Failed to load attendance',
                style: GoogleFonts.prompt(
                  fontWeight: FontWeight.w600,
                  fontSize: 16 * scale,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                'Please try refreshing the page',
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
    );
  }

  Widget _buildEmptyState(double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: cardPadding,
        child: Center(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7280).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                child: Icon(
                  Icons.history_rounded,
                  color: const Color(0xFF6B7280),
                  size: 32 * scale,
                ),
              ),
              SizedBox(height: 16 * scale),
              Text(
                'No attendance records found',
                style: GoogleFonts.prompt(
                  fontWeight: FontWeight.w600,
                  fontSize: 16 * scale,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8 * scale),
              Text(
                'Your attendance history will appear here',
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
    );
  }

  // Helper methods
  List<Attendance> _getTodaySessions(AppProvider provider, Student student) {
    final now = DateTime.now();
    
    // Check if today is a holiday
    final isHoliday = provider.holidays.any((h) =>
      h.date.year == now.year &&
      h.date.month == now.month &&
      h.date.day == now.day
    );
    
    if (isHoliday) return [];
    
    // Get potential sessions for today based on student's batches and schedule
    final List<Attendance> todaySessions = [];
    
    for (final batch in student.batches) {
      final batchTime = getBatchTime(batch);
      
      // Check if this batch has a session today
      if (batchTime != null && batchTime.daysOfWeek.contains(now.weekday)) {
        // Check if there's not a holiday specific to this batch
        final batchHoliday = provider.holidays.any((h) =>
          h.date.year == now.year &&
          h.date.month == now.month &&
          h.date.day == now.day &&
          h.batch == batch
        );
        
        if (!batchHoliday) {
          // Create a potential session for today
          final sessionDate = DateTime(
            now.year,
            now.month,
            now.day,
            batchTime.startTime.hour,
            batchTime.startTime.minute,
          );
          
          // Check if attendance already exists for this session
          final existingAttendance = provider.attendance.firstWhere(
            (a) => a.studentId == widget.studentId &&
                   a.batch == batch &&
                   a.date.year == now.year &&
                   a.date.month == now.month &&
                   a.date.day == now.day,
            orElse: () => Attendance(
              studentId: widget.studentId,
              date: sessionDate,
              isPresent: false,
              batch: batch,
              status: AttendanceStatus.absent,
              markedByType: AttendanceMarkedBy.student,
            ),
          );
          
          // Only add if attendance is not already marked
          if (!existingAttendance.isPresent) {
            todaySessions.add(existingAttendance);
          }
        }
      }
    }
    
    return todaySessions;
  }

  bool _isAttendanceMarkedToday(AppProvider provider, Student student) {
    final now = DateTime.now();
    
    // Check if attendance is marked for any of the student's batches today
    for (final batch in student.batches) {
      final batchTime = getBatchTime(batch);
      
      // Only check batches that have sessions today
      if (batchTime != null && batchTime.daysOfWeek.contains(now.weekday)) {
        final attendanceList = provider.attendance.where((att) {
          return att.studentId == widget.studentId &&
                 att.batch == batch &&
                 att.date.year == now.year &&
                 att.date.month == now.month &&
                 att.date.day == now.day &&
                 att.isPresent;
        }).toList();
        
        if (attendanceList.isNotEmpty) {
          return true; // Found attendance marked for at least one batch
        }
      }
    }
    
    return false;
  }

  Map<String, dynamic> _getAttendanceStats(AppProvider provider, Student student) {
    // Use the provider's getStudentStats method for consistency
    final baseStats = provider.getStudentStats(widget.studentId);
    final classesAttended = baseStats['classesAttended'] as int;
    final totalClasses = baseStats['totalClasses'] as int;
    final attendanceRate = totalClasses > 0 ? ((classesAttended / totalClasses) * 100).round() : 0;
    
    // Calculate this month's attendance
    final now = DateTime.now();
    final thisMonth = provider.attendance.where((a) => 
      a.studentId == widget.studentId &&
      a.date.year == now.year && 
      a.date.month == now.month && 
      a.isPresent
    ).length;

    return {
      'classesAttended': classesAttended,
      'totalClasses': totalClasses,
      'attendanceRate': attendanceRate,
      'thisMonth': thisMonth,
    };
  }

  Future<void> _markAttendanceFromCard(BuildContext context, AppProvider provider, String batchName) async {
    try {
      final currentUser = FirebaseService().getCurrentUser();
      if (currentUser == null) {
        _showAttendanceErrorSnackBar(context, 'User not authenticated');
        return;
      }

      // Check permissions
      if (!canMarkAttendance(
        userRole: 'student',
        userId: currentUser.uid,
        studentId: widget.studentId,
        batchName: batchName,
      )) {
        _showAttendanceErrorSnackBar(context, 'You can only mark attendance during class time');
        return;
      }

      // Check if attendance already marked today
      final marked = await FirebaseService().isAttendanceMarkedToday(widget.studentId, batch: batchName);
      if (marked) {
        _showAttendanceErrorSnackBar(context, 'Attendance already marked for today in this batch');
        return;
      }

      // Show confirmation dialog
      final confirmed = await _showAttendanceConfirmationDialogCard(context, batchName);
      if (!confirmed) return;

      // Mark attendance
      final attendance = Attendance(
        studentId: widget.studentId,
        date: DateTime.now(),
        isPresent: true,
        batch: batchName,
        status: AttendanceStatus.present,
        markedByType: AttendanceMarkedBy.student,
        markedAt: DateTime.now(),
        markedByUserId: currentUser.uid,
        markedBy: 'Self',
      );

      await provider.markAttendance(attendance);
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Attendance marked successfully for $batchName',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showAttendanceErrorSnackBar(context, 'Failed to mark attendance: ${e.toString()}');
      }
    }
  }

  Future<bool> _showAttendanceConfirmationDialogCard(BuildContext context, String batchName) async {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF13131A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18 * scale)),
        title: Row(
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: const Color(0xFF10B981),
              size: 24 * scale,
            ),
            SizedBox(width: 12 * scale),
            Text(
              'Mark Attendance',
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontSize: 18 * scale,
              ),
            ),
          ],
        ),
        content: Text(
          'Mark yourself as present for $batchName today?',
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14 * scale,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.7),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Mark Present',
              style: GoogleFonts.poppins(
                color: const Color(0xFF10B981),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showAttendanceErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFFEF4444),
      ),
    );
  }
}

class StudentPaymentsScreen extends StatefulWidget {
  final String studentId;
  const StudentPaymentsScreen({super.key, required this.studentId});
  @override
  State<StudentPaymentsScreen> createState() => _StudentPaymentsScreenState();
}

class _StudentPaymentsScreenState extends State<StudentPaymentsScreen> {
  String? _selectedBatch;
  late Razorpay _razorpay;
  bool _isPaying = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final student = provider.getStudentById(widget.studentId);
    if (student == null || _selectedBatch == null) return;
    final payment = Payment(
      id: null,
      studentId: widget.studentId,
      amount: student.monthlyFee,
      status: 'pending',
      paymentMethod: 'razorpay',
      transactionId: null,
      batch: student.primaryBatch ?? 'Unknown Batch',
      paymentDate: DateTime.now(),
    );
    await provider.addPayment(payment);
    setState(() => _isPaying = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Payment successful!'), backgroundColor: Colors.green),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    setState(() => _isPaying = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}'), backgroundColor: Colors.red),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    setState(() => _isPaying = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External wallet selected'), backgroundColor: Colors.orange),
    );
  }

  void _startPayment(Student student) {
    setState(() => _isPaying = true);
    
    // Check if batch is selected
    if (_selectedBatch == null) {
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a batch first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    // For now, we'll simulate a successful payment since Razorpay requires a real API key
    // In production, you would use a real Razorpay test key
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        // Simulate payment processing
        final provider = Provider.of<AppProvider>(context, listen: false);
        final payment = Payment(
          id: null,
          studentId: widget.studentId,
          amount: student.monthlyFee,
          status: 'completed',
          paymentMethod: 'razorpay',
          transactionId: 'TXN_${DateTime.now().millisecondsSinceEpoch}',
          batch: _selectedBatch!,
          paymentDate: DateTime.now(),
        );
        
        await provider.addPayment(payment);
        
        if (mounted) {
          setState(() => _isPaying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment successful! Your payment has been recorded.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isPaying = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
    
    /*
    final options = {
      'key': 'rzp_test_YOUR_ACTUAL_KEY_HERE', // Replace with your actual Razorpay test key
      'amount': (student.monthlyFee * 100).toInt(),
      'currency': 'INR',
      'name': 'Kickboxing Academy',
      'description': 'Monthly Fee Payment for ${_selectedBatch}',
      'prefill': {
        'contact': student.phone,
        'email': student.email,
      },
    };
    try {
      _razorpay.open(options);
    } catch (e) {
      setState(() => _isPaying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
    */
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
        final student = provider.getStudentById(widget.studentId);
        if (student == null) {
          return _buildErrorState(scale, cardRadius, cardPadding);
        }

        final paymentStats = _getPaymentStats(provider, student);

        return Container(
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
                child: RefreshIndicator(
                  onRefresh: () async {
                    try {
                      await provider.loadPayments();
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
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 20.0 * scale),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                        // Header Section
                        _buildHeaderSection(context, student, scale, cardRadius, cardPadding),
                        SizedBox(height: sectionSpacing),

                        // Search Section
                        _buildSearchSection(context, scale, cardRadius, cardPadding),
                        SizedBox(height: sectionSpacing),

                        // Payment Statistics Section
                        _buildPaymentStatsSection(context, paymentStats, scale, cardRadius, cardSpacing),
                        SizedBox(height: sectionSpacing),

                        // Make Payment Section
                        _buildMakePaymentSection(context, provider, student, scale, cardRadius, cardPadding, cardSpacing),
                        SizedBox(height: sectionSpacing),

                        // Payment History Section
                        _buildPaymentHistorySection(context, provider, scale, cardRadius, cardPadding, cardSpacing),
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

  Widget _buildHeaderSection(BuildContext context, Student student, double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF1976D2).withOpacity(0.15),
            const Color(0xFF1565C0).withOpacity(0.08),
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.2),
                borderRadius: BorderRadius.circular(14 * scale),
              ),
              child: Icon(Icons.payment_rounded, color: const Color(0xFFF59E0B), size: 24 * scale),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Management',
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.w600,
                      fontSize: 18 * scale,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Text(
                    'Manage your fee payments and view history',
                    style: GoogleFonts.poppins(
                      fontSize: 14 * scale,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchSection(BuildContext context, double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
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
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Padding(
        padding: cardPadding,
              child: TextField(
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 14 * scale,
          ),
                decoration: InputDecoration(
            hintText: 'Search by batch, date, or status...',
            hintStyle: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.5),
              fontSize: 14 * scale,
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Colors.white.withOpacity(0.7),
              size: 20 * scale,
            ),
                  filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12 * scale),
              borderSide: BorderSide(color: const Color(0xFF1976D2).withOpacity(0.5)),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
    );
  }

  Widget _buildPaymentStatsSection(BuildContext context, Map<String, dynamic> stats, double scale, double cardRadius, double cardSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Icon(
                Icons.analytics_rounded,
                color: const Color(0xFF10B981),
                size: 20 * scale,
              ),
            ),
            SizedBox(width: 12 * scale),
            Text(
              'Payment Statistics',
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.w600,
                fontSize: 18 * scale,
                color: Colors.white,
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
              'Total Paid',
              '₹${stats['totalPaid'].toStringAsFixed(2)}',
              Icons.check_circle_rounded,
              const Color(0xFF10B981),
              scale,
              cardRadius,
            ),
            _buildStatCard(
              context,
              'Payments Made',
              '${stats['paymentsMade']}',
              Icons.payment_rounded,
              const Color(0xFF1976D2),
              scale,
              cardRadius,
            ),
            _buildStatCard(
              context,
              'This Month',
              '₹${stats['thisMonth'].toStringAsFixed(2)}',
              Icons.calendar_month_rounded,
              const Color(0xFFF59E0B),
              scale,
              cardRadius,
            ),
            _buildStatCard(
              context,
              'Pending',
              '₹${stats['pending'].toStringAsFixed(2)}',
              Icons.pending_rounded,
              const Color(0xFFEF4444),
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

  Widget _buildMakePaymentSection(BuildContext context, AppProvider provider, Student student, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
              ),
              child: Icon(Icons.add_card_rounded, color: const Color(0xFF8B5CF6), size: 20 * scale),
            ),
            SizedBox(width: 12 * scale),
            Text(
              'Make Payment',
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.w600,
                fontSize: 18 * scale,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: cardSpacing),
        
        // Make Payment Card
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
                // Card Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12 * scale),
                        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
                      ),
                      child: Icon(Icons.add_card_rounded, color: const Color(0xFF8B5CF6), size: 24 * scale),
                    ),
                    SizedBox(width: 16 * scale),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Payment Details',
                            style: GoogleFonts.prompt(
                              fontWeight: FontWeight.w600,
                              fontSize: 18 * scale,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            'Select batch and complete payment',
                            style: GoogleFonts.poppins(
                              fontSize: 14 * scale,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: cardSpacing * 1.5),

                // Batch Selection
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
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _selectedBatch,
                    items: (student.batches.isNotEmpty ? student.batches : kBatches).map((batch) => DropdownMenuItem(
                      value: batch,
                      child: Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8,
                        ),
                        child: Text(
                          batch,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14 * scale,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    )).toList(),
                    onChanged: (val) => setState(() => _selectedBatch = val),
                    decoration: InputDecoration(
                      hintText: student.batches.isNotEmpty ? 'Select Your Batch' : 'Select Any Available Batch',
                      hintStyle: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 14 * scale,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                        borderSide: BorderSide(color: const Color(0xFF8B5CF6).withOpacity(0.5), width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                    ),
                    dropdownColor: const Color(0xFF13131A),
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.7), size: 22 * scale),
                    isExpanded: true,
                    menuMaxHeight: 250 * scale,
                  ),
                ),
                SizedBox(height: cardSpacing),

                // Help text
                if (_selectedBatch == null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.15),
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
                            student.batches.isNotEmpty 
                                ? 'Please select your batch to proceed with payment'
                                : 'No batches assigned. Please select any available batch.',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFF59E0B),
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedBatch == null) SizedBox(height: cardSpacing),

                // Payment Amount Chip
                if (_selectedBatch != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.attach_money_rounded, color: const Color(0xFF10B981), size: 20 * scale),
                        SizedBox(width: 12 * scale),
                        Text(
                          '₹${student.monthlyFee.toStringAsFixed(2)}',
                          style: GoogleFonts.prompt(
                            fontWeight: FontWeight.w700,
                            fontSize: 18 * scale,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          'Monthly Fee',
                          style: GoogleFonts.poppins(
                            fontSize: 14 * scale,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_selectedBatch != null) SizedBox(height: cardSpacing),

                // Pay Button
                ElevatedButton(
                  onPressed: _selectedBatch == null || _isPaying ? null : () => _startPayment(student),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedBatch == null || _isPaying 
                        ? Colors.grey.withOpacity(0.3)
                        : const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16 * scale),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(cardRadius),
                    ),
                    elevation: _selectedBatch == null || _isPaying ? 0 : 4,
                    shadowColor: const Color(0xFF8B5CF6).withOpacity(0.3),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: _isPaying
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24 * scale,
                                height: 24 * scale,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3 * scale,
                                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 16 * scale),
                              Text(
                                'Processing...',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : Text(
                            _selectedBatch == null ? 'Select Batch First' : 'Pay Now',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
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
      ],
    );
  }

  Widget _buildPaymentHistorySection(BuildContext context, AppProvider provider, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    return Container(
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
            // Section Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: const Color(0xFF1976D2),
                    size: 24 * scale,
                  ),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment History',
                        style: GoogleFonts.prompt(
                          fontWeight: FontWeight.w600,
                          fontSize: 18 * scale,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        'View your payment records and status',
                        style: GoogleFonts.poppins(
                          fontSize: 14 * scale,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: cardSpacing * 1.5),

            // Payment History List
            FutureBuilder<List<Payment>>(
              future: provider.getPaymentsByStudent(widget.studentId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingState(scale, cardRadius, cardPadding);
                }
                if (snapshot.hasError) {
                  return _buildErrorState(scale, cardRadius, cardPadding);
                }

                final payments = (snapshot.data ?? []).where((p) =>
                  p.batch.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  DateFormat('MMM d, y').format(p.paymentDate).toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  p.status.toLowerCase().contains(_searchQuery.toLowerCase())
                ).toList();

                if (payments.isEmpty) {
                  return _buildEmptyState(scale, cardRadius, cardPadding);
                }

                return Column(
                  children: payments.map((payment) => _buildPaymentCard(context, payment, scale, cardRadius, cardPadding, cardSpacing)).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, Payment payment, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    final isCompleted = payment.status == 'completed';
    final color = isCompleted ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final icon = isCompleted ? Icons.check_circle_rounded : Icons.pending_rounded;
    final status = isCompleted ? 'Completed' : 'Pending';

    return Container(
      margin: EdgeInsets.only(bottom: cardSpacing),
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
            // Header Row with Icon and Status
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12 * scale),
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
                        DateFormat('EEEE, MMMM d, y').format(payment.paymentDate),
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
                        payment.paymentMethod,
                        style: GoogleFonts.poppins(
                          fontSize: 13 * scale,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: cardSpacing),

            // Chips Section
            Wrap(
              spacing: 8 * scale,
              runSpacing: 8 * scale,
              children: [
                // Batch Chip
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                              decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF1976D2).withOpacity(0.2),
                        const Color(0xFF1565C0).withOpacity(0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18 * scale),
                    border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.group_rounded,
                        color: const Color(0xFF1976D2),
                        size: 16 * scale,
                      ),
                      SizedBox(width: 6 * scale),
                      Text(
                        payment.batch,
                        style: GoogleFonts.poppins(
                                  color: Colors.white,
                          fontSize: 12 * scale,
                                  fontWeight: FontWeight.w600,
                                ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Amount Chip
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981).withOpacity(0.2),
                        const Color(0xFF059669).withOpacity(0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18 * scale),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                      Icon(
                        Icons.attach_money_rounded,
                        color: const Color(0xFF10B981),
                        size: 16 * scale,
                      ),
                      SizedBox(width: 6 * scale),
                      Text(
                        '₹${payment.amount.toStringAsFixed(2)}',
                        style: GoogleFonts.prompt(
                          color: Colors.white,
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // Status Chip
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.2),
                        color.withOpacity(0.12),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18 * scale),
                    border: Border.all(color: color.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        color: color,
                        size: 16 * scale,
                      ),
                      SizedBox(width: 6 * scale),
                      Text(
                        status,
                        style: GoogleFonts.poppins(
                          color: color,
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState(double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF1976D2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14 * scale),
                  border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                ),
                child: SizedBox(
                  width: 32 * scale,
                  height: 32 * scale,
                  child: CircularProgressIndicator(
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                    strokeWidth: 3 * scale,
                  ),
                ),
              ),
              SizedBox(height: 20 * scale),
              Text(
                'Loading Payment History',
                style: GoogleFonts.prompt(
                  fontWeight: FontWeight.w600,
                  fontSize: 16 * scale,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * scale),
              Text(
                'Please wait while we fetch your records...',
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
    );
  }

  Widget _buildErrorState(double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
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
              SizedBox(height: 20 * scale),
              Text(
                'Failed to Load Payments',
                style: GoogleFonts.prompt(
                  fontWeight: FontWeight.w600,
                  fontSize: 16 * scale,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * scale),
              Text(
                'Please check your connection and try again',
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
                  color: const Color(0xFFEF4444).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                ),
                child: Text(
                  'Pull to refresh',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFFEF4444),
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
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
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(16 * scale),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7280).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14 * scale),
                  border: Border.all(color: const Color(0xFF6B7280).withOpacity(0.3)),
                ),
                child: Icon(
                  Icons.payment_rounded,
                  color: const Color(0xFF6B7280),
                  size: 32 * scale,
                ),
              ),
              SizedBox(height: 20 * scale),
              Text(
                'No Payment Records',
                style: GoogleFonts.prompt(
                  fontWeight: FontWeight.w600,
                  fontSize: 16 * scale,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * scale),
              Text(
                'Your payment history will appear here once you make payments',
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
                  color: const Color(0xFF1976D2).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add_card_rounded,
                      color: const Color(0xFF1976D2),
                      size: 18 * scale,
                    ),
                    SizedBox(width: 8 * scale),
                    Text(
                      'Make your first payment',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF1976D2),
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
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

  // Helper methods
  Map<String, dynamic> _getPaymentStats(AppProvider provider, Student student) {
    final studentPayments = provider.payments.where((p) => p.studentId == widget.studentId).toList();
    final completedPayments = studentPayments.where((p) => p.status == 'completed').toList();
    final pendingPayments = studentPayments.where((p) => p.status == 'pending').toList();
    
    final totalPaid = completedPayments.fold(0.0, (sum, p) => sum + p.amount);
    final paymentsMade = completedPayments.length;
    
    final now = DateTime.now();
    final thisMonth = completedPayments.where((p) => 
      p.paymentDate.year == now.year && 
      p.paymentDate.month == now.month
    ).fold(0.0, (sum, p) => sum + p.amount);
    
    final pending = pendingPayments.fold(0.0, (sum, p) => sum + p.amount);

    return {
      'totalPaid': totalPaid,
      'paymentsMade': paymentsMade,
      'thisMonth': thisMonth,
      'pending': pending,
    };
  }
}

class StudentProfileScreen extends StatelessWidget {
  final String studentId;

  const StudentProfileScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final student = provider.getStudentById(studentId);
        if (student == null) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF13131A), Color(0xFF1976D2)],
              ),
            ),
            child: const Center(
              child: Text(
                'Student not found',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          );
        }

        final width = MediaQuery.of(context).size.width;
        final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
        final cardRadius = 18 * scale;
        final cardPadding = EdgeInsets.all(20 * scale);
        final sectionSpacing = 20 * scale;
        final cardSpacing = 12 * scale;

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
                  padding: EdgeInsets.fromLTRB(16 * scale, 16 * scale, 16 * scale, 80 * scale),
                  child: Column(
                    children: [
                      // Profile Header Card
                      Container(
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
                                    colors: [Colors.cyan.shade400, Colors.blue.shade600],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyan.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    student.name[0].toUpperCase(),
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
                                student.name,
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
                                  color: Colors.cyan.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20 * scale),
                                  border: Border.all(color: Colors.cyan.withOpacity(0.3)),
                                ),
                                child: Text(
                                  'Student',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.cyan.shade300,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: sectionSpacing),

                      // Profile Information Section
                      _buildSectionHeader(
                        'Profile Information',
                        Icons.person_outline,
                        Colors.blue,
                        scale,
                      ),
                      SizedBox(height: cardSpacing),
                      _buildProfileInfoCard(student, scale, cardRadius, cardPadding),

                      SizedBox(height: sectionSpacing),

                      // Account Status Section
                      _buildSectionHeader(
                        'Account Status',
                        Icons.verified_user,
                        Colors.green,
                        scale,
                      ),
                      SizedBox(height: cardSpacing),
                      _buildStatusCard(student, scale, cardRadius, cardPadding),

                      SizedBox(height: sectionSpacing),

                      // Batch Information Section
                      _buildSectionHeader(
                        'Batch Information',
                        Icons.group,
                        Colors.orange,
                        scale,
                      ),
                      SizedBox(height: cardSpacing),
                      _buildBatchInfoCard(student, scale, cardRadius, cardPadding),
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

  Widget _buildSectionHeader(String title, IconData icon, Color color, double scale) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8 * scale),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12 * scale),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20 * scale,
          ),
        ),
        SizedBox(width: 12 * scale),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.prompt(
              fontSize: 18 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard(Student student, double scale, double cardRadius, EdgeInsets cardPadding) {
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
            _buildProfileItem('Email', student.email, Icons.email, Colors.blue, scale),
            _buildProfileItem('Phone', student.phone, Icons.phone, Colors.green, scale),
            _buildProfileItem('Join Date', DateFormat('MMM d, y').format(student.createdAt), Icons.calendar_today, Colors.orange, scale),
            _buildProfileItem('Monthly Fee', '₹${student.monthlyFee.toStringAsFixed(2)}', Icons.attach_money, Colors.purple, scale),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(Student student, double scale, double cardRadius, EdgeInsets cardPadding) {
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
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12 * scale),
              decoration: BoxDecoration(
                color: student.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12 * scale),
                border: Border.all(
                  color: student.isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                ),
              ),
              child: Icon(
                student.isActive ? Icons.check_circle : Icons.cancel,
                color: student.isActive ? Colors.green : Colors.red,
                size: 24 * scale,
              ),
            ),
            SizedBox(width: 16 * scale),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: GoogleFonts.poppins(
                      fontSize: 14 * scale,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 4 * scale),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                    decoration: BoxDecoration(
                      color: student.isActive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20 * scale),
                      border: Border.all(
                        color: student.isActive ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      student.isActive ? 'Active' : 'Inactive',
                      style: GoogleFonts.poppins(
                        fontSize: 14 * scale,
                        fontWeight: FontWeight.w600,
                        color: student.isActive ? Colors.green.shade300 : Colors.red.shade300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchInfoCard(Student student, double scale, double cardRadius, EdgeInsets cardPadding) {
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
        child: student.batches.isNotEmpty
            ? Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.group,
                      color: Colors.orange,
                      size: 24 * scale,
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assigned Batch',
                          style: GoogleFonts.poppins(
                            fontSize: 14 * scale,
                            color: Colors.white70,
                          ),
                        ),
                        SizedBox(height: 4 * scale),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20 * scale),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Text(
                            student.primaryBatch ?? 'No Batch',
                            style: GoogleFonts.poppins(
                              fontSize: 14 * scale,
                              fontWeight: FontWeight.w600,
                              color: Colors.orange.shade300,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12 * scale),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: Icon(
                      Icons.group_off,
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
                          'No batch assigned yet',
                          style: GoogleFonts.poppins(
                            fontSize: 14 * scale,
                            color: Colors.grey.shade400,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfileItem(String label, String value, IconData icon, Color color, double scale) {
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
}

class PaymentDialog extends StatefulWidget {
  final student;
  final AppProvider provider;

  const PaymentDialog({super.key, required this.student, required this.provider});

  @override
  State<PaymentDialog> createState() => _PaymentDialogState();
}

class _PaymentDialogState extends State<PaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  String _selectedMethod = 'Cash';
  String? _selectedBatch;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.student.monthlyFee.toString();
    if (widget.student.batch != null) {
      _selectedBatch = widget.student.batch;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _submitPayment() {
    if (_formKey.currentState!.validate()) {
      if (_selectedBatch == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a batch.'), backgroundColor: Colors.red),
        );
        return;
      }
      final payment = Payment(
        studentId: widget.student.id!,
        amount: double.parse(_amountController.text),
        paymentDate: DateTime.now(),
        paymentMethod: _selectedMethod,
        status: 'completed',
        batch: _selectedBatch!,
      );
      widget.provider.addPayment(payment).then((_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Make Payment'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter amount';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedBatch,
              decoration: const InputDecoration(
                labelText: 'Batch',
                prefixIcon: Icon(Icons.group),
              ),
              items: kBatches.map((batch) {
                return DropdownMenuItem(
                  value: batch,
                  child: Text(batch),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBatch = value;
                });
              },
              validator: (value) => value == null ? 'Please select a batch' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                prefixIcon: Icon(Icons.payment),
              ),
              items: ['Cash', 'Card', 'Online'].map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submitPayment,
          child: const Text('Submit'),
        ),
      ],
    );
  }
} 