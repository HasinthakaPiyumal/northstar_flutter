import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:intl/intl.dart';

class CreateVideoSession extends StatelessWidget {
  const CreateVideoSession({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    RxList selectedMembers = [].obs;

    TextEditingController title = TextEditingController();
    TextEditingController description = TextEditingController();
    TextEditingController dateTime = TextEditingController();

    RxString meetingDateTime = "".obs;

    void saveMeeting() async {
      ready.value = false;
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

      if (res['code'] == 200) {
        print(res);
        Get.back();
        showSnack('Success!', 'Meeting created successfully!');
      } else {
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
                    textFieldConfiguration: TextFieldConfiguration(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: 'Search Members...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                        )
                    ),
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
                    onSuggestionSelected: (suggestion) {
                      var jsonObj = jsonDecode(jsonEncode(suggestion));

                      var already = selectedMembers.firstWhereOrNull((element) => element['user_id'] == jsonObj['user_id']);
                      if (already == null){
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
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                    onTap: () {
                      DatePickerBdaya.showDateTimePicker(
                          context,
                          theme: DatePickerThemeBdaya(
                            backgroundColor: Color(0xffF1F1F1),
                            containerHeight: Get.height/3,
                          ),
                          showTitleActions: true,
                          minTime: DateTime.now(),
                          currentTime: DateTime.now(),
                          onChanged: (date) {
                            print('change $date');
                          }, onConfirm: (date) {
                            print('confirm $date');
                            meetingDateTime.value = date.toLocal().toString();
                            dateTime.text = DateFormat("dd MMM, yyyy").format(date).toString() + " at " + DateFormat("h:mm a").format(date).toString();
                          },
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: title,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: description,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                ],
              ),
            ),
          ),
          Obx(()=>Expanded(
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
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      tileColor: Get.isDarkMode ? Color(0xff101010) : Color(0xffF1F1F1),
                      leading: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: HttpClient.s3BaseUrl + selectedMembers[index]['user']['avatar_url'],
                          placeholder: (context, url) => CircularProgressIndicator(),
                        ),
                      ),
                      title: Text(selectedMembers[index]['user']['name']),
                      subtitle: Text(selectedMembers[index]['user']['email']),
                      trailing: IconButton(
                        icon:  Icon(Icons.close),
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
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 10,horizontal: 16),
        child: Container(
          height: 56,
          child: ElevatedButton(
            style: ButtonStyles.bigBlackButton(),
            child:  Obx(()=>ready.value ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_call),
                SizedBox(width: 8),
                Text('Create Session',
                  style: TypographyStyles.boldText(16, Themes.mainThemeColorAccent.shade100),
                )
              ],
            ) : Center(
              child: CircularProgressIndicator(),
            )),
            onPressed: (){
              saveMeeting();
            },
          ),
        ),
      ),
    );
  }
}
