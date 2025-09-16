import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/app_provider.dart';
import '../models/payment.dart';
import '../models/student.dart';
import '../constants/batches.dart';
import '../widgets/animated_button.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});
  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> {
  String? _selectedStudentId;
  String? _selectedBatch;
  String? _selectedStatus;
  DateTime _selectedMonth = DateTime.now();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    
    // Define a standard card radius and padding for consistency
    final double cardRadius = 18 * scale;
    final EdgeInsets cardPadding = EdgeInsets.all(20 * scale);
    final double sectionSpacing = 20 * scale;
    final double cardSpacing = 12 * scale;

    return Consumer<AppProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
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
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB2FF00)),
              ),
            ),
          );
        }

        final students = _selectedBatch == null
            ? provider.students
            : provider.students.where((s) => s.isInBatch(_selectedBatch!)).toList();
        final payments = provider.payments.where((p) {
          final studentMatch = _selectedStudentId == null || p.studentId == _selectedStudentId;
          final batchMatch = _selectedBatch == null || p.batch == _selectedBatch;
          final statusMatch = _selectedStatus == null || p.status == _selectedStatus;
          // Search filter
          final student = provider.getStudentById(p.studentId);
          final searchLower = _searchQuery.toLowerCase();
          final matchesSearch = student != null && (
            student.name.toLowerCase().contains(searchLower) ||
            p.batch.toLowerCase().contains(searchLower) ||
            (p.transactionId ?? '').toLowerCase().contains(searchLower)
          );
          return studentMatch && batchMatch && statusMatch && (_searchQuery.isEmpty || matchesSearch);
        }).toList();

        // Payments Overview Section
        final overviewPayments = provider.payments.where((p) {
          return p.paymentDate.year == _selectedMonth.year && p.paymentDate.month == _selectedMonth.month;
        }).toList();
        
        final completedPayments = overviewPayments.where((p) => p.status == 'completed').length;
        final pendingPayments = overviewPayments.where((p) => p.status == 'pending').length;
        final failedPayments = overviewPayments.where((p) => p.status == 'failed').length;
        final totalAmount = overviewPayments.where((p) => p.status == 'completed').fold(0.0, (sum, p) => sum + p.amount);

        // Overdue students for the selected month/batch
        final overdueStudents = provider.getOverdueStudents(forMonth: _selectedMonth)
          .where((entry) => _selectedBatch == null || entry['batch'] == _selectedBatch)
          .toList();

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
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.0 * scale),
                          child: Text(
                            'Payment Management',
                            style: GoogleFonts.prompt(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 22 * scale,
                            ),
                          ),
                        ),

                      // Overdue Payments Alert
                      if (overdueStudents.isNotEmpty) ...[
                        Container(
                          margin: EdgeInsets.only(bottom: sectionSpacing),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFEF4444).withOpacity(0.2),
                                const Color(0xFFDC2626).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(cardRadius),
                            border: Border.all(
                              color: const Color(0xFFEF4444).withOpacity(0.3),
                              width: 1,
                            ),
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
                                        color: const Color(0xFFEF4444).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12 * scale),
                                      ),
                                      child: Icon(
                                        Icons.warning_rounded,
                                        color: const Color(0xFFEF4444),
                                        size: 24 * scale,
                                      ),
                                    ),
                                    SizedBox(width: 12 * scale),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Overdue Payments',
                                            style: GoogleFonts.prompt(
                                              fontSize: 18 * scale,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFEF4444),
                                            ),
                                          ),
                                          Text(
                                            '${overdueStudents.length} students have pending payments',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12 * scale,
                                              color: Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16 * scale),
                                ...overdueStudents.map((entry) {
                                  final Student student = entry['student'];
                                  final String batch = entry['batch'];
                                  return Container(
                                    margin: EdgeInsets.only(bottom: cardSpacing),
                                    padding: EdgeInsets.all(14 * scale),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(cardRadius - 4 * scale),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.1),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 16 * scale,
                                          backgroundColor: const Color(0xFFB2FF00).withOpacity(0.2),
                                          child: Text(
                                            student.name.substring(0, 1).toUpperCase(),
                                            style: GoogleFonts.poppins(
                                              fontSize: 14 * scale,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFFB2FF00),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12 * scale),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student.name,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14 * scale,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                'Batch: $batch',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12 * scale,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB2FF00).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(20 * scale),
                                          ),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.notifications_active_rounded,
                                              color: const Color(0xFFB2FF00),
                                              size: 20 * scale,
                                            ),
                                            tooltip: 'Send Reminder',
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('Reminder sent to ${student.name} for batch $batch'),
                                                  backgroundColor: const Color(0xFFB2FF00),
                                                  behavior: SnackBarBehavior.floating,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(12 * scale),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],

                      // Upcoming Payment Reminders Section
                      Builder(
                        builder: (context) {
                          final studentsToRemind = provider.getStudentsToRemindForPayment(DateTime.now());
                          print('[ReminderDebug] UI studentsToRemind: ${studentsToRemind.map((s) => s.name).toList()}');
                          if (studentsToRemind.isEmpty) return SizedBox.shrink();
                          return Container(
                            margin: EdgeInsets.only(bottom: sectionSpacing),
                            width: double.infinity,
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
                              padding: cardPadding,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(10 * scale),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(14 * scale),
                                        ),
                                        child: Icon(Icons.notifications_active_rounded, color: Colors.orange, size: 22 * scale),
                                      ),
                                      SizedBox(width: 12 * scale),
                                      Expanded(
                                        child: Text(
                                          'Upcoming Payment Reminders',
                                          style: GoogleFonts.prompt(
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16 * scale,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10 * scale),
                                  ...studentsToRemind.map((student) => Padding(
                                    padding: EdgeInsets.only(bottom: 8 * scale),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 18 * scale),
                                        SizedBox(width: 8 * scale),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                student.name,
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14 * scale,
                                                ),
                                              ),
                                              Text(
                                                'Batches: ' + student.batches.join(', '),
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white.withOpacity(0.7),
                                                  fontSize: 12 * scale,
                                                ),
                                              ),
                                              Text(
                                                'Preferred Payment Day: ${student.preferredPaymentDay ?? 1}',
                                                style: GoogleFonts.poppins(
                                                  color: Colors.white.withOpacity(0.7),
                                                  fontSize: 12 * scale,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      // Search and Filters
                      Container(
                        margin: EdgeInsets.only(bottom: sectionSpacing),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.08),
                              Colors.white.withOpacity(0.03),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                            width: 1,
                          ),
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
                                      color: const Color(0xFFB2FF00).withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12 * scale),
                                    ),
                                    child: Icon(
                                      Icons.search_rounded,
                                      color: const Color(0xFFB2FF00),
                                      size: 20 * scale,
                                    ),
                                  ),
                                  SizedBox(width: 12 * scale),
                                  Text(
                                    'Search & Filters',
                                    style: GoogleFonts.prompt(
                                      fontSize: 16 * scale,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20 * scale),
                              
                              // Search
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.2),
                                    width: 1,
                                  ),
                                ),
                                child: TextField(
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 14 * scale,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Search by student name, batch, or amount...',
                                    hintStyle: GoogleFonts.poppins(
                                      color: Colors.white60,
                                      fontSize: 14 * scale,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: const Color(0xFFB2FF00),
                                      size: 20 * scale,
                                    ),
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(18 * scale),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _searchQuery = value;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: 20 * scale),

                              // Filters Row
                              Row(
                                children: [
                                  // Batch Filter
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: PopupMenuButton<String>(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedBatch ?? 'All Batches',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14 * scale,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: const Color(0xFFB2FF00),
                                              size: 20 * scale,
                                            ),
                                          ],
                                        ),
                                        onSelected: (value) => setState(() => _selectedBatch = value),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: null,
                                            child: Text(
                                              'All Batches',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14 * scale,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          ...kBatches.map((b) => PopupMenuItem(
                                            value: b,
                                            child: Container(
                                              width: 200 * scale,
                                              child: Text(
                                                b,
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14 * scale,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          )).toList(),
                                        ],
                                        color: const Color(0xFF28282F),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14 * scale),
                                        ),
                                        elevation: 8,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: cardSpacing),
                                  // Status Filter
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                                        border: Border.all(
                                          color: Colors.white.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      child: PopupMenuButton<String>(
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                _selectedStatus ?? 'All Status',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14 * scale,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Icon(
                                              Icons.keyboard_arrow_down_rounded,
                                              color: const Color(0xFFB2FF00),
                                              size: 20 * scale,
                                            ),
                                          ],
                                        ),
                                        onSelected: (value) => setState(() => _selectedStatus = value),
                                        itemBuilder: (context) => [
                                          PopupMenuItem(
                                            value: null,
                                            child: Text(
                                              'All Status',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14 * scale,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'completed',
                                            child: Text(
                                              'Completed',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14 * scale,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'pending',
                                            child: Text(
                                              'Pending',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14 * scale,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: 'failed',
                                            child: Text(
                                              'Failed',
                                              style: GoogleFonts.poppins(
                                                fontSize: 14 * scale,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                        color: const Color(0xFF28282F),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(14 * scale),
                                        ),
                                        elevation: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20 * scale),

                              // Month Picker
                              Container(
                                padding: EdgeInsets.all(16 * scale),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.1),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(8 * scale),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB2FF00).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12 * scale),
                                      ),
                                      child: Icon(
                                        Icons.calendar_today_rounded,
                                        color: const Color(0xFFB2FF00),
                                        size: 20 * scale,
                                      ),
                                    ),
                                    SizedBox(width: 16 * scale),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Selected Month',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12 * scale,
                                              color: Colors.white70,
                                            ),
                                          ),
                                          Text(
                                            '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}',
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                              fontSize: 16 * scale,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFB2FF00).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12 * scale),
                                      ),
                                      child: IconButton(
                                        icon: Icon(
                                          Icons.edit_calendar_rounded,
                                          color: const Color(0xFFB2FF00),
                                          size: 20 * scale,
                                        ),
                                        onPressed: () async {
                                          final picked = await showDatePicker(
                                            context: context,
                                            initialDate: _selectedMonth,
                                            firstDate: DateTime(2020),
                                            lastDate: DateTime.now(),
                                            helpText: 'Select Month',
                                            fieldLabelText: 'Month/Year',
                                            initialDatePickerMode: DatePickerMode.year,
                                            builder: (context, child) {
                                              final width = MediaQuery.of(context).size.width;
                                              final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
                                              final double cardRadius = 18 * scale;
                                              return Theme(
                                                data: Theme.of(context).copyWith(
                                                  colorScheme: const ColorScheme.dark(
                                                    primary: Color(0xFFB2FF00),
                                                    onPrimary: Colors.white,
                                                    surface: Color(0xFF13131A),
                                                    onSurface: Colors.white,
                                                  ),
                                                  dialogBackgroundColor: const Color(0xFF13131A),
                                                  dialogTheme: DialogTheme(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(cardRadius),
                                                    ),
                                                  ),
                                                  textTheme: TextTheme(
                                                    titleLarge: GoogleFonts.prompt(
                                                      fontWeight: FontWeight.w700,
                                                      fontSize: 20 * scale,
                                                      color: Colors.white,
                                                    ),
                                                    titleMedium: GoogleFonts.prompt(
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 16 * scale,
                                                      color: Colors.white,
                                                    ),
                                                    bodyLarge: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 16 * scale,
                                                      color: Colors.white.withOpacity(0.9),
                                                    ),
                                                    bodyMedium: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w500,
                                                      fontSize: 14 * scale,
                                                      color: Colors.white.withOpacity(0.7),
                                                    ),
                                                  ),
                                                  textButtonTheme: TextButtonThemeData(
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: const Color(0xFFB2FF00),
                                                      textStyle: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 16 * scale,
                                                      ),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(cardRadius),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                child: child!,
                                              );
                                            },
                                          );
                                          if (picked != null) {
                                            setState(() {
                                              _selectedMonth = DateTime(picked.year, picked.month);
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Payment Summary Cards
                      Container(
                        margin: EdgeInsets.only(bottom: sectionSpacing),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8 * scale),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB2FF00).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12 * scale),
                                  ),
                                  child: Icon(
                                    Icons.analytics_rounded,
                                    color: const Color(0xFFB2FF00),
                                    size: 20 * scale,
                                  ),
                                ),
                                SizedBox(width: 12 * scale),
                                Text(
                                  'Payment Summary',
                                  style: GoogleFonts.prompt(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16 * scale),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: cardPadding,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF10B981).withOpacity(0.2),
                                          const Color(0xFF059669).withOpacity(0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(cardRadius),
                                      border: Border.all(
                                        color: const Color(0xFF10B981).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12 * scale),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF10B981).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16 * scale),
                                          ),
                                          child: Icon(
                                            Icons.check_circle_rounded,
                                            color: const Color(0xFF10B981),
                                            size: 28 * scale,
                                          ),
                                        ),
                                        SizedBox(height: 12 * scale),
                                        Text(
                                          completedPayments.toString(),
                                          style: GoogleFonts.prompt(
                                            fontSize: 28 * scale,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF10B981),
                                          ),
                                        ),
                                        Text(
                                          'Completed',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFF10B981),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14 * scale,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: cardSpacing),
                                Expanded(
                                  child: Container(
                                    padding: cardPadding,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFF59E0B).withOpacity(0.2),
                                          const Color(0xFFD97706).withOpacity(0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(cardRadius),
                                      border: Border.all(
                                        color: const Color(0xFFF59E0B).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12 * scale),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF59E0B).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16 * scale),
                                          ),
                                          child: Icon(
                                            Icons.pending_rounded,
                                            color: const Color(0xFFF59E0B),
                                            size: 28 * scale,
                                          ),
                                        ),
                                        SizedBox(height: 12 * scale),
                                        Text(
                                          pendingPayments.toString(),
                                          style: GoogleFonts.prompt(
                                            fontSize: 28 * scale,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFF59E0B),
                                          ),
                                        ),
                                        Text(
                                          'Pending',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFF59E0B),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14 * scale,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(width: cardSpacing),
                                Expanded(
                                  child: Container(
                                    padding: cardPadding,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFFB2FF00).withOpacity(0.2),
                                          const Color(0xFF9CCC65).withOpacity(0.1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(cardRadius),
                                      border: Border.all(
                                        color: const Color(0xFFB2FF00).withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(12 * scale),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFB2FF00).withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(16 * scale),
                                          ),
                                          child: Icon(
                                            Icons.attach_money_rounded,
                                            color: const Color(0xFFB2FF00),
                                            size: 28 * scale,
                                          ),
                                        ),
                                        SizedBox(height: 12 * scale),
                                        Text(
                                          '₹${totalAmount.toStringAsFixed(0)}',
                                          style: GoogleFonts.prompt(
                                            fontSize: 24 * scale,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFFB2FF00),
                                          ),
                                        ),
                                        Text(
                                          'Total',
                                          style: GoogleFonts.poppins(
                                            color: const Color(0xFFB2FF00),
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14 * scale,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Payment Records
                      Container(
                        height: 400 * scale,
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(8 * scale),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFB2FF00).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12 * scale),
                                  ),
                                  child: Icon(
                                    Icons.receipt_long_rounded,
                                    color: const Color(0xFFB2FF00),
                                    size: 20 * scale,
                                  ),
                                ),
                                SizedBox(width: 12 * scale),
                                Text(
                                  'Payment Records',
                                  style: GoogleFonts.prompt(
                                    fontSize: 16 * scale,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Spacer(),
                                Text(
                                  '${payments.length} records',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12 * scale,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16 * scale),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () => provider.loadPayments(),
                                child: payments.isEmpty
                                    ? Container(
                                        width: double.infinity,
                                        constraints: const BoxConstraints(maxWidth: 600),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.05),
                                              Colors.white.withOpacity(0.02),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(cardRadius),
                                          border: Border.all(
                                            color: Colors.white.withOpacity(0.1),
                                            width: 1,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: cardPadding,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(20 * scale),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(50 * scale),
                                                ),
                                                child: Icon(
                                                  Icons.payment_outlined,
                                                  size: 48 * scale,
                                                  color: Colors.white.withOpacity(0.5),
                                                ),
                                              ),
                                              SizedBox(height: 20 * scale),
                                              Text(
                                                'No payment records found',
                                                style: GoogleFonts.prompt(
                                                  fontSize: 18 * scale,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              SizedBox(height: 8 * scale),
                                              Text(
                                                'Try adjusting your search or filters',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14 * scale,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
                                        itemCount: payments.length,
                                        itemBuilder: (context, index) {
                                          final payment = payments[index];
                                          final student = provider.getStudentById(payment.studentId);

                                          if (student == null) return SizedBox.shrink();

                                          return Container(
                                            margin: EdgeInsets.only(bottom: cardSpacing),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.white.withOpacity(0.08),
                                                  Colors.white.withOpacity(0.03),
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(cardRadius),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.1),
                                                width: 1,
                                              ),
                                            ),
                                            child: ListTile(
                                              contentPadding: cardPadding,
                                              leading: Container(
                                                width: 56 * scale,
                                                height: 56 * scale,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: [
                                                      _getStatusColor(payment.status).withOpacity(0.3),
                                                      _getStatusColor(payment.status).withOpacity(0.1),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  ),
                                                  borderRadius: BorderRadius.circular(16 * scale),
                                                  border: Border.all(
                                                    color: _getStatusColor(payment.status).withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Icon(
                                                  _getStatusIcon(payment.status),
                                                  color: _getStatusColor(payment.status),
                                                  size: 28 * scale,
                                                ),
                                              ),
                                              title: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      student.name,
                                                      style: GoogleFonts.poppins(
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 16 * scale,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    padding: EdgeInsets.symmetric(
                                                      horizontal: 12 * scale,
                                                      vertical: 6 * scale,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: _getStatusColor(payment.status).withOpacity(0.2),
                                                      borderRadius: BorderRadius.circular(20 * scale),
                                                      border: Border.all(
                                                        color: _getStatusColor(payment.status).withOpacity(0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: Text(
                                                      payment.status.toUpperCase(),
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 10 * scale,
                                                        fontWeight: FontWeight.bold,
                                                        color: _getStatusColor(payment.status),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  SizedBox(height: 8 * scale),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.access_time_rounded,
                                                        size: 14 * scale,
                                                        color: Colors.white60,
                                                      ),
                                                      SizedBox(width: 4 * scale),
                                                      Text(
                                                        DateFormat('MMM d, y - h:mm a').format(payment.paymentDate),
                                                        style: GoogleFonts.poppins(
                                                          color: Colors.white60,
                                                          fontSize: 12 * scale,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (payment.transactionId != null) ...[
                                                    SizedBox(height: 4 * scale),
                                                    Row(
                                                      children: [
                                                        Icon(
                                                          Icons.receipt_rounded,
                                                          size: 14 * scale,
                                                          color: Colors.white60,
                                                        ),
                                                        SizedBox(width: 4 * scale),
                                                        Text(
                                                          'Txn ID: ${payment.transactionId}',
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 12 * scale,
                                                            color: Colors.white60,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              trailing: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(12 * scale),
                                                ),
                                                child: PopupMenuButton<String>(
                                                  icon: Icon(
                                                    Icons.more_horiz_rounded,
                                                    color: const Color(0xFFB2FF00),
                                                    size: 24 * scale,
                                                  ),
                                                  onSelected: (value) {
                                                    if (value == 'edit') {
                                                      _showEditPaymentDialog(context, provider, payment);
                                                    } else if (value == 'delete') {
                                                      _showDeletePaymentConfirmation(context, provider, payment);
                                                    } else if (value == 'view') {
                                                      _showPaymentDetails(context, payment, student);
                                                    }
                                                  },
                                                  itemBuilder: (context) => [
                                                    PopupMenuItem(
                                                      value: 'view',
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.all(6 * scale),
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFFB2FF00).withOpacity(0.2),
                                                              borderRadius: BorderRadius.circular(8 * scale),
                                                            ),
                                                            child: Icon(
                                                              Icons.visibility_rounded,
                                                              color: const Color(0xFFB2FF00),
                                                              size: 16 * scale,
                                                            ),
                                                          ),
                                                          SizedBox(width: 12 * scale),
                                                          Text(
                                                            'View Details',
                                                            style: GoogleFonts.poppins(
                                                              color: Colors.white,
                                                              fontSize: 14 * scale,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 'edit',
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.all(6 * scale),
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFFB2FF00).withOpacity(0.2),
                                                              borderRadius: BorderRadius.circular(8 * scale),
                                                            ),
                                                            child: Icon(
                                                              Icons.edit_rounded,
                                                              color: const Color(0xFFB2FF00),
                                                              size: 16 * scale,
                                                            ),
                                                          ),
                                                          SizedBox(width: 12 * scale),
                                                          Text(
                                                            'Edit',
                                                            style: GoogleFonts.poppins(
                                                              color: Colors.white,
                                                              fontSize: 14 * scale,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 'delete',
                                                      child: Row(
                                                        children: [
                                                          Container(
                                                            padding: EdgeInsets.all(6 * scale),
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xFFEF4444).withOpacity(0.2),
                                                              borderRadius: BorderRadius.circular(8 * scale),
                                                            ),
                                                            child: Icon(
                                                              Icons.delete_rounded,
                                                              color: const Color(0xFFEF4444),
                                                              size: 16 * scale,
                                                            ),
                                                          ),
                                                          SizedBox(width: 12 * scale),
                                                          Text(
                                                            'Delete',
                                                            style: GoogleFonts.poppins(
                                                              color: const Color(0xFFEF4444),
                                                              fontSize: 14 * scale,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                  color: const Color(0xFF28282F),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(14 * scale),
                                                  ),
                                                  elevation: 8,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                          ],
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
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'failed':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'failed':
        return Icons.cancel;
      default:
        return Icons.payment;
    }
  }

  void _showAddPaymentDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AddPaymentDialog(provider: provider),
    );
  }

  void _showEditPaymentDialog(BuildContext context, AppProvider provider, Payment payment) {
    showDialog(
      context: context,
      builder: (context) => EditPaymentDialog(provider: provider, payment: payment),
    );
  }

  void _showPaymentDetails(BuildContext context, Payment payment, Student student) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF28282F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * scale)),
        title: Text(
          'Payment Receipt',
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.bold,
            fontSize: 18 * scale,
            color: Colors.white,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Student', student.name, scale),
            _buildDetailRow('Batch', payment.batch, scale),
            _buildDetailRow('Amount', '₹${payment.amount.toStringAsFixed(2)}', scale),
            _buildDetailRow('Date', DateFormat('MMM d, y').format(payment.paymentDate), scale),
            _buildDetailRow('Status', payment.status, scale),
            _buildDetailRow('Method', payment.paymentMethod, scale),
            if (payment.transactionId != null)
              _buildDetailRow('Transaction ID', payment.transactionId!, scale),
            if (payment.notes != null && payment.notes!.isNotEmpty)
              _buildDetailRow('Notes', payment.notes!, scale),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100 * scale,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: const Color(0xFFB2FF00),
                fontSize: 14 * scale,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14 * scale,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeletePaymentConfirmation(BuildContext context, AppProvider provider, Payment payment) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF28282F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * scale)),
        title: Text(
          'Delete Payment',
          style: GoogleFonts.prompt(
            fontWeight: FontWeight.bold,
            fontSize: 18 * scale,
            color: Colors.white,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this payment record?',
          style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
            ),
          ),
          AnimatedButton(
            width: 120 * scale,
            height: 40 * scale,
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            text: 'Delete',
            onPressed: () {
              try {
                provider.deletePayment(payment.id!);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Payment record deleted',
                      style: GoogleFonts.poppins(fontSize: 14 * scale),
                    ),
                    backgroundColor: const Color(0xFFEF4444),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed to delete payment: ${e.toString()}',
                      style: GoogleFonts.poppins(fontSize: 14 * scale),
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            logoImage: null,
            addBorder: null,
          ),
        ],
      ),
    );
  }
}

class AddPaymentDialog extends StatefulWidget {
  final AppProvider provider;

  const AddPaymentDialog({super.key, required this.provider});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedStudentId;
  final _amountController = TextEditingController();
  String _selectedMethod = 'Cash';
  String _selectedStatus = 'completed';
  final _notesController = TextEditingController();
  DateTime _paymentDate = DateTime.now();
  String? _selectedBatch;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedStudentId != null) {
      final payment = Payment(
        studentId: _selectedStudentId!,
        amount: double.parse(_amountController.text),
        paymentDate: _paymentDate,
        paymentMethod: _selectedMethod,
        status: _selectedStatus,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        batch: _selectedBatch ?? 'Unknown',
      );

      try {
        widget.provider.addPayment(payment).then((_) async {
          await widget.provider.initializeData();
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Payment added successfully!'),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add payment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeStudents = widget.provider.getActiveStudents();
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;

    return AlertDialog(
      backgroundColor: const Color(0xFF28282F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * scale)),
      title: Text(
        'Add Payment',
        style: GoogleFonts.prompt(
          fontWeight: FontWeight.bold,
          fontSize: 20 * scale,
          color: Colors.white,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Student Selection
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: PopupMenuButton<String>(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedStudentId != null 
                            ? activeStudents.firstWhere((s) => s.id == _selectedStudentId).name
                            : 'Select Student',
                          style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20 * scale),
                    ],
                  ),
                  onSelected: (value) => setState(() => _selectedStudentId = value),
                  itemBuilder: (context) => activeStudents.map((student) => PopupMenuItem(
                    value: student.id,
                    child: Container(
                      width: 200 * scale,
                      child: Text(student.name, style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white)),
                    ),
                  )).toList(),
                  color: const Color(0xFF28282F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                  elevation: 8,
                ),
              ),
              SizedBox(height: 16 * scale),

              // Batch Selection
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: PopupMenuButton<String>(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedBatch ?? 'Select Batch',
                          style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20 * scale),
                    ],
                  ),
                  onSelected: (value) => setState(() => _selectedBatch = value),
                  itemBuilder: (context) => kBatches.map((batch) => PopupMenuItem(
                    value: batch,
                    child: Container(
                      width: 200 * scale,
                      child: Text(batch, style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white)),
                    ),
                  )).toList(),
                  color: const Color(0xFF28282F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                  elevation: 8,
                ),
              ),
              SizedBox(height: 16 * scale),

              // Amount
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: TextFormField(
                  controller: _amountController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                    prefixIcon: Icon(Icons.attach_money, color: const Color(0xFFB2FF00), size: 20 * scale),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16 * scale),
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
              ),
              SizedBox(height: 16 * scale),

              // Payment Method
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: PopupMenuButton<String>(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedMethod,
                          style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20 * scale),
                    ],
                  ),
                  onSelected: (value) => setState(() => _selectedMethod = value!),
                  itemBuilder: (context) => ['Cash', 'Card', 'Online', 'Bank Transfer'].map((method) => PopupMenuItem(
                    value: method,
                    child: Container(
                      width: 200 * scale,
                      child: Text(method, style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white)),
                    ),
                  )).toList(),
                  color: const Color(0xFF28282F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                  elevation: 8,
                ),
              ),
              SizedBox(height: 16 * scale),

              // Payment Status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: PopupMenuButton<String>(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedStatus,
                          style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20 * scale),
                    ],
                  ),
                  onSelected: (value) => setState(() => _selectedStatus = value!),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'completed', child: Text('Completed', style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white))),
                    PopupMenuItem(value: 'pending', child: Text('Pending', style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white))),
                    PopupMenuItem(value: 'failed', child: Text('Failed', style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white))),
                  ],
                  color: const Color(0xFF28282F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                  elevation: 8,
                ),
              ),
              SizedBox(height: 16 * scale),

              // Payment Date
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                leading: Icon(Icons.calendar_today, color: const Color(0xFFB2FF00), size: 24 * scale),
                title: Text(
                  'Payment Date',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 16 * scale,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MMM d, y').format(_paymentDate),
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                ),
                trailing: Icon(Icons.arrow_drop_down, color: const Color(0xFFB2FF00), size: 20 * scale),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFFB2FF00),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() {
                      _paymentDate = date;
                    });
                  }
                },
              ),
              SizedBox(height: 16 * scale),

              // Notes
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: TextFormField(
                  controller: _notesController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                  decoration: InputDecoration(
                    labelText: 'Notes (Optional)',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                    prefixIcon: Icon(Icons.note, color: const Color(0xFFB2FF00), size: 20 * scale),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16 * scale),
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
          ),
        ),
        AnimatedButton(
          width: 200 * scale,
          height: 45 * scale,
          backgroundColor: const Color(0xFFB2FF00),
          foregroundColor: const Color(0xFF13131A),
          text: 'Add Payment',
          onPressed: _selectedStudentId == null || _selectedBatch == null ? null : _submit,
          logoImage: null,
          addBorder: null,
        ),
      ],
    );
  }
}

