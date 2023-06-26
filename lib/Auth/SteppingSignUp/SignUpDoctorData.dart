import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/CommonAuthUtils.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

import 'package:north_star/Auth/SteppingSignUp/SignUpData.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class SignUpDoctorData extends StatelessWidget {
  const SignUpDoctorData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool isLoading = false.obs;
    RxBool canPrescribe = false.obs;
    RxString title = 'Dr'.obs;
    TextEditingController _specialtyController = TextEditingController();
    TextEditingController _hourlyController = TextEditingController();

    

    void signUp() async {
      isLoading.value = true;
      Map res = await httpClient.signUp(signUpData.toDoctorJson());

      if (res['code'] == 200) {
        CommonAuthUtils.signIn(res);
        showSnack('Welcome to NorthStar!', 'Your personal fitness Application!');
        Get.defaultDialog(
          title: 'Notice!',
          middleText: 'You must be verified by an admin before you can use the app. Please wait for an email from us.',
          barrierDismissible: false,
          confirm: ElevatedButton(
            style: ButtonStyles.flatButton(),
            child: Text('OK'),
            onPressed: () {
              Get.close(1);
            },
          ),
        );
      } else {
      }
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Additional\nInformation',
                            style: TypographyStyles.title(24)),
                        Hero(
                          tag: 'progress',
                          child: CircularStepProgressIndicator(
                            totalSteps: 100,
                            currentStep: 100,
                            stepSize: 5,
                            selectedColor: colors.Colors().deepYellow(1),
                            unselectedColor: Colors.grey[800],
                            padding: 0,
                            width: 100,
                            height: 100,
                            selectedStepSize: 7,
                            roundedCap: (_, __) => true,
                            child: Center(child: Text("4 of 4", style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1),),)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: _specialtyController,
                      decoration: InputDecoration(
                        labelText: 'Specialty',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _hourlyController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Hourly Rate (' + signUpData.currency + ')',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text('Are You Authorized to Prescribe?', style: TypographyStyles.title(20)),
                    SizedBox(height: 20),
                    Obx(()=>Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            child: ElevatedButton(
                              style: canPrescribe.value ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                              onPressed:(){
                                canPrescribe.value = true;
                                signUpData.canPrescribe = true;
                              },
                              child: Text('Yes'),
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            height: 50,
                            child: ElevatedButton(
                              style: !canPrescribe.value ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                              onPressed:(){
                                canPrescribe.value = false;
                                signUpData.canPrescribe = false;
                              },
                              child: Text('No'),
                            ),
                          ),
                        ),
                      ],
                    )),
                    SizedBox(height: 16),
                    Text('Title', style: TypographyStyles.title(20)),
                    SizedBox(height: 10,),
                    Obx(()=>Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 40,
                            child: ElevatedButton(
                              style: title.value == 'Dr' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                              onPressed:(){
                                title.value = 'Dr';
                                signUpData.title = 'Dr';
                              },
                              child: Text('Dr'),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 40,
                            child: ElevatedButton(
                              style: title.value == 'Mr' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                              onPressed:(){
                                title.value = 'Mr';
                                signUpData.title = 'Mr';
                              },
                              child: Text('Mr'),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 40,
                            child: ElevatedButton(
                              style: title.value == 'Ms' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                              onPressed:(){
                                title.value = 'Ms';
                                signUpData.title = 'Ms';
                              },
                              child: Text('Ms'),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 40,
                            child: ElevatedButton(
                              style: title.value == 'Mrs' ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                              onPressed:(){
                                title.value = 'Mrs';
                                signUpData.title = 'Mrs';
                              },
                              child: Text('Mrs'),
                            ),
                          ),
                        ),
                      ],
                    ),)
                  ],
                ),
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
            style: ButtonStyles.bigBlackButton(),
            child: Text('Sign Up'),
            onPressed: () {
              signUpData.speciality = _specialtyController.text;
              signUpData.hourlyRate = _hourlyController.text;

              if (_specialtyController.text.isNotEmpty && _hourlyController.text.isNotEmpty){
                signUp();
              } else {
                showSnack('Incomplete information', 'Please enter all the information');
              }
            },
          ),
        ),
      ),
    );
  }
}
