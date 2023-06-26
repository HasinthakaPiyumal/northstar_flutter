import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_currency_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/GymView.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetPro.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class HomeWidgetProActive extends StatelessWidget{

  const HomeWidgetProActive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxBool ready = false.obs;
    RxMap subData = {}.obs;
    RxList myBookings = [].obs;
    DateFormat tmFormat = DateFormat('hh:mm a');

    void getMyComGymBookings() async {
      Map res = await httpClient.getComGymSchedules();
      if (res['code'] == 200) {
        myBookings.addAll(res['data']);
      }
    }

    void getMyGymBookings() async {
      Map res = await httpClient.getExclusiveGymSchedules();
      if (res['code'] == 200) {
        myBookings.value = res['data'];
      }
      getMyComGymBookings();
    }

    void getMe() async{
      ready.value = false;
      Map res = await httpClient.getMyProfile();
      print(res);
      if (res['code'] == 200) {
        subData.value = res['data']['subscription'];
        print(subData);
        if (authUser.role == 'client'){
          authUser.saveUser(res['data']['user']);
        } else {
          authUser.saveUser(res['data']);
        }
      } else {
        print(res);
        showSnack('Something went wrong!', 'Please contact support.');
      }
      ready.value = true;
    }

    String getDaysRemaining(String expiry){
      Duration difference = DateTime.parse(expiry).difference(DateTime.now());
      int days = difference.inDays;
      return days.toString();
    }

    void showInfo(Map data){

      Get.defaultDialog(
          title: '${data['client_ids'].length} Member(s) Have Access',
          titlePadding: EdgeInsets.only(top: 20),
          radius: 8,
          content: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Container(
                  height: 256,
                  width: Get.width,
                  child: ListView.builder(
                    itemCount: data['clients'].length,
                    itemBuilder: (context,index){
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              HttpClient.s3BaseUrl + data['clients'][index]['user']['avatar_url']
                          ),
                        ),
                        title: Text(data['clients'][index]['user']['name']),
                        subtitle: Text(data['clients'][index]['user']['email']),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: ()=>Get.back(), child: Text('Close'))
          ]
      );
    }

    getMyGymBookings();

    getMe();

    return Scaffold(
      appBar: AppBar(
        title: Text('Pro Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(()=> ready.value ? SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 5),
              Card(
                color: Get.isDarkMode ? colors.Colors().lightBlack(1) : colors.Colors().selectedCardBG,
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("My Pro Plan",
                            style: TypographyStyles.boldText(18, Get.isDarkMode ? Colors.white : Colors.black),
                          ),
                          Text(authUser.user['subscription']['is_active'] == true ? "Active" : "Inactive",
                            style: TypographyStyles.boldText(16,
                              authUser.user['subscription']['is_active'] == true ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 55,),
                      SizedBox(
                        height: 10,
                        width: Get.width,
                        child: Stack(
                          children: [
                            Container(
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: colors.Colors().deepGrey(1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                            Container(
                              width: (Get.width - 56)/100*((DateTime.parse(authUser.user['subscription']['valid_till']).difference(DateTime.now()).inDays)/(DateTime.parse(authUser.user['subscription']['valid_till']).difference(DateTime.parse(authUser.user['subscription']['updated_at'])).inDays)*100),
                              decoration: BoxDecoration(
                                color: colors.Colors().deepYellow(1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(getDaysRemaining(authUser.user['subscription']['valid_till']) +' days left', style: TypographyStyles.title(18)),
                              SizedBox(height: 5,),
                              Text('valid until : ' + DateFormat("dd MMM, yyyy").format(DateTime.parse(authUser.user['subscription']['valid_till'])),
                                style: TypographyStyles.normalText(14, Get.isDarkMode ? colors.Colors().lightWhite(0.6) : colors.Colors().lightBlack(1)),
                              ),
                            ],
                          ),
                          MaterialButton(
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            color: colors.Colors().deepYellow(1),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Text(
                                'Extend Package',
                                textAlign: TextAlign.left,
                                style: TypographyStyles.boldText(14, Colors.white),
                              ),
                            ),
                            onPressed: () async {
                              Get.to(()=>HomeWidgetPro(extend: true));
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),

              myBookings.length > 0 ? SizedBox(height: 15,) : SizedBox(),

              myBookings.length > 0 ? Text("Gym Bookings",
                style: TypographyStyles.boldText(20, Get.isDarkMode ? colors.Colors().lightWhite(0.6) : colors.Colors().lightBlack(1)),
              ) : SizedBox(),

              myBookings.length > 0 ? SizedBox(height: 15,) : SizedBox(),

              myBookings.length > 0 ? ListView.separated(
                shrinkWrap: true,
                itemCount: myBookings.length,
                physics: NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) {
                  return SizedBox(height: 10,);
                },
                itemBuilder: (context, index) {
                  if (myBookings[index]['type'] != null) {
                    DateTime selectedDateForEquation;

                    int daysDif = DateTime.parse(myBookings[index]['start_date']).difference(DateTime.now()).inDays;

                    if (daysDif > 0) {
                      selectedDateForEquation = DateTime.parse(myBookings[index]['start_date']);
                    } else {
                      selectedDateForEquation = DateTime.now();
                    }

                    int endAndTodayDif = DateTime.parse(myBookings[index]['end_date']).difference(DateTime.now()).inDays;
                    int endAndStartDif = DateTime.parse(myBookings[index]['end_date']).difference(selectedDateForEquation).inDays;

                    return InkWell(
                      onTap: () {
                        Get.to(()=>HomeWidgetGym());
                        // Get.to(() => GymView(
                        //   gymObj: myBookings[index]['gym_data'],
                        //   viewOnly: true,
                        // ));
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        color: Get.isDarkMode ? colors.Colors().lightBlack(1) : colors.Colors().selectedCardBG,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundImage:
                                    CachedNetworkImageProvider(HttpClient.s3BaseUrl + myBookings[index]['gym']['avatar_url']),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        myBookings[index]['gym_data']['gym_name'],
                                        style: TypographyStyles.boldText(20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                      ),
                                      Text(
                                        "${CountryPickerUtils.getCountryByIsoCode(myBookings[index]['gym_data']['gym_country']).name}",
                                        style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20,),

                              SizedBox(
                                height: 10,
                                width: Get.width,
                                child: Stack(
                                  children: [
                                    Container(
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        color: colors.Colors().deepGrey(1),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                    Container(
                                      width: (Get.width - 56)/100*(endAndTodayDif/endAndStartDif)*100,
                                      decoration: BoxDecoration(
                                        color: colors.Colors().deepYellow(1),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10,),

                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "${DateTime.parse(myBookings[index]['end_date']).difference(selectedDateForEquation).inDays} Day(s) Remaining",
                                        style: TypographyStyles.boldText(15, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        DateFormat("MMM dd,yyyy").format(DateTime.parse(myBookings[index]['start_date'])) + ' - ' + DateFormat("MMM dd,yyyy").format(DateTime.parse(myBookings[index]['end_date'])),
                                        style: TypographyStyles.normalText(14, Get.isDarkMode ? colors.Colors().lightWhite(0.6) : colors.Colors().lightBlack(1)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else {
                    return InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        Get.to(() => GymView(gymObj: myBookings[index]['gym_data'], viewOnly: true,),);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        color: Get.isDarkMode ? colors.Colors().lightBlack(1) : colors.Colors().selectedCardBG,
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircleAvatar(
                                    radius: 26,
                                    backgroundImage:
                                    CachedNetworkImageProvider(HttpClient.s3BaseUrl + myBookings[index]['gym']['avatar_url']),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        myBookings[index]['gym_data']['gym_name'],
                                        style: TypographyStyles.boldText(20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                      ),
                                      Text(
                                        "${CountryPickerUtils.getCountryByIsoCode(myBookings[index]['gym_data']['gym_country']).name}",
                                        style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 15,),
                              Divider(
                                thickness: 1,
                                color: Get.isDarkMode ? Colors.grey[700] : Colors.grey[400],
                              ),
                              SizedBox(height: 5,),
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        DateFormat("EEEE, MMM dd,yyyy")
                                            .format(DateTime.parse(myBookings[index]['start_time']))
                                            .toString(),
                                        style: TypographyStyles.boldText(15, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        tmFormat.format(DateTime.parse(myBookings[index]['start_time'])) +
                                            ' - ' +
                                            tmFormat.format(DateTime.parse(myBookings[index]['end_time'])),
                                        style: TypographyStyles.normalText(14, Get.isDarkMode ? colors.Colors().lightWhite(0.6) : colors.Colors().lightBlack(1)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                },
              ) : SizedBox(),
            ],
          ),
        ) : Center(
          child: LoadingAndEmptyWidgets.loadingWidget(),
      ))
      ),

    );
  }
}
