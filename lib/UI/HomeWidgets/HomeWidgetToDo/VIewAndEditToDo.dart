import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class ViewAndEditToDo extends StatelessWidget {

  final selectedToDo;

  const ViewAndEditToDo({Key? key, this.selectedToDo}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            color: colors.Colors().lightBlack(1),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(selectedToDo["todo"], style: TypographyStyles.normalText(16, Themes.mainThemeColorAccent.shade100).copyWith(height: 1.4),
                  ),
                  SizedBox(height: 8, width: Get.width,),
                  Text(selectedToDo["notes"], style: TypographyStyles.normalText(14, Themes.mainThemeColorAccent.shade300).copyWith(height: 1.4),
                  ),
                  SizedBox(height: 12,),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text("Due Date", style: TypographyStyles.normalText(13,
                        DateTime.parse(selectedToDo["endDate"]).difference(DateTime.now()).inMinutes > 0 ? colors.Colors().lightCardBG.withOpacity(0.6) : selectedToDo["completed"] ? Colors.green : Colors.red,
                      ),),
                      SizedBox(width: 5,),
                      Text(
                        DateFormat("MMM dd, yyyy hh:mm a").format(DateTime.parse(selectedToDo["endDate"])),
                        style: TypographyStyles.boldText(15,
                          DateTime.parse(selectedToDo["endDate"]).difference(DateTime.now()).inMinutes > 0 ? colors.Colors().lightCardBG.withOpacity(0.6) : selectedToDo["completed"] ? Colors.green : Colors.red,
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
}
