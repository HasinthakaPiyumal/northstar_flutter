import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/Buttons.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
class AddMember extends StatelessWidget {
  AddMember({Key? key, this.extend = false,this.extendingId = 0,this.extendingEmail = "",this.onSuccess}) : super(key: key);
  final bool extend;
  final int extendingId;
  final String extendingEmail;
  final VoidCallback? onSuccess;
  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;

    Rx<DateTime> selectedStartDate = DateTime.now().obs;
    Rx<DateTime> selectedEndDate = DateTime.now().add(Duration(days: 7)).obs;

    final DateRangePickerController _controller = DateRangePickerController();

    TextEditingController email = TextEditingController(text: extendingEmail);
    TextEditingController dayCount = TextEditingController();

    void sendInvite() async {
      ready.value = false;

      if (dayCount.text.isBlank!) {
        showSnack('Warning!', 'Day Count can not be empty',status: PopupNotificationStatus.warning);
      }

      final intValue = int.tryParse(dayCount.text);
      if (intValue == null || intValue < 0) {
        showSnack('Invalid!', 'Please enter a valid day count',status: PopupNotificationStatus.warning);
      }

      Map res = await httpClient.inviteMember({
        'email': email.text,
        'trainer_id': authUser.id.toString(),
        'trainer_type': authUser.user['trainer']['type'],
        'days_count': int.parse(dayCount.text),
        'client_id': extendingId,
      },extend: extend);



      if (res['code'] == 200) {
        onSuccess?.call();
        Get.back();
        showSnack('Info', res['data']['message']);
        print(res);
        ready.value = true;
      } else {
        showSnack('Error!', 'Client does not exist or something went wrong!');
        ready.value = true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(extend?'Extend Contract Period':'Add Members'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: Get.width - 40,
                child: TextFormField(
                  controller: email,
                  decoration: InputDecoration(
                    label: Text('Email'),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2D2D2),
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2D2D2),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: Get.width - 40,
                child: TextFormField(
                  controller: dayCount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    label: Text('Days count'),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Color(0xFFD2D2D2),
                      ),
                    ),

                  ),
                ),
              ),
              // Container(width:Get.width-40,child: Text("Select Start Date And End Date",textAlign: TextAlign.left,style: TypographyStyles.text(16),)),
              // SizedBox(height: 10),
              // Obx(()=> Container(width:Get.width-40,child: Text("${selectedEndDate.value.difference(selectedStartDate.value).inDays } Days selected",textAlign: TextAlign.left,style: TypographyStyles.title(18),))),
              // SizedBox(height: 20),

              // SfDateRangePicker(
              //   controller: _controller,
              //   initialSelectedRange: PickerDateRange(selectedStartDate.value,selectedEndDate.value),
              //   minDate: DateTime.now(),
              //   // ca
              //   onSelectionChanged: (DateRangePickerSelectionChangedArgs args){
              //     if(args.value is PickerDateRange){
              //       // selectedStartDate.value = args.value.startDate ?? DateTime.now();
              //       selectedEndDate.value = args.value.endDate ?? DateTime.now();
              //     }
              //   },
              //   monthCellStyle: DateRangePickerMonthCellStyle(
              //     textStyle: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
              //     disabledDatesTextStyle: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1).withOpacity(0.5),),
              //     todayTextStyle: TypographyStyles.normalText(16, Themes.mainThemeColor.shade500),
              //   ),
              //   selectionMode: DateRangePickerSelectionMode.extendableRange,
              //   headerStyle: DateRangePickerHeaderStyle(
              //     textStyle: TypographyStyles.boldText(20, Get.isDarkMode ? Colors.white : Colors.black,),
              //   ),
              //   showNavigationArrow: true,
              // ),
              SizedBox(height: 20),
              Buttons.yellowFlatButton(
                  onPressed: () {
                    if (email.text.isEmail) {
                      sendInvite();
                    } else {
                      showSnack('Invalid!', 'Please enter a valid email');
                    }
                  },
                  width: Get.width - 40,
                  isLoading: !ready.value,
                  label: "Send Request"
              ),
              // Container(
              //   width: Get.width,
              //   height: 58,
              //   child: Obx(() => ElevatedButton(
              //         style: ElevatedButton.styleFrom(
              //             shape: Themes().roundedBorder(12),
              //             backgroundColor: Color(0xFF1C1C1C)),
              //         child: ready.value
              //             ? Text(
              //                 'Send Request',
              //                 style: TextStyle(
              //                     color: Colors.white,
              //                     fontWeight: FontWeight.bold,
              //                     fontSize: 18),
              //               )
              //             : Center(child: CircularProgressIndicator()),
              //         onPressed: () {
              //           if (email.text.isEmail) {
              //             sendInvite();
              //           } else {
              //             showSnack('Error!', 'Please enter a valid email');
              //           }
              //         },
              //       )),
              // )
            ],
          ),
        ),
      ),
    );
  }
}
