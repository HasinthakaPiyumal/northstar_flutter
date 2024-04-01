import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:north_star/Auth/SteppingSignUp/SignUpData.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../../../Models/HttpClient.dart';
import '../../../Styles/PickerDialogStyles.dart';
import 'TrainerRegister_02.dart';

class TrainerRegisterFirst extends StatefulWidget {
  @override
  State<TrainerRegisterFirst> createState() => _TrainerRegisterFirstState();
}

class _TrainerRegisterFirstState extends State<TrainerRegisterFirst> {
  RxBool ready = true.obs;

  int genderType = 1;
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _nicController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _birthdayController = TextEditingController();

  String phoneNumber = "";

  void next() async {
    ready.value = false;
    String email = _emailController.text;
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _nicController.text.isEmpty ||
        // _countryCodeController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _birthdayController.text.isEmpty) {
      showSnack('Incomplete information', 'Please enter all the information');
      return;
    }

    // Regular expression to validate email format
    final emailRegex = RegExp(
        r'^[\w-]+(\.[\w-]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,})$');

    if (!emailRegex.hasMatch(email)) {
      showSnack('Invalid Email', 'Please enter a valid email address.');
      return;
    }
    Map res = await httpClient.signUpDataCheck({
      'email': _emailController.text,
      'phone': phoneNumber,
      'nic': _nicController.text,
    });

