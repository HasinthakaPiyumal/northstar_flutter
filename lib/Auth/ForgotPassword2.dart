import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/AuthHome.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/Buttons.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../Styles/AppColors.dart';

class ForgotPassword2 extends StatefulWidget {
  final String mail;

  ForgotPassword2({Key? key, required this.mail}) : super(key: key);

  @override
  State<ForgotPassword2> createState() => _ForgotPassword2State();
}

class _ForgotPassword2State extends State<ForgotPassword2> {
  final TextEditingController code1 = TextEditingController();
  final TextEditingController code2 = TextEditingController();
  final TextEditingController code3 = TextEditingController();
  final TextEditingController code4 = TextEditingController();
  final TextEditingController code5 = TextEditingController();
  final TextEditingController code6 = TextEditingController();

  String pin = "";
  late FocusNode focusNode1;
  late FocusNode focusNode2;
  late FocusNode focusNode3;
  late FocusNode focusNode4;
  late FocusNode focusNode5;
  late FocusNode focusNode6;

  @override
  void initState() {
    super.initState();
    focusNode1 = FocusNode();
    focusNode2 = FocusNode();
    focusNode3 = FocusNode();
    focusNode4 = FocusNode();
    focusNode5 = FocusNode();
    focusNode6 = FocusNode();

    focusNode1.addListener(() {
      if (focusNode1.hasFocus && code1.text.isEmpty) {
        code1.text = '';
      }
    });

    focusNode2.addListener(() {
      if (focusNode2.hasFocus && code2.text.isEmpty) {
        code2.text = '';
      }
    });

    focusNode3.addListener(() {
      if (focusNode3.hasFocus && code3.text.isEmpty) {
        code3.text = '';
      }
    });

    focusNode4.addListener(() {
      if (focusNode4.hasFocus && code4.text.isEmpty) {
        code4.text = '';
      }
    });

    focusNode5.addListener(() {
      if (focusNode5.hasFocus && code5.text.isEmpty) {
        code5.text = '';
      }
    });

    focusNode6.addListener(() {
      if (focusNode6.hasFocus && code6.text.isEmpty) {
        code6.text = '';
      }
    });
  }

