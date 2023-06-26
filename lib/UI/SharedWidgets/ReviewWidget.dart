import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

Widget reviewWidget(Map reviews, RxMap data) {
  return Column(
    children: [
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            Text('Review Summary', style: TypographyStyles.title(20)),
          ],
        ),
      ),
      SizedBox(height: 20),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 8),
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
                      width: Get.width / 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.2) : colors.Colors().lightCardBG,
                          value: reviews['5'] / reviews['all'],
                          minHeight: 6,
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
                      width: Get.width / 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.2) : colors.Colors().lightCardBG,
                          value: reviews['4'] / reviews['all'],
                          minHeight: 6,
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
                      width: Get.width / 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.2) : colors.Colors().lightCardBG,
                          value: reviews['3'] / reviews['all'],
                          minHeight: 6,
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
                      width: Get.width / 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.2) : colors.Colors().lightCardBG,
                          value: reviews['2'] / reviews['all'],
                          minHeight: 6,
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
                      width: Get.width / 2,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: LinearProgressIndicator(
                          backgroundColor: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.2) : colors.Colors().lightCardBG,
                          value: reviews['1'] / reviews['all'],
                          minHeight: 6,
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
              padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Column(
                children: [
                  Text(
                    '${data['trainer']['rating'].toStringAsFixed(1)}',
                    style: TypographyStyles.boldText(30, Get.isDarkMode ? Colors.white : colors.Colors().lightBlack(1)),
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
                    itemSize: 15.0,
                    direction: Axis.horizontal,
                    unratedColor: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    "${data['trainer']['rating_count']} reviews",
                    style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.6) : colors.Colors().lightBlack(1)),
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
          return Padding(
            padding: EdgeInsets.fromLTRB(8, 20, 8, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage : CachedNetworkImageProvider(HttpClient.s3BaseUrl + data.value['avatar_url']),
                    ),
                  ],
                ),
                SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text( reviews['reviews'][index]['reviewer']['name'],
                            style: TypographyStyles.boldText(16, Get.isDarkMode ? Colors.white : colors.Colors().lightBlack(1)),
                          ),
                          RatingBarIndicator(
                            rating: double.parse(reviews['reviews'][index]['rating'].toString()),
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: colors.Colors().deepYellow(1),
                            ),
                            itemCount: 5,
                            itemSize: 15.0,
                            direction: Axis.horizontal,
                            unratedColor: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(reviews['reviews'][index]['comment'],
                        style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade500.withOpacity(0.6) : colors.Colors().lightBlack(0.6)),
                      ),
                    ],
                  ),
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
