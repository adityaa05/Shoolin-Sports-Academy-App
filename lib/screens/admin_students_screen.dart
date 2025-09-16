import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/app_provider.dart';
import '../models/student.dart';
import '../constants/batches.dart';
import '../widgets/animated_button.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/payment.dart';

class AdminStudentsScreen extends StatefulWidget {
  const AdminStudentsScreen({super.key});

  @override
  State<AdminStudentsScreen> createState() => _AdminStudentsScreenState();
}

class _AdminStudentsScreenState extends State<AdminStudentsScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all'; // 'all', 'active', 'inactive'
  String _filterBatch = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadStudents();
    });
  }

  Future<void> _refreshStudents(BuildContext context) async {
    await Provider.of<AppProvider>(context, listen: false).loadStudents();
  }

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

        final allStudents = provider.students;
        final filteredStudents = allStudents.where((student) {
          // Search filter
          final matchesSearch = student.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              student.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              student.phone.toLowerCase().contains(_searchQuery.toLowerCase());
          
          // Status filter
          final matchesStatus = _filterStatus == 'all' || 
              (_filterStatus == 'active' && student.isActive) ||
              (_filterStatus == 'inactive' && !student.isActive);
          
          // Batch filter
          final matchesBatch = _filterBatch == 'all' || student.batches.contains(_filterBatch);
          
          return matchesSearch && matchesStatus && matchesBatch;
        }).toList();

        final activeStudents = allStudents.where((s) => s.isActive).length;
        final inactiveStudents = allStudents.where((s) => !s.isActive).length;

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
            child: RefreshIndicator(
              onRefresh: () => _refreshStudents(context),
              color: const Color(0xFFB2FF00),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 20.0 * scale),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section with Statistics
                        _buildHeaderSection(context, activeStudents, inactiveStudents, scale, cardRadius, cardPadding),
                        SizedBox(height: sectionSpacing),
                        
                        // Search and Filter Section
                        _buildSearchAndFilterSection(context, provider, scale, cardRadius, cardPadding),
                        SizedBox(height: sectionSpacing),
                        
                        // Students List Section Header
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10 * scale),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB2FF00).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12 * scale),
                              ),
                              child: Icon(Icons.people_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            ),
                            SizedBox(width: 12 * scale),
                            Text(
                              'Students List',
                              style: GoogleFonts.prompt(
                                fontWeight: FontWeight.w600, 
                                fontSize: 18 * scale, 
                                color: Colors.white
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${filteredStudents.length} students',
                              style: GoogleFonts.poppins(
                                fontSize: 13 * scale,
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: cardSpacing),
                        
                        // Students List
                        _buildStudentsList(context, filteredStudents, provider, scale, cardRadius, cardPadding, cardSpacing),
                        
                        // Bottom padding for FAB
                        SizedBox(height: 80 * scale),
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

  Widget _buildHeaderSection(BuildContext context, int activeStudents, int inactiveStudents, double scale, double cardRadius, EdgeInsets cardPadding) {
    return Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB2FF00).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14 * scale),
                  ),
                  child: Icon(Icons.school_rounded, color: const Color(0xFFB2FF00), size: 22 * scale),
                ),
                SizedBox(width: 16 * scale),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Students Management',
                        style: GoogleFonts.prompt(
                          fontWeight: FontWeight.w700,
                          fontSize: 24 * scale,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        'Manage your student database',
                        style: GoogleFonts.poppins(
                          fontSize: 14 * scale,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, color: Colors.white, size: 22 * scale),
                  onPressed: () => _refreshStudents(context),
                  tooltip: 'Refresh',
                ),
              ],
            ),
            SizedBox(height: 20 * scale),
            
            // Statistics Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Active Students',
                    activeStudents.toString(),
                    Icons.people_rounded,
                    const Color(0xFF10B981),
                    scale: scale,
                    cardRadius: cardRadius,
                  ),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _buildStatCard(
                    'Inactive Students',
                    inactiveStudents.toString(),
                    Icons.people_outline_rounded,
                    const Color(0xFFEF4444),
                    scale: scale,
                    cardRadius: cardRadius,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {double scale = 1.0, double cardRadius = 18}) {
    return Container(
      padding: EdgeInsets.all(16 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14 * scale),
            ),
            child: Icon(icon, color: color, size: 24 * scale),
          ),
          SizedBox(height: 12 * scale),
          Text(
            value,
            style: GoogleFonts.prompt(
              fontSize: 22 * scale,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4 * scale),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12 * scale,
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterSection(BuildContext context, AppProvider provider, double scale, double cardRadius, EdgeInsets cardPadding) {
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
                  padding: EdgeInsets.all(10 * scale),
                  decoration: BoxDecoration(
                    color: const Color(0xFFB2FF00).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12 * scale),
                  ),
                  child: Icon(Icons.search_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                ),
                SizedBox(width: 12 * scale),
                Text(
                  'Search & Filter',
                  style: GoogleFonts.prompt(
                    fontWeight: FontWeight.w600, 
                    fontSize: 18 * scale, 
                    color: Colors.white
                  ),
                ),
              ],
            ),
            SizedBox(height: 16 * scale),
            
            // Search Field
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
                borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                border: Border.all(color: Colors.white.withOpacity(0.15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search students by name, email, or phone...',
                  hintStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.6), fontSize: 14 * scale),
                  prefixIcon: Icon(Icons.search_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
                ),
                style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            SizedBox(height: 16 * scale),
            
            // Filter Row
            Row(
              children: [
                Expanded(
                  child: _buildStatusSelector(scale, cardRadius),
                ),
                SizedBox(width: 12 * scale),
                Expanded(
                  child: _buildBatchSelector(scale, cardRadius),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSelector(double scale, double cardRadius) {
    final statusOptions = ['all', 'active', 'inactive'];
    final statusDisplayOptions = ['All', 'Active', 'Inactive'];
    final currentIndex = statusOptions.indexOf(_filterStatus);
    final currentDisplay = currentIndex >= 0 ? statusDisplayOptions[currentIndex] : 'All';
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: PopupMenuButton<String>(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                currentDisplay,
                style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.7), size: 20 * scale),
          ],
        ),
        onSelected: (value) {
          setState(() {
            _filterStatus = value;
          });
        },
        itemBuilder: (context) => statusOptions.map((status) {
          final index = statusOptions.indexOf(status);
          final displayName = statusDisplayOptions[index];
          return PopupMenuItem<String>(
            value: status,
            child: Container(
              width: 120 * scale,
              child: Text(
                displayName,
                style: GoogleFonts.poppins(
                  fontSize: 14 * scale,
                  color: Colors.white,
                  fontWeight: status == _filterStatus ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          );
        }).toList(),
        color: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scale)),
        elevation: 8,
      ),
    );
  }

  Widget _buildBatchSelector(double scale, double cardRadius) {
    final batchOptions = ['all', ...kBatches];
    final batchDisplayOptions = ['All Batches', ...kBatches];
    final currentIndex = batchOptions.indexOf(_filterBatch);
    final currentDisplay = currentIndex >= 0 ? batchDisplayOptions[currentIndex] : 'All Batches';
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: PopupMenuButton<String>(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                currentDisplay,
                style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.7), size: 20 * scale),
          ],
        ),
        onSelected: (value) {
          setState(() {
            _filterBatch = value;
          });
        },
        itemBuilder: (context) => batchOptions.map((batch) {
          final index = batchOptions.indexOf(batch);
          final displayName = batchDisplayOptions[index];
          return PopupMenuItem<String>(
            value: batch,
            child: Container(
              width: 200 * scale,
              child: Text(
                displayName,
                style: GoogleFonts.poppins(
                  fontSize: 14 * scale,
                  color: Colors.white,
                  fontWeight: batch == _filterBatch ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }).toList(),
        color: const Color(0xFF1F2937),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scale)),
        elevation: 8,
      ),
    );
  }

  Widget _buildStudentsList(BuildContext context, List<Student> students, AppProvider provider, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    if (students.isEmpty) {
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
                  Icons.people_outline_rounded,
                  size: 42 * scale,
                  color: Colors.white.withOpacity(0.4),
                ),
              ),
              SizedBox(height: 16 * scale),
              Text(
                'No students found',
                style: GoogleFonts.prompt(
                  fontSize: 18 * scale,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 6 * scale),
              Text(
                'Try adjusting your search or filters',
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
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
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
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: cardPadding,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 48 * scale,
                  height: 48 * scale,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: student.isActive
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [Colors.grey.shade600, Colors.grey.shade700],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14 * scale),
                    boxShadow: [
                      BoxShadow(
                        color: student.isActive 
                            ? const Color(0xFF10B981).withOpacity(0.3)
                            : Colors.grey.withOpacity(0.3),
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
                        fontWeight: FontWeight.w700,
                        fontSize: 18 * scale,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16 * scale),
                // Student Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              student.name,
                              style: GoogleFonts.prompt(
                                fontWeight: FontWeight.w700,
                                fontSize: 16 * scale,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Status chip + switch
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                                decoration: BoxDecoration(
                                  color: (student.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16 * scale),
                                  border: Border.all(
                                    color: (student.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  student.isActive ? 'Active' : 'Inactive',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12 * scale,
                                    fontWeight: FontWeight.w600,
                                    color: student.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8 * scale),
                              Switch(
                                value: student.isActive,
                                onChanged: (val) async {
                                  final updatedStudent = student.copyWith(isActive: val);
                                  try {
                                    await provider.updateStudent(updatedStudent);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          val ? 'Student activated' : 'Student deactivated',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        backgroundColor: val ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                      ),
                                    );
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Failed to update status: \\${e.toString()}', style: GoogleFonts.poppins()),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                                activeColor: const Color(0xFF10B981),
                                inactiveThumbColor: const Color(0xFFEF4444),
                                inactiveTrackColor: const Color(0xFFEF4444).withOpacity(0.3),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                            ],
                          ),
                        ],
                      ),
                      SizedBox(height: 6 * scale),
                      Text(
                        student.email,
                        style: GoogleFonts.poppins(
                          fontSize: 13 * scale,
                          color: Colors.white.withOpacity(0.7),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4 * scale),
                      Text(
                        'Joined: \\${DateFormat('MMM d, y').format(student.createdAt)}',
                        style: GoogleFonts.poppins(
                          fontSize: 12 * scale,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      if (student.batches.isNotEmpty) ...[
                        SizedBox(height: 8 * scale),
                        Wrap(
                          spacing: 6 * scale,
                          runSpacing: 3 * scale,
                          children: student.batches.map((batch) => Container(
                            padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB2FF00).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: Border.all(
                                color: const Color(0xFFB2FF00).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              batch,
                              style: GoogleFonts.poppins(
                                fontSize: 11 * scale,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB2FF00),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
                // Actions Menu
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert_rounded, color: Colors.white.withOpacity(0.7), size: 22 * scale),
                  color: const Color(0xFF1F2937),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10 * scale)),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditStudentDialog(context, provider, student);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, provider, student);
                    } else if (value == 'view') {
                      _showStudentDetails(context, provider, student);
                    } else if (value == 'mark_payment') {
                      _showMarkPaymentDialog(context, provider, student);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility_rounded, color: const Color(0xFFB2FF00), size: 18 * scale),
                          SizedBox(width: 10 * scale),
                          Text('View Details', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13 * scale)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded, color: const Color(0xFF3B82F6), size: 18 * scale),
                          SizedBox(width: 10 * scale),
                          Text('Edit', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13 * scale)),
                        ],
                      ),
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
                    ),
                    PopupMenuItem(
                      value: 'mark_payment',
                      child: Row(
                        children: [
                          Icon(Icons.payments_rounded, color: const Color(0xFF10B981), size: 18 * scale),
                          SizedBox(width: 10 * scale),
                          Text('Mark Payment', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13 * scale)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddStudentDialog(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AddStudentDialog(provider: provider),
    );
  }

  void _showEditStudentDialog(BuildContext context, AppProvider provider, Student student) {
    showDialog(
      context: context,
      builder: (context) => EditStudentDialog(provider: provider, student: student),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppProvider provider, Student student) {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                      'Delete Student',
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
                  'Are you sure you want to delete ${student.name}?',
                  style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.8), fontSize: 15 * scale),
                ),
                SizedBox(height: 20 * scale),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
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
                        onPressed: () {
                          provider.deleteStudent(student.id!);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${student.name} deleted successfully',
                                style: GoogleFonts.poppins(),
                              ),
                              backgroundColor: const Color(0xFFEF4444),
                            ),
                          );
                        },
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
      ),
    );
  }

  void _showStudentDetails(BuildContext context, AppProvider provider, Student student) {
    showDialog(
      context: context,
      builder: (context) => StudentDetailsDialog(student: student, provider: provider),
    );
  }

  void _showMarkPaymentDialog(BuildContext context, AppProvider provider, Student student) {
    showDialog(
      context: context,
      builder: (context) => MarkPaymentDialog(provider: provider, student: student),
    );
  }
}

