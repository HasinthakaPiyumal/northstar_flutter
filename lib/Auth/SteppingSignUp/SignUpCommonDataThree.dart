import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

import 'package:north_star/Auth/SteppingSignUp/SignUpData.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

import 'SignUpClientDataOne.dart';
import 'SignUpDoctorData.dart';
import 'SignUpTrainerData.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class SignUpCommonDataThree extends StatelessWidget {
  const SignUpCommonDataThree({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxInt gender = 99.obs;

    RxString day = '1'.obs;
    RxString month = 'January'.obs;
    RxString year = '1999'.obs;

    List<String> days = List.generate(31, (index) => (index + 1).toString());
    List<String> months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    List<String> years =
        List.generate(100, (index) => (DateTime.now().year - index).toString());

    void setDataValue(){
      signUpData.birthday = year.value + '-' + (months.indexOf(month.value)+1).toString() + '-' + day.value;
    }

    setDays(){
      DateTime dt = DateTime(int.parse(year.value), months.indexOf(month.value)+1);
      DateTime dtNext = DateTime(int.parse(year.value), months.indexOf(month.value)+2);
      days = List.generate(dtNext.difference(dt).inDays, (index) => (index + 1).toString());
    }

    void showDayPicker() {
      Get.bottomSheet(
        Card(
          child: ListView.builder(
            itemCount: days.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  day.value = days[index];
                  setDataValue();
                  Get.back();
                },
                child: Container(
                  height: 50,
                  child: Center(child: Text(days[index])),
                ),
              );
            },
          ),
        ),
      );
    }

    void showMonthPicker() {
      Get.bottomSheet(
        Card(
          child: ListView.builder(
            itemCount: months.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  month.value = months[index];
                  day.value = '1';
                  setDays();
                  setDataValue();
                  Get.back();
                },
                child: Container(
                  height: 50,
                  child: Center(child: Text(months[index])),
                ),
              );
            },
          ),
        ),
      );
    }

    void showYearPicker() {
      Get.bottomSheet(
        Card(
          child: ListView.builder(
            itemCount: years.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  year.value = years[index];
                  day.value = '1';
                  setDays();
                  setDataValue();
                  Get.back();
                },
                child: Container(
                  height: 50,
                  child: Center(child: Text(years[index])),
                ),
              );
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Spacer(),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Obx(() => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Your Information',
                                style: TypographyStyles.title(24)),
                            Hero(
                              tag: 'progress',
                              child: CircularStepProgressIndicator(
                                totalSteps: 100,
                                currentStep: 75,
                                stepSize: 5,
                                selectedColor: colors.Colors().deepYellow(1),
                                unselectedColor: Get.isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[300],
                                padding: 0,
                                width: 100,
                                height: 100,
                                selectedStepSize: 7,
                                roundedCap: (_, __) => true,
                                child: Center(
                                    child: Text(
                                  "3 of 4",
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium!
                                      .copyWith(
                                        color: Get.isDarkMode
                                            ? Themes
                                                .mainThemeColorAccent.shade100
                                                .withOpacity(0.5)
                                            : colors.Colors().lightBlack(1),
                                      ),
                                )),
                              ),
                            ),
                          ],
                        ),
                        Text('Gender', style: TypographyStyles.title(22)),
                        SizedBox(height: 16),
                        Container(
                          width: Get.width,
                          height: 80,
                          child: ElevatedButton(
                            style: gender.value == 0
                                ? SignUpStyles.selectedButton()
                                : SignUpStyles.notSelectedButton(),
                            onPressed: () {
                              gender.value = 0;
                              signUpData.gender = 'male';
                            },
                            child: Text('Male'),
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          width: Get.width,
                          height: 80,
                          child: ElevatedButton(
                            style: gender.value == 1
                                ? SignUpStyles.selectedButton()
                                : SignUpStyles.notSelectedButton(),
                            onPressed: () {
                              gender.value = 1;
                              signUpData.gender = 'female';
                            },
                            child: Text('Female'),
                          ),
                        ),
                        SizedBox(height: 32),
                        Text('Birthday', style: TypographyStyles.title(22)),
                        SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
                                height: 56,
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () {
                                      showYearPicker();
                                    },
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Year'),
                                        Obx(()=>Text('${year.value}',
                                            style: TypographyStyles.title(18)))
                                      ],
                                    )),
                                  ),
                                ),
                              ),
                            ),
                            
                            SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 56,
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () {
                                      showMonthPicker();
                                    },
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Month'),
                                        Obx(() => Text('${month.value}',
                                            style: TypographyStyles.title(18)),)
                                      ],
                                    )),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Container(
                                height: 56,
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(4),
                                    onTap: () {
                                      showDayPicker();
                                    },
                                    child: Center(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Day'),
                                        Obx(()=>Text('${day.value}',
                                            style: TypographyStyles.title(18)),)
                                      ],
                                    )),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
        child: Container(
          width: Get.width,
          height: 72,
          child: ElevatedButton(
            style: ButtonStyles.primaryButton(),
            child: Text('Continue'),
            onPressed: () {
              if ([0, 1].contains(gender.value)) {
                if (signUpData.userType == 'client') {
                  Get.to(() => SignUpClientDataOne());
                }

                if (signUpData.userType == 'trainer') {
                  Get.to(() => SignUpTrainerData());
                }

                if (signUpData.userType == 'doctor') {
                  Get.to(() => SignUpDoctorData());
                }
              } else {
                showSnack('Incomplete information',
                    'Please enter all the information');
              }
            },
          ),
        ),
      ),
    );
  }
}
