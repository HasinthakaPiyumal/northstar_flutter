import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDietaryConsultation/AddNewDietaryConsultation.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/Utils/PopUps.dart';

class HomeWidgetDietaryConsultation extends StatelessWidget {
  const HomeWidgetDietaryConsultation({Key? key, required this.userId,this.trainerId = 0}) : super(key: key);
  final int userId;
  final int trainerId;

  @override
  Widget build(BuildContext context) {
    RxList dietConsultations = [].obs;

    void requestDietaryConsultation() async{
      CommonConfirmDialog.confirm('Request Dietary Consultation',isSameButton: false,buttonText: "Send").then((value) async {
        if(value){
          await httpClient.sendNotification(
            userId,
            'Dietary Consultation Request',
            'Your Trainer ${authUser.name} has requested a dietary consultation form from you',
            NSNotificationTypes.DietConsultationRequest,
            {
              'trainer_id': authUser.id,
              'trainer_name': authUser.name,
            }
          );
          Get.back();
          showSnack('Dietary Consultation Request Sent', 'Your request has been sent to your client');
        }
      });
    }

    void getDietConsultations() async{
      Map res = await httpClient.getDietConsults(userId);
      print(res);
      if(res['code'] == 200){
        dietConsultations.value = res['data'];
      }
    }

    getDietConsultations();


    return Scaffold(
      appBar: AppBar(
        title: Text('Dietary Consultation'),
      ),
      floatingActionButton: authUser.role !='trainer' ? FloatingActionButton(
        onPressed: (){
          Get.to(() => AddNewDietaryConsultation(userId: userId,trainerId: trainerId,editMode: false,data:{}))?.then((value) {
            getDietConsultations();
          });
        },
        backgroundColor: AppColors.accentColor,
        child: Icon(Icons.add, color: AppColors.textOnAccentColor,size: 32,),
      ):null,
      body: Padding(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Visibility(
              visible: authUser.role == 'trainer',
              child: Container(
                height: 44,
                padding: EdgeInsets.symmetric(horizontal: 16),
                margin: EdgeInsets.only(bottom: 16),
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (){
                    requestDietaryConsultation();
                  },
                  style: ButtonStyles.primaryButton(),
                  child: Text("Request Dietary Consultation"),
                ),
              ),
            ),
            Expanded(
              child: Obx(()=>ListView.separated(
                itemCount: dietConsultations.value.length,
                separatorBuilder: (context, index){
                  return SizedBox(height: 10,);
                },
                itemBuilder: (context, index){
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      margin: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      child: InkWell(
                        onTap: (){
                          Get.to(() => AddNewDietaryConsultation(
                              userId: userId,
                              editMode: true,
                              data: dietConsultations.value[index],
                              trainerId:trainerId
                          ));
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(DateFormat("EEEE, MMM dd, yyyy").format(DateTime.parse(dietConsultations.value[index]['created_at'])),
                                style: TypographyStyles.normalText(14, Get.isDarkMode ? Colors.white : Colors.black),
                              ),
                              SizedBox(height: 15,),
                              Text("Dietary Consultation Form #${dietConsultations.value[index]['id']}",
                                style: TypographyStyles.boldText(16, Get.isDarkMode ? Colors.white : Colors.black),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              )),
            )
          ],
        ),
      ),
    );
  }
}
