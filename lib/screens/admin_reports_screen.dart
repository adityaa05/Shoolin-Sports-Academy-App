import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});

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
          return const Center(child: CircularProgressIndicator());
        }

        final activeStudents = provider.getActiveStudents();
        final completedPayments = provider.getCompletedPayments();
        final pendingPayments = provider.getPendingPayments();

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF13131A), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 24.0 * scale),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Overview Section
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: sectionSpacing),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Padding(
                          padding: cardPadding,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.all(12 * scale),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB2FF00).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14 * scale),
                                ),
                                child: Icon(Icons.analytics_rounded, color: const Color(0xFFB2FF00), size: 28 * scale),
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reports & Analytics',
                                      style: GoogleFonts.prompt(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        fontSize: 22 * scale,
                                      ),
                                    ),
                                    SizedBox(height: 8 * scale),
                                    Text(
                                      'Comprehensive overview of your kickboxing business',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white70,
                                        fontSize: 14 * scale,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Key Metrics
                      Padding(
                        padding: EdgeInsets.only(bottom: cardSpacing),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB2FF00).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              child: Icon(Icons.bar_chart_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            ),
                            SizedBox(width: 12 * scale),
                            Text(
                              'Key Metrics',
                              style: GoogleFonts.prompt(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18 * scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: cardSpacing,
                        mainAxisSpacing: cardSpacing,
                        childAspectRatio: 1.2,
                        children: [
                          _buildMetricCard(
                            context,
                            'Total Students',
                            activeStudents.length.toString(),
                            Icons.people,
                            const Color(0xFF1976D2),
                            scale,
                            cardRadius,
                            cardPadding,
                          ),
                          _buildMetricCard(
                            context,
                            'Active Students',
                            activeStudents.length.toString(),
                            Icons.person,
                            const Color(0xFF10B981),
                            scale,
                            cardRadius,
                            cardPadding,
                          ),
                          _buildMetricCard(
                            context,
                            'Total Revenue',
                            '₹${_calculateTotalRevenue(completedPayments)}',
                            Icons.attach_money,
                            const Color(0xFFB2FF00),
                            scale,
                            cardRadius,
                            cardPadding,
                          ),
                          _buildMetricCard(
                            context,
                            'Pending Payments',
                            pendingPayments.length.toString(),
                            Icons.pending,
                            const Color(0xFFF59E0B),
                            scale,
                            cardRadius,
                            cardPadding,
                          ),
                        ],
                      ),
                      SizedBox(height: sectionSpacing),

                      // Revenue Analysis
                      Padding(
                        padding: EdgeInsets.only(bottom: cardSpacing),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              child: Icon(Icons.stacked_line_chart_rounded, color: const Color(0xFF10B981), size: 20 * scale),
                            ),
                            SizedBox(width: 12 * scale),
                            Text(
                              'Revenue Analysis',
                              style: GoogleFonts.prompt(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18 * scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: sectionSpacing),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Padding(
                          padding: cardPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildRevenueItem('Total Revenue', '₹${_calculateTotalRevenue(completedPayments)}', const Color(0xFF10B981), scale),
                              _buildRevenueItem('Pending Revenue', '₹${_calculateTotalRevenue(pendingPayments)}', const Color(0xFFF59E0B), scale),
                              _buildRevenueItem('Average Payment', '₹${_calculateAveragePayment(completedPayments)}', const Color(0xFF1976D2), scale),
                            ],
                          ),
                        ),
                      ),

                      // Recent Activity
                      Padding(
                        padding: EdgeInsets.only(bottom: cardSpacing),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB2FF00).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              child: Icon(Icons.payments_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            ),
                            SizedBox(width: 12 * scale),
                            Text(
                              'Recent Payments',
                              style: GoogleFonts.prompt(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18 * scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: sectionSpacing),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Padding(
                          padding: cardPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...completedPayments.take(5).map((payment) {
                                final student = provider.getStudentById(payment.studentId);
                                return _buildRecentPaymentItem(payment, student, scale);
                              }).toList(),
                              if (completedPayments.isEmpty)
                                Padding(
                                  padding: EdgeInsets.all(16.0 * scale),
                                  child: Text(
                                    'No recent payments',
                                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 14 * scale),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Student Performance
                      Padding(
                        padding: EdgeInsets.only(bottom: cardSpacing),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1976D2).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              child: Icon(Icons.emoji_events_rounded, color: const Color(0xFF1976D2), size: 20 * scale),
                            ),
                            SizedBox(width: 12 * scale),
                            Text(
                              'Top Students',
                              style: GoogleFonts.prompt(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18 * scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: sectionSpacing),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Padding(
                          padding: cardPadding,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...activeStudents.take(5).map((student) {
                                return _buildTopStudentItem(context, student, provider, scale);
                              }).toList(),
                            ],
                          ),
                        ),
                      ),

                      // Export Options
                      Padding(
                        padding: EdgeInsets.only(bottom: cardSpacing),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(8 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB2FF00).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              child: Icon(Icons.file_download_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            ),
                            SizedBox(width: 12 * scale),
                            Text(
                              'Export Reports',
                              style: GoogleFonts.prompt(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 18 * scale,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: sectionSpacing),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(cardRadius),
                          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
                        ),
                        child: Padding(
                          padding: cardPadding,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildExportButton(
                                      context,
                                      'Student List',
                                      Icons.people,
                                      const Color(0xFF1976D2),
                                      () => _exportStudentList(context, activeStudents),
                                      scale,
                                      cardRadius,
                                    ),
                                  ),
                                  SizedBox(width: cardSpacing),
                                  Expanded(
                                    child: _buildExportButton(
                                      context,
                                      'Payment Report',
                                      Icons.payment,
                                      const Color(0xFF10B981),
                                      () => _exportPaymentReport(context, completedPayments),
                                      scale,
                                      cardRadius,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: cardSpacing),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildExportButton(
                                      context,
                                      'Attendance Report',
                                      Icons.checklist,
                                      const Color(0xFFF59E0B),
                                      () => _exportAttendanceReport(context, provider),
                                      scale,
                                      cardRadius,
                                    ),
                                  ),
                                  SizedBox(width: cardSpacing),
                                  Expanded(
                                    child: _buildExportButton(
                                      context,
                                      'Financial Summary',
                                      Icons.analytics,
                                      const Color(0xFFB2FF00),
                                      () => _exportFinancialSummary(context, completedPayments),
                                      scale,
                                      cardRadius,
                                    ),
                                  ),
                                ],
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
        );
      },
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value, IconData icon, Color color, double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.12), Colors.white.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: color.withOpacity(0.18), width: 1),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: cardPadding.horizontal / 2, vertical: cardPadding.vertical / 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10 * scale),
              decoration: BoxDecoration(
                color: color.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14 * scale),
              ),
              child: Icon(icon, size: 28 * scale, color: color),
            ),
            SizedBox(height: 8 * scale),
            Text(
              value,
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.bold,
                fontSize: 20 * scale,
                color: color,
              ),
            ),
            SizedBox(height: 4 * scale),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontSize: 12 * scale,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueItem(String label, String value, Color color, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0 * scale),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 16 * scale, color: Colors.white),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
            decoration: BoxDecoration(
              color: color.withOpacity(0.18),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Text(
              value,
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.bold,
                fontSize: 18 * scale,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPaymentItem(payment, student, double scale) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8 * scale),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withOpacity(0.18),
          borderRadius: BorderRadius.circular(14 * scale),
        ),
        child: Icon(Icons.check_circle_rounded, color: const Color(0xFF10B981), size: 20 * scale),
      ),
      title: Text(
        student?.name ?? 'Unknown Student',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16 * scale),
      ),
      subtitle: Wrap(
        spacing: 8 * scale,
        runSpacing: 8 * scale,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Text(
              '₹${payment.amount.toStringAsFixed(2)}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13 * scale, color: const Color(0xFFB2FF00)),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8 * scale),
            ),
            child: Text(
              payment.paymentMethod,
              style: GoogleFonts.poppins(fontSize: 12 * scale, color: Colors.white70),
            ),
          ),
        ],
      ),
      trailing: Text(
        DateFormat('MMM d').format(payment.paymentDate),
        style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13 * scale),
      ),
    );
  }

  Widget _buildTopStudentItem(BuildContext context, student, AppProvider provider, double scale) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.value(provider.getStudentStats(student.id!)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Failed to load statistics: \n${snapshot.error?.toString() ?? 'Unknown error'}',
              style: GoogleFonts.poppins(color: Colors.red, fontSize: 14 * scale),
              textAlign: TextAlign.center,
            ),
          );
        }
        final stats = snapshot.data ?? {};
        final attendanceRate = stats['totalClasses'] > 0 
            ? (stats['classesAttended'] / stats['totalClasses'] * 100).toStringAsFixed(1)
            : '0.0';

        return ListTile(
          leading: Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.18),
              borderRadius: BorderRadius.circular(14 * scale),
            ),
            child: Text(
              student.name[0].toUpperCase(),
              style: GoogleFonts.prompt(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18 * scale),
            ),
          ),
          title: Text(
            student.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white, fontSize: 16 * scale),
          ),
          subtitle: Wrap(
            spacing: 8 * scale,
            runSpacing: 8 * scale,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Text(
                  '${stats['classesAttended'] ?? 0} attended',
                  style: GoogleFonts.poppins(fontSize: 12 * scale, color: Colors.white70),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8 * scale),
                ),
                child: Text(
                  '$attendanceRate% attendance',
                  style: GoogleFonts.poppins(fontSize: 12 * scale, color: const Color(0xFF10B981)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportButton(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap, double scale, double cardRadius) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: color.withOpacity(0.18), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(cardRadius),
          child: Padding(
            padding: EdgeInsets.all(16.0 * scale),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(10 * scale),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  child: Icon(icon, size: 24 * scale, color: color),
                ),
                SizedBox(height: 8 * scale),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontSize: 14 * scale,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
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

  String _calculateAveragePayment(List payments) {
    if (payments.isEmpty) return '0.00';
    double total = 0;
    for (var payment in payments) {
      total += payment.amount;
    }
    return (total / payments.length).toStringAsFixed(2);
  }

  void _exportStudentList(BuildContext context, List students) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Student list export feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportPaymentReport(BuildContext context, List payments) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment report export feature coming soon!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _exportAttendanceReport(BuildContext context, AppProvider provider) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Attendance report export feature coming soon!'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _exportFinancialSummary(BuildContext context, List payments) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Financial summary export feature coming soon!'),
        backgroundColor: Colors.purple,
      ),
    );
  }
} 