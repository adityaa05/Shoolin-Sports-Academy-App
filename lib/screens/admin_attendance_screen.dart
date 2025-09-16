import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_provider.dart';
import '../models/attendance.dart';
import '../constants/batches.dart';
import '../widgets/animated_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:table_calendar/table_calendar.dart';
import '../utils/attendance_permissions.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  int _currentTabIndex = 0;
  DateTime _selectedDate = DateTime.now();
  DateTime _selectedMonth = DateTime.now();
  String? _selectedBatch;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadAttendanceByDate(_selectedDate);
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget _buildSectionHeader([double scale = 1.0]) {
    return Padding(
                        padding: EdgeInsets.only(bottom: 12.0 * scale),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12 * scale),
                                border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                              ),
                              child: Icon(Icons.fact_check, color: const Color(0xFF1976D2), size: 24 * scale),
                            ),
                            SizedBox(width: 16 * scale),
                            Text(
                              'Attendance Management',
                              style: GoogleFonts.prompt(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 20 * scale,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final cardRadius = 18 * scale;
    final sectionSpacing = 20 * scale;
    final cardSpacing = 12 * scale;
    final segmentHeight = 44.0 * scale;
    final segmentPadding = EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 8 * scale);
    final segmentBorderRadius = BorderRadius.circular(22 * scale);
    final segmentTextStyle = GoogleFonts.prompt(
      fontSize: 16 * scale,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      letterSpacing: 0.2,
    );
    final segmentBgGradient = LinearGradient(
      colors: [Color(0xFF13131A), Color(0xFF1976D2)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      decoration: BoxDecoration(
        gradient: segmentBgGradient,
      ),
      child: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8 * scale),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: sectionSpacing),
                  // Section header (keep as before)
                  _buildSectionHeader(scale),
                  SizedBox(height: sectionSpacing),
                  // CupertinoSegmentedControl replaces TabBar
                      Container(
                    padding: segmentPadding,
                        decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: segmentBorderRadius,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8 * scale,
                          offset: Offset(0, 2 * scale),
                        ),
                      ],
                    ),
                    child: CupertinoSegmentedControl<int>(
                      groupValue: _currentTabIndex,
                      borderColor: Colors.transparent,
                      selectedColor: Color(0xFF1976D2),
                      unselectedColor: Colors.transparent,
                      pressedColor: Color(0xFF1976D2).withOpacity(0.15),
                      children: {
                        0: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 6 * scale),
                          child: Text('Mark Attendance', style: segmentTextStyle),
                        ),
                        1: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 6 * scale),
                          child: Text('Attendance Report', style: segmentTextStyle),
                        ),
                      },
                      onValueChanged: (int index) {
                        setState(() {
                          _currentTabIndex = index;
                        });
                      },
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      Expanded(
                    child: IndexedStack(
                      index: _currentTabIndex,
                          children: [
                            _buildMarkAttendanceTab(scale),
                            _buildAttendanceReportTab(scale),
                          ],
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

  Widget _buildMarkAttendanceTab([double scale = 1.0]) {
    final cardRadius = 18 * scale;
    final cardPadding = EdgeInsets.all(20 * scale);
    final sectionSpacing = 20 * scale;
    final cardSpacing = 12 * scale;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Padding(
            padding: EdgeInsets.only(bottom: 8.0 * scale),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12 * scale),
                    border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                  ),
                  child: Icon(Icons.add_task, color: const Color(0xFF1976D2), size: 24 * scale),
                ),
                SizedBox(width: 16 * scale),
                Text(
                  'Mark Attendance',
                  style: GoogleFonts.prompt(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 18 * scale,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox(height: sectionSpacing),
          // Date Selection Card
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(cardRadius),
              border: Border.all(color: Colors.white.withOpacity(0.12)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 14 * scale,
                  offset: Offset(0, 4 * scale),
                ),
              ],
            ),
            child: Padding(
              padding: cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Date',
                    style: GoogleFonts.prompt(
                      fontSize: 16 * scale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10 * scale),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 14 * scale, vertical: 8 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(30 * scale),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, color: const Color(0xFF1976D2), size: 18 * scale),
                            SizedBox(width: 8 * scale),
                            Text(
                              DateFormat('EEE, MMM d, y').format(_selectedDate),
                          style: GoogleFonts.poppins(
                                fontSize: 15 * scale,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                          ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                        ),
                          ],
                      ),
                      ),
                      SizedBox(width: 12 * scale),
                      IconButton(
                        icon: Icon(Icons.edit_calendar, color: Color(0xFFB2FF00), size: 22 * scale),
                        tooltip: 'Change Date',
                        onPressed: () async {
                          DateTime tempSelected = _selectedDate;
                          final batchDays = _selectedBatch != null ? (getBatchTime(_selectedBatch!)?.daysOfWeek ?? []) : [];
                          final picked = await showDialog<DateTime>(
                            context: context,
                            builder: (context) {
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
                                    padding: cardPadding,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(12 * scale),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFB2FF00).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(14 * scale),
                                                border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                                              ),
                                              child: Icon(Icons.calendar_today_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                                            ),
                                            SizedBox(width: 16 * scale),
                                            Text(
                                              'Select Date',
                                              style: GoogleFonts.prompt(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontSize: 18 * scale,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20 * scale),
                                        SizedBox(
                                          width: 320 * scale,
                                          child: TableCalendar(
                                            firstDay: DateTime(2020),
                                            lastDay: DateTime(2100),
                                            focusedDay: tempSelected,
                                            selectedDayPredicate: (day) => isSameDay(day, tempSelected),
                                            onDaySelected: (selected, _) {
                                              if (_selectedBatch == null || batchDays.isEmpty || batchDays.contains(selected.weekday)) {
                                                tempSelected = selected;
                                                (context as Element).markNeedsBuild();
                                              }
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
                                            enabledDayPredicate: (date) {
                                              if (_selectedBatch == null || batchDays.isEmpty) return true;
                                              return batchDays.contains(date.weekday);
                                            },
                                          ),
                                        ),
                                        SizedBox(height: 20 * scale),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 20 * scale),
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
                                            SizedBox(width: 16 * scale),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, tempSelected),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF1976D2),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius - 2 * scale)),
                                                padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 20 * scale),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                'Select',
                                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13 * scale),
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
                          if (picked != null) setState(() => _selectedDate = picked);
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    'Tap the calendar to pick a different date.',
                    style: GoogleFonts.poppins(
                      fontSize: 13 * scale,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: sectionSpacing),
          // Mark New Attendance Button
          AnimatedButton(
                  width: double.infinity,
            height: 52 * scale,
                  backgroundColor: const Color(0xFFB2FF00),
                  foregroundColor: const Color(0xFF13131A),
                  text: 'Mark New Attendance',
                  onPressed: () => _showMarkAttendanceDialog(context),
                  logoImage: null,
                  addBorder: null,
                ),
          SizedBox(height: sectionSpacing),
          // Attendance Summary Card
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              final today = DateTime.now();
              // Check if today is a session day for any batch
              final isSessionDay = kBatchTimes.any((batchTime) => batchTime.daysOfWeek.contains(today.weekday));
              // Check if today is a holiday for all batches (batch == null)
              final isAllBatchHoliday = provider.holidays.any((h) =>
                h.date.year == today.year &&
                h.date.month == today.month &&
                h.date.day == today.day &&
                (h.batch == null)
              );
              if (!isSessionDay || isAllBatchHoliday) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.10),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(cardRadius),
                    border: Border.all(color: Colors.white.withOpacity(0.12)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.10),
                        blurRadius: 14 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: cardPadding,
                    child: Row(
                      children: [
                        Icon(Icons.event_busy, color: Color(0xFFF59E0B), size: 22 * scale),
                        SizedBox(width: 10 * scale),
                        Text(
                          'No sessions/holiday today',
                          style: GoogleFonts.prompt(
                            fontSize: 17 * scale,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final attendanceList = provider.attendance;
              final presentCount = attendanceList.where((a) => a.isPresent).length;
              final absentCount = attendanceList.where((a) => !a.isPresent).length;
              final totalCount = attendanceList.length;
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.10),
                      Colors.white.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 14 * scale,
                      offset: Offset(0, 4 * scale),
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
                          Icon(Icons.analytics, color: Color(0xFF42A5F5), size: 22 * scale),
                          SizedBox(width: 10 * scale),
                          Text(
                            'Today\'s Summary',
                            style: GoogleFonts.prompt(
                              fontSize: 17 * scale,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16 * scale),
                      Wrap(
                        spacing: 12 * scale,
                        runSpacing: 8 * scale,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(30 * scale),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_circle, color: const Color(0xFF10B981), size: 18 * scale),
                                SizedBox(width: 6 * scale),
                                Text(
                                  '$presentCount Present',
                              style: GoogleFonts.poppins(
                                    color: const Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                                fontSize: 14 * scale,
                              ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                              decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(30 * scale),
                              ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                                children: [
                                Icon(Icons.cancel, color: const Color(0xFFEF4444), size: 18 * scale),
                                SizedBox(width: 6 * scale),
                                  Text(
                                  '$absentCount Absent',
                                    style: GoogleFonts.poppins(
                                    color: const Color(0xFFEF4444),
                                    fontWeight: FontWeight.w600,
                                      fontSize: 14 * scale,
                                    ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                              decoration: BoxDecoration(
                              color: const Color(0xFFB2FF00).withOpacity(0.18),
                              borderRadius: BorderRadius.circular(30 * scale),
                              ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                                children: [
                                Icon(Icons.people, color: const Color(0xFFB2FF00), size: 18 * scale),
                                SizedBox(width: 6 * scale),
                                  Text(
                                  '$totalCount Total',
                                    style: GoogleFonts.poppins(
                                    color: const Color(0xFFB2FF00),
                                    fontWeight: FontWeight.w600,
                                      fontSize: 14 * scale,
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
            }, // end builder
          ),
          SizedBox(height: sectionSpacing),
          // Attendance Records
          Consumer<AppProvider>(
            builder: (context, provider, child) {
              final attendanceList = provider.attendance;
              if (provider.isLoading) {
                return Container(
                  height: 200 * scale,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
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
                  child: Center(
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
              if (attendanceList.isEmpty) {
                return Container(
                  // Remove margin and make the card fit the width
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.white.withOpacity(0.05),
                      ],
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(12 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14 * scale),
                            border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                          ),
                          child: Icon(
                            Icons.event_busy,
                            size: 32 * scale,
                            color: const Color(0xFF1976D2),
                          ),
                        ),
                        SizedBox(height: 18 * scale),
                        Text(
                          'No Attendance Records',
                          style: GoogleFonts.prompt(
                            fontWeight: FontWeight.w700,
                            fontSize: 18 * scale,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 10 * scale),
                        Text(
                          'for this date',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 14 * scale,
                            color: Colors.white.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        // Removed the Mark Attendance button from the empty state card
                      ],
                    ),
                  ),
                );
              }
              return Column(
                children: attendanceList.asMap().entries.map((entry) {
                  final index = entry.key;
                  final attendance = entry.value;
                  final student = provider.getStudentById(attendance.studentId);
                  if (student == null) return SizedBox.shrink();
                  return Container(
                    margin: EdgeInsets.only(bottom: cardSpacing),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(cardRadius),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8 * scale,
                          offset: Offset(0, 2 * scale),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16 * scale),
                      leading: Container(
                        width: 48 * scale,
                        height: 48 * scale,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: attendance.isPresent 
                              ? [const Color(0xFF10B981), const Color(0xFF059669)]
                              : [const Color(0xFFEF4444), const Color(0xFFDC2626)],
                          ),
                          borderRadius: BorderRadius.circular(24 * scale),
                          boxShadow: [
                            BoxShadow(
                              color: (attendance.isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.3),
                              blurRadius: 8 * scale,
                              offset: Offset(0, 2 * scale),
                            ),
                          ],
                        ),
                        child: Icon(
                          attendance.isPresent ? Icons.check : Icons.close,
                          color: Colors.white,
                          size: 24 * scale,
                        ),
                      ),
                      title: Text(
                        student.name,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16 * scale,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8 * scale,
                            runSpacing: 4 * scale,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                                decoration: BoxDecoration(
                                  color: (attendance.isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12 * scale),
                                  border: Border.all(
                                    color: (attendance.isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                            attendance.isPresent ? 'Present' : 'Absent',
                            style: GoogleFonts.poppins(
                              color: attendance.isPresent ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              fontWeight: FontWeight.w500,
                                    fontSize: 12 * scale,
                            ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                          ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4 * scale),
                          Text(
                            DateFormat('h:mm a').format(attendance.date),
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 12 * scale,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Color(0xFFB2FF00), size: 24 * scale),
                        color: const Color(0xFF1F2937),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scale)),
                        elevation: 8,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, color: const Color(0xFF3B82F6), size: 18 * scale),
                                SizedBox(width: 10 * scale),
                                Text('Edit', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13 * scale)),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_rounded, color: const Color(0xFFEF4444), size: 18 * scale),
                                SizedBox(width: 10 * scale),
                                Text('Delete', style: GoogleFonts.poppins(color: const Color(0xFFEF4444), fontSize: 13 * scale)),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 10 * scale),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditAttendanceDialog(context, provider, attendance);
                          } else if (value == 'delete') {
                            _showDeleteAttendanceConfirmation(context, provider, attendance);
                          }
                        },
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceReportTab([double scale = 1.0]) {
    final cardRadius = 18 * scale;
    final cardPadding = EdgeInsets.all(20 * scale);
    final sectionSpacing = 20 * scale;
    final cardSpacing = 12 * scale;
    
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Consumer<AppProvider>(
        builder: (context, provider, child) {
          final students = _selectedBatch == null
              ? provider.students
              : provider.students.where((s) => s.isInBatch(_selectedBatch!)).toList();
          final attendance = provider.attendance;
          // Map studentId to attendance count
          final Map<String, int> attendanceCount = {};
          for (var student in students) {
            attendanceCount[student.id!] = attendance
                .where((a) => a.studentId == student.id && a.isPresent)
                .length;
          }
          return SingleChildScrollView(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filters Section
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.08),
                        Colors.white.withOpacity(0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(cardRadius),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 12 * scale,
                        offset: Offset(0, 4 * scale),
                      ),
                    ],
                  ),
                child: Padding(
                    padding: cardPadding,
                  child: Column(
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
                              child: Icon(Icons.filter_list, color: const Color(0xFF1976D2), size: 24 * scale),
                            ),
                            SizedBox(width: 16 * scale),
                            Text(
                              'Report Filters',
                              style: GoogleFonts.prompt(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 18 * scale,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20 * scale),
                      // Batch Filter
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                          borderRadius: BorderRadius.circular(15 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.3)),
                        ),
                        child: PopupMenuButton<String>(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  _selectedBatch ?? 'All Batches',
                                  style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20 * scale),
                            ],
                          ),
                          onSelected: (value) {
                            setState(() {
                              _selectedBatch = value;
                            });
                            provider.loadAttendanceByMonth(
                              year: _selectedMonth.year,
                              month: _selectedMonth.month,
                              batch: value,
                            );
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: null,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(16 * scale),
                                  border: Border.all(color: Colors.white.withOpacity(0.18)),
                                ),
                                child: Text('All Batches', style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white)),
                              ),
                            ),
                            ...kBatches.map((b) => PopupMenuItem(
                              value: b,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1976D2).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16 * scale),
                                  border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                                ),
                                child: Text(b, style: GoogleFonts.poppins(fontSize: 14 * scale, color: const Color(0xFF1976D2))),
                              ),
                            )).toList(),
                          ],
                          color: const Color(0xFF28282F),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                          elevation: 8,
                        ),
                      ),
                      if (_selectedBatch != null) ...[
                        SizedBox(height: 12 * scale),
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [const Color(0xFFB2FF00).withOpacity(0.2), const Color(0xFFB2FF00).withOpacity(0.1)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            borderRadius: BorderRadius.circular(10 * scale),
                              border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                          ),
                          child: Text(
                            getBatchTime(_selectedBatch!) != null
                              ? 'Days: ' + getBatchTime(_selectedBatch!)!.daysOfWeek.map((d) => ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][d-1]).join(", ")
                              : '',
                            style: GoogleFonts.poppins(
                              fontSize: 12 * scale,
                              color: const Color(0xFFB2FF00),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                        ),
                      ],
                      SizedBox(height: 16 * scale),
                      // Month Picker
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(15 * scale),
                            border: Border.all(color: Colors.white.withOpacity(0.3)),
                          ),
                          child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                            leading: Container(
                              padding: EdgeInsets.all(8 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB2FF00).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10 * scale),
                              ),
                              child: Icon(Icons.calendar_today, color: Color(0xFFB2FF00), size: 20 * scale),
                            ),
                        title: Text(
                          'Select Month',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: 16 * scale,
                          ),
                        ),
                        subtitle: Text(
                          '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                        ),
                        trailing: Icon(Icons.arrow_drop_down, color: Color(0xFFB2FF00), size: 20 * scale),
                        onTap: () async {
                          DateTime tempSelected = _selectedMonth;
                          final picked = await showDialog<DateTime>(
                            context: context,
                            builder: (context) {
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
                                    padding: cardPadding,
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: EdgeInsets.all(12 * scale),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFB2FF00).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(14 * scale),
                                                border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                                              ),
                                              child: Icon(Icons.calendar_today_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                                            ),
                                            SizedBox(width: 16 * scale),
                                            Text(
                                              'Select Month',
                                              style: GoogleFonts.prompt(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                fontSize: 18 * scale,
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 20 * scale),
                                        SizedBox(
                                          width: 320 * scale,
                                          child: TableCalendar(
                                            firstDay: DateTime(2020),
                                            lastDay: DateTime(2100),
                                            focusedDay: tempSelected,
                                            selectedDayPredicate: (day) => isSameDay(day, tempSelected),
                                            onDaySelected: (selected, _) {
                                              tempSelected = selected;
                                              (context as Element).markNeedsBuild();
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
                                        SizedBox(height: 20 * scale),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(context),
                                              style: TextButton.styleFrom(
                                                padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 20 * scale),
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
                                            SizedBox(width: 16 * scale),
                                            ElevatedButton(
                                              onPressed: () => Navigator.pop(context, tempSelected),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF1976D2),
                                                foregroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius - 2 * scale)),
                                                padding: EdgeInsets.symmetric(vertical: 12 * scale, horizontal: 20 * scale),
                                                elevation: 0,
                                              ),
                                              child: Text(
                                                'Select',
                                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13 * scale),
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
                          if (picked != null) {
                            setState(() {
                              _selectedMonth = picked;
                            });
                            provider.loadAttendanceByMonth(
                              year: picked.year,
                              month: picked.month,
                              batch: _selectedBatch,
                            );
                          }
                        },
                          ),
                      ),
                    ],
                  ),
                ),
              ),
                SizedBox(height: sectionSpacing),
              // Attendance Report List
                students.isEmpty
                    ? Container(
                        margin: EdgeInsets.symmetric(vertical: sectionSpacing),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF13131A), Color(0xFF1976D2)],
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.10),
                              blurRadius: 18 * scale,
                              offset: Offset(0, 6 * scale),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: cardPadding,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16 * scale),
                                decoration: BoxDecoration(
                                  color: Color(0xFF1976D2).withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(32 * scale),
                                ),
                                child: Icon(
                                  Icons.event_busy,
                                  size: 44 * scale,
                                  color: Color(0xFF1976D2),
                                ),
                              ),
                              SizedBox(height: 18 * scale),
                              Text(
                                'No Attendance Records',
                                style: GoogleFonts.prompt(
                                  fontSize: 20 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 10 * scale),
                              Text(
                                'Try changing the batch or month to see attendance records.',
                                style: GoogleFonts.poppins(
                                  fontSize: 15 * scale,
                                  color: Colors.white70,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: cardSpacing),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withOpacity(0.08),
                                  Colors.white.withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(cardRadius),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 8 * scale,
                                  offset: Offset(0, 2 * scale),
                                ),
                              ],
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(16 * scale),
                              leading: Container(
                                width: 48 * scale,
                                height: 48 * scale,
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFB2FF00), Color(0xFF10B981)],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(24 * scale),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB2FF00).withOpacity(0.3),
                                      blurRadius: 8 * scale,
                                      offset: Offset(0, 2 * scale),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    student.name[0].toUpperCase(),
                                    style: GoogleFonts.prompt(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18 * scale,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                student.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 16 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    spacing: 8 * scale,
                                    runSpacing: 4 * scale,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1976D2).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12 * scale),
                                          border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                                        ),
                                        child: Text(
                                'Sessions attended: ${attendanceCount[student.id!] ?? 0}',
                                style: GoogleFonts.poppins(
                                            fontSize: 12 * scale,
                                            color: const Color(0xFF1976D2),
                                            fontWeight: FontWeight.w500,
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
                          );
                        },
              ),
            ],
            ),
          );
        },
      ),
    );
  }

  void _showMarkAttendanceDialog(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 500) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: MarkAttendanceDialog(selectedDate: DateTime.now(), isBottomSheet: true),
        ),
      );
    } else {
    showDialog(
      context: context,
        builder: (context) => MarkAttendanceDialog(selectedDate: DateTime.now()),
    );
    }
  }

  void _showEditAttendanceDialog(BuildContext context, AppProvider provider, Attendance attendance) {
    showDialog(
      context: context,
      builder: (context) => EditAttendanceDialog(provider: provider, attendance: attendance),
    );
  }

  void _showDeleteAttendanceConfirmation(BuildContext context, AppProvider provider, Attendance attendance) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final cardRadius = 18 * scale;
    final cardPadding = EdgeInsets.all(20 * scale);
    final sectionSpacing = 20 * scale;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 16 * scale),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400 * scale),
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF13131A), Color(0xFF1976D2)],
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
                          child: Icon(
                            Icons.delete_forever,
                            color: const Color(0xFFEF4444),
                            size: 24 * scale,
                          ),
                        ),
                        SizedBox(width: 16 * scale),
                        Expanded(
                          child: Text(
                            'Delete Attendance Record',
                            style: GoogleFonts.prompt(
                              fontWeight: FontWeight.w600,
                              fontSize: 18 * scale,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: sectionSpacing),
                    Text(
                      'Are you sure you want to delete this attendance record?',
                      style: GoogleFonts.poppins(
                        fontSize: 14 * scale,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: sectionSpacing),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                          ),
                        ),
                        SizedBox(width: 12 * scale),
                        AnimatedButton(
                          width: 120 * scale,
                          height: 40 * scale,
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          text: 'Delete',
                          onPressed: () {
                            provider.deleteAttendance(attendance.id!);
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Attendance record deleted',
                                  style: GoogleFonts.poppins(fontSize: 14 * scale),
                                ),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          },
                          logoImage: null,
                          addBorder: null,
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
    );
  }


}

