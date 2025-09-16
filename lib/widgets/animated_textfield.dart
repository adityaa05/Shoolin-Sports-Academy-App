import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constants/colors.dart';
import '../constants/dimensions.dart';

class AnimatedTextfield extends StatefulWidget {
  final String hintText;
  final Icon? prefixIcon;
  final bool isPassword;
  final TextEditingController? controller;

  const AnimatedTextfield(
      {super.key,
      required this.hintText,
      required this.prefixIcon,
      required this.isPassword, required this.controller, required String? Function(dynamic value) validator});

  @override
  State<AnimatedTextfield> createState() => _AnimatedTextfieldState();
}

class _AnimatedTextfieldState extends State<AnimatedTextfield> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  bool obscureText = true;

  String get hintText => widget.hintText;
  Icon? get prefixIcon => widget.prefixIcon;
  bool get isPassword => widget.isPassword;
  TextEditingController? get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    if (widget.isPassword == true) {
      obscureText = true;
    } else {
      obscureText = false;
    }

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      alignment: Alignment.centerLeft,
      curve: Curves.easeInOut,
      width: Dimensions().mediaQueryWidth(context) * 0.85,
      height: Dimensions().mediaQueryHeight(context) * 0.07,
      duration: const Duration(milliseconds: 500),
      decoration: BoxDecoration(
          color:
              _isFocused ? CustomColors().buttonGreenColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            _isFocused
                ? const BoxShadow(color: Colors.transparent)
                : BoxShadow(
                    color: CustomColors().buttonGreenColor.withOpacity(0.15),
                    spreadRadius: 0,
                    blurRadius: 0,
                    offset: const Offset(-3, 7),
                  )
          ]),
      child: TextField(
        controller: controller,
        focusNode: _focusNode,
        obscureText: obscureText,
        style: GoogleFonts.sen(
            fontSize: 18,
            color: _isFocused
                ? CustomColors().textFieldGreyColor
                : Colors.white),
        decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.sen(
                fontSize: 15.5,
                color: _isFocused
                    ? CustomColors().textFieldGreyColor
                    : Colors.grey.shade400),
            prefixIcon: prefixIcon,
            prefixIconConstraints: BoxConstraints(
                minWidth: Dimensions().mediaQueryWidth(context) * 0.15,
                minHeight: 80),
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(obscureText
                        ? CupertinoIcons.eye_slash
                        : CupertinoIcons.eye),
                    onPressed: () {
                      setState(() {
                        obscureText = !obscureText;
                      });
                    },
                  )
                : null,
            isDense: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: CustomColors().textFieldGreyColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide:
                    BorderSide(color: CustomColors().buttonGreenColor))),
      ),
    );
  }
} 