class AddStudentDialog extends StatefulWidget {
  final AppProvider provider;

  const AddStudentDialog({super.key, required this.provider});

  @override
  State<AddStudentDialog> createState() => _AddStudentDialogState();
}

class _AddStudentDialogState extends State<AddStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _feeController = TextEditingController();
  DateTime _joinDate = DateTime.now();
  final Set<String> _selectedBatches = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _feeController.dispose();
    super.dispose();
  }

  void _showBatchSelectionDialog() {
    final width = MediaQuery.of(context).size.width;
    final scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    final double cardRadius = 18 * scale;
    final tempSelected = Set<String>.from(_selectedBatches);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
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
                            color: const Color(0xFFB2FF00).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14 * scale),
                            border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                          ),
                          child: Icon(Icons.schedule_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                        ),
                        SizedBox(width: 16 * scale),
                        Text(
                          'Select Batches',
                          style: GoogleFonts.prompt(
                            fontWeight: FontWeight.w600,
                            fontSize: 18 * scale,
                            color: Colors.white,
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
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                              checkColor: const Color(0xFF1976D2),
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
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
                            onPressed: () {
                              setState(() {
                                _selectedBatches
                                  ..clear()
                                  ..addAll(tempSelected);
                              });
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB2FF00),
                              foregroundColor: const Color(0xFF1976D2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius - 2 * scale)),
                              padding: EdgeInsets.symmetric(vertical: 12 * scale),
                              elevation: 0,
                            ),
                            child: Text(
                              'Confirm',
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
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedBatches.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please select at least one batch',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        return;
      }
      final fee = double.tryParse(_feeController.text);
      if (fee == null || fee <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please enter a valid monthly fee',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
        return;
      }
      final student = Student(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        batches: _selectedBatches.toList(),
        isActive: true,
        createdAt: DateTime.now(),
        classType: 'kickboxing',
        monthlyFee: fee,
      );

      try {
        widget.provider.addStudent(student).then((_) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Student added successfully!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add student: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
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
          padding: cardPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12 * scale),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB2FF00).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14 * scale),
                    ),
                    child: Icon(Icons.person_add_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                  ),
                  SizedBox(width: 16 * scale),
                  Text(
                    'Add New Student',
                    style: GoogleFonts.prompt(
                      fontWeight: FontWeight.w600,
                      fontSize: 18 * scale,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: sectionSpacing),
              
              // Form
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Name Field
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
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 14 * scale),
                            prefixIcon: Icon(Icons.person_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
                          ),
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: cardSpacing),
                      
                      // Email Field
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
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 14 * scale),
                            prefixIcon: Icon(Icons.email_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
                          ),
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email';
                            }
                            final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
                            if (!emailRegex.hasMatch(value.trim())) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: cardSpacing),
                      
                      // Phone Field
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
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 14 * scale),
                            prefixIcon: Icon(Icons.phone_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
                          ),
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter phone number';
                            }
                            final phone = value.trim();
                            if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
                              return 'Please enter a valid 10-digit phone number';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: cardSpacing),
                      
                      // Batch Selection
                      GestureDetector(
                        onTap: () => _showBatchSelectionDialog(),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.1),
                                Colors.white.withOpacity(0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                            border: Border.all(color: Colors.white.withOpacity(0.15)),
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(16 * scale),
                            child: Row(
                              children: [
                                Icon(Icons.schedule_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
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
                                        SizedBox(height: 6 * scale),
                                        Wrap(
                                          spacing: 6 * scale,
                                          runSpacing: 3 * scale,
                                          children: _selectedBatches.map((batch) {
                                            return Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 4 * scale),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFB2FF00).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(16 * scale),
                                                border: Border.all(
                                                  color: const Color(0xFFB2FF00).withOpacity(0.3),
                                                ),
                                              ),
                                              child: Text(
                                                batch,
                                                style: GoogleFonts.poppins(
                                                  color: const Color(0xFFB2FF00),
                                                  fontSize: 11 * scale,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ] else ...[
                                        Text(
                                          'Select Batches',
                                          style: GoogleFonts.poppins(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 14 * scale,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.7), size: 20 * scale),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: cardSpacing),
                      
                      // Join Date
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
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: ListTile(
                          leading: Icon(Icons.calendar_today_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                          title: Text(
                            'Join Date',
                            style: GoogleFonts.poppins(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14 * scale),
                          ),
                          subtitle: Text(
                            DateFormat('MMM d, y').format(_joinDate),
                            style: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 13 * scale),
                          ),
                          onTap: () async {
                            final date = await showDialog<DateTime>(
                              context: context,
                              builder: (context) {
                                DateTime tempSelected = _joinDate;
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
                                      padding: EdgeInsets.all(20 * scale),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: EdgeInsets.all(12 * scale),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF1976D2).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(14 * scale),
                                                  border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                                                ),
                                                child: Icon(Icons.calendar_today_rounded, color: const Color(0xFF1976D2), size: 24 * scale),
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
                                                tempSelected = selected;
                                                setState(() {});
                                              },
                                              calendarStyle: CalendarStyle(
                                                todayDecoration: BoxDecoration(
                                                  color: const Color(0xFFB2FF00).withOpacity(0.2),
                                                  borderRadius: BorderRadius.circular(12 * scale),
                                                  border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                                                ),
                                                selectedDecoration: BoxDecoration(
                                                  color: const Color(0xFF1976D2),
                                                  borderRadius: BorderRadius.circular(12 * scale),
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
                            if (date != null) {
                              setState(() {
                                _joinDate = date;
                              });
                            }
                          },
                        ),
                      ),
                      SizedBox(height: cardSpacing),
                      
                      // Monthly Fee Field
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
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.15)),
                        ),
                        child: TextFormField(
                          controller: _feeController,
                          decoration: InputDecoration(
                            labelText: 'Monthly Fee',
                            labelStyle: GoogleFonts.poppins(color: Colors.white.withOpacity(0.7), fontSize: 14 * scale),
                            prefixIcon: Icon(Icons.attach_money_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.transparent,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
                          ),
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the monthly fee';
                            }
                            final fee = double.tryParse(value.trim());
                            if (fee == null || fee <= 0) {
                              return 'Please enter a valid fee';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: sectionSpacing),
              
              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB2FF00),
                        foregroundColor: const Color(0xFF1976D2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius - 2 * scale)),
                        padding: EdgeInsets.symmetric(vertical: 12 * scale),
                        elevation: 0,
                      ),
                      child: Text(
                        'Add Student',
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
}

