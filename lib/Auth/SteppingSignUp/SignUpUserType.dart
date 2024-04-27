import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpCommonData.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpData.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';

class SignUpUserType extends StatelessWidget {
  const SignUpUserType({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxInt selectedUserType = 99.obs;

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: Obx(()=>Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Account Type', style: TypographyStyles.title(24)),
                  SizedBox(height: 50),
                  Container(
                    width: Get.width,
                    height: 80,
                    child: ElevatedButton(
                      style: selectedUserType.value == 0 ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                      onPressed:(){
                        selectedUserType.value = 0;
                        signUpData.userType = 'client';
                      },
                      child: Text('Client',),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: Get.width,
                    height: 80,
                    child: ElevatedButton(
                      style: selectedUserType.value == 1 ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                      onPressed:(){
                        selectedUserType.value = 1;
                        signUpData.userType = 'trainer';
                      },
                      child: Text('Trainer',),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: Get.width,
                    height: 80,
                    child: ElevatedButton(
                      style: selectedUserType.value == 2 ? SignUpStyles.selectedButton(): SignUpStyles.notSelectedButton(),
                      onPressed:(){
                        selectedUserType.value = 2;
                        signUpData.userType = 'doctor';
                      },
                      child: Text('Medical Practitioner',),
                    ),
                  ),
                ],
              )),
            ),
            Container(
              width: Get.width,
              height: 72,
              child: ElevatedButton(
                style: ButtonStyles.primaryButton(),
                child: Text('Continue'),
                onPressed: () {

                  if([0,1,2].contains(selectedUserType.value)){
                    Get.to(()=>SignUpCommonData());
                  } else {
                    showSnack('Incomplete information', 'Please select a user type');
                  }
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
