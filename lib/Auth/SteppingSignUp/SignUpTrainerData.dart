import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/CommonAuthUtils.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpData.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class SignUpTrainerData extends StatelessWidget {
  const SignUpTrainerData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool isLoading = false.obs;
    //RxInt type = 99.obs;
    TextEditingController _aboutController = TextEditingController();
    RxInt _aboutLength = 0.obs;
    RxBool isInsured = false.obs;

    void signUp() async {
      isLoading.value = true;
      Map res = await httpClient.signUp(signUpData.toTrainerJson());

      if (res['code'] == 200) {
        CommonAuthUtils.signIn(res);
        showSnack('Welcome to NorthStar!', 'Your personal fitness Application!');
        CommonAuthUtils.showWelcomeDialog();
      } else {
        showSnack('SignUp Failed', res['data'].toString());
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
                child: Obx(()=>Column(
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
                            child: Center(child: Text("4 of 4", style: Theme.of(context).textTheme.titleMedium!.copyWith(color: colors.Colors().darkGrey(1)),)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    /*Container(
                      width: Get.width,
                      height: 80,
                      child: ElevatedButton(
                        style: type.value == 0 ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                        onPressed:(){
                          type.value = 0;
                          signUpData.type = 'physical';
                        },
                        child: Text('Physical Trainer'),
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: Get.width,
                      height: 80,
                      child: ElevatedButton(
                        style: type.value == 1 ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                        onPressed:(){
                          type.value = 1;
                          signUpData.type = 'diet';
                        },
                        child: Text('Diet Trainer'),
                      ),
                    ),
                    SizedBox(height: 16),*/
                    Text('Are You a Insured Trainer?', style: TypographyStyles.title(24)),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Container(
                          width: Get.width / 3,
                          height: 40,
                          child: ElevatedButton(
                            style: isInsured.value ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                            onPressed:(){
                              isInsured.value = true;
                              signUpData.isInsured = true;
                            },
                            child: Text('Yes'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Container(
                          width: Get.width / 3,
                          height: 40,
                          child: ElevatedButton(
                            style: !isInsured.value ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                            onPressed:(){
                              isInsured.value = false;
                              signUpData.isInsured = false;
                            },
                            child: Text('No'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text('About', style: TypographyStyles.title(24)),
                    SizedBox(height: 16),
                    TextField(
                      controller: _aboutController,
                      onChanged: (val){
                        _aboutLength.value = val.length;
                      },
                      maxLength: 250,
                      decoration: InputDecoration(
                        counter: Obx(()=>Text('${_aboutLength.value}/250')),
                        labelText: 'About',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                  ],
                )),
              ),
            ),
            Container(
              width: Get.width,
              height: 72,
              child: ElevatedButton(
                style: ButtonStyles.bigBlackButton(),
                child: Text('Sign Up'),
                onPressed: () {
                  signUpData.about = _aboutController.text;
                  if (_aboutController.text.isNotEmpty) {
                    signUp();
                  } else {
                    showSnack('Incomplete information', 'Please enter all the information');
                  }

                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
