import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

import '../Styles/AppColors.dart';

class DropdownButtonWithBorder extends StatefulWidget {
  final List<String> items;
  String? selectedValue;
  final double width;
  late Color color;
  final Function(String) onChanged;

  final List<DropdownMenuItem<String>>? preBuildItems;

  final bool isPreBuildItems;

  final Color backgroundColor;

  DropdownButtonWithBorder({
    required this.items,
    this.selectedValue,
    required this.onChanged,
    this.preBuildItems,
    this.isPreBuildItems = false,
    this.width  = 160,
    this.color = Colors.white,
    this.backgroundColor = AppColors.primary2Color
  });

  @override
  _DropdownButtonWithBorderState createState() =>
      _DropdownButtonWithBorderState();
}

class _DropdownButtonWithBorderState extends State<DropdownButtonWithBorder> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: 48,
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.color.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Stack(
        children: [
          Positioned(
            width: widget.width,
            child: DropdownButton<String>(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
              value: widget.selectedValue,
              onChanged: (String? newValue) {
                setState(() {
                  widget.selectedValue = newValue;
                });
                widget.onChanged(newValue!);
              },
              style: TypographyStyles.text(16).copyWith(color: widget.color ), // Button text color
              dropdownColor: widget.backgroundColor, // Dropdown background color
              elevation: 2,
              items: widget.isPreBuildItems
                  ? widget.preBuildItems
                  : widget.items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value // Dropdown item text color
                  ),
                );
              }).toList(),
              underline: Container(),
              icon: Icon(null),

            )
            ,
          ),
          Positioned(
            right: 6,
            top: 12,
            child: Icon(Icons.keyboard_arrow_down_rounded,color: widget.color,),
          ),
        ],
      ),
    );
  }
}

// Usage:
// DropdownButtonWithBorder(
//   items: ['All', 'Ongoing', 'Pending', 'Rejected'],
//   selectedValue: _assignFilterDropdown.value,
//   onChanged: (newValue) {
//     _assignFilterDropdown.value = newValue;
//   },
// )
