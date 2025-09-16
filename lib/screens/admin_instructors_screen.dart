import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/app_provider.dart';
import '../services/firebase_service.dart';
import '../models/instructor.dart';
import '../constants/batches.dart';
import 'package:google_fonts/google_fonts.dart';

class AdminInstructorsScreen extends StatefulWidget {
  const AdminInstructorsScreen({super.key});

  @override
  State<AdminInstructorsScreen> createState() => _AdminInstructorsScreenState();
}

class _AdminInstructorsScreenState extends State<AdminInstructorsScreen> {
  bool _isLoading = false;
  // 1. Add a search bar state and logic
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AppProvider>(context, listen: false).loadInstructors();
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
          return const Center(child: CircularProgressIndicator());
        }

        // Filter instructors by search query
        final filteredInstructors = provider.instructors.where((i) =>
          i.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          i.email.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();

        return Stack(
          children: [
            Container(
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header (without the button)
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 20.0 * scale),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12 * scale),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB2FF00).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(14 * scale),
                                ),
                                child: Icon(Icons.person_pin, color: const Color(0xFFB2FF00), size: 28 * scale),
                              ),
                              SizedBox(width: 16 * scale),
                              Expanded(
                                child: Text(
                                  'Instructor Management',
                                  style: GoogleFonts.prompt(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 22 * scale,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Search bar
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0 * scale, vertical: 8.0 * scale),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(cardRadius),
                              border: Border.all(color: Colors.white.withOpacity(0.1)),
                            ),
                            child: TextField(
                              style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                              decoration: InputDecoration(
                                hintText: 'Search instructors by name or email...',
                                hintStyle: GoogleFonts.poppins(color: Colors.white54, fontSize: 14 * scale),
                                prefixIcon: Icon(Icons.search, color: const Color(0xFFB2FF00), size: 20 * scale),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(16 * scale),
                              ),
                              onChanged: (value) => setState(() => _searchQuery = value),
                            ),
                          ),
                        ),
                        // Instructors list
                        Expanded(
                          child: filteredInstructors.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.person_pin, size: 64 * scale, color: Colors.white24),
                                      SizedBox(height: 16 * scale),
                                      Text('No instructors found', style: GoogleFonts.prompt(fontSize: 18 * scale, color: Colors.white54)),
                                      SizedBox(height: 8 * scale),
                                      Text('Add your first instructor to get started', style: GoogleFonts.poppins(color: Colors.white38, fontSize: 14 * scale)),
                                      SizedBox(height: 16 * scale),
                                      ElevatedButton.icon(
                                        onPressed: () => _showAddInstructorDialog(context, provider, scale, cardRadius),
                                        icon: Icon(Icons.add, size: 20 * scale),
                                        label: Text('Add Instructor', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14 * scale)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF1976D2),
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
                                          padding: EdgeInsets.symmetric(horizontal: 18 * scale, vertical: 12 * scale),
                                          elevation: 0,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  padding: EdgeInsets.symmetric(horizontal: 8.0 * scale, vertical: 8.0 * scale),
                                  itemCount: filteredInstructors.length,
                                  itemBuilder: (context, index) {
                                    final instructor = filteredInstructors[index];
                                    return _buildInstructorCard(context, instructor, provider, scale, cardRadius, cardPadding, cardSpacing);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Floating Action Button
            Positioned(
              bottom: 80 * scale, // Increased to be above bottom nav
              right: 24 * scale,
              child: FloatingActionButton(
                onPressed: () => _showAddInstructorDialog(context, provider, scale, cardRadius),
                backgroundColor: const Color(0xFF1976D2),
                foregroundColor: Colors.white,
                elevation: 6,
                tooltip: 'Add Instructor',
                child: Icon(Icons.add, size: 24 * scale),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInstructorCard(BuildContext context, Instructor instructor, AppProvider provider, double scale, double cardRadius, EdgeInsets cardPadding, double cardSpacing) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: cardSpacing / 2, horizontal: 4 * scale),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: cardPadding,
          childrenPadding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 8 * scale),
          leading: Container(
            padding: EdgeInsets.all(8 * scale),
            decoration: BoxDecoration(
              color: const Color(0xFF1976D2).withOpacity(0.18),
              borderRadius: BorderRadius.circular(14 * scale),
            ),
            child: Text(
              instructor.name[0].toUpperCase(),
              style: GoogleFonts.prompt(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18 * scale),
            ),
          ),
          title: Text(
            instructor.name,
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 16 * scale),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(instructor.email, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 13 * scale)),
              if (instructor.phone != null)
                Text(instructor.phone!, style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13 * scale)),
              SizedBox(height: 4 * scale),
              // 2. Show assigned batches as chips on the card (in subtitle)
              if (instructor.assignedBatches.isNotEmpty)
                Wrap(
                  spacing: 6 * scale,
                  runSpacing: 4 * scale,
                  children: instructor.assignedBatches.map((batch) =>
                    Tooltip(
                      message: 'Batch: $batch',
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8 * scale, vertical: 3 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB2FF00).withOpacity(0.18),
                          borderRadius: BorderRadius.circular(10 * scale),
                        ),
                        child: Text(batch, style: GoogleFonts.poppins(color: const Color(0xFFB2FF00), fontWeight: FontWeight.w600, fontSize: 11 * scale)),
                      ),
                    ),
                  ).toList(),
                ),
              // 4. Status toggle as Switch on the card
              Row(
                children: [
                  Tooltip(
                    message: instructor.isActive ? 'Active' : 'Inactive',
                    child: Switch(
                      value: instructor.isActive,
                      onChanged: (val) => _toggleInstructorStatus(context, provider, instructor, scale, cardRadius),
                      activeColor: const Color(0xFF10B981),
                      inactiveThumbColor: const Color(0xFFEF4444),
                      inactiveTrackColor: Colors.white24,
                    ),
                  ),
                  Text(
                    instructor.isActive ? 'Active' : 'Inactive',
                    style: GoogleFonts.poppins(
                      color: instructor.isActive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontSize: 12 * scale,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12 * scale),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                  color: Color(0xFF13131A),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18 * scale),
                    side: BorderSide(color: Colors.white.withOpacity(0.2)),
                  ),
                  textStyle: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 14 * scale,
                    fontWeight: FontWeight.w600,
                  ),
                  elevation: 8,
                ),
              ),
              child: PopupMenuButton<String>(
                icon: Icon(Icons.more_horiz_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      _showEditInstructorDialog(context, provider, instructor, scale, cardRadius);
                      break;
                    case 'assign_batches':
                      _showAssignBatchesDialog(context, provider, instructor, scale, cardRadius);
                      break;
                    case 'toggle_status':
                      _toggleInstructorStatus(context, provider, instructor, scale, cardRadius);
                      break;
                    case 'delete':
                      _showDeleteInstructorDialog(context, provider, instructor, scale, cardRadius);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_rounded, size: 16 * scale, color: const Color(0xFF1976D2)),
                        SizedBox(width: 8 * scale),
                        Text('Edit', style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'assign_batches',
                    child: Row(
                      children: [
                        Icon(Icons.assignment_rounded, size: 16 * scale, color: const Color(0xFFB2FF00)),
                        SizedBox(width: 8 * scale),
                        Text('Assign Batches', style: GoogleFonts.poppins(fontSize: 14 * scale, color: const Color(0xFFB2FF00))),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_status',
                    child: Row(
                      children: [
                        Icon(
                          instructor.isActive ? Icons.block : Icons.check_circle,
                          size: 16 * scale,
                          color: instructor.isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        ),
                        SizedBox(width: 8 * scale),
                        Text(
                          instructor.isActive ? 'Deactivate' : 'Activate',
                          style: GoogleFonts.poppins(
                            fontSize: 14 * scale,
                            color: instructor.isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_rounded, size: 16 * scale, color: const Color(0xFFEF4444)),
                        SizedBox(width: 8 * scale),
                        Text('Delete', style: GoogleFonts.poppins(fontSize: 14 * scale, color: const Color(0xFFEF4444))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          children: [
            Padding(
              padding: cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assigned Batches:',
                    style: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 15 * scale),
                  ),
                  SizedBox(height: 8 * scale),
                  if (instructor.assignedBatches.isEmpty)
                    Text(
                      'No batches assigned',
                      style: GoogleFonts.poppins(color: Colors.white54, fontStyle: FontStyle.italic, fontSize: 13 * scale),
                    )
                  else
                    Wrap(
                      spacing: 8 * scale,
                      runSpacing: 4 * scale,
                      children: instructor.assignedBatches.map((batch) {
                        return Container(
                          padding: EdgeInsets.symmetric(horizontal: 10 * scale, vertical: 4 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB2FF00).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(12 * scale),
                          ),
                          child: Text(
                            batch,
                            style: GoogleFonts.poppins(color: const Color(0xFFB2FF00), fontWeight: FontWeight.w600, fontSize: 12 * scale),
                          ),
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 8 * scale),
                  Text(
                    'Joined: ${DateFormat('MMM d, y').format(instructor.createdAt)}',
                    style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13 * scale),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddInstructorDialog(BuildContext context, AppProvider provider, double scale, double cardRadius) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

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
                      'Add Instructor',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20 * scale,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24 * scale),
                // Form
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Name field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextFormField(
                          controller: nameController,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                            prefixIcon: Icon(Icons.person_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16 * scale),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      // Email field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextFormField(
                          controller: emailController,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                          decoration: InputDecoration(
                            labelText: 'Email',
                            labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                            prefixIcon: Icon(Icons.email_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16 * scale),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter an email';
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      // Phone field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextFormField(
                          controller: phoneController,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                          decoration: InputDecoration(
                            labelText: 'Phone (Optional)',
                            labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                            prefixIcon: Icon(Icons.phone_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16 * scale),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      // Password field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextFormField(
                          controller: passwordController,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                          decoration: InputDecoration(
                            labelText: 'Password',
                            labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                            prefixIcon: Icon(Icons.lock_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16 * scale),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24 * scale),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(width: 16 * scale),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              await FirebaseService().registerInstructor(
                                name: nameController.text.trim(),
                                email: emailController.text.trim(),
                                password: passwordController.text,
                                phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                              );
                              await provider.loadInstructors();
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Instructor added successfully!', style: GoogleFonts.poppins(fontSize: 14 * scale)),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e', style: GoogleFonts.poppins(fontSize: 14 * scale)),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                                  ),
                                );
                              }
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius - 2 * scale)),
                          padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 16 * scale,
                                height: 16 * scale,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2 * scale),
                              )
                            : Text(
                                'Add',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14 * scale),
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

  void _showEditInstructorDialog(BuildContext context, AppProvider provider, Instructor instructor, double scale, double cardRadius) {
    final nameController = TextEditingController(text: instructor.name);
    final phoneController = TextEditingController(text: instructor.phone ?? '');
    final formKey = GlobalKey<FormState>();

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
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFB2FF00).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14 * scale),
                      ),
                      child: Icon(Icons.edit_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                    ),
                    SizedBox(width: 16 * scale),
                    Text(
                      'Edit Instructor',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20 * scale,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24 * scale),
                // Form
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      // Name field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextFormField(
                          controller: nameController,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                            prefixIcon: Icon(Icons.person_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16 * scale),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(height: 16 * scale),
                      // Phone field
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                          border: Border.all(color: Colors.white.withOpacity(0.2)),
                        ),
                        child: TextFormField(
                          controller: phoneController,
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 14 * scale),
                          decoration: InputDecoration(
                            labelText: 'Phone',
                            labelStyle: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale),
                            prefixIcon: Icon(Icons.phone_rounded, color: const Color(0xFFB2FF00), size: 20 * scale),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16 * scale),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24 * scale),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(width: 16 * scale),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => _isLoading = true);
                            try {
                              final updatedInstructor = instructor.copyWith(
                                name: nameController.text.trim(),
                                phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                              );
                              await provider.updateInstructor(updatedInstructor);
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Instructor updated successfully!', style: GoogleFonts.poppins(fontSize: 14 * scale)),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e', style: GoogleFonts.poppins(fontSize: 14 * scale)),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                                  ),
                                );
                              }
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius - 2 * scale)),
                          padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 16 * scale,
                                height: 16 * scale,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2 * scale),
                              )
                            : Text(
                                'Update',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14 * scale),
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

  void _showAssignBatchesDialog(BuildContext context, AppProvider provider, Instructor instructor, double scale, double cardRadius) {
    final selectedBatches = <String>{...instructor.assignedBatches};

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
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
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(12 * scale),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB2FF00).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14 * scale),
                        ),
                        child: Icon(Icons.assignment_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                      ),
                      SizedBox(width: 16 * scale),
                      Expanded(
                        child: Text(
                          'Assign Batches',
                          style: GoogleFonts.prompt(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20 * scale,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16 * scale),
                  Text(
                    'Select batches to assign to ${instructor.name}:',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15 * scale),
                  ),
                  SizedBox(height: 20 * scale),
                  // Batch list
                  Container(
                    constraints: BoxConstraints(maxHeight: 300 * scale),
                    child: SingleChildScrollView(
                      child: Column(
                        children: kBatches.map((batch) => Container(
                          margin: EdgeInsets.only(bottom: 8 * scale),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(cardRadius - 4 * scale),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: CheckboxListTile(
                            title: Text(batch, style: GoogleFonts.poppins(fontSize: 14 * scale, color: Colors.white)),
                            subtitle: getBatchTime(batch) != null
                                ? Text(
                                    'Days: ' + getBatchTime(batch)!.daysOfWeek.map((d) => ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"][d-1]).join(", "),
                                    style: GoogleFonts.poppins(fontSize: 12 * scale, color: Colors.white54),
                                  )
                                : null,
                            value: selectedBatches.contains(batch),
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  selectedBatches.add(batch);
                                } else {
                                  selectedBatches.remove(batch);
                                }
                              });
                            },
                            activeColor: const Color(0xFFB2FF00),
                            checkColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 8 * scale),
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 24 * scale),
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12 * scale),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                              side: BorderSide(color: Colors.white.withOpacity(0.3)),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      SizedBox(width: 16 * scale),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            setState(() => _isLoading = true);
                            try {
                              final updatedInstructor = instructor.copyWith(
                                assignedBatches: selectedBatches.toList(),
                              );
                              await provider.updateInstructor(updatedInstructor);
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Batches assigned successfully!', style: GoogleFonts.poppins(fontSize: 14 * scale)),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e', style: GoogleFonts.poppins(fontSize: 14 * scale)),
                                    backgroundColor: const Color(0xFFEF4444),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                                  ),
                                );
                              }
                            } finally {
                              setState(() => _isLoading = false);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1976D2),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius - 2 * scale)),
                            padding: EdgeInsets.symmetric(vertical: 12 * scale),
                            elevation: 0,
                          ),
                          child: _isLoading
                              ? SizedBox(
                                  width: 16 * scale,
                                  height: 16 * scale,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2 * scale),
                                )
                              : Text(
                                  'Assign',
                                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14 * scale),
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

  void _toggleInstructorStatus(BuildContext context, AppProvider provider, Instructor instructor, double scale, double cardRadius) {
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
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: instructor.isActive 
                            ? const Color(0xFFEF4444).withOpacity(0.2)
                            : const Color(0xFF10B981).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14 * scale),
                      ),
                      child: Icon(
                        instructor.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                        color: instructor.isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                        size: 24 * scale,
                      ),
                    ),
                    SizedBox(width: 16 * scale),
                    Text(
                      instructor.isActive ? 'Deactivate Instructor' : 'Activate Instructor',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20 * scale,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24 * scale),
                // Content
                Text(
                  'Are you sure you want to ${instructor.isActive ? 'deactivate' : 'activate'} ${instructor.name}?',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16 * scale),
                ),
                SizedBox(height: 24 * scale),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(width: 16 * scale),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          try {
                            final updatedInstructor = instructor.copyWith(
                              isActive: !instructor.isActive,
                            );
                            await provider.updateInstructor(updatedInstructor);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Instructor ${instructor.isActive ? 'deactivated' : 'activated'} successfully!',
                                    style: GoogleFonts.poppins(fontSize: 14 * scale)
                                  ),
                                  backgroundColor: instructor.isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e', style: GoogleFonts.poppins(fontSize: 14 * scale)),
                                  backgroundColor: const Color(0xFFEF4444),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                                ),
                              );
                            }
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: instructor.isActive ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius - 2 * scale)),
                          padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 16 * scale,
                                height: 16 * scale,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2 * scale),
                              )
                            : Text(
                                instructor.isActive ? 'Deactivate' : 'Activate',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14 * scale),
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

  void _showDeleteInstructorDialog(BuildContext context, AppProvider provider, Instructor instructor, double scale, double cardRadius) {
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
                // Header
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12 * scale),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14 * scale),
                      ),
                      child: Icon(Icons.delete_rounded, color: const Color(0xFFEF4444), size: 24 * scale),
                    ),
                    SizedBox(width: 16 * scale),
                    Text(
                      'Delete Instructor',
                      style: GoogleFonts.prompt(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20 * scale,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24 * scale),
                // Content
                Text(
                  'Are you sure you want to delete ${instructor.name}? This action cannot be undone.',
                  style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16 * scale),
                ),
                SizedBox(height: 24 * scale),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(cardRadius - 2 * scale),
                            side: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14 * scale, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    SizedBox(width: 16 * scale),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          try {
                            await provider.deleteInstructor(instructor.id!);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Instructor deleted successfully!', style: GoogleFonts.poppins(fontSize: 14 * scale)),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                                ),
                              );
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e', style: GoogleFonts.poppins(fontSize: 14 * scale)),
                                  backgroundColor: const Color(0xFFEF4444),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12 * scale)),
                                ),
                              );
                            }
                          } finally {
                            setState(() => _isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEF4444),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius - 2 * scale)),
                          padding: EdgeInsets.symmetric(vertical: 12 * scale),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 16 * scale,
                                height: 16 * scale,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2 * scale),
                              )
                            : Text(
                                'Delete',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14 * scale),
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
} 