class EditStudentDialog extends StatefulWidget {
  final AppProvider provider;
  final Student student;

  const EditStudentDialog({super.key, required this.provider, required this.student});

  @override
  State<EditStudentDialog> createState() => _EditStudentDialogState();
}

class _EditStudentDialogState extends State<EditStudentDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late DateTime _joinDate;
  late bool _isActive;
  late Set<String> _selectedBatches;
  late int _preferredPaymentDay;

  late double scale;
  late double cardRadius;
  late EdgeInsets cardPadding;
  late double sectionSpacing;
  late double cardSpacing;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.student.name);
    _emailController = TextEditingController(text: widget.student.email);
    _phoneController = TextEditingController(text: widget.student.phone);
    _joinDate = widget.student.createdAt;
    _isActive = widget.student.isActive;
    _selectedBatches = Set<String>.from(widget.student.batches);
    _preferredPaymentDay = widget.student.preferredPaymentDay ?? 1;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    scale = width < 400 ? 0.90 : width > 700 ? 1.10 : 1.0;
    cardRadius = 18 * scale;
    cardPadding = EdgeInsets.all(20 * scale);
    sectionSpacing = 20 * scale;
    cardSpacing = 12 * scale;
    
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
        child: Padding(
          padding: cardPadding,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14 * scale),
                          border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                        ),
                        child: Icon(Icons.edit_rounded, color: const Color(0xFF1976D2), size: 24 * scale),
                      ),
                      SizedBox(width: 16 * scale),
                      Expanded(
                        child: Text(
                          'Edit Student',
                          style: GoogleFonts.prompt(
                            fontWeight: FontWeight.w700,
                            fontSize: 20 * scale,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16 * scale,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14 * scale,
                      ),
                      prefixIcon: Icon(Icons.person, color: Colors.white.withOpacity(0.7), size: 20 * scale),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: cardSpacing),
                  // Email Field
                  TextFormField(
                    controller: _emailController,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16 * scale,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14 * scale,
                      ),
                      prefixIcon: Icon(Icons.email, color: Colors.white.withOpacity(0.7), size: 20 * scale),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter email';
                      }
                      final emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');
                      if (!emailRegex.hasMatch(value.trim())) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: cardSpacing),
                  // Phone Field
                  TextFormField(
                    controller: _phoneController,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16 * scale,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      labelStyle: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14 * scale,
                      ),
                      prefixIcon: Icon(Icons.phone, color: Colors.white.withOpacity(0.7), size: 20 * scale),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter phone number';
                      }
                      final phone = value.trim();
                      if (!RegExp(r'^\d{10}$').hasMatch(phone)) {
                        return 'Please enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: cardSpacing),
                  // Batch Selection
                  GestureDetector(
                    onTap: () => _showBatchSelectionDialog(),
                    child: Container(
                      width: double.infinity,
                      constraints: BoxConstraints(minHeight: 56 * scale),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(cardRadius),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 12.0 * scale),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.schedule, color: Colors.white.withOpacity(0.7), size: 20 * scale),
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
                                      spacing: 8 * scale,
                                      runSpacing: 8 * scale,
                                      children: _selectedBatches.map((batch) => Container(
                                        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF59E0B).withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(16 * scale),
                                          border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3)),
                                        ),
                                        child: Text(
                                          batch,
                                          style: GoogleFonts.poppins(
                                            fontSize: 12 * scale,
                                            fontWeight: FontWeight.w600,
                                            color: const Color(0xFFF59E0B),
                                          ),
                                        ),
                                      )).toList(),
                                    ),
                                  ] else ...[
                                    Text(
                                      'Tap to select batches',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 13 * scale,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: cardSpacing),
                  // Preferred Payment Day Dropdown
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14 * scale),
                          border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                        ),
                        child: Icon(Icons.calendar_today_rounded, color: const Color(0xFF1976D2), size: 20 * scale),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: DropdownButtonFormField<int>(
                          value: _preferredPaymentDay,
                          decoration: InputDecoration(
                            labelText: 'Preferred Payment Day',
                            labelStyle: GoogleFonts.poppins(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14 * scale,
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.08),
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
                            contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                          ),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16 * scale,
                          ),
                          dropdownColor: const Color(0xFF13131A),
                          icon: Icon(Icons.arrow_drop_down, color: Colors.white),
                          items: List.generate(28, (i) => i + 1).map((day) => DropdownMenuItem<int>(
                            value: day,
                            child: Text('Day $day', style: GoogleFonts.poppins(color: Colors.white)),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _preferredPaymentDay = val);
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: cardSpacing),
                  // Status Switch
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                        decoration: BoxDecoration(
                          color: _isActive ? const Color(0xFF10B981).withOpacity(0.2) : const Color(0xFFEF4444).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(color: (_isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(_isActive ? Icons.check_circle_rounded : Icons.cancel_rounded, color: _isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444), size: 18 * scale),
                            SizedBox(width: 8 * scale),
                            Text(
                              _isActive ? 'Active' : 'Inactive',
                              style: GoogleFonts.poppins(
                                fontSize: 12 * scale,
                                fontWeight: FontWeight.w600,
                                color: _isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      Switch(
                        value: _isActive,
                        onChanged: (val) => setState(() => _isActive = val),
                        activeColor: const Color(0xFF10B981),
                        inactiveThumbColor: const Color(0xFFEF4444),
                        inactiveTrackColor: const Color(0xFFEF4444).withOpacity(0.3),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  SizedBox(height: sectionSpacing),
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            padding: EdgeInsets.symmetric(vertical: 16 * scale),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(cardRadius),
                            ),
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontSize: 16 * scale,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12 * scale),
                      Expanded(
                        child: ElevatedButton(
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
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final updatedStudent = widget.student.copyWith(
                                name: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                phone: _phoneController.text.trim(),
                                isActive: _isActive,
                                batches: _selectedBatches.toList(),
                                preferredPaymentDay: _preferredPaymentDay,
                              );
                              try {
                                await widget.provider.updateStudent(updatedStudent);
                                Navigator.of(context).pop();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Failed to update student: ${e.toString()}',
                                      style: GoogleFonts.poppins(),
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: Text(
                            'Save',
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
        ),
      ),
    );
  }

  void _showBatchSelectionDialog() {
    final tempSelected = Set<String>.from(_selectedBatches);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF13131A), Color(0xFF1976D2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18 * scale),
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
                            color: const Color(0xFFB2FF00).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14 * scale),
                            border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                          ),
                          child: Icon(Icons.schedule_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                        ),
                        SizedBox(width: 16 * scale),
                        Text(
                          'Select Batches',
                          style: GoogleFonts.prompt(
                            fontWeight: FontWeight.w600,
                            fontSize: 18 * scale,
                            color: Colors.white,
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
                              borderRadius: BorderRadius.circular(16 * scale),
                              border: Border.all(color: Colors.white.withOpacity(0.08)),
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
                              checkColor: const Color(0xFF1976D2),
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                              contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20 * scale),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(context).pop(),
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
                            onPressed: () {
                              setState(() {
                                _selectedBatches
                                  ..clear()
                                  ..addAll(tempSelected);
                              });
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB2FF00),
                              foregroundColor: const Color(0xFF1976D2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius - 2 * scale)),
                              padding: EdgeInsets.symmetric(vertical: 12 * scale),
                              elevation: 0,
                            ),
                            child: Text(
                              'Confirm',
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
        },
      ),
    );
  }
}

