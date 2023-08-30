import 'package:flutter/material.dart';
import 'package:north_star/Styles/AppColors.dart';

class CheckButton extends StatefulWidget {
  final bool isChecked;
  final double width;
  final double height;

  CheckButton({this.isChecked = false, this.width = 48, this.height = 24});

  @override
  _CheckButtonState createState() => _CheckButtonState();
}

class _CheckButtonState extends State<CheckButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: widget.width,
              height: widget.height,
              decoration: ShapeDecoration(
                color: widget.isChecked ? AppColors.accentColor : Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: BorderSide(width: 0.75, color: AppColors.accentColor),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Positioned(
            left: widget.isChecked ? 26 : 4,
            top: widget.isChecked ? 3 : 4,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 100),
              width: widget.isChecked ? 18 : 16,
              height: widget.isChecked ? 18 : 16,
              decoration: ShapeDecoration(
                color: widget.isChecked ? Colors.white : AppColors.accentColor,
                shape: CircleBorder(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}