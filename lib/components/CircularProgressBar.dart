import 'package:flutter/material.dart';

class CircularProgressBar extends StatelessWidget {
  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color backgroundColor;
  final double radius;
  final double fontSize;

  CircularProgressBar({
    required this.progress,
    this.strokeWidth = 4.0,
    this.progressColor = const Color(0xFF67FB7F),
    this.radius = 26.0,
    this.backgroundColor = const Color(0x1167FB7F),
    this.fontSize = 16
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: radius*2,
          height: radius*2,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: strokeWidth,
            backgroundColor: backgroundColor,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
        Center(
          child: Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}