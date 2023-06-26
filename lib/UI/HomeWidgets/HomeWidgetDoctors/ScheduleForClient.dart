import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:get/get.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import 'package:north_star/UI/Layout.dart';

class ScheduleForClient extends StatelessWidget {
  const ScheduleForClient({Key? key, this.doctor}) : super(key: key);

  final doctor;

  @override
  Widget build(BuildContext context) {
    RxMap selectedClient = {}.obs;
    RxBool ready = true.obs;
    RxMap walletData = {}.obs;

    TextEditingController dateTime = new TextEditingController();
    TextEditingController descriptionController = new TextEditingController();
    TextEditingController titleController = new TextEditingController();

    late DateTime selectedDateTime;

    void confirmAndPay(DateTime dateTimeOfBooking, double total) async{

      Map res = await httpClient.getWallet();

      if (res['code'] == 200) {
        print(res);
        walletData.value = res['data'];
      } else {
        print(res);
      }

      Get.defaultDialog(
          radius: 8,
          title: '',
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(horizontal: 20,),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("BOOKING SUMMARY",
                style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Doctor',
                    style: TypographyStyles.normalText(16, Themes.mainThemeColorAccent.shade300),
                  ),
                  Text(
                    '${doctor['name']}',
                    style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Divider(
                thickness: 1,
                color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date:',
                    style: TypographyStyles.normalText(16, Themes.mainThemeColorAccent.shade300),
                  ),
                  Text(
                    '${DateFormat("MMM dd,yyyy").format(dateTimeOfBooking).toString()}',
                    style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Divider(
                thickness: 1,
                color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Time:',
                    style: TypographyStyles.normalText(16, Themes.mainThemeColorAccent.shade300),
                  ),
                  Text(
                    '${DateFormat("hh:mm a").format(dateTimeOfBooking)}',
                    style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                  ),
                ],
              ),
              Divider(
                thickness: 1,
                color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
              ),
              SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Approx. Payment',
                    style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().darkGrey(1),),
                  ),
                  Text(
                    'N\$ ${total.toStringAsFixed(2)}',
                    style: TypographyStyles.boldText(20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                  ),
                ],
              ),
              SizedBox(height: 15),
            ],
          ),
          actions: [
            Container(
              width: Get.width,
              child: ElevatedButton(
                onPressed: () async {
                  if (walletData.value['balance'] >= double.parse(doctor['doctor']['hourly_rate'].toString())) {
                    Map res = await httpClient.newDoctorMeeting({
                      'doctor_id': doctor['id'].toString(),
                      'trainer_id': authUser.id.toString(),
                      'client_id': selectedClient.value['id'].toString(),
                      'title': titleController.text,
                      'description': descriptionController.text,
                      'start_time': dateTimeOfBooking.toString(),
                    });
                    if (res['code'] == 200) {
                      Get.offAll(() => Layout());
                      showSnack('Booking Successful', 'Your booking has been successfully placed.');
                    } else {
                      showSnack('Booking Failed',
                          'Something went wrong. Please try again later.');
                    }
                  } else {
                    showSnack('Not Enough Balance',
                        'You do not have enough balance to pay for this booking');
                  }
                },
                style: ButtonStyles.matButton(Themes.mainThemeColor.shade500, 0),
                child: Obx(() => ready.value ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Pay with eWallet',
                        style: TypographyStyles.boldText(16, Colors.black),
                      ),
                      SizedBox(height: 3,),
                      Text('(eWallet Balance - ${walletData['balance'].toStringAsFixed(2)})',
                        style: TypographyStyles.normalText(13, Colors.black),
                      ),
                    ],
                  ),
                ) : LoadingAndEmptyWidgets.loadingWidget()),
              ),
            ),
            Container(
              height: 48,
              width: Get.width,
              child: TextButton(onPressed: ()=>Get.back(), child: Text('Cancel', style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),)),
            ),
            SizedBox(height: 5,),
          ]
      );
    }


    Future<List> searchClient(pattern) async {
      print('PATTERN: ' + pattern);
      Map res = await httpClient.searchMembers(pattern);

      if (res['code'] == 200) {
        return res['data'];
      } else {
        print(res);
        return [];
      }
    }

    String getChargingMethod(){
      return doctor['doctor']['charge_type'] == 'SESSION' ? '(Per Session)' : '(Per Hour)';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule for a Client'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().lightCardBG,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 26,
                            backgroundImage: CachedNetworkImageProvider(HttpClient.s3BaseUrl + doctor['avatar_url']),
                          ),
                          SizedBox(width: 10,),
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dr. ' + doctor['name'],
                                  overflow: TextOverflow.clip,
                                  maxLines: 1,
                                  style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                                ),
                                SizedBox(height: 5,),
                                Text(doctor['doctor']['speciality'],
                                  style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().darkGrey(1),),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 6,),
                      Divider(thickness: 1, color: colors.Colors().darkGrey(0.8),),
                      SizedBox(height: 6,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Rate ', style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),)),
                          Text(getChargingMethod(), style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),)),
                          Spacer(),
                          Text('N\$ ' + doctor['doctor']['hourly_rate'].toStringAsFixed(2), style: TypographyStyles.boldText(20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightBlack(1),)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Divider(),
              Text('Appointment for Client', style: TypographyStyles.title(18)),
              SizedBox(height: 16),
              Obx(() => Visibility(
                    visible: selectedClient['id'] == null,
                    child: TypeAheadField(
                      hideOnEmpty: true,
                      hideOnError: true,
                      hideOnLoading: true,
                      textFieldConfiguration: TextFieldConfiguration(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Search Clients...',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0)),
                          )),
                      suggestionsCallback: (pattern) async {
                        print(pattern);
                        return await searchClient(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        var jsonObj = jsonDecode(jsonEncode(suggestion));

                        return ListTile(
                          leading: CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(
                                  HttpClient.s3BaseUrl +
                                      jsonObj['user']['avatar_url'])),
                          tileColor: Colors.transparent,
                          title: Text(jsonObj['user']['name']),
                          subtitle: Text(jsonObj['user']['email'].toString()),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        var jsonObj = jsonDecode(jsonEncode(suggestion));
                        selectedClient.value = jsonObj['user'];
                        print(jsonObj);
                      },
                    ),
                  )),
              Obx(
                () => selectedClient['id'] != null
                    ? ListTile(
                        leading: CircleAvatar(
                            backgroundImage: CachedNetworkImageProvider(
                                HttpClient.s3BaseUrl +
                                    selectedClient['avatar_url'])),
                        title: Text(selectedClient['name'] ?? ''),
                        subtitle: Text(selectedClient['email'] ?? ''),
                        trailing: IconButton(
                          icon: Icon(Icons.highlight_remove_rounded,
                              color: Colors.red),
                          onPressed: () {
                            selectedClient.value = {};
                          },
                        ),
                      )
                    : Container(),
              ),
              SizedBox(height: 16),
              TextField(
                controller: dateTime,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Approximate Meeting Start Time',
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
                    },
                    onConfirm: (date) {
                      print('confirm $date');
                      selectedDateTime = date;
                      dateTime.text = DateFormat("MMM dd,yyyy").format(date).toString() + " at " + DateFormat('HH:mm').format(date);
                    },
                  );
                },
              ),
              SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 5, 16, 15),
        child: Container(
          width: Get.width,
          height: 56,
          child: Obx(()=>ElevatedButton(
            style: ButtonStyles.bigBlackButton(),
            child: ready.value ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_call),
                SizedBox(width: 8),
                Text('Schedule Meeting',
                  style: TypographyStyles.boldText(16, Themes.mainThemeColorAccent.shade100),
                )
              ],
            ): Center(
              child: CircularProgressIndicator(),
            ),
            onPressed: (){
              if (descriptionController.text.isNotEmpty &&
                  titleController.text.isNotEmpty &&
                  dateTime.text.isNotEmpty &&
                  selectedClient['id'] != null) {
                confirmAndPay(selectedDateTime, double.parse(doctor['doctor']['hourly_rate'].toString()));
              } else {
                showSnack('Fill All the Fields!',
                    'please fill all the fields and select your client');
              }
            },
          )),
        ),
      ),
    );
  }
}