class EditPaymentDialog extends StatefulWidget {
  final AppProvider provider;
  final Payment payment;

  const EditPaymentDialog({super.key, required this.provider, required this.payment});

  @override
  State<EditPaymentDialog> createState() => _EditPaymentDialogState();
}

class _EditPaymentDialogState extends State<EditPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late String _selectedMethod;
  late String _selectedStatus;
  late final TextEditingController _notesController;
  late DateTime _paymentDate;
  String? _selectedBatch;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.payment.amount.toString());
    _selectedMethod = widget.payment.paymentMethod;
    _selectedStatus = widget.payment.status;
    _notesController = TextEditingController(text: widget.payment.notes ?? '');
    _paymentDate = widget.payment.paymentDate;
    _selectedBatch = widget.payment.batch;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updatedPayment = widget.payment.copyWith(
        amount: double.parse(_amountController.text),
        paymentDate: _paymentDate,
        paymentMethod: _selectedMethod,
        status: _selectedStatus,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        batch: _selectedBatch ?? 'Unknown',
      );

      try {
        widget.provider.updatePayment(updatedPayment).then((_) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Payment updated successfully!'), backgroundColor: Colors.green),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update payment: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final student = widget.provider.getStudentById(widget.payment.studentId);
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;

    return AlertDialog(
      backgroundColor: const Color(0xFF28282F),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20 * scale)),
      title: Text(
        'Edit Payment - ${student?.name ?? 'Unknown'}',
        style: GoogleFonts.prompt(
          fontWeight: FontWeight.bold,
          fontSize: 18 * scale,
          color: Colors.white,
        ),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Amount
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: TextFormField(
                  controller: _amountController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                    prefixIcon: Icon(Icons.attach_money, color: const Color(0xFFB2FF00), size: 20 * scale),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16 * scale),
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
              ),
              SizedBox(height: 16 * scale),

              // Batch Selection
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: PopupMenuButton<String>(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedBatch ?? 'Select Batch',
                          style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20 * scale),
                    ],
                  ),
                  onSelected: (value) => setState(() => _selectedBatch = value),
                  itemBuilder: (context) => kBatches.map((batch) => PopupMenuItem(
                    value: batch,
                    child: Container(
                      width: 200 * scale,
                      child: Text(batch, style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white)),
                    ),
                  )).toList(),
                  color: const Color(0xFF28282F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                  elevation: 8,
                ),
              ),
              SizedBox(height: 16 * scale),

              // Payment Method
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: PopupMenuButton<String>(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedMethod,
                          style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20 * scale),
                    ],
                  ),
                  onSelected: (value) => setState(() => _selectedMethod = value!),
                  itemBuilder: (context) => ['Cash', 'Card', 'Online', 'Bank Transfer'].map((method) => PopupMenuItem(
                    value: method,
                    child: Container(
                      width: 200 * scale,
                      child: Text(method, style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white)),
                    ),
                  )).toList(),
                  color: const Color(0xFF28282F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                  elevation: 8,
                ),
              ),
              SizedBox(height: 16 * scale),

              // Payment Status
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: PopupMenuButton<String>(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _selectedStatus,
                          style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Colors.white70, size: 20 * scale),
                    ],
                  ),
                  onSelected: (value) => setState(() => _selectedStatus = value!),
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'completed', child: Text('Completed', style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white))),
                    PopupMenuItem(value: 'pending', child: Text('Pending', style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white))),
                    PopupMenuItem(value: 'failed', child: Text('Failed', style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white))),
                  ],
                  color: const Color(0xFF28282F),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14 * scale)),
                  elevation: 8,
                ),
              ),
              SizedBox(height: 16 * scale),

              // Payment Date
              ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                leading: Icon(Icons.calendar_today, color: const Color(0xFFB2FF00), size: 24 * scale),
                title: Text(
                  'Payment Date',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 16 * scale,
                  ),
                ),
                subtitle: Text(
                  DateFormat('MMM d, y').format(_paymentDate),
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                ),
                trailing: Icon(Icons.arrow_drop_down, color: const Color(0xFFB2FF00), size: 20 * scale),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _paymentDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFFB2FF00),
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() {
                      _paymentDate = date;
                    });
                  }
                },
              ),
              SizedBox(height: 16 * scale),

              // Notes
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: TextFormField(
                  controller: _notesController,
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                    prefixIcon: Icon(Icons.note, color: const Color(0xFFB2FF00), size: 20 * scale),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16 * scale),
                  ),
                  maxLines: 3,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
          ),
        ),
        AnimatedButton(
          width: 180 * scale,
          height: 45 * scale,
          backgroundColor: const Color(0xFFB2FF00),
          foregroundColor: const Color(0xFF13131A),
          text: 'Update Payment',
          onPressed: _submit,
          logoImage: null,
          addBorder: null,
        ),
      ],
    );
  }
} 