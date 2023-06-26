import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class ViewWorkoutFeedback extends StatelessWidget {
  const ViewWorkoutFeedback({Key? key, required this.data,  required this.viewOnly}) : super(key: key);
  final Map data;
  final bool viewOnly;
  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxBool hasFeedback = false.obs;
    double questionOne = 0.0;
    double questionTwo = 0.0;
    double questionThree = 0.0;
    double questionFour = 0.0;
    TextEditingController feedback = TextEditingController();

    void setValues(){
      print(data['feedback']);
      if(data['feedback'] != null){
        questionOne = data['feedback']['1'].toDouble();
        questionTwo = data['feedback']['2'].toDouble();
        questionThree = data['feedback']['3'].toDouble();
        questionFour = data['feedback']['4'].toDouble();
        feedback.text = data['feedback']['feedback'] ?? "";
        hasFeedback.value = true;
      } else {
        hasFeedback.value = false;
      }
    }

    void markAsFinished() async{
      ready.value = false;
      Map res = await httpClient.markWorkoutAsFinished({
        'workout_plan_id': data['id'].toString(),
        'feedback': jsonEncode({
          "1": questionOne,
          "2": questionTwo,
          "3": questionThree,
          "4": questionFour,
          "feedback": feedback.text
        })
      });

      await httpClient.sendNotification(
          data['trainer_id'],
          '${authUser.user['name']} has completed a workout!',
          '${authUser.user['name']} has completed the workout titled "${authUser.user['title']}"',
          NSNotificationTypes.WorkoutCompleted,
          {
            'sender_id': authUser.id,
            'sender_name': authUser.name,
            'workout_plan_id': data['id'],
            'workout_plan_title': data['title'],
          }
      );

      if (res['code'] == 200) {
        ready.value = true;
        Get.back();
      } else {
        ready.value = true;
      }
    }

    print(data);

    setValues();

    return Scaffold(
      appBar: AppBar(
        title: Text('Workout Feedback'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Obx(()=>hasFeedback.value ? SizedBox():Column(
                    children: [
                      Text('User has not yet provided any feedback', style: TypographyStyles.title(18),),
                      SizedBox(height: 16),
                    ],
                  ),),
                  SizedBox(height: 10),
                  Text('1. How was your Workout?',style: TypographyStyles.title(14)),
                  SizedBox(height: 8),
                  viewOnly ? RatingBarIndicator(
                    rating: questionOne,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: colors.Colors().deepYellow(1),
                    ),
                    itemCount: 5,
                    itemSize: 40.0,
                    direction: Axis.horizontal,
                    unratedColor: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,
                  ) : RatingBar(
                    initialRating: questionOne,
                    ratingWidget: RatingWidget(
                      full: Icon(Icons.star, color: colors.Colors().deepYellow(1),),
                      half: Icon(Icons.star_half, color: colors.Colors().deepYellow(1),),
                      empty: Icon(Icons.star, color: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,),
                    ),
                    tapOnlyMode: true,
                    itemCount: 5,
                    onRatingUpdate: (double value) {
                      questionOne = value;
                    },
                  ),
                  SizedBox(height: 30),
                  Text('2. How is your cardio going between workouts?',style: TypographyStyles.title(14)),
                  SizedBox(height: 8),
                  viewOnly ? RatingBarIndicator(
                    rating: questionTwo,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: colors.Colors().deepYellow(1),
                    ),
                    itemCount: 5,
                    itemSize: 40.0,
                    direction: Axis.horizontal,
                    unratedColor: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,
                  ) : RatingBar(
                    initialRating: questionTwo,
                    ratingWidget: RatingWidget(
                      full: Icon(Icons.star, color: colors.Colors().deepYellow(1),),
                      half: Icon(Icons.star_half, color: colors.Colors().deepYellow(1),),
                      empty: Icon(Icons.star, color: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,),
                    ),
                    tapOnlyMode: true,
                    itemCount: 5,
                    onRatingUpdate: (double value) {
                      questionTwo = value;
                    },
                  ),
                  SizedBox(height: 30),
                  Text('3. How is your nutrition going?',style: TypographyStyles.title(14)),
                  SizedBox(height: 8),
                  viewOnly ? RatingBarIndicator(
                    rating: questionThree,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: colors.Colors().deepYellow(1),
                    ),
                    itemCount: 5,
                    itemSize: 40.0,
                    direction: Axis.horizontal,
                    unratedColor: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,
                  ) : RatingBar(
                    initialRating: questionThree,
                    ratingWidget: RatingWidget(
                      full: Icon(Icons.star, color: colors.Colors().deepYellow(1),),
                      half: Icon(Icons.star_half, color: colors.Colors().deepYellow(1),),
                      empty: Icon(Icons.star, color: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,),
                    ),
                    tapOnlyMode: true,
                    itemCount: 5,
                    onRatingUpdate: (double value) {
                      questionThree = value;
                    },
                  ),
                  SizedBox(height: 30),
                  Text('4. How are your energy levels?',style: TypographyStyles.title(14)),
                  SizedBox(height: 8),
                  viewOnly ? RatingBarIndicator(
                    rating: questionFour,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: colors.Colors().deepYellow(1),
                    ),
                    itemCount: 5,
                    itemSize: 40.0,
                    direction: Axis.horizontal,
                    unratedColor: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,
                  ) : RatingBar(
                    initialRating: questionFour,
                    ratingWidget: RatingWidget(
                      full: Icon(Icons.star, color: colors.Colors().deepYellow(1),),
                      half: Icon(Icons.star_half, color: colors.Colors().deepYellow(1),),
                      empty: Icon(Icons.star, color: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,),
                    ),
                    tapOnlyMode: true,
                    itemCount: 5,
                    onRatingUpdate: (double value) {
                      questionFour = value;
                    },
                  ),
                  SizedBox(height: 30),
                  viewOnly ? Text(feedback.text,style: TypographyStyles.title(14)) : TextField(
                    controller: feedback,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Feedback',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              authUser.role == 'client' ? Container(
                width: Get.width,
                height: 56,
                child: ElevatedButton(
                  style: ButtonStyles.bigBlackButton(),
                  onPressed: (){
                    markAsFinished();
                  },
                  child: Text('Submit and Mark as Finished'),
                ),
              ) : Container(),
            ],
          )
        ),
      ),
    );
  }
}
