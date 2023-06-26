import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/AuthHome.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Models/HttpClient.dart';

class ForgotPassword2 extends StatelessWidget {
  const ForgotPassword2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool loading = false.obs;
    RxBool passVisibility = true.obs;
    RxBool passVisibilityR = true.obs;
    TextEditingController code = new TextEditingController();
    TextEditingController password = new TextEditingController();
    TextEditingController rPassword = new TextEditingController();

    void resetAndGoHome() async{
      print(code.text);
      Map res = await httpClient.forgotPasswordStepTwo(
        code.text,
        password.text,
        rPassword.text
      );

      print(res);
      if(res['code'] == 200){
        Get.offAll(()=>AuthHome());
        showSnack('Password Reset is Successful!', 'You may now login with your new password.');
      } else {
        showSnack('Error', res['data']);
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
                controller: code,
                keyboardType: TextInputType.number,
                maxLength: 6,
                decoration: InputDecoration(
                  labelText: 'OTP Code',
                ),
              ),
              SizedBox(height: 16),
              Obx(()=>Stack(
                children: [
                  TextField(
                    controller: password,
                    style: TextStyle(fontSize: 18),
                    obscureText: passVisibility.value,
                    decoration: InputDecoration(
                        labelText: 'New Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                        )),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: IconButton(
                        icon: Icon(passVisibility.value ? Icons.visibility : Icons.visibility_off),
                        onPressed: (){
                          passVisibility.value = !passVisibility.value;
                        }),
                  )
                ],
              )),
              SizedBox(height: 16),
              Obx(()=>Stack(
                children: [
                  TextField(
                    controller: rPassword,
                    style: TextStyle(fontSize: 18),
                    obscureText: passVisibilityR.value,
                    decoration: InputDecoration(
                        labelText: 'Repeat New Password',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)
                        )),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: IconButton(
                        icon: Icon(passVisibilityR.value ? Icons.visibility : Icons.visibility_off),
                        onPressed: (){
                          passVisibilityR.value = !passVisibilityR.value;
                        }),
                  )
                ],
              )),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: Get.width * 0.5,
                    height: 56,
                    child: ElevatedButton(
                      style: ButtonStyles.bigBlackButton(),
                      child: Text('Reset'),
                      onPressed: () {
                        if(password.text == rPassword.text){
                          loading.value = true;
                          resetAndGoHome();
                        } else {
                          showSnack('Passwords do not match', 'Passwords do not match');
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
