import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/ForgotPassword2.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Utils/PopUps.dart';

class ForgotPassword extends StatelessWidget {
  const ForgotPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextEditingController email = new TextEditingController();

    void sendResetEmail() async{
      Map res = await httpClient.forgotPasswordStepOne(email.text);

      if(res['code'] == 200){
        Get.to(()=>ForgotPassword2());
        showSnack('An email has been sent to you with the 6 Digit CODE.', 'An email has been sent to you with the 6 Digit CODE. Enter it to reset your password.');

      } else {
        showSnack('Error', 'Please use the correct email address');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: email,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: Get.width * 0.5,
                    height: 56,
                    child: ElevatedButton(
                      style: ButtonStyles.bigBlackButton(),
                      child: Text('Send'),
                      onPressed: () {
                        if(email.text.isNotEmpty){
                          sendResetEmail();
                        } else {
                          showSnack('Enter Your Email!', 'Please enter your email to send the reset Code');
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
