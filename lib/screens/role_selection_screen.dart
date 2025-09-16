import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';
import '../widgets/animated_button.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({Key? key}) : super(key: key);

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String _selectedRole = 'student';

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Section Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFFB2FF00).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(14 * scale),
                            border: Border.all(color: const Color(0xFFB2FF00).withOpacity(0.3)),
                          ),
                          child: Icon(Icons.sports_martial_arts_rounded, color: const Color(0xFFB2FF00), size: 24 * scale),
                        ),
                        SizedBox(width: 16 * scale),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to',
                                style: GoogleFonts.prompt(
                                  fontSize: 24 * scale,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                              Text(
                                'Shoolin Academy',
                                style: GoogleFonts.prompt(
                                  fontSize: 32 * scale,
                                  fontWeight: FontWeight.w700,
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
                    SizedBox(height: 8 * scale),
                    Text(
                      'Please select your role to continue',
                      style: GoogleFonts.poppins(
                        fontSize: 16 * scale,
                        color: Colors.white.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: sectionSpacing * 2),

                    // Role Selection Section Header
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10 * scale),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1976D2).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12 * scale),
                            border: Border.all(color: const Color(0xFF1976D2).withOpacity(0.3)),
                          ),
                          child: Icon(Icons.person_rounded, color: const Color(0xFF1976D2), size: 20 * scale),
                        ),
                        SizedBox(width: 12 * scale),
                        Text(
                          'Select Your Role',
                          style: GoogleFonts.prompt(
                            fontWeight: FontWeight.w600, 
                            fontSize: 18 * scale, 
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: cardSpacing),

                    // Role selection cards (keeping them as they are)
                    Column(
                      children: [
                        _buildRoleCard(
                          'Student',
                          'student',
                          CupertinoIcons.person_2,
                          'Access your classes, mark attendance, and track your progress',
                          scale,
                          cardRadius,
                          cardPadding,
                        ),
                        SizedBox(height: cardSpacing),
                        _buildRoleCard(
                          'Instructor',
                          'instructor',
                          CupertinoIcons.person_crop_circle_badge_checkmark,
                          'Manage your classes, view student attendance, and track performance',
                          scale,
                          cardRadius,
                          cardPadding,
                        ),
                        SizedBox(height: cardSpacing),
                        _buildRoleCard(
                          'Admin',
                          'admin',
                          CupertinoIcons.person_crop_circle_badge_exclam,
                          'Full system access to manage students, instructors, and academy operations',
                          scale,
                          cardRadius,
                          cardPadding,
                        ),
                      ],
                    ),
                    SizedBox(height: sectionSpacing * 1.5),

                    // Proceed Button Section
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
                                    color: const Color(0xFF10B981).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12 * scale),
                                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                                  ),
                                  child: Icon(Icons.arrow_forward_rounded, color: const Color(0xFF10B981), size: 20 * scale),
                                ),
                                SizedBox(width: 12 * scale),
                                Text(
                                  'Ready to Continue',
                                  style: GoogleFonts.prompt(
                                    fontWeight: FontWeight.w600, 
                                    fontSize: 18 * scale, 
                                    color: Colors.white
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: cardSpacing * 1.5),
                            
                            // Proceed button
                            AnimatedButton(
                              width: double.infinity,
                              height: 56 * scale,
                              backgroundColor: const Color(0xFFB2FF00),
                              text: "Proceed",
                              onPressed: () {
                                Navigator.pushNamed(context, '/login', arguments: _selectedRole);
                              },
                              logoImage: null,
                              addBorder: null,
                              foregroundColor: const Color(0xFF13131A),
                              fontSize: 16 * scale,
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
    );
  }

  Widget _buildRoleCard(String title, String role, IconData icon, String description, double scale, double cardRadius, EdgeInsets cardPadding) {
    final isSelected = _selectedRole == role;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: cardPadding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected 
                ? [
                    const Color(0xFFB2FF00).withOpacity(0.15),
                    const Color(0xFFB2FF00).withOpacity(0.08),
                  ]
                : [
                    Colors.white.withOpacity(0.12),
                    Colors.white.withOpacity(0.06),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(cardRadius),
          border: Border.all(
            color: isSelected 
                ? const Color(0xFFB2FF00).withOpacity(0.4)
                : Colors.white.withOpacity(0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xFFB2FF00).withOpacity(0.2)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 56 * scale,
              height: 56 * scale,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isSelected 
                      ? [
                          const Color(0xFFB2FF00).withOpacity(0.25),
                          const Color(0xFFB2FF00).withOpacity(0.15),
                        ]
                      : [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14 * scale),
                border: Border.all(
                  color: isSelected 
                      ? const Color(0xFFB2FF00).withOpacity(0.4)
                      : Colors.white.withOpacity(0.2),
                ),
              ),
              child: Icon(
                icon,
                color: isSelected 
                    ? const Color(0xFF13131A)
                    : Colors.white,
                size: 26 * scale,
              ),
            ),
            SizedBox(width: 16 * scale),
            
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.prompt(
                      fontSize: 20 * scale,
                      fontWeight: FontWeight.w700,
                      color: isSelected 
                          ? const Color(0xFFB2FF00)
                          : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6 * scale),
                  Text(
                    description,
                    style: GoogleFonts.poppins(
                      fontSize: 14 * scale,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Selection indicator
            if (isSelected)
              Container(
                width: 28 * scale,
                height: 28 * scale,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFB2FF00),
                      const Color(0xFFB2FF00).withOpacity(0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFB2FF00).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  CupertinoIcons.check_mark,
                  color: const Color(0xFF13131A),
                  size: 18 * scale,
                ),
              ),
          ],
        ),
      ),
    );
  }
} 