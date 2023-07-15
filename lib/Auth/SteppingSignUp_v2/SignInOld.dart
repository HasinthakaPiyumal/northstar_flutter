import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/CommonAuthUtils.dart';
import 'package:north_star/Auth/ForgotPassword.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpStart.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';

class SignIn extends StatelessWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxBool loading = false.obs;
    RxBool passVisibility = true.obs;
    void toggle() => loading.value = !loading.value;

    TextEditingController userName = new TextEditingController();
    TextEditingController password = new TextEditingController();

    void signIn() async{
      if(!userName.text.isEmail){
        showSnack('Incorrect Email', 'Please use the correct email address');
      } else if (password.text.isEmpty){
        showSnack('Incorrect Password', 'Please use the correct password');
      } else {
        toggle();
        Map res = await httpClient.signIn({
          'email': userName.text,
          'password': password.text
        });

        if (res['code'] == 200) {
          CommonAuthUtils.signIn(res);
        } else {
          showSnack('Incorrect Email and/or Password', 'Please use the correct password and email');
          toggle();
        }
      }
    }

    return Scaffold(
        body: Container(
      height: Get.height,
      child: Stack(
        children: [
          Container(
            width: Get.width,
            child: Image.asset(
              'assets/images/bg_login.png',
              fit: BoxFit.fitWidth,
            ),
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 72,
            child: Container(
              child: Card(
                shape: Themes().roundedBorder(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 50,
                              child: Image.asset(
                                Get.isDarkMode ? 'assets/allwhite.png' : 'assets/allblack.png',
                                fit: BoxFit.contain,
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 32),
                        Row(
                          children: [
                            Text('Login', style: TypographyStyles.title(28)),
                          ],
                        ),
                        SizedBox(height: 16),
                        TextField(
                          controller: userName,
                          style: TextStyle(fontSize: 18),
                          decoration: InputDecoration(
                              labelText: 'Email Address',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12)
                              )),
                        ),
                        SizedBox(height: 8),
                        Obx(()=>Stack(
                          children: [
                            TextField(
                              controller: password,
                              style: TextStyle(fontSize: 18),
                              obscureText: passVisibility.value,
                              decoration: InputDecoration(
                                  labelText: 'Password',
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
                        SizedBox(height: 4),
                        Row(
                          children: [
                            TextButton(
                              child: Text(
                                'Forgot Password?',
                              ),
                              onPressed: () {
                                Get.to(ForgotPassword());
                              },
                            )
                          ],
                        ),
                        SizedBox(height: 8),
                        Container(
                          width: Get.width,
                          height: 58,
                          child: Obx((){
                            return ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  shape: Themes().roundedBorder(12),
                                  backgroundColor: Color(0xFF1C1C1C)),
                              child: loading.value ? Center(
                                child: CircularProgressIndicator(),
                              ):Text(
                                'LOGIN',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              ),
                              onPressed: () {
                                //devFastSignIn();
                                signIn();
                              },
                            );
                          }),
                        )
                      ],
                    ),
                  ),
                ),
              )
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account?'),
                  TextButton(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                    onPressed: () {
                      Get.to(() => SignUpStart());
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}
