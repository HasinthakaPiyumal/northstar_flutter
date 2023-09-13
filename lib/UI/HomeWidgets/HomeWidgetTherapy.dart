import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDoctors/DoctorMeetings.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDoctors/Doctors_List.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDoctors/Prescriptions.dart';

import 'HomeWidgetTherapy/TherapyMeetings.dart';

class Therapy extends StatelessWidget {
  const Therapy({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Physiotherapy Channeling',
          style: TypographyStyles.title(20),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset(
                'assets/images/therapy_widget_home.png',
              ),
            ),
          ),
          SizedBox(height: 10),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'channel a Physiotherapist just in few taps',
                  style: TypographyStyles.smallBoldTitle(26),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'SKIP THE TRAFFIC, CROWDED HOSPITAL WAITING ROOMS AND EXPOSURE TO GERMS AND CHANNELV ADOCTOR FROM THE COMFORT OF YOUR HOME'
                      .toUpperCase(),
                  style: TypographyStyles.textWithWeight(16, FontWeight.w400),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              // Container(
              //   width: Get.width * 0.9,
              //   height: 44,
              //   child: ElevatedButton(
              //     style: ButtonStyles.bigFlatYellowButton(),
              //     child: Text(
              //       'Appointments',
              //       style: TextStyle(
              //         fontSize: 20,
              //         fontFamily: 'Bebas Neue',
              //         fontWeight: FontWeight.w400,
              //       ),
              //     ),
              //     onPressed: () {
              //       Get.to(() => DoctorMeetings());
              //     },
              //   ),
              // ),
              // SizedBox(height: 16),
              // Container(
              //   width: Get.width * 0.9,
              //   height: 44,
              //   child: ElevatedButton(
              //     style: ButtonStyles.bigFlatYellowButton(),
              //     child: Text('Prescriptions',
              //         style: TextStyle(
              //           fontSize: 20,
              //           fontFamily: 'Bebas Neue',
              //           fontWeight: FontWeight.w400,
              //         )),
              //     onPressed: () {
              //       Get.to(() => Prescriptions());
              //     },
              //   ),
              // ),
              // SizedBox(height: 16),
              Container(
                width: Get.width * 0.9,
                height: 44,
                child: ElevatedButton(
                  style: ButtonStyles.bigFlatYellowButton(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_call_outlined),
                      SizedBox(width: 8),
                      Text('channel',
                          style: TextStyle(
                            fontSize: 20,
                            fontFamily: 'Bebas Neue',
                            fontWeight: FontWeight.w400,
                          ))
                    ],
                  ),
                  onPressed: () {
                    // Get.to(() => DoctorsList());
                    Get.to(() => TherapyMeetings());
                  },
                ),
              ),
              SizedBox(height: 32),
            ],
          )
        ],
      ),
    );
  }
}
