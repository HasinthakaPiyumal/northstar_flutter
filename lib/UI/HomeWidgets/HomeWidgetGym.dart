import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_currency_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/CommercialGyms.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/ExclusiveGyms.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/GymView.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/UnlockDoorQR.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class HomeWidgetGym extends StatelessWidget {
  const HomeWidgetGym({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList myBookings = [].obs;
    DateFormat tmFormat = DateFormat('hh:mm a');

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

    getMyGymBookings();



    return Scaffold(
      appBar: AppBar(title: Text('Facilities')),
      body: Obx(() => Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Visibility(
                      child: Container(
                        height: 80,
                        child: ElevatedButton(
                          style: Get.isDarkMode ? ButtonStyles.bigBlackButton() : ButtonStyles.matButton(colors.Colors().selectedCardBG, 1),
                          onPressed: () {
                            Get.to(() => ExclusiveGyms());
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hotel_class,
                                color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                              ),
                              SizedBox(width: 8),
                              Text('Exclusive Gyms',
                                style: TextStyle(
                                  color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      visible: authUser.role != 'client',
                    ),
                    SizedBox(height: 15),
                    Container(
                      height: 80,
                      child: ElevatedButton(
                        style: Get.isDarkMode ? ButtonStyles.bigBlackButton() : ButtonStyles.matButton(colors.Colors().selectedCardBG, 1),
                        onPressed: () {
                          Get.to(() => CommercialGyms());
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.business,
                              color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                            ),
                            SizedBox(width: 8),
                            Text('Commercial Gyms',
                              style: TextStyle(
                                color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                SizedBox(height: 8),
                Divider(
                  thickness: 1,
                ),
                SizedBox(height: 8),
                Text('My Bookings', style: TypographyStyles.title(20)),
                SizedBox(height: 8),
                Expanded(
                  child: myBookings.length > 0 ? ListView.builder(
                          itemCount: myBookings.length,
                          itemBuilder: (_, index) {
                            if (myBookings[index]['type'] != null) {
                              DateTime selectedDateForEquation;

                              int daysDif = DateTime.parse(myBookings[index]['start_date']).difference(DateTime.now()).inDays;

                              if (daysDif > 0) {
                                selectedDateForEquation = DateTime.parse(myBookings[index]['start_date']);
                              } else {
                                selectedDateForEquation = DateTime.now();
                              }

                              return Card(
                                margin: EdgeInsets.only(bottom: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().selectedCardBG,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
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
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Divider(
                                                  thickness: 1,
                                                  color: Colors.grey[700],
                                                ),
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
                                                          DateFormat("MMM dd,yyyy").format(DateTime.parse(myBookings[index]['start_date'])) +
                                                              ' - ' +
                                                              DateFormat("MMM dd,yyyy").format(DateTime.parse(myBookings[index]['end_date'])),
                                                          style: TypographyStyles.normalText(13, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            onTap: () {
                                              Get.to(() => GymView(
                                                gymObj: myBookings[index]['gym_data'],
                                                viewOnly: true,
                                              ));
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 20,
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              height: 90,
                                              child: ElevatedButton(
                                                style: ButtonStyles.bigFlatBlackButton(),
                                                onPressed: () {
                                                  //unlockGym(myBookings[index]['gym_id']);
                                                  Get.to(() => UnlockDoorQR(gymID: myBookings[index]['gym_id']));
                                                },
                                                child: Image.asset(
                                                  "assets/images/unlock.png",
                                                  height: 60,
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: authUser.role == 'trainer' && myBookings[index]['gym_data']['gym_type'] != 'normal',
                                              child: Container(
                                                child: ElevatedButton(
                                                  style: ButtonStyles.bigFlatBlackButton(),
                                                  child: Text('Info'),
                                                  onPressed: (){
                                                    showInfo(myBookings[index]);
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        )
                                      ],
                                    )),
                              );
                            } else {
                              return Card(
                                margin: EdgeInsets.only(bottom: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                child: Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().selectedCardBG,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: InkWell(
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
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Divider(
                                                  thickness: 1,
                                                  color: Get.isDarkMode ? Colors.grey[700] : Colors.grey[400],
                                                ),
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
                                                          style: TypographyStyles.normalText(13, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(8),
                                            onTap: () {
                                              Get.to(() => GymView(
                                                    gymObj: myBookings[index]['gym_data'],
                                                    viewOnly: true,
                                                  ));
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              height: 90,
                                              child: ElevatedButton(
                                                style: ButtonStyles.bigFlatBlackButton(),
                                                onPressed: () {
                                                  //unlockGym(myBookings[index]['gym_id']);
                                                  Get.to(() => UnlockDoorQR(gymID: myBookings[index]['gym_id']));
                                                },
                                                child: Image.asset(
                                                  "assets/images/unlock.png",
                                                  height: 60,
                                                  fit: BoxFit.fitHeight,
                                                ),
                                              ),
                                            ),
                                            Visibility(
                                              visible: authUser.role == 'trainer',
                                              child: Container(
                                                child: ElevatedButton(
                                                  style: ButtonStyles.bigFlatBlackButton(),
                                                  child: Text('Info'),
                                                  onPressed: (){
                                                    showInfo(myBookings[index]);
                                                  },
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    )),
                              );
                            }
                          },
                        )
                      : Center(
                          child: Text(
                          'No Bookings Yet.',
                          style: TypographyStyles.normalText(15, Themes.mainThemeColorAccent.shade300),
                        )),
                )
              ],
            ),
          )),
    );
  }
}
