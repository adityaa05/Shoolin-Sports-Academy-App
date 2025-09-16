import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_provider.dart';
import 'admin_students_screen.dart';
import 'admin_attendance_screen.dart';
import 'admin_payments_screen.dart';
import 'admin_reports_screen.dart';
import 'admin_instructors_screen.dart';
import '../models/holiday.dart';
import '../constants/batches.dart';
import '../widgets/animated_button.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const AdminStudentsScreen(),
    const AdminAttendanceScreen(),
    const AdminPaymentsScreen(),
    const AdminReportsScreen(),
    const AdminInstructorsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).initializeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        final today = DateTime.now();
        final upcomingHolidays = provider.holidays.where((h) {
          final diff = h.date.difference(today).inDays;
          return diff >= 0 && diff <= 2;
        }).toList();
        upcomingHolidays.sort((a, b) => a.date.compareTo(b.date));
        
        return Scaffold(
          extendBody: true,
          backgroundColor: const Color(0xFF13131A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF13131A),
            elevation: 0,
            title: Text(
              'Admin Dashboard',
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
                if (_selectedIndex == 0 && upcomingHolidays.isNotEmpty)
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
                      padding: EdgeInsets.all(20 * scale),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14 * scale),
                            ),
                            child: Icon(Icons.event_busy, color: const Color(0xFFF59E0B), size: 26 * scale),
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
                  child: _screens[_selectedIndex],
                ),
              ],
            ),
          ),
          floatingActionButton: _selectedIndex == 1
              ? FloatingActionButton(
                  onPressed: () {
                    // Find the students screen's context and call its add student dialog
                    showDialog(
                      context: context,
                      builder: (context) => AddStudentDialog(provider: Provider.of<AppProvider>(context, listen: false)),
                    );
                  },
                  backgroundColor: const Color(0xFF1976D2),
                  elevation: 8,
                  child: Icon(Icons.add, color: Colors.white, size: 26 * scale),
                )
              : null,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
                  icon: Icon(Icons.dashboard, size: 22 * scale),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people, size: 22 * scale),
                  label: 'Students',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.checklist, size: 22 * scale),
                  label: 'Attendance',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.payment, size: 22 * scale),
                  label: 'Payments',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.analytics, size: 22 * scale),
                  label: 'Reports',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_pin, size: 22 * scale),
                  label: 'Instructors',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(18 * scale);
    final double sectionSpacing = 16 * scale;
    final double cardSpacing = 10 * scale;
    
    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          // Design system loading state: card with gradient, border, padding, and loading indicator
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
                mainAxisAlignment: MainAxisAlignment.center,
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
                    'Loading...',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final activeStudents = provider.getActiveStudents();
        final completedPayments = provider.getCompletedPayments();
        final pendingPayments = provider.getPendingPayments();

        return RefreshIndicator(
          onRefresh: () async {
            await provider.initializeData();
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
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1976D2).withOpacity(0.85),
                              const Color(0xFF1565C0).withOpacity(0.75),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: Colors.white.withOpacity(0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1976D2).withOpacity(0.2),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
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
                                ),
                                child: Icon(Icons.dashboard_rounded, color: const Color(0xFFB2FF00), size: 22 * scale),
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: GoogleFonts.prompt(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16 * scale,
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                    Text(
                                      'Administrator',
                                      style: GoogleFonts.prompt(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24 * scale,
                                        color: Colors.white,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      // Statistics Section Header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB2FF00).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                            child: Icon(Icons.analytics_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                          ),
                          SizedBox(width: 12 * scale),
                          Text(
                            'Dashboard Statistics',
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
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: cardSpacing,
                        mainAxisSpacing: cardSpacing,
                        childAspectRatio: 1.3,
                        children: [
                          _buildStatCard(
                            context,
                            'Active Students',
                            activeStudents.length.toString(),
                            Icons.people_rounded,
                            const Color(0xFF3B82F6),
                            scale,
                            cardRadius,
                            cardPadding,
                          ),
                          _buildStatCard(
                            context,
                            'Completed Payments',
                            completedPayments.length.toString(),
                            Icons.check_circle_rounded,
                            const Color(0xFF10B981),
                            scale,
                            cardRadius,
                            cardPadding,
                          ),
                          _buildStatCard(
                            context,
                            'Pending Payments',
                            pendingPayments.length.toString(),
                            Icons.pending_rounded,
                            const Color(0xFFF59E0B),
                            scale,
                            cardRadius,
                            cardPadding,
                          ),
                          _buildStatCard(
                            context,
                            'Total Revenue',
                            '₹${_calculateTotalRevenue(completedPayments)}',
                            Icons.attach_money_rounded,
                            const Color(0xFF8B5CF6),
                            scale,
                            cardRadius,
                            cardPadding,
                          ),
                        ],
                      ),
                      SizedBox(height: sectionSpacing),

                      // Quick Actions Section Header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB2FF00).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                            child: Icon(Icons.flash_on_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
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
                      SizedBox(height: cardSpacing),
                      
                      // Quick Actions Grid
                      SizedBox(
                        width: double.infinity,
                        child: _buildQuickActionCard(
                          context,
                          'Declare Holiday',
                          Icons.event_busy_rounded,
                          const Color(0xFFEF4444),
                          () async {
                            final provider = Provider.of<AppProvider>(context, listen: false);
                            final created = await showDialog<Holiday>(
                              context: context,
                              builder: (context) => DeclareHolidayDialog(scale: scale, cardRadius: cardRadius),
                            );
                            if (created != null) {
                              await provider.addHoliday(created);
                            }
                          },
                          scale,
                          cardRadius,
                          cardPadding,
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      
                      // Upcoming Holidays Section Header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12 * scale),
                            ),
                            child: Icon(Icons.event_rounded, color: const Color(0xFFF59E0B), size: 20 * scale),
                          ),
                          SizedBox(width: 12 * scale),
                          Text(
                            'Upcoming Holidays',
                            style: GoogleFonts.prompt(
                              fontWeight: FontWeight.w600, 
                              fontSize: 18 * scale, 
                              color: Colors.white
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: cardSpacing),
                      
                      // Upcoming Holidays List
                      Consumer<AppProvider>(
                        builder: (context, provider, child) {
                          final holidays = provider.holidays.where((h) => h.date.isAfter(DateTime.now().subtract(const Duration(days: 1)))).toList();
                          if (holidays.isEmpty) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF1976D2).withOpacity(0.08),
                                    const Color(0xFF1565C0).withOpacity(0.04),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(cardRadius),
                                border: Border.all(color: Colors.white.withOpacity(0.08)),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(28 * scale),
                                child: Column(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(14 * scale),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(18 * scale),
                                      ),
                                      child: Icon(
                                        Icons.event_busy_rounded,
                                        size: 42 * scale,
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                    SizedBox(height: 16 * scale),
                                    Text(
                                      'No upcoming holidays',
                                      style: GoogleFonts.prompt(
                                        fontSize: 18 * scale,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 6 * scale),
                                    Text(
                                      'All classes are scheduled',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14 * scale,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: holidays.length,
                            itemBuilder: (context, index) {
                              final holiday = holidays[index];
                              return Container(
                                margin: EdgeInsets.only(bottom: cardSpacing),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF1976D2).withOpacity(0.08),
                                      const Color(0xFF1565C0).withOpacity(0.04),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(cardRadius),
                                  border: Border.all(color: Colors.white.withOpacity(0.08)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
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
                                        children: [
                                          Container(
                                            width: 48 * scale,
                                            height: 48 * scale,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFF59E0B).withOpacity(0.2),
                                              borderRadius: BorderRadius.circular(14 * scale),
                                            ),
                                            child: Icon(
                                              Icons.event_busy_rounded,
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
                                                  DateFormat('EEE, MMM d, y').format(holiday.date),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16 * scale,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                SizedBox(height: 6 * scale),
                                                Wrap(
                                                  spacing: 6 * scale,
                                                  runSpacing: 3 * scale,
                                                  children: [
                                                    Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFB2FF00).withOpacity(0.2),
                                                        borderRadius: BorderRadius.circular(16 * scale),
                                                        border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                                                      ),
                                                      child: Text(
                                                        '${holiday.batch == null ? 'All Batches' : holiday.batch!}',
                                                        style: GoogleFonts.poppins(
                                                          fontSize: 11 * scale,
                                                          fontWeight: FontWeight.w600,
                                                          color: const Color(0xFFB2FF00),
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          PopupMenuButton<String>(
                                            icon: Icon(Icons.more_vert, color: Colors.white.withOpacity(0.6), size: 22 * scale),
                                            color: const Color(0xFF1F2937),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scale)),
                                            onSelected: (value) async {
                                              if (value == 'delete') {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) => _buildDeleteHolidayDialog(context, holiday, scale, cardRadius),
                                                );
                                                if (confirm == true) {
                                                  await provider.deleteHoliday(holiday.id!);
                                                }
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'delete',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.delete_rounded, color: const Color(0xFFEF4444), size: 18 * scale),
                                                    SizedBox(width: 10 * scale),
                                                    Text(
                                                      'Delete',
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 13 * scale,
                                                        color: const Color(0xFFEF4444),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 10 * scale),
                                      Text(
                                        holiday.reason,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13 * scale,
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      SizedBox(height: sectionSpacing), // Bottom padding
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

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color, double scale, double cardRadius, EdgeInsets cardPadding) {
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
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: cardPadding,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(10 * scale),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14 * scale),
                ),
                child: Icon(
                  icon,
                  size: 28 * scale,
                  color: color,
                ),
              ),
              SizedBox(height: 12 * scale),
              Text(
                value,
                style: GoogleFonts.prompt(
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontSize: 22 * scale,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6 * scale),
              SizedBox(
                width: 90 * scale,
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13 * scale,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.15),
            color.withOpacity(0.08),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cardRadius),
          child: Padding(
            padding: cardPadding,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.all(10 * scale),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
                    child: Icon(
                      icon,
                      size: 24 * scale,
                      color: color,
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  SizedBox(
                    width: 90 * scale,
                    child: Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 12 * scale,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildDeleteHolidayDialog(BuildContext context, Holiday holiday, double scale, double cardRadius) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF13131A), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Padding(
          padding: EdgeInsets.all(24 * scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14 * scale),
                      border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                    ),
                    child: Icon(Icons.delete_rounded, color: const Color(0xFFEF4444), size: 24 * scale),
                  ),
                  SizedBox(width: 16 * scale),
                  Text(
                    'Delete Holiday',
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 18 * scale,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20 * scale),
              Text(
                'Are you sure you want to delete this holiday?',
                style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 15 * scale),
              ),
              SizedBox(height: 20 * scale),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12 * scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 13 * scale, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(width: 16 * scale),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius - 2 * scale)),
                        padding: EdgeInsets.symmetric(vertical: 12 * scale),
                        elevation: 0,
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13 * scale),
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

  String _calculateTotalRevenue(List payments) {
    double total = 0;
    for (var payment in payments) {
      total += payment.amount;
    }
    return total.toStringAsFixed(2);
  }
}

class DeclareHolidayDialog extends StatefulWidget {
  final double scale;
  final double cardRadius;
  
  const DeclareHolidayDialog({
    super.key,
    required this.scale,
    required this.cardRadius,
  });

  @override
  State<DeclareHolidayDialog> createState() => _DeclareHolidayDialogState();
}

class _DeclareHolidayDialogState extends State<DeclareHolidayDialog> {
  final _formKey = GlobalKey<FormState>();
  DateTime _date = DateTime.now();
  String? _selectedBatch;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF13131A), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(widget.cardRadius),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Padding(
          padding: EdgeInsets.all(24 * widget.scale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12 * widget.scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14 * widget.scale),
                      border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                    ),
                    child: Icon(Icons.event_busy_rounded, color: const Color(0xFFF59E0B), size: 24 * widget.scale),
                  ),
                  SizedBox(width: 16 * widget.scale),
                  Text(
                    'Declare Holiday',
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 18 * widget.scale,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20 * widget.scale),
              
              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Date picker
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(widget.cardRadius - 2 * widget.scale),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: ListTile(
                        leading: Icon(Icons.calendar_today_rounded, color: const Color(0xFFB2FF00), size: 20 * widget.scale),
                        title: Text(
                          DateFormat('EEE, MMM d, y').format(_date),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 14 * widget.scale,
                          ),
                        ),
                        onTap: () async {
                          final picked = await showDialog<DateTime>(
                            context: context,
                            builder: (context) {
                              DateTime tempSelected = _date;
                              return Dialog(
                                backgroundColor: Colors.transparent,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF13131A), Color(0xFF1976D2)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(widget.cardRadius),
                                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 18,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(20 * widget.scale),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(12 * widget.scale),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF1976D2).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(14 * widget.scale),
                                                border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                                              ),
                                              child: Icon(Icons.calendar_today_rounded, color: const Color(0xFF1976D2), size: 24 * widget.scale),
                                            ),
                                            SizedBox(width: 16 * widget.scale),
                                            Text(
                                              'Select Date',
                                              style: GoogleFonts.prompt(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontSize: 18 * widget.scale,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20 * widget.scale),
                                        SizedBox(
                                          width: 320 * widget.scale,
                                          child: TableCalendar(
                                            firstDay: DateTime(2020),
                                            lastDay: DateTime(2100),
                                            focusedDay: tempSelected,
                                            selectedDayPredicate: (day) => isSameDay(day, tempSelected),
                                            onDaySelected: (selected, _) {
                                              tempSelected = selected;
                                              setState(() {});
                                            },
                                            calendarStyle: CalendarStyle(
                                              todayDecoration: BoxDecoration(
                                                color: const Color(0xFFB2FF00).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(12 * widget.scale),
                                                border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                                              ),
                                              selectedDecoration: BoxDecoration(
                                                color: const Color(0xFF1976D2),
                                                borderRadius: BorderRadius.circular(12 * widget.scale),
                                                border: Border.all(color: const Color(0xFFB2FF00), width: 2),
                                              ),
                                              defaultTextStyle: GoogleFonts.poppins(
                                                color: Colors.white.withOpacity(0.85),
                                                fontSize: 14 * widget.scale,
                                              ),
                                              weekendTextStyle: GoogleFonts.poppins(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: 14 * widget.scale,
                                              ),
                                              todayTextStyle: GoogleFonts.poppins(
                                                color: const Color(0xFFB2FF00),
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14 * widget.scale,
                                              ),
                                              selectedTextStyle: GoogleFonts.prompt(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15 * widget.scale,
                                              ),
                                              outsideTextStyle: GoogleFonts.poppins(
                                                color: Colors.white.withOpacity(0.3),
                                                fontSize: 13 * widget.scale,
                                              ),
                                              cellMargin: EdgeInsets.all(2 * widget.scale),
                                            ),
                                            headerStyle: HeaderStyle(
                                              titleTextStyle: GoogleFonts.prompt(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16 * widget.scale,
                                              ),
                                              formatButtonVisible: false,
                                              leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white, size: 22 * widget.scale),
                                              rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white, size: 22 * widget.scale),
                                              titleCentered: true,
                                            ),
                                            daysOfWeekStyle: DaysOfWeekStyle(
                                              weekdayStyle: GoogleFonts.poppins(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: 13 * widget.scale,
                                              ),
                                              weekendStyle: GoogleFonts.poppins(
                                                color: Colors.white.withOpacity(0.7),
                                                fontSize: 13 * widget.scale,
                                              ),
                                            ),
                                            calendarFormat: CalendarFormat.month,
                                            availableGestures: AvailableGestures.horizontalSwipe,
                                            rowHeight: 38 * widget.scale,
                                          ),
                                        ),
                                        SizedBox(height: 20 * widget.scale),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.symmetric(vertical: 12 * widget.scale, horizontal: 20 * widget.scale),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(widget.cardRadius - 2 * widget.scale),
                                                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                                                ),
                                              ),
                                              child: Text(
                                                'Cancel',
                                                style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 13 * widget.scale, fontWeight: FontWeight.w600),
                                              ),
                                            ),
                                            SizedBox(width: 16 * widget.scale),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, tempSelected),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF1976D2),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.cardRadius - 2 * widget.scale)),
                                                padding: EdgeInsets.symmetric(vertical: 12 * widget.scale, horizontal: 20 * widget.scale),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                'Select',
                                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13 * widget.scale),
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
                          if (picked != null) setState(() => _date = picked);
                        },
                      ),
                    ),
                    SizedBox(height: 16 * widget.scale),
                    
                    // Batch dropdown
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(widget.cardRadius - 2 * widget.scale),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedBatch,
                        isExpanded: true,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * widget.scale),
                        decoration: InputDecoration(
                          labelText: 'Batch (optional)',
                          labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 14 * widget.scale),
                          prefixIcon: Icon(Icons.group_rounded, color: const Color(0xFFB2FF00), size: 20 * widget.scale),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16 * widget.scale),
                        ),
                        dropdownColor: const Color(0xFF1F2937),
                        items: [
                          DropdownMenuItem(value: null, child: Text('All Batches', style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * widget.scale))),
                          ...kBatches.map((b) => DropdownMenuItem(value: b, child: Text(b, style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * widget.scale)))).toList(),
                        ],
                        onChanged: (val) => setState(() => _selectedBatch = val),
                      ),
                    ),
                    
                    if (_selectedBatch != null)
                      Padding(
                        padding: EdgeInsets.only(top: 8 * widget.scale),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12 * widget.scale, vertical: 6 * widget.scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB2FF00).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20 * widget.scale),
                              border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                            ),
                            child: Text(
                              getBatchTime(_selectedBatch!) != null
                                ? 'Days: ' + getBatchTime(_selectedBatch!)!.daysOfWeek.map((d) => ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][d-1]).join(", ")
                                : '',
                              style: GoogleFonts.poppins(fontSize: 12 * widget.scale, color: const Color(0xFFB2FF00), fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                    
                    SizedBox(height: 16 * widget.scale),
                    
                    // Reason field
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(widget.cardRadius - 2 * widget.scale),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: TextFormField(
                        controller: _reasonController,
                        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * widget.scale),
                        decoration: InputDecoration(
                          labelText: 'Reason',
                          labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 14 * widget.scale),
                          prefixIcon: Icon(Icons.note_rounded, color: const Color(0xFFB2FF00), size: 20 * widget.scale),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16 * widget.scale),
                        ),
                        validator: (v) => v == null || v.isEmpty ? 'Enter a reason' : null,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20 * widget.scale),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12 * widget.scale),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(widget.cardRadius - 2 * widget.scale),
                          side: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 13 * widget.scale, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  SizedBox(width: 16 * widget.scale),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final now = DateTime.now();
                          final holiday = Holiday(
                            date: _date,
                            batch: _selectedBatch,
                            reason: _reasonController.text,
                            createdBy: 'admin',
                            createdAt: now,
                          );
                          Navigator.pop(context, holiday);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(widget.cardRadius - 2 * widget.scale)),
                        padding: EdgeInsets.symmetric(vertical: 12 * widget.scale),
                        elevation: 0,
                      ),
                      child: Text(
                        'Declare',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13 * widget.scale),
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
} 