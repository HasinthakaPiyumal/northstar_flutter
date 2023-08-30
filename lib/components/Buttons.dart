import 'package:flutter/material.dart';

class Buttons {
  static Widget yellowFlatButton({
    String label = 'Button',
    required VoidCallback onPressed,
    double width = 264,
    double height = 44,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        splashColor: Colors.yellow, // Customize the splash color
        borderRadius: BorderRadius.circular(5),
        child: Container(
          width: width,
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: ShapeDecoration(
            color: Color(0xFFFFB700),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          ),
          child: Center(
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF1B1F24),
                fontSize: 20,
                fontFamily: 'Bebas Neue',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