  @override
  void dispose() {
    code1.dispose();
    code2.dispose();
    code3.dispose();
    code4.dispose();
    code5.dispose();
    code6.dispose();
    focusNode1.dispose();
    focusNode2.dispose();
    focusNode3.dispose();
    focusNode4.dispose();
    focusNode5.dispose();
    focusNode6.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    RxBool loading = false.obs;
    RxBool passVisibility = true.obs;
    RxBool passVisibilityR = true.obs;

    TextEditingController pinController = new TextEditingController();
    TextEditingController password = new TextEditingController();
    TextEditingController rPassword = new TextEditingController();

    void resetAndGoHome() async {
      if(password.text.length<8){
        showSnack("Password Validation", "Your password must be at least 8 characters long.",status: PopupNotificationStatus.warning);
        return;
      }if(password.text.length>15){
        showSnack("Password Validation", "The password may not be greater than 15 characters.",status: PopupNotificationStatus.warning);
        return;
      }
      if(password.text!=rPassword.text){
        showSnack("Password Mismatch", "The passwords you entered do not match. Please ensure that both passwords are the same.",status: PopupNotificationStatus.warning);
        return;
      }
      Map res = await httpClient.forgotPasswordStepTwo(
          // '${code1.text}${code2.text}${code3.text}${code4.text}${code5.text}${code6.text}',
          pin,
          password.text,
          rPassword.text);

      if (res['code'] == 200) {
        Get.offAll(() => AuthHome());
        showSnack('Password Reset is Successful!',
            'You may now login with your new password.',status: PopupNotificationStatus.success);
      } else {
        print(res);
        showSnack('Something went wrong', res['data'],status: PopupNotificationStatus.error);
      }
    }

    return Scaffold(
      appBar: AppBar(
          // title: Text('Reset Password'),
          ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Image.asset(
              //
              // ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    'OTP Verification',
                    textAlign: TextAlign.center,
                    style: TypographyStyles.title(20),
                  ),
                ],
              ),
              SizedBox(height: 40),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Enter the OTP Sent to ',
                      style: TypographyStyles.text(16)),
                  Text('${widget.mail.toLowerCase()}',
                      style: TypographyStyles.text(16)
                          .copyWith(decoration: TextDecoration.underline),overflow: TextOverflow.ellipsis,),
                ],
              ),
              SizedBox(height: 20),
              Container(
                width:290,
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  animationType: AnimationType.fade,
                  cursorColor: Get.isDarkMode ? Colors.white : Colors.black,
                  keyboardType: TextInputType.number,
                  controller: pinController,
                  enablePinAutofill: false,
                  pinTheme: PinTheme(
                    activeFillColor: AppColors.accentColor,
                    activeColor: AppColors.accentColor,
                    inactiveColor: Get.isDarkMode?Colors.white.withOpacity(0.5):Colors.black
                  ),
                  onChanged: (value) {
                    print(value);
                    setState(() {
                      pin = value;
                    });
                  },                ),
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     buildTextField(code1, focusNode1),
              //     SizedBox(width: 10),
              //     buildTextField(code2, focusNode2),
              //     SizedBox(width: 10),
              //     buildTextField(code3, focusNode3),
              //     SizedBox(width: 10),
              //     buildTextField(code4, focusNode4),
              //     SizedBox(width: 10),
              //     buildTextField(code5, focusNode5),
              //     SizedBox(width: 10),
              //     buildTextField(code6, focusNode6),
              //   ],
              // ),
              SizedBox(height: 46),
              Obx(() => Stack(
                    children: [
                      TextField(
                        controller: password,
                        style: TextStyle(fontSize: 18),
                        obscureText: passVisibility.value,
                        decoration: InputDecoration(
                            labelText: 'New Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: UnderlineInputBorder()),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        top: 0,
                        child: IconButton(
                            icon: Icon(passVisibility.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              passVisibility.value = !passVisibility.value;
                            }),
                      )
                    ],
                  )),
              SizedBox(height: 16),
              Obx(() => Stack(
                    children: [
                      TextField(
                        controller: rPassword,
                        style: TextStyle(fontSize: 18),
                        obscureText: passVisibilityR.value,
                        decoration: InputDecoration(
                            labelText: 'Repeat New Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            border: UnderlineInputBorder()),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        top: 0,
                        child: IconButton(
                            icon: Icon(passVisibilityR.value
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              passVisibilityR.value = !passVisibilityR.value;
                            }),
                      )
                    ],
                  )),
              SizedBox(height: 26),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: Get.width * 0.8,
                    height: 44,
                    child: ElevatedButton(
                      style: ButtonStyles.primaryButton(),
                      child: Text('Reset'),
                      onPressed: () {
                        if (password.text == rPassword.text) {
                          loading.value = true;
                          resetAndGoHome();
                        } else {
                          showSnack('Passwords do not match',
                              'Passwords do not match');
                        }
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Buttons.outlineButton(
                  onPressed: () {
                    Get.back();
                  },
                  width: Get.width * 0.8,
                  label: "Cancel"),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField(TextEditingController controller, FocusNode focusNode) {
    return Container(
      width: 40,
      child: TextField(
        controller: controller,
        maxLength: 1,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          counterText: "",
          border: UnderlineInputBorder(),
        ),
        focusNode: focusNode,
        onChanged: (value) {
          controller.text = value;
          if (value.isNotEmpty) {
            if (focusNode != focusNode6) {
              focusNode.nextFocus();
            }
          } else {
            if (focusNode != focusNode1) {
              focusNode.previousFocus();
            }
          }
        },
      ),
    );
  }
}
