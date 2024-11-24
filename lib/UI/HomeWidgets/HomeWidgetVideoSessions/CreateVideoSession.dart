import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/DatePickerThemes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../../../Styles/ThemeBdayaStyles.dart';
import '../../../components/Buttons.dart';

class CreateVideoSession extends StatelessWidget {
  const CreateVideoSession({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;

    RxBool isCreating = false.obs;
    RxList selectedMembers = [].obs;

    TextEditingController title = TextEditingController();
    TextEditingController description = TextEditingController();
    TextEditingController dateTime = TextEditingController();

    RxString meetingDateTime = "".obs;

    String _formatMeetingDateTime(dynamic dateTime) {
      // Assuming dateTime is a DateTime object or a string in a specific format
      // Convert the dateTime to a formatted string
      if (dateTime is DateTime) {
        // Format DateTime object to desired format (e.g., "MM/dd/yyyy HH:mm")
        return DateFormat('MMMM d, y - HH:mm').format(dateTime);
      } else {
        // If it's a string already in a desired format
        return dateTime; // Or format it accordingly if it's in a different format
      }
    }

    void saveMeeting() async {
      ready.value = false;
      isCreating.value = true;
      List idList = [];
      selectedMembers.forEach((element) {
        idList.add(element['user_id']);
      });

      Map res = await httpClient.saveMeeting({
        'title': title.text,
        'description': description.text,
        'trainer_id': authUser.id,
        'clients': idList,
        'start_time': meetingDateTime.value,
      });
      print({
        'title': title.text,
        'description': description.text,
        'trainer_id': authUser.id,
        'clients': idList,
        'start_time': meetingDateTime.value,
      });

      if (res['code'] == 200) {
        print(res);
        idList.forEach((id) {
          httpClient.sendNotification(
              id,
              "New meeting scheduled",
              "You have a new meeting with ${authUser.name} on ${_formatMeetingDateTime(meetingDateTime.value)}",
              NSNotificationTypes.Common, {});
        });
        Get.back();
        showSnack('Success!', 'Meeting created successfully!');
      } else {
        isCreating.value = false;
        ready.value = true;
        print(res);
        showSnack('Error!', 'Something went wrong!');
      }
    }

    Future<List> searchMembers(pattern) async {
      Map res = await httpClient.searchMembers(pattern);
      if (res['code'] == 200) {
        return res['data'];
      } else {
        return [];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Create Video Session'),
      ),
      body: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Container(
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Add Members', style: TypographyStyles.title(18)),
                    ],
                  ),
                  SizedBox(height: 16),
                  TypeAheadField(
                    builder: (context, controller, focusNode) {
                      return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofocus: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Search Members...',
                            border: UnderlineInputBorder(),
                          ));
                    },
                    suggestionsCallback: (pattern) async {
                      print(pattern);
                      return await searchMembers(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      var jsonObj = jsonDecode(jsonEncode(suggestion));

                      return ListTile(
                        title: Text(jsonObj['user']['name']),
                        subtitle: Text(jsonObj['user']['email']),
                      );
                    },
                    onSelected: (suggestion) {
                      var jsonObj = jsonDecode(jsonEncode(suggestion));

                      var already = selectedMembers.firstWhereOrNull(
                          (element) =>
                              element['user_id'] == jsonObj['user_id']);
                      if (already == null) {
                        selectedMembers.add(jsonObj);
                        print(jsonObj);
                      } else {
                        print('already added');
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: dateTime,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Meeting Start Time',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: SvgPicture.asset(
                          "assets/svgs/birthday.svg",
                          width: 14,
                          height: 14,
                          color: AppColors().getPrimaryColor(reverse: true),
                        ),
                      ),
                      border: UnderlineInputBorder(),
                    ),
                    onTap: () {
                      DatePickerBdaya.showDateTimePicker(
                        context,
                        theme: ThemeBdayaStyles.main(),
                        showTitleActions: true,
                        minTime: DateTime.now(),
                        currentTime: DateTime.now(),
                        onChanged: (date) {
                          print('change $date');
                        },
                        onConfirm: (date) {
                          print('confirm $date');
                          meetingDateTime.value = date.toUtc().toString();
                          print(date.isUtc);
                          print(date.timeZoneOffset);
                          dateTime.text = DateFormat("dd MMM, yyyy")
                                  .format(date)
                                  .toString() +
                              " at " +
                              DateFormat("h:mm a").format(date).toString();
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: dateTime,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Meeting Duration',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: SvgPicture.asset(
                          "assets/svgs/time.svg",
                          width: 14,
                          height: 14,
                          color: AppColors().getPrimaryColor(reverse: true),
                        ),
                      ),
                      border: UnderlineInputBorder(),
                    ),
                    onTap: () {
                      DatePickerBdaya.showDateTimePicker(
                        context,
                        theme: ThemeBdayaStyles.main(),
                        showTitleActions: true,
                        minTime: DateTime.now(),
                        currentTime: DateTime.now(),
                        onChanged: (date) {
                          print('change $date');
                        },
                        onConfirm: (date) {
                          print('confirm $date');
                          meetingDateTime.value = date.toUtc().toString();
                          print(date.isUtc);
                          print(date.timeZoneOffset);
                          dateTime.text = DateFormat("dd MMM, yyyy")
                                  .format(date)
                                  .toString() +
                              " at " +
                              DateFormat("h:mm a").format(date).toString();
                        },
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: title,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: UnderlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    maxLines: 3,
                    controller: description,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Obx(() => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: ListView.builder(
                    itemCount: selectedMembers.length,
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          tileColor: Get.isDarkMode
                              ? AppColors.primary2Color
                              : Colors.white,
                          leading: ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: HttpClient.s3BaseUrl +
                                  selectedMembers[index]['user']['avatar_url'],
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                            ),
                          ),
                          title: Text(selectedMembers[index]['user']['name']),
                          subtitle:
                              Text(selectedMembers[index]['user']['email']),
                          trailing: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              selectedMembers.removeAt(index);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              )),
        ],
      ),
      bottomNavigationBar: Obx(
        () => Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          child: Container(
              height: 44,
              child: Buttons.yellowTextIconButton(
                  onPressed: () {
                    saveMeeting();
                  },
                  icon: Icons.video_call_outlined,
                  label: 'create video session',
                  isLoading: isCreating.value)),
        ),
      ),
    );
  }
}