class MarkAttendanceDialog extends StatefulWidget {
  final DateTime selectedDate;
  final bool isBottomSheet;
  const MarkAttendanceDialog({super.key, required this.selectedDate, this.isBottomSheet = false});
  @override
  State<MarkAttendanceDialog> createState() => _MarkAttendanceDialogState();
}

class _MarkAttendanceDialogState extends State<MarkAttendanceDialog> {
  String? _selectedBatch;
  String? _selectedStudentId;
  bool _isPresent = true;
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedStudentId == null) {
      ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
        SnackBar(
          content: Text(
            'Please select a student',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
      return;
    }

    // Debug print for isPresent
    print('Marking attendance: isPresent =  [32m [1m [4m [7m [41m$_isPresent [0m');

    final provider = Provider.of<AppProvider>(context, listen: false);
    final attendance = Attendance(
      studentId: _selectedStudentId!,
      date: _selectedDate,
      isPresent: _isPresent,
      batch: _selectedBatch!,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    provider.markAttendance(attendance).then((_) {
      // Refresh the attendance report for the current month and batch
      provider.loadAttendanceByMonth(
        year: _selectedDate.year,
        month: _selectedDate.month,
        batch: _selectedBatch,
      );
      ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
        SnackBar(
          content: Text(
            'Attendance marked for  [32m [1m [4m [7m [41m${_isPresent ? 'present' : 'absent'} [0m',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
      Navigator.of(context).pop();
    }).catchError((e) {
      ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to mark attendance: '
            '${e is Exception ? e.toString() : 'Unknown error'}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final allStudents = provider.getActiveStudents();
    final filteredStudents = _selectedBatch == null
      ? allStudents
      : allStudents.where((s) => s.isInBatch(_selectedBatch!)).toList();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final scale = width < 400 ? 0.85 : width > 900 ? 1.18 : width > 700 ? 1.10 : 1.0;
    final cardRadius = 18 * scale;
    final cardPadding = EdgeInsets.all(width < 400 ? 10 * scale : 20 * scale);
    final sectionSpacing = 20 * scale;
    final cardSpacing = 12 * scale;
    final maxDialogWidth = width < 400 ? width - 16 : width < 700 ? 360 * scale : 480 * scale;
    final maxDialogHeight = height * 0.92;
    final dialogContent = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxDialogWidth,
          maxHeight: maxDialogHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF13131A), Color(0xFF1976D2)],
            ),
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 24 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: Padding(
            padding: cardPadding,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12 * scale),
                        decoration: BoxDecoration(
                          color: Color(0xFFB2FF00).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16 * scale),
                        ),
                        child: Icon(
                          Icons.fact_check,
                          color: Color(0xFFB2FF00),
                          size: 28 * scale,
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      Text(
        'Mark Attendance',
        style: GoogleFonts.prompt(
          fontWeight: FontWeight.bold,
                          fontSize: 22 * scale,
          color: Colors.white,
        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),
            // Batch Selection
            Container(
                    margin: EdgeInsets.only(bottom: cardSpacing),
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
              decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.10),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(15 * scale),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: PopupMenuButton<String>(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _selectedBatch ?? 'Select Batch',
                              style: GoogleFonts.poppins(fontSize: 15 * scale, color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                          Icon(Icons.arrow_drop_down, color: Colors.white70, size: 22 * scale),
                  ],
                ),
                onSelected: (value) => setState(() => _selectedBatch = value),
                itemBuilder: (context) => kBatches.map((batch) => PopupMenuItem(
                  value: batch,
                  child: Container(
                    width: 200 * scale,
                          child: Text(batch, style: GoogleFonts.poppins(fontSize: 15 * scale, color: Colors.white)),
                  ),
                )).toList(),
                      color: Color(0xFF28282F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                elevation: 8,
              ),
            ),
            // Student Selection
            Container(
                    margin: EdgeInsets.only(bottom: cardSpacing),
              padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
              decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.10),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(15 * scale),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: PopupMenuButton<String>(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        (_selectedStudentId != null && filteredStudents.any((s) => s.id == _selectedStudentId))
                          ? filteredStudents.firstWhere((s) => s.id == _selectedStudentId).name
                          : 'Select Student',
                          style: GoogleFonts.poppins(fontSize: 15 * scale, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                      ),
                    ),
                          Icon(Icons.arrow_drop_down, color: Colors.white70, size: 22 * scale),
                  ],
                ),
                onSelected: (value) => setState(() => _selectedStudentId = value),
                itemBuilder: (context) => filteredStudents.map((student) => PopupMenuItem(
                  value: student.id,
                  child: Container(
                    width: 200 * scale,
                          child: Text(student.name, style: GoogleFonts.poppins(fontSize: 15 * scale, color: Colors.white)),
                  ),
                )).toList(),
                      color: Color(0xFF28282F),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                elevation: 8,
              ),
            ),
            // Attendance Status
            Container(
                    margin: EdgeInsets.only(bottom: cardSpacing),
              decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(15 * scale),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0 * scale),
                child: Column(
                  children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8 * scale),
                                decoration: BoxDecoration(
                                  color: Color(0xFF10B981).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10 * scale),
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF10B981),
                                  size: 22 * scale,
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                    Text(
                      'Attendance Status',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * scale,
                        color: Colors.white,
                      ),
                              ),
                            ],
                    ),
                    SizedBox(height: 16 * scale),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isPresent = true),
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              padding: EdgeInsets.all(16 * scale),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: _isPresent
                                      ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                      : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                                ),
                                borderRadius: BorderRadius.circular(12 * scale),
                                border: Border.all(
                                  color: _isPresent ? const Color(0xFF10B981) : Colors.white.withOpacity(0.3),
                                  width: _isPresent ? 3 : 1.5,
                                ),
                                boxShadow: _isPresent
                                    ? [
                                        BoxShadow(
                                          color: const Color(0xFF10B981).withOpacity(0.4),
                                          blurRadius: 12 * scale,
                                          offset: Offset(0, 4 * scale),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: _isPresent ? Colors.white : Colors.white70,
                                    size: 32 * scale,
                                  ),
                                  SizedBox(height: 8 * scale),
                                  Text(
                                    'Present',
                                    style: GoogleFonts.poppins(
                                      color: _isPresent ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14 * scale,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16 * scale),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isPresent = false),
                            child: Container(
                              padding: EdgeInsets.all(16 * scale),
                              decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: !_isPresent 
                                          ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                                          : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                                      ),
                                borderRadius: BorderRadius.circular(12 * scale),
                                border: Border.all(
                                  color: !_isPresent ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.3),
                                ),
                                      boxShadow: !_isPresent ? [
                                        BoxShadow(
                                          color: const Color(0xFFEF4444).withOpacity(0.3),
                                          blurRadius: 8 * scale,
                                          offset: Offset(0, 2 * scale),
                                        ),
                                      ] : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    color: !_isPresent ? Colors.white : Colors.white70,
                                    size: 32 * scale,
                                  ),
                                  SizedBox(height: 8 * scale),
                                  Text(
                                    'Absent',
                                    style: GoogleFonts.poppins(
                                      color: !_isPresent ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14 * scale,
                                    ),
                                  ),
                                ],
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
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
          ),
        ),
                      SizedBox(width: 12 * scale),
        AnimatedButton(
                        width: 180 * scale,
                        height: 48 * scale,
          backgroundColor: const Color(0xFFB2FF00),
          foregroundColor: const Color(0xFF13131A),
          text: 'Mark Attendance',
          onPressed: _selectedBatch == null || _selectedStudentId == null ? null : _submit,
          logoImage: null,
          addBorder: null,
                        fontSize: 18 * scale, // Pass a larger, scaled font size for readability
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
    if (widget.isBottomSheet) {
      return SafeArea(child: dialogContent);
    } else {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 16 * scale),
        child: SafeArea(child: dialogContent),
    );
    }
  }
}

