import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';

class AnimatedButton extends StatelessWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color? foregroundColor;
  final String text;
  final VoidCallback? onPressed;
  final String? logoImage;
  final BorderSide? addBorder;
  final double? fontSize; // Add fontSize parameter

  const AnimatedButton(
      {super.key,
      required this.width,
      required this.height,
      required this.backgroundColor,
      required this.text,
      required this.onPressed,
      required this.logoImage,
      required this.addBorder, required this.foregroundColor,
      this.fontSize}); // Add fontSize to constructor

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.linear,
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: addBorder ?? BorderSide.none),
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        onPressed: onPressed,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (logoImage != null) ...[
                SizedBox(
                  width: 24, 
                  height: 24, 
                  child: Image.asset(logoImage!)
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    text,
                    style: GoogleFonts.poppins(
                      fontSize: fontSize ?? 15.5, // Use provided fontSize or default
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 