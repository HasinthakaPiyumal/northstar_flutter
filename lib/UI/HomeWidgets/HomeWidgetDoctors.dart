import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDoctors/DoctorMeetings.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDoctors/Doctors_List.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDoctors/Prescriptions.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class Doctors extends StatelessWidget {
  const Doctors({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Medical Professionals',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset('assets/images/undraw_medicine_b1ol.png'),
            ),
          ),
          SizedBox(height: 40),
          Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Channel a medical professional just in few taps!', style: TypographyStyles.title(24), textAlign: TextAlign.center,),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Skip the traffic, crowded hospital waiting rooms and exposure to germs and channel a doctor from the comfort of your home.',
                  style: TextStyle(
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: Get.width*0.9,
                height: 56,
                child: ElevatedButton(
                  style: Get.isDarkMode ? ButtonStyles.bigBlackButton() : ButtonStyles.matButton(colors.Colors().selectedCardBG, 0),
                  child: Text('Appointments'),
                  onPressed: (){
                    Get.to(()=>DoctorMeetings());
                  },
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: Get.width*0.9,
                height: 56,
                child: ElevatedButton(
                  style: Get.isDarkMode ? ButtonStyles.bigBlackButton() : ButtonStyles.matButton(colors.Colors().selectedCardBG, 0),
                  child: Text('Prescriptions'),
                  onPressed: (){
                    Get.to(()=>Prescriptions());
                  },
                ),
              ),
              SizedBox(height: 16),
              Container(
                width: Get.width*0.9,
                height: 56,
                child: ElevatedButton(
                  style: Get.isDarkMode ? ButtonStyles.bigGreyButton() : ButtonStyles.bigBlackButton(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_call),
                      SizedBox(width: 8),
                      Text('CONNECT')
                    ],
                  ),
                  onPressed: (){
                    Get.to(()=>DoctorsList());
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