class EditAttendanceDialog extends StatefulWidget {
  final AppProvider provider;
  final Attendance attendance;

  const EditAttendanceDialog({super.key, required this.provider, required this.attendance});

  @override
  State<EditAttendanceDialog> createState() => _EditAttendanceDialogState();
}

class _EditAttendanceDialogState extends State<EditAttendanceDialog> {
  late bool _isPresent;
  // Remove notes controller for consistency
  // final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isPresent = widget.attendance.isPresent;
    // _notesController.text = widget.attendance.notes ?? '';
  }

  @override
  void dispose() {
    // _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    final updatedAttendance = widget.attendance.copyWith(
      isPresent: _isPresent,
      notes: null, // Remove notes
    );

    widget.provider.updateAttendance(updatedAttendance).then((_) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(Navigator.of(context).context).showSnackBar(
        SnackBar(
          content: Text(
            'Attendance updated successfully!',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.provider.getStudentById(widget.attendance.studentId);
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final scale = width < 400 ? 0.85 : width > 900 ? 1.18 : width > 700 ? 1.10 : 1.0;
    final cardRadius = 18 * scale;
    final cardPadding = EdgeInsets.all(width < 400 ? 10 * scale : 20 * scale);
    final sectionSpacing = 20 * scale;
    final cardSpacing = 12 * scale;
    final maxDialogWidth = width < 400 ? width - 16 : width < 700 ? 360 * scale : 480 * scale;
    final maxDialogHeight = height * 0.92;
    final dialogContent = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxDialogWidth,
          maxHeight: maxDialogHeight,
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF13131A), Color(0xFF1976D2)],
            ),
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 24 * scale,
                offset: Offset(0, 8 * scale),
              ),
            ],
          ),
          child: Padding(
            padding: cardPadding,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Section Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12 * scale),
                        decoration: BoxDecoration(
                          color: Color(0xFFB2FF00).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(16 * scale),
                        ),
                        child: Icon(
                          Icons.edit,
                          color: Color(0xFFB2FF00),
                          size: 28 * scale,
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      Expanded(
                        child: Text(
        'Edit Attendance - ${student?.name ?? 'Unknown'}',
        style: GoogleFonts.prompt(
          fontWeight: FontWeight.bold,
                            fontSize: 22 * scale,
          color: Colors.white,
        ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),
            // Attendance Status
            Container(
                    margin: EdgeInsets.only(bottom: cardSpacing),
              decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.white.withOpacity(0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(15 * scale),
                      border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.0 * scale),
                child: Column(
                  children: [
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(8 * scale),
                                decoration: BoxDecoration(
                                  color: Color(0xFF10B981).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(10 * scale),
                                ),
                                child: Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF10B981),
                                  size: 22 * scale,
                                ),
                              ),
                              SizedBox(width: 12 * scale),
                    Text(
                      'Attendance Status',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.bold,
                        fontSize: 16 * scale,
                        color: Colors.white,
                      ),
                              ),
                            ],
                    ),
                    SizedBox(height: 16 * scale),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isPresent = true),
                            child: Container(
                              padding: EdgeInsets.all(16 * scale),
                              decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: _isPresent 
                                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                                          : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                                      ),
                                borderRadius: BorderRadius.circular(12 * scale),
                                border: Border.all(
                                  color: _isPresent ? const Color(0xFF10B981) : Colors.white.withOpacity(0.3),
                                ),
                                      boxShadow: _isPresent ? [
                                        BoxShadow(
                                          color: const Color(0xFF10B981).withOpacity(0.3),
                                          blurRadius: 8 * scale,
                                          offset: Offset(0, 2 * scale),
                                        ),
                                      ] : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.check_circle,
                                    color: _isPresent ? Colors.white : Colors.white70,
                                    size: 32 * scale,
                                  ),
                                  SizedBox(height: 8 * scale),
                                  Text(
                                    'Present',
                                    style: GoogleFonts.poppins(
                                      color: _isPresent ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14 * scale,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16 * scale),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _isPresent = false),
                            child: Container(
                              padding: EdgeInsets.all(16 * scale),
                              decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: !_isPresent 
                                          ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                                          : [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.05)],
                                      ),
                                borderRadius: BorderRadius.circular(12 * scale),
                                border: Border.all(
                                  color: !_isPresent ? const Color(0xFFEF4444) : Colors.white.withOpacity(0.3),
                                ),
                                      boxShadow: !_isPresent ? [
                                        BoxShadow(
                                          color: const Color(0xFFEF4444).withOpacity(0.3),
                                          blurRadius: 8 * scale,
                                          offset: Offset(0, 2 * scale),
                                        ),
                                      ] : null,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.cancel,
                                    color: !_isPresent ? Colors.white : Colors.white70,
                                    size: 32 * scale,
                                  ),
                                  SizedBox(height: 8 * scale),
                                  Text(
                                    'Absent',
                                    style: GoogleFonts.poppins(
                                      color: !_isPresent ? Colors.white : Colors.white70,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14 * scale,
                                    ),
                                  ),
                                ],
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
                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
          ),
        ),
                      SizedBox(width: 12 * scale),
        AnimatedButton(
                        width: 180 * scale,
                        height: 48 * scale,
          backgroundColor: const Color(0xFFB2FF00),
          foregroundColor: const Color(0xFF13131A),
          text: 'Update Attendance',
          onPressed: _submit,
          logoImage: null,
          addBorder: null,
                        fontSize: 18 * scale,
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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 16 * scale),
      child: SafeArea(child: dialogContent),
    );
  }
} 