class StudentDetailsDialog extends StatelessWidget {
  final Student student;
  final AppProvider provider;

  const StudentDetailsDialog({super.key, required this.student, required this.provider});

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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Section Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB2FF00).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14 * scale),
                        border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                      ),
                      child: Icon(Icons.person_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                    ),
                    SizedBox(width: 16 * scale),
                    Expanded(
                      child: Text(
                        "Student Details",
                        style: GoogleFonts.prompt(
                          fontWeight: FontWeight.w700,
                          fontSize: 20 * scale,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sectionSpacing),

                // Student Avatar and Basic Info
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80 * scale,
                        height: 80 * scale,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: student.isActive
                                ? [const Color(0xFFB2FF00), const Color(0xFF10B981)]
                                : [Colors.grey, Colors.grey.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(40 * scale),
                        ),
                        child: Center(
                          child: Text(
                            student.name[0].toUpperCase(),
                            style: GoogleFonts.prompt(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 32 * scale,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12 * scale),
                      Text(
                        student.name,
                        style: GoogleFonts.prompt(
                          fontSize: 20 * scale,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8 * scale),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 4 * scale),
                        decoration: BoxDecoration(
                          color: student.isActive
                              ? const Color(0xFF10B981).withOpacity(0.2)
                              : const Color(0xFFEF4444).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16 * scale),
                          border: Border.all(
                            color: student.isActive
                                ? const Color(0xFF10B981).withOpacity(0.3)
                                : const Color(0xFFEF4444).withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          student.isActive ? 'Active' : 'Inactive',
                          style: GoogleFonts.poppins(
                            fontSize: 12 * scale,
                            fontWeight: FontWeight.w600,
                            color: student.isActive
                                ? const Color(0xFF10B981)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: sectionSpacing),

                // Personal Information
                _buildSectionTitle('Personal Information', scale),
                _buildDetailRow(context, 'Email', student.email, scale),
                _buildDetailRow(context, 'Phone', student.phone, scale),
                _buildDetailRow(context, 'Join Date', DateFormat('MMM d, y').format(student.createdAt), scale),
                if (student.preferredPaymentDay != null)
                  _buildDetailRow(context, 'Preferred Payment Day', 'Day ${student.preferredPaymentDay}', scale),

                SizedBox(height: sectionSpacing),

                // Batch Information
                _buildSectionTitle('Batch Information', scale),
                if (student.batches.isNotEmpty) ...[
                  Wrap(
                    spacing: 8 * scale,
                    runSpacing: 8 * scale,
                    children: student.batches.map((batch) => Container(
                      padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 6 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB2FF00).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16 * scale),
                        border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                      ),
                      child: Text(
                        batch,
                        style: GoogleFonts.poppins(
                          fontSize: 12 * scale,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFB2FF00),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )).toList(),
                  ),
                ] else ...[
                  Text(
                    'No batches assigned',
                    style: GoogleFonts.poppins(color: Colors.white60, fontSize: 14 * scale),
                  ),
                ],

                SizedBox(height: sectionSpacing),

                // Statistics
                _buildSectionTitle('Statistics', scale),
                FutureBuilder<Map<String, dynamic>>(
                  future: Future.value(provider.getStudentStats(student.id!)),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(16 * scale),
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
                          ),
                          child: SizedBox(
                            width: 36 * scale,
                            height: 36 * scale,
                            child: CircularProgressIndicator(
                              strokeWidth: 3 * scale,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan.shade300),
                            ),
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Failed to load statistics',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFFEF4444),
                            fontSize: 14 * scale,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    final stats = snapshot.data ?? {};
                    final actualSessions = provider.attendance.where((a) => a.studentId == student.id).length;
                    return Column(
                      children: [
                        _buildStatCard('Classes Attended', '${stats['classesAttended'] ?? 0}', Icons.check_circle, scale),
                        SizedBox(height: cardSpacing),
                        _buildStatCard('Total Possible Sessions', '${stats['totalClasses'] ?? 0}', Icons.schedule, scale),
                        SizedBox(height: cardSpacing),
                        _buildStatCard('Actual Sessions Held', '$actualSessions', Icons.event, scale),
                        SizedBox(height: cardSpacing),
                        _buildStatCard('Payments Made', '${stats['totalPayments'] ?? 0}', Icons.payment, scale),
                        SizedBox(height: cardSpacing),
                        _buildStatCard('Total Paid', '₹${(stats['totalAmountPaid'] ?? 0.0).toStringAsFixed(2)}', Icons.attach_money, scale),
                      ],
                    );
                  },
                ),

                SizedBox(height: sectionSpacing),

                // Close Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB2FF00),
                      foregroundColor: const Color(0xFF1976D2),
                      padding: EdgeInsets.symmetric(vertical: 16 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFFB2FF00).withOpacity(0.3),
                    ),
                    child: Text(
                      'Close',
                      style: GoogleFonts.poppins(
                        fontSize: 16 * scale,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double scale) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.0 * scale),
      child: Text(
        title,
        style: GoogleFonts.prompt(
          fontSize: 16 * scale,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFB2FF00),
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, double scale) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.12),
            Colors.white.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14 * scale),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFFB2FF00).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
            ),
            child: Icon(icon, color: const Color(0xFFB2FF00), size: 20 * scale),
          ),
          SizedBox(width: 14 * scale),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14 * scale,
                color: Colors.white70,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.prompt(
              fontSize: 16 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, double scale) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.0 * scale),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100 * scale,
            child: Text(
              '$label:',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                fontSize: 14 * scale,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14 * scale,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
} 

