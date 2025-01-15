import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Auth/SteppingSignUp_v2/MedicalPro/MedicalProRegister_01.dart';
import 'package:north_star/Auth/SteppingSignUp_v2/Trainer/TrainerRegister_01.dart';
import 'package:north_star/Utils/PopUps.dart';

import '../SteppingSignUp/SignUpData.dart';
import 'Client/ClientRegister_01.dart';

class SignUpUserType extends StatefulWidget {
  @override
  State<SignUpUserType> createState() => _SignUpUserTypeState();
}

class _SignUpUserTypeState extends State<SignUpUserType> {
  int value = 1;

  @override
  Widget build(BuildContext context) {
    double type_height = Get.height / 100 * 20;

    return SafeArea(
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                      'assets/images/backgrounds/signup_account_type.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Color.fromRGBO(0, 0, 0, 0.5), // Overlay color with opacity
            ),
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(
                      width: Get.width,
                      child: Text(
                        'Choose Your Account Type',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => setState(() {
                        value = 1;
                      }),
                      child: Container(
                        width: Get.width,
                        height: type_height,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 4),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/item_backgrounds/type_01.png'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.7599999904632568),
                              // Adjust the opacity here (0.0 - 1.0)
                              BlendMode.darken,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Member',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontFamily: 'Bebas Neue',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: Get.width - 148,
                                        child: Text(
                                          'Connect with trainers and medical professionals.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Radio(
                                value: 1,
                                groupValue: value,
                                onChanged: (Object? v) {
                                  setState(() {
                                    value = 1;
                                  });
                                },
                                activeColor: Colors.amber,
                                fillColor: MaterialStateProperty.resolveWith(
                                    (Set states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.orange.withOpacity(.32);
                                  }
                                  return Colors.orange;
                                }))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => setState(() {
                        value = 2;
                      }),
                      child: Container(
                        width: Get.width,
                        height: type_height,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 4),
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(
                                'assets/images/item_backgrounds/type_02.png'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.7599999904632568),
                              // Adjust the opacity here (0.0 - 1.0)
                              BlendMode.darken,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Trainer',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontFamily: 'Bebas Neue',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: Get.width - 148,
                                        child: Text(
                                          'Connect and manage clients.',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Radio(
                                value: 2,
                                groupValue: value,
                                onChanged: (Object? v) {
                                  setState(() {
                                    value = 2;
                                  });
                                },
                                activeColor: Colors.amber,
                                fillColor: MaterialStateProperty.resolveWith(
                                    (Set states) {
                                  if (states.contains(MaterialState.disabled)) {
                                    return Colors.orange.withOpacity(.32);
                                  }
                                  return Colors.orange;
                                }))
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    // GestureDetector(
                    //   onTap: () => setState(() {
                    //     value = 3;
                    //   }),
                    //   child: Container(
                    //     width: Get.width,
                    //     height: type_height,
                    //     padding: const EdgeInsets.symmetric(
                    //         horizontal: 24, vertical: 4),
                    //     decoration: BoxDecoration(
                    //       image: DecorationImage(
                    //         image: AssetImage(
                    //             'assets/images/item_backgrounds/type_03.png'),
                    //         fit: BoxFit.cover,
                    //         colorFilter: ColorFilter.mode(
                    //           Colors.black.withOpacity(0.7599999904632568),
                    //           // Adjust the opacity here (0.0 - 1.0)
                    //           BlendMode.darken,
                    //         ),
                    //       ),
                    //       borderRadius: BorderRadius.circular(10),
                    //     ),
                    //     child: Row(
                    //       children: [
                    //         Column(
                    //           mainAxisSize: MainAxisSize.min,
                    //           mainAxisAlignment: MainAxisAlignment.end,
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Container(
                    //               padding: const EdgeInsets.symmetric(
                    //                   horizontal: 20, vertical: 5),
                    //               child: Row(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 mainAxisAlignment: MainAxisAlignment.start,
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.center,
                    //                 children: [
                    //                   Text(
                    //                     'medical professional',
                    //                     style: TextStyle(
                    //                       color: Colors.white,
                    //                       fontSize: 26,
                    //                       fontFamily: 'Bebas Neue',
                    //                       fontWeight: FontWeight.w400,
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //             Container(
                    //               padding: const EdgeInsets.symmetric(
                    //                   horizontal: 10, vertical: 5),
                    //               child: Row(
                    //                 mainAxisSize: MainAxisSize.min,
                    //                 mainAxisAlignment: MainAxisAlignment.start,
                    //                 crossAxisAlignment:
                    //                     CrossAxisAlignment.center,
                    //                 children: [
                    //                   SizedBox(
                    //                     width: Get.width - 148,
                    //                     child: Text(
                    //                       'Consult and manage patients.',
                    //                       style: TextStyle(
                    //                         color: Colors.white,
                    //                         fontSize: 16,
                    //                         fontFamily: 'Poppins',
                    //                         fontWeight: FontWeight.w500,
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         Radio(
                    //             value: 3,
                    //             groupValue: value,
                    //             onChanged: (Object? v) {
                    //               setState(() {
                    //                 value = 3;
                    //               });
                    //             },
                    //             activeColor: Colors.amber,
                    //             fillColor: MaterialStateProperty.resolveWith(
                    //                 (Set states) {
                    //               if (states.contains(MaterialState.disabled)) {
                    //                 return Colors.orange.withOpacity(.32);
                    //               }
                    //               return Colors.orange;
                    //             }))
                    //       ],
                    //     ),
                    //   ),
                    // ),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if ([1, 2, 3].contains(value)) {
                              switch (value) {
                                case 1:
                                  signUpData.userType = 'client';
                                  Get.to(() => ClientRegisterFirst());
                                  break;
                                case 2:
                                  signUpData.userType = 'trainer';
                                  Get.to(() => TrainerRegisterFirst());
                                  break;
                                case 3:
                                  signUpData.userType = 'doctor';
                                  Get.to(() => MedicalProRegisterFirst());
                                  break;
                              }
                            } else {
                              showSnack('Incomplete information',
                                  'Please select a user type');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFFFB700),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            minimumSize: Size(184, 64),
                          ),
                          child: Text(
                            'continue',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF1B1F24),
                              fontSize: 24,
                              fontFamily: 'Bebas Neue',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
