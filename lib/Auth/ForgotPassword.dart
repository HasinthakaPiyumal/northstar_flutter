import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/ForgotPassword2.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController email = new TextEditingController();

    void sendResetEmail() async {
      Map res = await httpClient.forgotPasswordStepOne(email.text);
      if (res['code'] == 200) {
        Get.to(() => ForgotPassword2(mail:email.text));
        showSnack('An email has been sent to you with the 6 Digit CODE.',
            'An email has been sent to you with the 6 Digit CODE. Enter it to reset your password.');
      } else {
        showSnack('Error', 'Please use the correct email address');
      }
    }

    return Scaffold(
      appBar: AppBar(
        // title: Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.accentColor,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      'Forgot',
                      textAlign: TextAlign.center,
                      style: TypographyStyles.title(20).copyWith(color: AppColors.textColorLight),
                    ),
                  ),
                  SizedBox(width: 10,),
                  Text(
                    'Password',
                    textAlign: TextAlign.center,
                    style: TypographyStyles.title(20),
                  ),
                ],
              ),
              SizedBox(height: 60),

              Text(
                'OTP Verification',
                textAlign: TextAlign.center,
                style: TypographyStyles.title(20),
              ),
              SizedBox(height: 10),
              Text(
                'We will send you an one time password on this email',
                textAlign: TextAlign.center,
                style: TypographyStyles.text(16)
              ),
              SizedBox(height: 20),
              TextField(
                controller: email,
                decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  prefixIcon: Icon(Icons.email_outlined),
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: Get.width *0.8,
                    height: 44,
                    child: ElevatedButton(
                      style: ButtonStyles.bigBlackButton(),
                      child: Text('Send'),
                      onPressed: () {
                        if (email.text.isNotEmpty) {
                          sendResetEmail();
                        } else {
                          showSnack('Enter Your Email!',
                              'Please enter your email to send the reset Code');
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Back To",style: TypographyStyles.text(16),),
                  TextButton(onPressed: (){Get.back();}, child: Text("Login",style: TypographyStyles.text(16)))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