class MarkPaymentDialog extends StatefulWidget {
  final AppProvider provider;
  final Student student;
  const MarkPaymentDialog({super.key, required this.provider, required this.student});

  @override
  State<MarkPaymentDialog> createState() => _MarkPaymentDialogState();
}

class _MarkPaymentDialogState extends State<MarkPaymentDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'Cash';
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
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
          child: Padding(
            padding: cardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14 * scale),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                      ),
                      child: Icon(Icons.payments_rounded, color: const Color(0xFF10B981), size: 24 * scale),
                    ),
                    SizedBox(width: 16 * scale),
                    Text(
                      'Mark Payment',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.w600,
                        fontSize: 18 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: sectionSpacing),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Student: ${widget.student.name}',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.w600,
                      fontSize: 15 * scale,
                    ),
                  ),
                ),
                SizedBox(height: cardSpacing),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                    prefixIcon: Icon(Icons.currency_rupee_rounded, color: Colors.white70, size: 18 * scale),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
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
                      borderSide: BorderSide(color: const Color(0xFF10B981), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                  ),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16 * scale),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: cardSpacing),
                Theme(
                  data: Theme.of(context).copyWith(
                    canvasColor: const Color(0xFF1F2937),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: _paymentMethod,
                    dropdownColor: const Color(0xFF1F2937),
                    items: ['Cash', 'UPI', 'Cheque', 'Card', 'Other']
                        .map((method) => DropdownMenuItem(
                              value: method,
                              child: Text(method, style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _paymentMethod = value!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Payment Method',
                      labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
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
                        borderSide: BorderSide(color: const Color(0xFF10B981), width: 2),
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                    ),
                    style: GoogleFonts.poppins(color: Colors.white, fontSize: 16 * scale),
                    icon: Icon(Icons.keyboard_arrow_down, color: Colors.white),
                  ),
                ),
                SizedBox(height: cardSpacing),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: ColorScheme.dark(
                              primary: const Color(0xFF1976D2),
                              onPrimary: Colors.white,
                              surface: const Color(0xFF13131A),
                              onSurface: Colors.white,
                            ),
                            dialogBackgroundColor: const Color(0xFF13131A),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 14 * scale, horizontal: 16 * scale),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10 * scale),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, color: Colors.white70, size: 18 * scale),
                        SizedBox(width: 10 * scale),
                        Text(
                          'Date: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 15 * scale),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: cardSpacing),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                    prefixIcon: Icon(Icons.note_alt_rounded, color: Colors.white70, size: 18 * scale),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.08),
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
                      borderSide: BorderSide(color: const Color(0xFF10B981), width: 2),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 16 * scale),
                  ),
                  style: GoogleFonts.poppins(color: Colors.white, fontSize: 16 * scale),
                  maxLines: 2,
                ),
                SizedBox(height: sectionSpacing),
                SizedBox(
                  width: double.infinity,
                  height: 48 * scale,
                  child: ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                            if (!_formKey.currentState!.validate()) return;
                            setState(() => _isLoading = true);
                            try {
                              final payment = Payment(
                                id: null,
                                studentId: widget.student.id!,
                                amount: double.parse(_amountController.text.trim()),
                                paymentDate: _selectedDate,
                                paymentMethod: _paymentMethod,
                                status: 'completed',
                                batch: widget.student.batches.isNotEmpty ? widget.student.batches.first : '',
                                transactionId: null,
                                notes: _notesController.text.trim(),
                                isActive: true,
                                deactivatedAt: null,
                              );
                              await widget.provider.addPayment(payment);
                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Payment marked successfully!', style: GoogleFonts.poppins()),
                                    backgroundColor: const Color(0xFF10B981),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Failed to mark payment: \\${e.toString()}', style: GoogleFonts.poppins()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16 * scale),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(cardRadius),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF10B981).withOpacity(0.3),
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
                              Icon(Icons.check_circle_rounded, size: 20 * scale),
                              SizedBox(width: 8 * scale),
                              Text('Mark Payment', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16 * scale)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 