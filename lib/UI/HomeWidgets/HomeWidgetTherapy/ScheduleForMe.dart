import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/ThemeBdayaStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Layout.dart';
import 'package:north_star/UI/Payments/CardPayment.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/ImageUploader.dart';

import '../../../Styles/AppColors.dart';
import '../../../components/SessionTimePicker.dart';

class ScheduleForMe extends StatefulWidget {
  ScheduleForMe({Key? key, this.doctor}) : super(key: key);
  RxList reservedTimes = [].obs;
  RxString curDate = "".obs;
  RxString stTime = "".obs;
  RxString enTime = "".obs;
  TextEditingController selectedDate = new TextEditingController();
  TextEditingController startTime = new TextEditingController();
  TextEditingController endTime = new TextEditingController();
  TextEditingController descriptionController = new TextEditingController();
  TextEditingController titleController = new TextEditingController();
  final doctor;

  @override
  State<ScheduleForMe> createState() => _ScheduleForMeState();
}

class _ScheduleForMeState extends State<ScheduleForMe> {
  late dynamic imageFile = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.doctor);

    RxBool ready = true.obs;
    RxMap walletData = {}.obs;

    late DateTime selectedDateTime;
    DateTime selectedStartTime = DateTime(2000, 1, 1, 0, 0);
    DateTime selectedEndTime = DateTime(2000, 1, 1, 0, 0);

    DateTime roundToNearestHour(DateTime date) {
      int minutes = date.minute;
      int roundedMinutes =
          (minutes + 30) ~/ 60 * 60; // Round to the nearest hour
      DateTime roundedDate = date
          .subtract(Duration(minutes: minutes))
          .add(Duration(minutes: roundedMinutes));
      return roundedDate;
    }

    void confirmAndPay(DateTime dateTimeOfBooking, double total) async {
      Map res = await httpClient.getWallet();

      if (res['code'] == 200) {
        print(res);
        walletData.value = res['data'];
      } else {
        print(res);
      }

      Get.defaultDialog(
          radius: 5,
          title: '',
          titlePadding: EdgeInsets.zero,
          backgroundColor:
              Get.isDarkMode ? AppColors.primary2Color : Colors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 20,
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "BOOKING SUMMARY",
                textAlign: TextAlign.center,
                style: TypographyStyles.title(20),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Date:',
                    style: TypographyStyles.normalText(
                        16, Themes.mainThemeColorAccent.shade300),
                  ),
                  Text(
                    '${DateFormat("MMM dd,yyyy").format(dateTimeOfBooking).toString()}',
                    style: TypographyStyles.textWithWeight(16, FontWeight.w500),
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
                    style: TypographyStyles.normalText(
                        16, Themes.mainThemeColorAccent.shade300),
                  ),
                  Text(
                    '${DateFormat("hh:mm a").format(dateTimeOfBooking)}',
                    style: TypographyStyles.textWithWeight(16, FontWeight.w500),
                  ),
                ],
              ),
              Divider(
                thickness: 1,
                color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
              ),
              SizedBox(
                height: 7,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Physiotherapist',
                    style: TypographyStyles.normalText(
                        16, Themes.mainThemeColorAccent.shade300),
                  ),
                  Text(
                    '${widget.doctor['name']}',
                    style: TypographyStyles.textWithWeight(16, FontWeight.w500),
                  ),
                ],
              ),
              Divider(
                thickness: 1,
                color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
              ),
              SizedBox(
                height: 7,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Location',
                    style: TypographyStyles.normalText(
                        16, Themes.mainThemeColorAccent.shade300),
                  ),
                  Text(
                    'Hulhumale maldives',
                    style: TypographyStyles.textWithWeight(16, FontWeight.w500),
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
                    'Amount',
                    style: TypographyStyles.normalText(
                      16,
                      Get.isDarkMode
                          ? Themes.mainThemeColorAccent.shade100
                          : colors.Colors().lightBlack(1),
                    ),
                  ),
                  Text(
                    'MVR ${total.toStringAsFixed(2)}',
                    style: TypographyStyles.textWithWeight(16, FontWeight.w500),
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
                  if (walletData.value['balance'] >=
                      double.parse(widget.doctor['hourly_rate'].toString())) {
                    Map res = await httpClient.newTrainerDoctorMeeting({
                      'doctor_id': widget.doctor['id'].toString(),
                      'trainer_id': authUser.id.toString(),
                      'role': authUser.role,
                      'reason': widget.titleController.text,
                      'description': widget.descriptionController.text,
                      'start_time': dateTimeOfBooking.toString(),
                    });
                    print(res);
                    if (res['code'] == 200) {
                      Get.offAll(() => Layout());
                      showSnack('Booking Successful',
                          'Your booking has been successfully placed.');
                    } else {
                      showSnack('Booking Failed',
                          'Something went wrong. Please try again later.');
                    }
                  } else {
                    showSnack('Not Enough Balance',
                        'You do not have enough balance to pay for this booking');
                  }
                },
                style:
                    ButtonStyles.matButton(Themes.mainThemeColor.shade500, 0),
                child: Obx(() => ready.value
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Pay with eWallet',
                              style: TypographyStyles.boldText(
                                  14, AppColors.textOnAccentColor),
                            ),
                            SizedBox(
                              height: 3,
                            ),
                            Text(
                              '(eWallet Balance: ${walletData['balance'].toStringAsFixed(2)})',
                              style: TypographyStyles.normalText(
                                  12, AppColors.textOnAccentColor),
                            ),
                          ],
                        ),
                      )
                    : LoadingAndEmptyWidgets.loadingWidget()),
              ),
            ),
            Container(
              width: Get.width,
              child: ElevatedButton(
                onPressed: () {
                  Get.to(() => CardPayment(total));
                },
                style:
                    ButtonStyles.matButton(Themes.mainThemeColor.shade500, 0),
                child: Obx(() => ready.value
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset("assets/icons/creditCard.png"),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'PAY WITH CARD',
                              style: TypographyStyles.boldText(
                                  14, AppColors.textOnAccentColor),
                            ),
                          ],
                        ),
                      )
                    : LoadingAndEmptyWidgets.loadingWidget()),
              ),
            ),
            Container(
              height: 48,
              width: Get.width,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(
                  color: AppColors.accentColor,
                  width: 1.25,
                ),
              ),
              child: TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TypographyStyles.title(20),
                  )),
            ),
            SizedBox(
              height: 5,
            ),
          ]);
    }

    String getChargingMethod() {
      return widget.doctor['paying_type'] == 2 ? '(Per Session)' : '(Per Hour)';
    }

    void checkReserved(String date) async {
      var data = {"therapy_id": widget.doctor["therapy_Id"], "apt_date": date};
      var res = await httpClient.checkReservedTherapy(data);
      print(res["data"]);
      if (res['code'] == 200) {
        if (res['data'].length > 0) {
          // reservedTimes.value = res['data'];
          res['data'].forEach((item) {
            widget.reservedTimes.add(item);
            print(item);
          });
        } else {
          widget.reservedTimes.value = [];
        }
      } else {
        widget.reservedTimes.value = [];
      }
    }

    void addMeeting() async {
      var data = {
        "therapy_id": widget.doctor["therapy_Id"],
        "reason": widget.descriptionController.text ?? "",
        "additional":"-",
        "amount": 10.0,
        "apt_date": widget.curDate.value,
        "start_time": widget.stTime.value,
        "end_time": widget.enTime.value
      };
      print(data);
      var res;
      res = await httpClient.addTherapyMeeting(
          data, imageFile != false ? imageFile : null);

      if (res["code"] == 200 && res["data"][0]["status"]) {
        Get.back();
        Get.back();
        Get.back();
        showSnack(
            'Booking Successful', 'Your booking has been successfully placed.');
      } else {
        print('data printing-->$res');
        showSnack('Booking Failed', res["data"][0]["message"]);
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Make A Appointment',
          style: TypographyStyles.title(20),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color:
                      Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: CachedNetworkImageProvider(
                            HttpClient.s3BaseUrl + widget.doctor['avatar_url']),
                      ),
                      SizedBox(
                        width: 26,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Text(doctor['doctor']['speciality'],
                            //     style: TextStyle(
                            //       color: Color(0xFFFFB700),
                            //       fontSize: 16,
                            //       fontFamily: 'Poppins',
                            //       fontWeight: FontWeight.w700,
                            //     )),
                            // SizedBox(height: 5),
                            Text(
                              'Dr. ' + widget.doctor['name'],
                              overflow: TextOverflow.clip,
                              maxLines: 1,
                              style: TypographyStyles.title(20),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Rate ',
                                    style: TypographyStyles.textWithWeight(
                                        16, FontWeight.w400)),
                                Text(getChargingMethod(),
                                    style: TypographyStyles.textWithWeight(
                                        16, FontWeight.w400)),
                                Spacer(),
                                Text(
                                    'MVR ' +
                                        (widget.doctor['paying_type'] == 1
                                                ? widget.doctor['hourly_rate']
                                                : widget.doctor['session_rate'])
                                            .toStringAsFixed(2),
                                    style: TextStyle(
                                      color: Color(0xFFFFB700),
                                      fontSize: 20,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    )),
                              ],
                            ),
                            Visibility(
                              visible: widget.doctor['paying_type'] == 2,
                              child: Text(
                                  "Session Duration: ${widget.doctor['session_duration']} Min",
                                  style: TypographyStyles.text(14)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 25),
              Text('Appointment for you', style: TypographyStyles.title(18)),
              SizedBox(height: 25),
              TextField(
                controller: widget.selectedDate,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Approximate Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
                onTap: () {
                  DatePickerBdaya.showDatePicker(
                    context,
                    theme: ThemeBdayaStyles.main(),
                    showTitleActions: true,
                    minTime: DateTime.now(),
                    currentTime: DateTime.now(),
                    onChanged: (date) {
                      print('change $date');
                    },
                    onConfirm: (date) {
                      selectedDateTime = date;
                      if (widget.doctor['paying_type'] == 2) {
                        //  Per session
                      } else {
                        //  Per hour
                      }
                      checkReserved(
                          DateFormat("yyyy-M-d").format(date).toString());
                      widget.selectedDate.text = DateFormat("MMM dd,yyyy")
                          .format(date)
                          .toString(); //+" at " +DateFormat('HH:mm').format(date);
                      widget.curDate.value =
                          DateFormat("yyyy-M-d").format(date).toString();
                    },
                  );
                },
              ),
              SizedBox(height: 16),

              Obx(() => Visibility(
                    visible: widget.reservedTimes.value.length > 0,
                    child: Container(
                      width: Get.width,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                          color: Get.isDarkMode
                              ? AppColors.primary2Color
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Reserved Times",
                            style: TypographyStyles.title(16),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            itemCount: widget.reservedTimes.value.length,
                            itemBuilder: (context, index) {
                              final item = widget.reservedTimes.value[index];
                              DateFormat dateFormat = DateFormat("hh:mm a");
                              String stT = dateFormat.format(DateTime.parse(
                                  '1970-01-01 ${item['start_time']}'));
                              String enT = dateFormat.format(DateTime.parse(
                                  '1970-01-01 ${item['end_time']}'));
                              return Row(
                                children: [
                                  Text(
                                    stT,
                                    style: TypographyStyles.text(16),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text("-", style: TypographyStyles.text(16)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(enT, style: TypographyStyles.text(16)),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  )),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: ((Get.width - 32) / 2) - 8,
                    child: TextField(
                      controller: widget.startTime,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Start Time',
                        prefixIcon: Icon(Icons.access_time_rounded),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onTap: () {
                        SessionTimePicker(
                          initial: selectedStartTime,
                          onConfirm: (date) {
                            print('confirm $date');
                            // date = roundToNearestHour(date);
                            selectedStartTime = date;
                            if (widget.doctor['paying_type'] == 2) {
                              print('setting session');
                              DateTime sessionEndTime = date.add(Duration(
                                  minutes: widget.doctor['session_duration']));
                              widget.endTime.text =
                                  DateFormat('HH:mm').format(sessionEndTime);
                              widget.enTime.value =
                                  '${DateFormat("HH:mm").format(sessionEndTime).toString()}:00';
                            }
                            widget.startTime.text =
                                DateFormat('HH:mm').format(date);
                            widget.stTime.value =
                                '${DateFormat("HH:mm").format(date).toString()}:00';
                          },
                        );
                      },
                    ),
                  ),
                  Container(
                    width: ((Get.width - 32) / 2) - 8,
                    child: TextField(
                      controller: widget.endTime,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'End Time',
                        prefixIcon: Icon(Icons.access_time_rounded),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                      onTap: () {
                        if (widget.doctor['paying_type'] == 2) {
                          showSnack("Info",
                              "The end time is automatically selected based on the session's duration.");
                          return;
                        }
                        SessionTimePicker(
                          initial: selectedEndTime,
                          onConfirm: (date) {
                            print('confirm $date');
                            // date = roundToNearestHour(date);
                            selectedEndTime = date;
                            widget.endTime.text =
                                DateFormat('HH:mm').format(date);
                            widget.enTime.value =
                            '${DateFormat("HH:mm").format(date).toString()}:00';
                          },
                        );
                        // DatePickerBdaya.showTimePicker(
                        //   context,
                        //   theme: ThemeBdayaStyles.main(),
                        //   showTitleActions: true,
                        //   showSecondsColumn: false,
                        //   currentTime: selectedEndTime,
                        //   onChanged: (date) {
                        //     print('change $date');
                        //   },
                        //   onConfirm: (date) {
                        //     print('confirm $date');
                        //     date = roundToNearestHour(date);
                        //     selectedEndTime = date;
                        //     widget.endTime.text =
                        //         DateFormat('HH:mm').format(date);
                        //     widget.enTime.value =
                        //         '${DateFormat("HH:mm").format(date).toString()}:00';
                        //   },
                        // );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              // TextField(
              //   controller: titleController,
              //   maxLength: 250,
              //   decoration: InputDecoration(
              //     labelText: 'Reason',
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(5.0),
              //     ),
              //   ),
              // ),

              SizedBox(height: 16),
              TextField(
                controller: widget.descriptionController,
                maxLength: 250,
                decoration: InputDecoration(
                  labelText: 'Additional details',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              SizedBox(
                height: 16,
              ),
              ImageUploader(handler: (img) {
                setState(() {
                  imageFile = img;
                });
              }),
              SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(36, 5, 36, 15),
        child: Container(
          width: Get.width,
          height: 44,
          child: Obx(() => ElevatedButton(
                style: ButtonStyles.bigFlatYellowButton(),
                child: ready.value
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.video_call_outlined),
                          SizedBox(width: 8),
                          Text(
                            'Channel',
                            style: TextStyle(
                              color: Color(0xFF1B1F24),
                              fontSize: 20,
                              fontFamily: 'Bebas Neue',
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      )
                    : Center(
                        child: CircularProgressIndicator(),
                      ),
                onPressed: () {
                  if (widget.curDate.value.isNotEmpty &&
                      widget.stTime.value.isNotEmpty &&
                      widget.enTime.value.isNotEmpty) {
                    addMeeting();
                    return;
                    confirmAndPay(selectedDateTime,
                        double.parse(widget.doctor['hourly_rate'].toString()));
                  } else {
                    showSnack('Something Went Wrong!',
                        'Please fill out all the input fields');
                  }
                },
              )),
        ),
      ),
    );
  }
}
