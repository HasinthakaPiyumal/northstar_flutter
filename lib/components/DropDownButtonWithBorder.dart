import 'package:flutter/material.dart';

import '../Styles/AppColors.dart';

class DropdownButtonWithBorder extends StatefulWidget {
  final List<String> items;
  final String selectedValue;
  final double width;
  final Function(String) onChanged;

  DropdownButtonWithBorder({
    required this.items,
    required this.selectedValue,
    required this.onChanged,
    this.width  = 160
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
          color: Colors.white.withOpacity(0.5),
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
                widget.onChanged(newValue!);
              },
              dropdownColor: AppColors.primary2Color,
              elevation: 2,
              items: widget.items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              underline: Container(),
              icon: Icon(null),
            ),
          ),
          Positioned(
            right: 6,
            top: 12,
            child: Icon(Icons.keyboard_arrow_down_rounded),
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
