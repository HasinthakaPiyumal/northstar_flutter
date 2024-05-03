import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/CommonAuthUtils.dart';
import 'package:north_star/Auth/ForgotPassword.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpStart.dart';
import 'package:north_star/Auth/SteppingSignUp_v2/SignUpUserType.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../components/Buttons.dart';

class SignIn extends StatelessWidget {
  SignIn({Key? key}) : super(key: key);

  RxBool loading = false.obs;

  RxBool passVisibility = true.obs;

  RxBool rememberMe = true.obs;

  void toggle() {
    passVisibility.value = !passVisibility.value;
  }

  TextEditingController userName = TextEditingController();
  TextEditingController password = TextEditingController();

  FocusNode userNameFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  void signIn() async {
    if (!userName.text.isEmail) {
      showSnack('Incorrect Email', 'Please use the correct email address',status:PopupNotificationStatus.error);
    } else if (password.text.isEmpty) {
      showSnack('Incorrect Password', 'Please use the correct password',status:PopupNotificationStatus.error);
    } else {

      loading.value = true;
      Map res = await httpClient.signIn({
        'email': userName.text,
        'password': password.text,
      });

      if (res['code'] == 200) {
        loading.value = false;
        CommonAuthUtils.signIn(res);
      } else {
        loading.value = false;
        print(res);
        if(res['data']['error']==null){
          showSnack(
              'Incorrect Email and/or Password',
              'Please use the correct password and email',
              status:PopupNotificationStatus.error
          );
        }else{
          showSnack(
              res['data']['message']??'Incorrect Email and/or Password',
              res['data']['error']??'Please use the correct password and email',
              status:PopupNotificationStatus.warning
          );
        }

      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/backgrounds/login.png"),
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(0.00, -1.00),
                  end: Alignment(0, 1),
                  colors: [
                    Colors.black.withOpacity(0.5399999856948853),
                    isDark ? Colors.black : Colors.white
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Scaffold(
                backgroundColor: Colors.transparent,
                body: Stack(
                  children: [],
                ),
                bottomNavigationBar: SingleChildScrollView(
                  child: Container(
                    color: Theme.of(context).primaryColor.withOpacity(0),
                    child: AutofillGroup(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/appicons/logo_black_white.png"),
                                    fit: BoxFit.fill,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Container(
                                width: 66,
                                height: 29,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                        "assets/appicons/mini_logo_text_white.png"),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text.rich(
                            TextSpan(
                              text: 'login\n'.toUpperCase(),
                              style: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                                fontSize: 24,
                                fontFamily: 'Bebas Neue',
                                fontWeight: FontWeight.w400,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Empower Your Fitness Journey',
                                  style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black,
                                    fontSize: 32,
                                    fontFamily: 'Bebas Neue',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.start,
                          ),
                          SizedBox(height: Get.height / 100 * 4),
                          TextField(
                            controller: userName,
                            focusNode: userNameFocusNode,
                            autofillHints: [AutofillHints.email],
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              hintText: 'Enter your email',
                              hintStyle: TextStyle(
                                color: isDark ? Colors.white : Colors.black,
                              ),
                              border: UnderlineInputBorder(),
                              contentPadding: EdgeInsets.only(top: 15.0),
                            ),
                            onSubmitted: (data){
                              passwordFocusNode.requestFocus();
                            },
                          ),
                          SizedBox(height: 10),
                          Obx(()=> TextField(
                              controller: password,
                              focusNode: passwordFocusNode,
                              obscureText: passVisibility.value,
                              autofillHints: [AutofillHints.password,AutofillHints.newPassword],
                              onEditingComplete: ()=>TextInput.finishAutofillContext(),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                hintText: 'Enter your password',
                                hintStyle: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                ),
                                border: UnderlineInputBorder(),
                                contentPadding: EdgeInsets.only(top: 15.0),
                                suffixIcon: IconButton(
                                  onPressed: () =>
                                    toggle()
                                  ,
                                  icon: Icon(
                                    passVisibility.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: isDark ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              onSubmitted: (data){
                                if(password.text.isNotEmpty && userName.text.isNotEmpty){
                                  signIn();
                                }
                              },
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 25.0),
                                child: Obx(()=> Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Checkbox(
                                        activeColor: Color(0xFFFFB700),
                                        checkColor: Color(0xFF1B1F24),
                                        value: rememberMe.value,
                                        onChanged: (bool? value) {
                                          rememberMe.value = (!(rememberMe.value));
                                        },
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          rememberMe.value = (!(rememberMe.value));
                                        },
                                        child: Text(
                                          'Remember Me',
                                          style: TextStyle(
                                            color: isDark ? Colors.white : Colors.black,
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Add your login button onTap logic here
                                },
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ForgotPassword(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    overlayColor: MaterialStateColor.resolveWith(
                                        (states) => Colors.transparent),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Obx(()=> Center(
                            child: Buttons.yellowFlatButton(
                              label: "Login",
                              isLoading: loading.value,
                              width: 240,
                              onPressed: () {
                                signIn();
                              },
                            ),
                          ),
                          ),
                          SizedBox(height: Get.height / 100 * 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Haven’t An Account? ',
                                style: TextStyle(
                                  color: isDark ? Colors.white : Colors.black,
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  // Add your login button onTap logic here
                                },
                                child: TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SignUpUserType(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Sign Up',
                                    style: TextStyle(
                                      color: isDark ? Colors.white : Colors.black,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                  style: ButtonStyle(
                                    overlayColor: MaterialStateColor.resolveWith(
                                        (states) => Colors.transparent),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: Get.height / 100 * 1),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
