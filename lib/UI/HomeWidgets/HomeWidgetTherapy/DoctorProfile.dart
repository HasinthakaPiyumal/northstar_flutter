import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDoctors/ScheduleForClient.dart';

import 'ScheduleForMe.dart';

class DoctorProfile extends StatelessWidget {
  const DoctorProfile({Key? key, this.doctor}) : super(key: key);

  final doctor;

  @override
  Widget build(BuildContext context) {
    if(doctor['qualifications'].length ==0){
      doctor['qualifications'].add({"title":"No Qualification Found","description":""});
    }
    void showSelection() {
      Get.defaultDialog(
        radius: 10,
        titlePadding: EdgeInsets.only(top: 20),
        contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 10),
        title: 'Channel for',
        titleStyle: TypographyStyles.title(20),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        content: Container(
          width: Get.width - 20,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ButtonStyles.matRadButton(AppColors.accentColor, 5, 5),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      'ME',
                      style: TextStyle(
                        color: Color(0xFF1B1F24),
                        fontSize: 20,
                        fontFamily: 'Bebas Neue',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    Get.to(() => ScheduleForMe(doctor: doctor));
                  },
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Visibility(
                child: Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(width: 2, color: Color(0xFFFFB700)),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        'CLIENT',
                        style: TypographyStyles.smallBoldTitle(20),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.to(() => ScheduleForClient(doctor: doctor));
                    },
                  ),
                ),
                visible: authUser.role == 'trainer',
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Channel Physiotherapy',
          style: TypographyStyles.title(20),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            Container(
              width: 378,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: CachedNetworkImageProvider(
                            "${HttpClient.s3BaseUrl}${doctor['avatar_url']}"),
                        fit: BoxFit.fill,
                      ),
                      shape: OvalBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 378,
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            doctor['doctor']['title'] + ' ' + doctor['name'],
                            textAlign: TextAlign.center,
                            style: TypographyStyles.title(20),
                          ),
                        ),
                        Container(
                          height: 44,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.only(top: 4, bottom: 10),
                                child: Text(
                                  doctor['doctor']['speciality'],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFFFFB700),
                                    fontSize: 16,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // ListTile(
            //   shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(8.0),
            //   ),
            //   leading: CircleAvatar(
            //     radius: 32,
            //     backgroundImage: CachedNetworkImageProvider(
            //         "${HttpClient.s3BaseUrl}${doctor['avatar_url']}"),
            //   ),
            //   title: Text(doctor['doctor']['title'] + ' ' + doctor['name'],
            //       overflow: TextOverflow.clip,
            //       maxLines: 1,
            //       style: TypographyStyles.boldText(
            //         20,
            //         Get.isDarkMode
            //             ? Themes.mainThemeColorAccent.shade100
            //             : colors.Colors().lightBlack(1),
            //       )),
            //   subtitle: Padding(
            //     padding: EdgeInsets.only(top: 10),
            //     child: Text(doctor['doctor']['speciality']),
            //   ),
            // ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Location',
                        style: TypographyStyles.title(20),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 12),
            Container(
              width: Get.width-32,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(color:AppColors.primary2Color,borderRadius: BorderRadius.circular(10)),
              child:Text('No: 123 road,\nmain street,\nhulhumale maldives.',textAlign: TextAlign.start,style:TypographyStyles.text(12))
            ),

            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Qualifications',
                        style: TypographyStyles.title(20),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                height: doctor['qualifications'].length > 0 ? 180 : 8,
                // width: Get.width-32,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: doctor['qualifications'].length,
                  itemBuilder: (_, index) {
                    return Container(
                      width: Get.width-32,
                      margin: EdgeInsets.only(bottom: 10,right: index+1==doctor['qualifications'].length?0:16.0),
                      decoration: BoxDecoration(
                        color: Get.isDarkMode
                            ? AppColors.primary2Color
                            : AppColors.baseColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 36,
                              child: Image.asset(
                                "assets/images/award_v2.png",
                                fit: BoxFit.fitWidth,
                              ),
                            ),
                            SizedBox(height: 10.0),
                            Text(
                                doctor['qualifications'][index]['title']
                                    .toString(),
                                style: TypographyStyles.title(16)),
                            SizedBox(height: 8.0),
                            Text(
                              doctor['qualifications'][index]['description'],
                              textAlign: TextAlign.center,
                              style: TypographyStyles.textWithWeight(12, FontWeight.w300),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Available Times',
                        style: TypographyStyles.title(20),
                      ),
                    ],
                  )
                ],
              ),
            ),
            Container(
              width: 398,
              // height: 388,
              padding: const EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
              decoration: ShapeDecoration(
                color: Color(0xFF1E2630),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(7, (index) {
                  // Define the day of the week and time for each day
                  String dayOfWeek = '';
                  String time = '';
                  double sizedHeight = 28;

                  // Set the values based on the index (0 for Monday, 1 for Tuesday, etc.)
                  switch (index) {
                    case 0:
                      dayOfWeek = 'Monday';
                      time = ': 8.00 PM - 5.00 PM';
                      break;
                    case 1:
                      dayOfWeek = 'Tuesday';
                      time = ': 8.00 PM - 5.00 PM';
                      break;
                    case 2:
                      dayOfWeek = 'Wednesday';
                      time = ': 8.00 PM - 5.00 PM';
                      break;
                    case 3:
                      dayOfWeek = 'Thursday';
                      time = ': 8.00 PM - 5.00 PM';
                      break;
                    case 4:
                      dayOfWeek = 'Friday';
                      time = ': 8.00 PM - 5.00 PM';
                      break;
                    case 5:
                      dayOfWeek = 'Saturday';
                      time = ': 8.00 PM - 5.00 PM';
                      break;
                    case 6:
                      dayOfWeek = 'Sunday';
                      time = ': 8.00 PM - 5.00 PM';
                      sizedHeight = 0;
                      break;
                  }

                  // Create the widget for each day
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            dayOfWeek,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: sizedHeight),
                    ],
                  );
                }),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        child: Container(
          child: Container(
            width: Get.width,
            height: 44,
            child: ElevatedButton(
              style: ButtonStyles.bigFlatYellowButton(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.video_call_outlined,
                    color: AppColors.textColorLight,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'channel',
                    style: TextStyle(
                      color: AppColors.textColorLight,
                      fontSize: 20,
                      fontFamily: 'Bebas Neue',
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
              onPressed: () {
                Get.to(() => ScheduleForMe(doctor: doctor));
              },
            ),
          ),
        ),
      ),
    );
  }
}
