import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/ServiceBooking.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/ServiceBooking/GymDateAndTime.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/ServiceBooking/SelectGymBookingDates.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';

import '../../../components/Buttons.dart';
import 'ServiceBooking/PickDate.dart';

class BookNowServices extends StatelessWidget {
  const BookNowServices({Key? key, this.gymObj}) : super(key: key);
  final gymObj;

  @override
  Widget build(BuildContext context) {
    RxList selectedMembers = [].obs;

    Future<List> searchMembers(pattern) async {
      Map res = await httpClient.searchMembers(pattern);
      if (res['code'] == 200) {
        return res['data'];
      } else {
        return [];
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Now'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 15),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: CachedNetworkImageProvider(
                      HttpClient.s3BaseUrl + gymObj['user']['avatar_url'],
                    ),
                  ),
                  SizedBox(width: 16,),
                  Text(gymObj['gym_name'], style: TypographyStyles.text(16)),
                  SizedBox(height: 5,),
                  Text("${gymObj['gym_city']}, ${gymObj['gym_country']}",
                    style: TypographyStyles.text(14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Row(
              children: [
                Text('ADD A MEMBER', style: TypographyStyles.title(14)),
              ],
            ),
            SizedBox(height: 16),
            TypeAheadField(
        builder: (context, controller, focusNode){
      return TextField(
          controller: controller,
          focusNode: focusNode,
          autofocus: true,
                  decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'Search Members...',
                border: UnderlineInputBorder(),
              ));},
              suggestionsCallback: (pattern) async {
                print(pattern);
                return await searchMembers(pattern);
              },
              itemBuilder: (context, suggestion) {
                var jsonObj = jsonDecode(jsonEncode(suggestion));

                return ListTile(
                  title: Text(jsonObj['user']['name']),
                  subtitle: Text(jsonObj['user']['email']),
                );
              },
              onSelected: (suggestion) {
                var jsonObj = jsonDecode(jsonEncode(suggestion));
                var already = selectedMembers.firstWhereOrNull(
                    (element) => element['user_id'] == jsonObj['user_id']);
                if (already == null) {
                  // selectedMembers.clear();
                  selectedMembers.value = RxList([jsonObj]);
                  print(jsonObj);
                } else {
                  print('already added');
                }
              },
            ),
            SizedBox(
              height: 20,
            ),
            Obx(() => Expanded(
                  child: ListView.builder(
                    itemCount: selectedMembers.length,
                    itemBuilder: (_, index) {
                      return Container(
                        margin: EdgeInsets.only(top: 10),
                        padding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                        decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? AppColors.primary2Color
                                : Colors.white,
                            borderRadius: BorderRadius.circular(10)),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: CachedNetworkImageProvider(
                                    "${HttpClient.s3BaseUrl + selectedMembers[index]['user']['avatar_url']}",
                                  ),
                                ),
                                SizedBox(
                                  width: 20,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      selectedMembers[index]['user']['name'],
                                      style: TypographyStyles.boldText(
                                          18,
                                          Get.isDarkMode
                                              ? Color(0xffF1F1F1)
                                              : Color(0xff101010)),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      selectedMembers[index]['user']['email'],
                                      style: TypographyStyles.normalText(15,
                                          Themes.mainThemeColorAccent.shade300),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            IconButton(
                              icon:  Container(
                                  decoration: BoxDecoration(color: Get.isDarkMode?Colors.white:Colors.black,borderRadius: BorderRadius.circular(100)),
                                  child: Icon(Icons.close,color: Get.isDarkMode?Colors.black:Colors.white,)),
                              onPressed: () {
                                selectedMembers.removeAt(index);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                )),
            SizedBox(
              height: 15,
            ),
            Container(
              width: Get.width,
              child: Buttons.yellowFlatButton(
                label: 'continue',
                onPressed: () {
                  print(selectedMembers);
                  List<int> selectedMemberIds = List.generate(
                      selectedMembers.length,
                      (index) => selectedMembers[index]['user_id']);
                  if(selectedMemberIds.length>0){
                    Get.to(() => AddBooking(
                        gymObj: gymObj, clientIds: selectedMemberIds,));
                    // Get.to(() => SelectGymBookingDates(
                    //     gymObj: gymObj, clientIds: selectedMemberIds));
                  }else{
                    showSnack('No Members are Selected!', 'Please select at least one member' );
                  }


                  /* Get.to(()=>GymTimeAndPay(
                    gymObj: gymObj,
                    clientIds: selectedMemberIds,
                  ));*/
                  /*if(selectedMemberIds.length > 0){
                    Get.to(()=>GymTimeAndPay(
                      gymObj: gymObj,
                      clientIds: selectedMemberIds,
                    ));
                  } else {
                    showSnack('No Members are Selected!', 'Please select at least one member' );
                  }*/
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
