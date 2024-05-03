import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'package:url_launcher/url_launcher.dart';

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
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundImage : CachedNetworkImageProvider(HttpClient.s3BaseUrl + trainerObj['avatar_url']),
                    ),
                    SizedBox(width: 10,),
                    Text(trainerObj['name'], style: TypographyStyles.title(20)),
                    SizedBox(height: 3,),
                    Text(trainerObj['email'], style: TypographyStyles.text(16),),
                    SizedBox(height: 32),
                  ],
                ),
              ),
              Container(
                width: Get.width,
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors().getSecondaryColor(),borderRadius: BorderRadius.circular(10)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset("assets/svgs/profile-outline.svg"),
                        SizedBox(width: 10,),
                        Text('About', style: TypographyStyles.title(20)),
                      ],
                    ),
                    SizedBox(height: 20),
                    Text(trainerObj['trainer']['about'].toString()),
                    SizedBox(height: 8),
                  ],
                ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                style: Get.isDarkMode
                    ? ButtonStyles.matButton(AppColors.primary2Color, 0)
                    : ButtonStyles.matButton(Colors.white, 1),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 4,
                      ),
                      Icon(
                        Icons.phone,
                        size: 25,
                        color: Get.isDarkMode
                            ? Themes.mainThemeColorAccent.shade100
                            : colors.Colors().lightBlack(1),
                      ),
                      SizedBox(width: 13),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(trainerObj['phone'],
                              style: TypographyStyles.title(16).copyWith(
                                color: Get.isDarkMode
                                    ? Themes.mainThemeColorAccent.shade100
                                    : colors.Colors().lightBlack(1),
                              )),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            'TAP TO CALL',
                            style: TypographyStyles.normalText(
                                12, AppColors.accentColor),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                onPressed: () async {
                  final Uri launchUri = Uri(
                    scheme: 'tel',
                    path: "+${trainerObj['phone']}",
                  );
                  await launchUrl(launchUri);
                },
              ),
              
              SizedBox(height: 16),
              Visibility(
                visible: trainerObj['qualifications'].length > 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('Qualifications',
                          style: TypographyStyles.title(20)),
                    ),
                    SizedBox(height: 5),
                    Container(
                      height:
                      trainerObj['qualifications'].length > 0 ? 164 : 8,
                      width: Get.width,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: trainerObj['qualifications'].length,
                        itemBuilder: (_, index) {
                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                                width: Get.width * 0.75,
                                margin: index == 0
                                    ? EdgeInsets.only(left: 8)
                                    : EdgeInsets.only(left: 14, right: 8),
                                child: Card(
                                  color: Get.isDarkMode
                                      ? AppColors.primary2Color
                                      : Color(0xFFffffff),
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Container(
                                          width: 36,
                                          child: Image.asset(
                                            "assets/images/award_v2.png",
                                            fit: BoxFit.fitWidth,
                                          ),
                                        ),
                                        SizedBox(width: 18),
                                        Text(
                                            trainerObj['qualifications']
                                            [index]['title']
                                                .toString(),
                                            style:
                                            TypographyStyles.title(16)),
                                        SizedBox(height: 10.0),
                                        Text(
                                          trainerObj['qualifications'][index]
                                          ['description'],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              color: Get.isDarkMode
                                                  ? Colors.white
                                                  : Color(0xFF1B1F24),
                                              fontFamily: 'Poppins',
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
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
