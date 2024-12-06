import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/LocalNotificationsController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/components/CheckButton.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../../../components/Buttons.dart';
import '../../../components/Radios.dart';

class CreateClientNotes extends StatelessWidget {
  const CreateClientNotes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    RxBool isIncome = true.obs;
    RxMap selectedClient = {}.obs;
    RxString selectedServiceValue = "service".obs;
    RxString selectedPaymentTerm = "Onetime".obs;

    TextEditingController note = TextEditingController();
    TextEditingController otherService = TextEditingController();
    TextEditingController amount = TextEditingController();
    TextEditingController date = TextEditingController();

    Future<List> searchMembers(pattern) async {
      Map res = await httpClient.searchMembers(pattern);
      if (res['code'] == 200) {
        return res['data'];
      } else {
        return [];
      }
    }

    void saveNote() async {
      print(double.parse(amount.text.toString()));
      Map res = await httpClient.saveClientNotes({
        'client_id': selectedClient['user_id'],
        'trainer_id': authUser.id,
        'note': note.text,
        'service': selectedServiceValue.value == "other"
            ? otherService.text
            : selectedServiceValue.value.toString(),
        'amount': double.parse(amount.text.toString()),
        'payment_term': selectedPaymentTerm.value,
        'start_date': date.text,
        'type': isIncome.value ? 1 : 2
      });
      print(res);
      if (res['code'] == 200) {
        String nDescription = 'Your trainer has added ' +
                    selectedServiceValue.value ==
                "other"
            ? otherService.text
            : selectedServiceValue.value.toString() +
                'for you. You will be charged ${amount.text}MVR every ${selectedPaymentTerm.value}';
        if (selectedPaymentTerm.value == "Onetime") {
          nDescription =
              'Your trainer has updated your payment for ${selectedServiceValue.value == "other" ? otherService.text : selectedServiceValue.value.toString()}. The amount is ${amount.text}';
        }

        await httpClient.sendNotification(selectedClient['user_id'],
            'Payment Status Added', nDescription, NSNotificationTypes.Common, {
          'client_id': selectedClient['user_id'],
          'trainer_id': authUser.id,
        });

        if (DateTime.now().isBefore(DateTime.parse(date.text))) {
          LocalNotificationsController.showLocalNotification(
            id: res['data']['data']['id'],
            title: 'Reminder!',
            body: note.text,
            scheduledDate: DateTime.parse(date.text).add(Duration(hours: 12)),
          );
        }

        Get.back();
        showSnack('Note Saved!', 'Member Notes is saved successfully');
      } else {
        showSnack('Something went wrong!', 'please try again');
      }
    }

    List<DropdownMenuItem<String>> menuItems = [
      const DropdownMenuItem(child: Text("Service"), value: "service"),
      const DropdownMenuItem(
          child: Text("Channelling Fee"), value: "Channelling Fee"),
      const DropdownMenuItem(child: Text("Trainer Fee"), value: "Coach Fee"),
      const DropdownMenuItem(
          child: Text("Exclusive Gym Fee"), value: "Exclusive Gym Fee"),
      const DropdownMenuItem(
          child: Text("Membership Fee"), value: "Membership Fee"),
      const DropdownMenuItem(
          child: Text("Coaching Fee"), value: "Coaching Fee"),
      const DropdownMenuItem(child: Text("Other"), value: "other"),
    ];

    List<DropdownMenuItem<String>> paymentTerms = [
      const DropdownMenuItem(child: Text("Onetime"), value: "Onetime"),
      const DropdownMenuItem(child: Text("Upcoming"), value: "Upcoming"),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('New Member Note'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      isIncome.value = true;
                    },
                    splashColor: Colors.transparent,
                    child: Container(
                      height: 50,
                      width: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Obx(() => isIncome.value
                              ? Radios.radioChecked2()
                              : Radios.radio()),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Income",
                            style: TypographyStyles.text(14),
                          )
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      isIncome.value = false;
                    },
                    splashColor: Colors.transparent,
                    child: Container(
                      height: 50,
                      width: 140,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Obx(() => !isIncome.value
                              ? Radios.radioChecked2()
                              : Radios.radio()),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Expense",
                            style: TypographyStyles.text(14),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),

              Obx(
                () => Text(
                  selectedClient.isNotEmpty
                      ? 'Selected Client'
                      : "Select Client",
                  style: TypographyStyles.boldText(
                    16,
                    Get.isDarkMode
                        ? Themes.mainThemeColorAccent.shade100
                        : colors.Colors().lightBlack(1),
                  ),
                ),
              ),

              SizedBox(
                height: 15,
              ),

