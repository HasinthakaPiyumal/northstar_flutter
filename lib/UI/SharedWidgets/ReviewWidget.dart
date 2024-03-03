import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

Widget reviewWidget(Map reviews, RxMap data) {
  print('===reviews');
  print(reviews);
  return Column(
    children: [
      Row(
        children: [
          Text('Review Summary', style: TypographyStyles.title(20)),
        ],
      ),
      SizedBox(height: 20),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    Text('5',
                      style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1)),
                    ),
                    SizedBox(width: 10),
                    Container(
                      width: Get.width *0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightCardBG,
                          value: reviews['5'] / reviews['all'],
                          minHeight: 8,
                          valueColor: AlwaysStoppedAnimation<Color>(Themes.mainThemeColor.shade500),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Text('4',
                      style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: Get.width *0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightCardBG,
                          value: reviews['4'] / reviews['all'],
                          minHeight: 8,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Themes.mainThemeColor.shade500),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Text('3',
                      style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: Get.width *0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightCardBG,
                          value: reviews['3'] / reviews['all'],
                          minHeight: 8,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Themes.mainThemeColor.shade500),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Text('2',
                      style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: Get.width *0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightCardBG,
                          value: reviews['2'] / reviews['all'],
                          minHeight: 8,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Themes.mainThemeColor.shade500),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Text('1',
                      style: TypographyStyles.normalText(14,Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(1)),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Container(
                      width: Get.width *0.4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().lightCardBG,
                          value: reviews['1'] / reviews['all'],
                          minHeight: 8,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Themes.mainThemeColor.shade500),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 42, 0),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: ShapeDecoration(
                              color: Color(0xFFFFB700),
                              shape: OvalBorder(),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            '${data['trainer']['rating'].toStringAsFixed(1)}',
                            style: TypographyStyles.textWithWeight(16, FontWeight.w400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  RatingBarIndicator(
                    rating: double.parse(data['trainer']['rating'].toString()),
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: colors.Colors().deepYellow(1),
                    ),
                    itemCount: 5,
                    itemSize: 16.0,
                    direction: Axis.horizontal,
                    unratedColor: Get.isDarkMode ? Colors.white : colors.Colors().selectedCardBG,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "${data['trainer']['rating_count']} reviews",
                    style: TypographyStyles.textWithWeight(14, FontWeight.w400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      SizedBox(height: 20),
      ListView.builder(
        itemCount: reviews['reviews'].length,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (_,index){
          return Container(
            decoration: ShapeDecoration(
              color: Get.isDarkMode ?Color(0xFF1E2630):Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            padding: EdgeInsets.all(10.0),
            margin: EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage : CachedNetworkImageProvider(HttpClient.s3BaseUrl + reviews['reviews'][index]['reviewer']['avatar_url']),
                    ),
                    SizedBox(width: 10,),
                    Text( reviews['reviews'][index]['reviewer']['name'],
                      style: TypographyStyles.textWithWeight(16,  FontWeight.w500),
                    )
                  ],
                ),
                SizedBox(height:20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [

                        RatingBarIndicator(
                          rating: double.parse(reviews['reviews'][index]['rating'].toString()),
                          itemBuilder: (context, index) => Icon(
                            Icons.star,
                            color: colors.Colors().deepYellow(1),
                          ),
                          itemCount: 5,
                          itemSize: 24.0,
                          direction: Axis.horizontal,
                          unratedColor: Get.isDarkMode ? Colors.white : colors.Colors().selectedCardBG,
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(reviews['reviews'][index]['comment'],
                      style: TypographyStyles.textWithWeight(12,FontWeight.w300 ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      SizedBox(height: 20),
    ],
  );
}
