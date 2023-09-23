import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/components/Buttons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ViewAndEditToDo extends StatelessWidget {
  final selectedToDo;

  const ViewAndEditToDo({Key? key, this.selectedToDo}) : super(key: key);

  Future<void> shareNow(BuildContext context) async {
    final RenderBox box = context.findRenderObject() as RenderBox;

    try {
      final response =
          await http.get(Uri.parse("https://placehold.co/600x400@3x.png"));

      if (response.statusCode == 200) {
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/image.png';

        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        Share.shareFiles(
          [filePath],
          text: '${selectedToDo["notes"]}'.capitalizeFirst as String,
          subject: '${selectedToDo["todo"]}'.capitalizeFirst as String,
          mimeTypes: ['image/*'],
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size,
        );
      } else {
        throw Exception('Failed to load image');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View ToDo"),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
                width: Get.width,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color:
                        Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                    borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${selectedToDo["todo"]}'.capitalize as String,
                        style: TypographyStyles.title(20)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 20,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                DateFormat("MMM dd, yyyy hh:mm a").format(
                                    DateTime.parse(selectedToDo["endDate"])),
                                style: TypographyStyles.text(16),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          Text(
                            '${selectedToDo["notes"]}'.capitalizeFirst
                                as String,
                            style: TypographyStyles.text(14),
                          ),
                          SizedBox(
                            height: 24,
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                            child: Buttons.outlineButton(
                                onPressed: () {
                                  Get.back();
                                },
                                label: 'close')),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            child: Buttons.yellowFlatButton(
                                onPressed: () {
                                  shareNow(context);
                                },
                                label: 'share')),
                      ],
                    )
                  ],
                ))
            // child: Card(
            //   elevation: 0,
            //   margin: EdgeInsets.zero,
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(15),
            //   ),
            //   color: colors.Colors().lightBlack(1),
            //   child: Padding(
            //     padding: EdgeInsets.all(16),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(selectedToDo["todo"], style: TypographyStyles.normalText(16, Themes.mainThemeColorAccent.shade100).copyWith(height: 1.4),
            //         ),
            //         SizedBox(height: 8, width: Get.width,),
            //         Text(selectedToDo["notes"], style: TypographyStyles.normalText(14, Themes.mainThemeColorAccent.shade300).copyWith(height: 1.4),
            //         ),
            //         SizedBox(height: 12,),
            //         Row(
            //           mainAxisSize: MainAxisSize.min,
            //           crossAxisAlignment: CrossAxisAlignment.center,
            //           children: [
            //             Text("Due Date", style: TypographyStyles.normalText(13,
            //               DateTime.parse(selectedToDo["endDate"]).difference(DateTime.now()).inMinutes > 0 ? colors.Colors().lightCardBG.withOpacity(0.6) : selectedToDo["completed"] ? Colors.green : Colors.red,
            //             ),),
            //             SizedBox(width: 5,),
            //             Text(
            //               DateFormat("MMM dd, yyyy hh:mm a").format(DateTime.parse(selectedToDo["endDate"])),
            //               style: TypographyStyles.boldText(15,
            //                 DateTime.parse(selectedToDo["endDate"]).difference(DateTime.now()).inMinutes > 0 ? colors.Colors().lightCardBG.withOpacity(0.6) : selectedToDo["completed"] ? Colors.green : Colors.red,
            //               ),
            //             ),
            //           ],
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            ),
      ),
    );
  }
}
