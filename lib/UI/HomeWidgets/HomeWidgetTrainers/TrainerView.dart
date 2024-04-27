import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/UI/SharedWidgets/ReviewWidget.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/main.dart';

class TrainerView extends StatelessWidget {
  const TrainerView({Key? key, this.trainerObj, this.isViewOnly = false}) : super(key: key);
  final bool isViewOnly;
  final trainerObj;

  @override
  Widget build(BuildContext context) {

    RxBool ready = false.obs;
    RxMap reviews = {}.obs;
    RxMap data = {}.obs;

    void getReviews() async{
      ready.value = false;
      Map res = await httpClient.getReviews(trainerObj['id']);
      if (res['code'] == 200) {
        print(res['data']);
        reviews.value = res['data'];
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }


    getReviews();

    setData(){
      data.value = trainerObj;
    }

    setData();


    void sendRequest() async{
      ready.value = false;
      Map res = await httpClient.checkIfAlreadyHasARequest(trainerObj['id']);

      if(res['code'] == 200) {
        Map res = await httpClient.sendNotification(
          trainerObj['id'],
          'New Client Request!',
          authUser.name + ' is Requesting to Connect With You.',
          NSNotificationTypes.ClientRequest,
          {
            'sender_id': authUser.id,
            'sender_email': authUser.email,
            'sender_name': authUser.name,
            'sender_phone': authUser.user['phone'],
          }
        );
        print(res);
        if(res['code'] == 400) {
          showSnack('Cannot Sent Trainer Request!', res['data']['info']['error']);
          ready.value = true;
        } else {
          Get.back();
          showSnack('Success!', 'Your Request Sent Successfully.');
          ready.value = true;
        }
      } else {
        print(res);
        showSnack('Cannot Sent Trainer Request!', res['data']['error']);
        ready.value = true;
      }


    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Trainer'),
      ),
      body: Obx(()=> ready.value ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20,),
              Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundImage : CachedNetworkImageProvider(HttpClient.s3BaseUrl + trainerObj['avatar_url']),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 3,),
                        Text(trainerObj['name'], style: TypographyStyles.title(20)),
                        SizedBox(height: 3,),
                        Text(trainerObj['email'], style: TypographyStyles.normalText(13, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.7) : colors.Colors().lightBlack(1),),)
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Row(
                children: [
                  Icon(Icons.phone),
                  SizedBox(width: 8),
                  Text(trainerObj['phone'])
                ],
              ),
              SizedBox(height: 8),
              Divider(),
              SizedBox(height: 16),
              Text('About', style: TypographyStyles.title(20)),
              SizedBox(height: 20),
              Text(trainerObj['trainer']['about'].toString()),
              SizedBox(height: 8),
              Visibility(
                visible: trainerObj['qualifications'].length > 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Divider(),
                    SizedBox(height: 16),
                    Text('Qualifications', style: TypographyStyles.title(20)),
                    SizedBox(height: 20),
                    Container(
                      height: trainerObj['qualifications'].length > 0 ? 100: 8,
                      width: Get.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: trainerObj['qualifications'].length,
                        itemBuilder: (_,index){
                          return Container(
                            width: Get.width*0.75,
                            margin: index == 0 ? EdgeInsets.only(left: 0) : EdgeInsets.only(left: 10),
                            decoration: BoxDecoration(
                              color: Get.isDarkMode ? AppColors.primary2Color : colors.Colors().lightCardBG,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(children: [
                                    Container(
                                      width:18,
                                      child: Image.asset("assets/images/award.png",
                                        color: isDarkMode == true ? colors.Colors().deepYellow(1) : Colors.black,
                                        fit: BoxFit.fitWidth,
                                      ),
                                    ),
                                    SizedBox(width: 15),
                                    Text(trainerObj['qualifications'][index]['title'].toString(),style: TypographyStyles.title(16))
                                  ],),
                                  SizedBox(height: 8.0),
                                  Text(trainerObj['qualifications'][index]['description'], textAlign: TextAlign.left, style: TextStyle(color: Get.isDarkMode ? Colors.grey[500] : colors.Colors().lightBlack(0.6), fontSize: 14),)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
              Divider(),
              SizedBox(height: 15,),
              Visibility(
                child: Container(
                  width: Get.width,
                  height: 56,
                  child: Obx(()=>ElevatedButton(
                    style: ButtonStyles.primaryButton(),
                    child: ready.value ? Text('Send a Request') :
                    LoadingAndEmptyWidgets.loadingWidget(),
                    onPressed: (){
                      CommonConfirmDialog.confirm('Request').then((value){
                        if(value){
                          sendRequest();
                          /*print(authUser.user['client']);
                          if(authUser.user['client']['physical_trainer_id'] == trainerObj['id']) {
                            showSnack('Invalid Choice', 'You are already under this trainer');
                          } else if(authUser.user['client']['physical_trainer_id'] != null && authUser.user['client']['diet_trainer_id'] != null){
                            showSnack('Invalid Choice', 'You have 2 trainers already');
                          } else {

                          }*/
                        }
                      });
                    },
                  )),
                ),
                visible: authUser.role == 'client',
              ),
              SizedBox(height: 8),
              Visibility(visible: trainerObj['trainer_classes'].length>0,child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("All Classes",style: TypographyStyles.title(20),),
                  Container(
                      height: trainerObj['trainer_classes'].length > 0 ? 200: 8,
                      child: ListView.builder(scrollDirection: Axis.horizontal,itemCount: trainerObj['trainer_classes'].length,itemBuilder: (BuildContext context, int index) {
                        Map cls = trainerObj['trainer_classes'][index];
                        return Container(
                          width: Get.width-40,
                          margin: EdgeInsets.only( top: 16,left: index!=trainerObj['trainer_classes'].length-1?0:16,right: 16),
                          padding: EdgeInsets.all( 16),
                          decoration: BoxDecoration(
                            color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                            borderRadius: BorderRadius.circular(10),),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(child: Text(cls['class_name'].toString().capitalizeFirst.toString(),style: TypographyStyles.title(18),overflow: TextOverflow.ellipsis,)),
                              // SizedBox(height: 10,),
                              Expanded(child: Text(cls['description'].toString().capitalizeFirst.toString(),style: TypographyStyles.text(14),overflow: TextOverflow.fade,)),
                              SizedBox(height: 10,)
                              ,Row(
                                  children:[
                                    Icon(Icons.watch_later_outlined),
                                    SizedBox(width: 10,),
                                    Text(DateFormat("yyyy-MM-dd HH:mm a").format(DateTime.parse(cls['shedule_time'])).toString(),style: TypographyStyles.text(16),),
                                  ]
                              ),
                              SizedBox(height: 10,),
                              Row(
                                  children:[
                                    Icon(Icons.location_on_outlined),
                                    SizedBox(width: 10,),
                                    Text(cls['location'].toString(),style: TypographyStyles.text(16),),
                                  ]
                              ),
                            ],
                          ),
                        );
                      },)),
                ],
              )),
              SizedBox(height: 10),
              reviewWidget(reviews, data),
            ],
          ),
        ),
      ): LoadingAndEmptyWidgets.loadingWidget()),
    );
  }
}
