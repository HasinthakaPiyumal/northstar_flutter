import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpCommonDataTwo.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpData.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
class SignUpCommonData extends StatelessWidget {
  const SignUpCommonData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;

    RxBool pswd = true.obs;
    RxBool confmPswd = true.obs;

    TextEditingController _emailController = TextEditingController();
    TextEditingController _phoneController = TextEditingController();
    TextEditingController _nicController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _confirmPasswordController = TextEditingController();

    void checkIfDupes(String email, String phone, String nic) async {
      ready.value = false;
      Map res = await httpClient.signUpDataCheck({
        'email': email,
        'phone': phone,
        'nic': nic,
      });

      if (res['code'] == 200) {
        if (res['data']['error'] != null) {
          showSnack('Account Information', res['data']['error']);
        } else {
          if (_emailController.text.toString().isNotEmpty &&
              _emailController.text.isEmail &&
              _phoneController.text.toString().isNotEmpty &&
              _passwordController.text.toString().isNotEmpty &&
              _passwordController.text.toString() ==
                  _confirmPasswordController.text.toString()) {
            Get.to(() => SignUpCommonDataTwo());
          } else {
            showSnack('Incomplete information', 'Please Enter correct information');
          }
        }
        ready.value = true;
      } else {
        showSnack('Incomplete information', 'Please Enter correct information');
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
                        Text('Account Information',
                            style: TypographyStyles.title(24)),
                        Hero(
                          tag: "progress",
                          child: CircularStepProgressIndicator(
                            totalSteps: 100,
                            currentStep: 25,
                            stepSize: 5,
                            selectedColor: colors.Colors().deepYellow(1),
                            unselectedColor: Get.isDarkMode ? Colors.grey[800] : Colors.grey[300],
                            padding: 0,
                            width: 100,
                            height: 100,
                            selectedStepSize: 7,
                            roundedCap: (_, __) => true,
                            child: Center(child: Text("1 of 4", style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1)),)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _nicController,
                      decoration: InputDecoration(
                        labelText: 'NIC or Passport',
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
                      initialCountryCode: 'MV',
                      onChanged: (phone) {
                        _phoneController.text = "${phone.completeNumber}";
                      },
                    ),
                    SizedBox(height: 40),
                    Obx(()=>TextField(
                      controller: _passwordController,
                      obscureText: pswd.value,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye, color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.7) : colors.Colors().selectedCardBG,),
                          onPressed: (){
                            pswd.value = !pswd.value;
                          },
                        ),
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                    ),),
                    SizedBox(height: 16),
                    Obx(()=>TextField(
                      controller: _confirmPasswordController,
                      obscureText: confmPswd.value,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(Icons.remove_red_eye, color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.7) : colors.Colors().selectedCardBG,),
                          onPressed: (){
                            confmPswd.value = !confmPswd.value;
                          },
                        ),
                      ),
                    ),),
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
            child: Text('Continue'),
            onPressed: () {
              signUpData.email = _emailController.text;
              signUpData.phone = _phoneController.text;
              signUpData.password = _passwordController.text;
              signUpData.passwordConfirmation =
                  _confirmPasswordController.text;
              signUpData.idNumber = _nicController.text;

              if (_emailController.text.toString().isNotEmpty &&
                  _phoneController.text.toString().isNotEmpty &&
                  _passwordController.text.toString().isNotEmpty &&
                  _passwordController.text.toString() ==
                      _confirmPasswordController.text.toString()) {
                checkIfDupes(_emailController.text, _phoneController.text,
                    _nicController.text);
              } else {
                showSnack('Incomplete information',
                    'Please Enter correct information');
              }
            },
          ),
        ),
      ),
    );
  }
}