              Obx(() => selectedClient.isNotEmpty
                  ? SizedBox()
                  : TypeAheadField(
                      builder: (context, controller, focusNode) {
                        return TextField(
                          controller: controller,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                            labelText: 'Search Members...',
                            border: UnderlineInputBorder(),
                          ),
                        );
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

                        var already =
                            (selectedClient['user_id'] == jsonObj['user_id']);
                        if (already == false) {
                          selectedClient.value = jsonObj;
                          print(jsonObj);
                        } else {
                          print('already added');
                        }
                      },
                    )),

              Obx(() => selectedClient['user_id'] == null
                  ? Container()
                  : ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      tileColor: Get.isDarkMode
                          ? Color(0xff101010)
                          : Color(0xffF1F1F1),
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider(
                          HttpClient.s3BaseUrl +
                              selectedClient['user']['avatar_url'],
                        ),
                      ),
                      title: Text(selectedClient['user']['name']),
                      subtitle: Text(selectedClient['user']['email']),
                      trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          selectedClient.value = {}.obs;
                        },
                      ),
                    )),

              SizedBox(height: 30),

              Text(
                'Note Info',
                style: TypographyStyles.boldText(
                  16,
                  Get.isDarkMode
                      ? Themes.mainThemeColorAccent.shade100
                      : colors.Colors().lightBlack(1),
                ),
              ),

              // Obx(()=> GestureDetector(
              //     onTap: (){isIncome.value = !isIncome.value;},
              //     child: Container(
              //       color:Colors.transparent,
              //       padding: EdgeInsets.symmetric(vertical: 16),
              //       child: Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //         Text('Is income note?',
              //           style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
              //         ),
              //         CheckButton(isChecked: isIncome.value,)
              //       ],),
              //     ),
              //   ),
              // ),
              SizedBox(
                height: 16,
              ),

              Obx(() => DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: colors.Colors().darkGrey(1),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 17, horizontal: 10),
                    ),
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconEnabledColor: Theme.of(context).primaryColor,
                    dropdownColor: Get.isDarkMode
                        ? colors.Colors().deepGrey(1)
                        : colors.Colors().lightCardBG,
                    value: selectedServiceValue.value,
                    items: menuItems,
                    style: TypographyStyles.normalText(
                      16,
                      selectedServiceValue.value == "service"
                          ? Get.isDarkMode
                              ? Themes.mainThemeColorAccent.shade100
                                  .withOpacity(0.5)
                              : colors.Colors().lightBlack(0.7)
                          : Get.isDarkMode
                              ? Themes.mainThemeColorAccent.shade100
                              : colors.Colors().lightBlack(1),
                    ),
                    onChanged: (String? newValue) {
                      selectedServiceValue.value = newValue!;
                    },
                  )),
              SizedBox(height: 15),
              Obx(() => DropdownButtonFormField(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                        borderSide: BorderSide(
                          color: colors.Colors().darkGrey(1),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 17, horizontal: 10),
                    ),
                    icon: Icon(Icons.keyboard_arrow_down),
                    iconEnabledColor: Theme.of(context).primaryColor,
                    dropdownColor: Get.isDarkMode
                        ? colors.Colors().deepGrey(1)
                        : colors.Colors().lightCardBG,
                    value: selectedPaymentTerm.value,
                    items: paymentTerms,
                    style: TypographyStyles.normalText(
                      16,
                      selectedPaymentTerm.value == "Onetime"
                          ? Get.isDarkMode
                              ? Themes.mainThemeColorAccent.shade100
                                  .withOpacity(0.5)
                              : colors.Colors().lightBlack(0.7)
                          : Get.isDarkMode
                              ? Themes.mainThemeColorAccent.shade100
                              : colors.Colors().lightBlack(1),
                    ),
                    onChanged: (String? newValue) {
                      selectedPaymentTerm.value = newValue!;
                    },
                  )),

              Obx(() => Visibility(
                    visible: selectedServiceValue.value == "other",
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(height: 15),
                        TextField(
                          controller: otherService,
                          decoration: InputDecoration(
                            labelText: 'Service',
                          ),
                        ),
                      ],
                    ),
                  )),

              SizedBox(height: 15),

              TextField(
                readOnly: true,
                controller: date,
                decoration: InputDecoration(
                  hintText: 'Start Date',
                ),
                onTap: () {
                  final DateRangePickerController _controller =
                      DateRangePickerController();

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                      actionsPadding: EdgeInsets.zero,
                      titlePadding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                      content: SizedBox(
                        height: Get.height / 2.5,
                        width: Get.width,
                        child: SfDateRangePicker(
                          controller: _controller,
                          onSelectionChanged:
                              (DateRangePickerSelectionChangedArgs args) {
                            //date.text = DateFormat("MMM dd,yyyy").format(args.value).toString();
                            date.text =
                                args.value.toLocal().toString().split(' ')[0];
                          },
                          monthCellStyle: DateRangePickerMonthCellStyle(
                            textStyle: TypographyStyles.normalText(
                              16,
                              Get.isDarkMode
                                  ? Themes.mainThemeColorAccent.shade100
                                  : colors.Colors().lightBlack(1),
                            ),
                            disabledDatesTextStyle: TypographyStyles.normalText(
                              16,
                              Get.isDarkMode
                                  ? Themes.mainThemeColorAccent.shade100
                                      .withOpacity(0.5)
                                  : colors.Colors()
                                      .lightBlack(1)
                                      .withOpacity(0.5),
                            ),
                            todayTextStyle: TypographyStyles.normalText(
                                16, Themes.mainThemeColor.shade500),
                          ),
                          selectionMode: DateRangePickerSelectionMode.single,
                          headerStyle: DateRangePickerHeaderStyle(
                            textStyle: TypographyStyles.boldText(
                              20,
                              Get.isDarkMode
                                  ? Themes.mainThemeColorAccent.shade100
                                  : colors.Colors().lightBlack(1),
                            ),
                          ),
                          showNavigationArrow: true,
                          monthViewSettings: DateRangePickerMonthViewSettings(
                            dayFormat: 'EEE',
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              SizedBox(height: 16),

              TextField(
                controller: note,
                decoration: InputDecoration(
                  labelText: 'Note',
                ),
              ),

              SizedBox(height: 16),

              TextField(
                controller: amount,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (MVR)',
                ),
              ),

              SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Buttons.yellowFlatButton(
            onPressed: () {
              if (date.text.isNotEmpty &&
                  amount.text.isNotEmpty &&
                  note.text.isNotEmpty &&
                  selectedClient != {} &&
                  selectedServiceValue.value != "service") {
                saveNote();
              } else {
                showSnack(
                    'Fill All the Fields', 'Fill All the fields in the form');
              }
            },
            label: "Save Note"),
      ),
    );
  }
}