    if (res['code'] == 200) {
      if (res['data']['error'] != null) {
        showSnack('Account Information', res['data']['error']);
      } else {
        finishNext();
      }
      ready.value = true;
    } else {
      showSnack('Incomplete information', 'Please Enter correct information');
    }
  }

  void finishNext() async {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _nicController.text.isEmpty ||
        // _countryCodeController.text.isEmpty ||
        _phoneNumberController.text.isEmpty ||
        _birthdayController.text.isEmpty) {
      showSnack('Incomplete information', 'Please enter all the information');
    } else {
      signUpData.name =
          _firstNameController.text + " " + _lastNameController.text;
      signUpData.email = _emailController.text;
      signUpData.idNumber = _nicController.text;
      signUpData.phone = phoneNumber;
      signUpData.birthday = _birthdayController.text;

      if (genderType == 2) {
        signUpData.gender = "female";
      } else {
        signUpData.gender = "male";
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TrainerRegisterSecond(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double contentHeight = 25.0;
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                          image: AssetImage(isDark
                              ? "assets/appicons/mini_logo_text_white.png"
                              : "assets/appicons/mini_logo_text_black.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Container(
                  width: 85,
                  height: 50,
                  padding: const EdgeInsets.all(3.0),
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              padding: const EdgeInsets.all(2),
                              decoration: ShapeDecoration(
                                color: Color(0xFFFFB700),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    '01',
                                    style: TextStyle(
                                      color: Color(0xFF1B1F24),
                                      fontSize: 20,
                                      fontFamily: 'Bebas Neue',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '/ 03',
                              style: TextStyle(
                                color: Color(0xFF1B1F24),
                                fontSize: 20,
                                fontFamily: 'Bebas Neue',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_2_outlined,
                              color: isDark?Colors.white:Colors.black, size: 18),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          labelText: 'First Name',
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                          contentPadding: EdgeInsets.only(bottom: 0),
                        ),
                        style: TextStyle(color: isDark?Colors.white:Colors.black),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                            Icons.person_2_outlined,
                            color: isDark?Colors.white:Colors.black,
                            size: 20,
                          ),
                          border: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          labelText: 'Last Name',
                          labelStyle: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                          contentPadding: EdgeInsets.only(bottom: 0),
                        ),
                        style: TextStyle(
                          color: isDark?Colors.white:Colors.black,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: contentHeight),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email_outlined,
                        color: isDark?Colors.white:Colors.black, size: 18),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    labelText: 'Email',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.only(bottom: 0),
                  ),
                  style: TextStyle(color: isDark?Colors.white:Colors.black),
                ),
                SizedBox(height: contentHeight),
                TextFormField(
                  controller: _nicController,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.credit_card_outlined,
                        color: isDark?Colors.white:Colors.black, size: 18),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    labelText: 'Nic Or Passport',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.only(bottom: 0),
                  ),
                  style: TextStyle(color: isDark?Colors.white:Colors.black),
                ),
                SizedBox(height: contentHeight),
                Theme(
                  data: Theme.of(context).copyWith(
                      listTileTheme: ListTileThemeData()
                  ),
                  child: IntlPhoneField(
                    controller: _phoneNumberController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.call_outlined,
                          color: isDark?Colors.white:Colors.black, size: 18),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      labelText: 'Phone',
                      labelStyle: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                      contentPadding: EdgeInsets.only(bottom: 0),
                    ),
                    style: TextStyle(color: isDark?Colors.white:Colors.black),
                    pickerDialogStyle: PickerDialogStyles.main(),
                    initialCountryCode: 'MV',
                    onChanged: (phone) {
                      setState(() {
                        phoneNumber = "${phone.completeNumber}";
                      });
                    },
                  ),
                ),
                // TextFormField(
                //   controller: _phoneNumberController,
                //   decoration: InputDecoration(
                //     prefixIcon: Icon(Icons.call_outlined,
                //         color: isDark?Colors.white:Colors.black, size: 18),
                //     border: UnderlineInputBorder(
                //       borderSide: BorderSide(color: Colors.white),
                //     ),
                //     labelText: 'Phone',
                //     labelStyle: TextStyle(
                //       color: isDark ? Colors.white70 : Colors.black54,
                //       fontWeight: FontWeight.w500,
                //       fontFamily: 'Poppins',
                //       fontSize: 16,
                //     ),
                //     contentPadding: EdgeInsets.only(bottom: 0),
                //   ),
                //   style: TextStyle(color: isDark?Colors.white:Colors.black),
                // ),
                SizedBox(height: contentHeight),
                TextFormField(
                  controller: _birthdayController,
                  readOnly: true,
                  onTap: () async {
                    final DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime(2000),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      // builder: (BuildContext context, Widget? child) {
                      //   return Theme(
                      //     data: isDark
                      //         ? ThemeData.dark().copyWith(
                      //       primaryColor:
                      //       isDark ? Colors.white : Colors.black,
                      //       colorScheme: ColorScheme.dark(
                      //           primary: Color(0xFFFFB700),
                      //           onSecondary: Color(0xFFFFB700)),
                      //       dialogBackgroundColor: Color(0xFF1B1F24),
                      //     )
                      //         : ThemeData.light().copyWith(
                      //       primaryColor:
                      //       isDark ? Colors.white : Colors.black,
                      //       colorScheme: ColorScheme.light(
                      //           primary: Color(0xFFFFB700)),
                      //     ),
                      //     child: child!,
                      //   );
                      // },
                    );

                    if (pickedDate != null) {
                      setState(() {
                        final formattedDate =
                            pickedDate.toLocal().toString().split(' ')[0];
                        _birthdayController.text = formattedDate;
                      });
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.calendar_today_outlined,
                        color: isDark?Colors.white:Colors.black, size: 18),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                    labelText: 'Birthday',
                    labelStyle: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black54,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                    ),
                    contentPadding: EdgeInsets.only(bottom: 0),
                  ),
                  style: TextStyle(color: isDark?Colors.white:Colors.black),
                ),
                SizedBox(height: contentHeight),
                Row(
                  children: [
                    Row(
                      children: [
                        Radio(
                          value: 1,
                          groupValue: genderType,
                          onChanged: (Object? v) {
                            setState(() {
                              genderType = 1;
                            });
                          },
                          activeColor: Colors.amber,
                          fillColor:
                              MaterialStateProperty.resolveWith((Set states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.orange.withOpacity(.32);
                            }
                            return Colors.orange;
                          }),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              genderType = 1;
                            });
                          },
                          child: Text(
                            'Male',
                            style: TextStyle(
                              fontSize: 16,
                              // Add any other styles you want for the label text
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 50),
                    Row(
                      children: [
                        Radio(
                          value: 2,
                          groupValue: genderType,
                          onChanged: (Object? v) {
                            setState(() {
                              genderType = 2;
                            });
                          },
                          activeColor: Colors.amber,
                          fillColor:
                              MaterialStateProperty.resolveWith((Set states) {
                            if (states.contains(MaterialState.disabled)) {
                              return Colors.orange.withOpacity(.32);
                            }
                            return Colors.orange;
                          }),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              genderType = 2;
                            });
                          },
                          child: Text(
                            'Female',
                            style: TextStyle(
                              fontSize: 16,
                              // Add any other styles you want for the label text
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: contentHeight),
                Center(
                  child: Container(
                    width: 350,
                    height: 64,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        // Get.to(() => ClientRegisterSecond());
                        next();
                      },
                      style: ElevatedButton.styleFrom(
                        primary: Color(0xFFFFB700),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'next'.toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1B1F24),
                              fontSize: 22,
                              fontFamily: 'Bebas Neue',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
