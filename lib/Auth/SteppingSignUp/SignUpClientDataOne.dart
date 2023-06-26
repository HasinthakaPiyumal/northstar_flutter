import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:north_star/Auth/CommonAuthUtils.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpData.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class SignUpClientDataOne extends StatelessWidget {
  const SignUpClientDataOne({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool isLoading = false.obs;
    TextEditingController _emergencyNameController = TextEditingController();
    TextEditingController _emergencyPhoneController = TextEditingController();

    void signUp() async {
      isLoading.value = true;
      Map res = await httpClient.signUp(signUpData.toClientJson());

      if (res['code'] == 200) {
        CommonAuthUtils.signIn(res);
        showSnack('Welcome to NorthStar!', 'Your personal fitness Application!');
        CommonAuthUtils.showWelcomeDialog();
      } else {
        showSnack('Something went wrong!', res.toString());
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
                        Text('Emergency Contact',
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
                    SizedBox(height: 40),
                    Text('Contact Person', style: TypographyStyles.title(18)),
                    SizedBox(height: 16),
                    TextField(
                      controller: _emergencyNameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    IntlPhoneField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        ),
                      ),
                      countries: ['MV','LK', 'AU', 'IN'],
                      initialCountryCode: 'MV',
                      onChanged: (phone) {
                        _emergencyPhoneController.text = "${phone.completeNumber}";
                      },
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: Get.width,
              height: 72,
              child: ElevatedButton(
                style: ButtonStyles.bigBlackButton(),
                child: Text('Sign Up'),
                onPressed: () {
                  signUpData.eContactName = _emergencyNameController.text;
                  signUpData.eContactPhone = _emergencyPhoneController.text;

                  if (_emergencyNameController.text.isNotEmpty && _emergencyPhoneController.text.isNotEmpty) {
                    signUp();
                  } else {
                    showSnack('Incomplete information',
                        'Please enter all the information');
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
