import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart' as HttpWidget;
import 'package:north_star/Plugins/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:http/http.dart' as http;
import 'package:north_star/UI/HomeWidgets/HomeWidgetTrainers/TrainerView.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class HomeWidgetTrainers extends StatelessWidget {
  const HomeWidgetTrainers({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList trainers = [].obs;
    TextEditingController searchController = TextEditingController();

    Future<List> searchTrainers(pattern) async {
      if (pattern == "") {
        pattern = "ALL_TRAINERS";
      }
      print('PATTERN: ' + pattern);
      ready.value = false;
      var request = http.Request(
          'GET',
          Uri.parse(HttpClient.baseURL +
              '/api/trainer/search/' +
              pattern.toString()));
      print(HttpClient.baseURL);
      request.headers.addAll(client.headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200) {
        var res = jsonDecode(await response.stream.bytesToString());
        print(res);
        trainers.value = res;
        ready.value = true;
        return res;
      } else {
        var dt = jsonDecode(await response.stream.bytesToString());
        print(dt);
        ready.value = true;
        return [];
      }
    }

    searchTrainers('ALL_TRAINERS');

    return Scaffold(
      appBar: AppBar(title: Text('Trainers')),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TypeAheadField(
                      hideOnEmpty: true,
                      hideOnError: true,
                      hideOnLoading: true,
                      builder: (context, controller, focusNode) {
                        return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            autofocus: true,
                            decoration: InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                suffixIcon: IconButton(
                                  color: AppColors.accentColor,
                                  onPressed: () {
                                    searchTrainers(
                                        searchController.text ?? "ALL");
                                  },
                                  icon: Container(
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: AppColors.accentColor,
                                      ),
                                      child: SvgPicture.asset(
                                          "assets/svgs/mi_filter.svg")),
                                ),
                                labelText: 'Search Trainers...',
                                border: UnderlineInputBorder()));
                      },
                      suggestionsCallback: (pattern) async {
                        print(pattern);
                        return await searchTrainers(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return Container();
                      },
                      onSelected: (suggestion) {},
                    ),
                  ),
                ],
              )),
          Expanded(
            child: Obx(() => ready.value
                ? trainers.length != 0
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: AlignedGridView.count(
                          crossAxisCount: 1,
                          itemCount: trainers.length,
                          itemBuilder: (_, index) {
                            return Container(
                              margin: EdgeInsets.only(bottom: 20),
                              child: InkWell(
                                onTap: () {
                                  Get.to(() =>
                                      TrainerView(trainerObj: trainers[index]));
                                },
                                child: Ink(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color: Get.isDarkMode
                                          ? AppColors.primary2Color
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 32,
                                        backgroundImage:
                                            CachedNetworkImageProvider(
                                          "${HttpWidget.HttpClient.s3ResourcesBaseUrl}avatars/${trainers[index]['avatar_url']}",
                                        ),
                                      ),
                                      SizedBox(
                                        width: 20,
                                      ),
                                      Container(
                                        width: Get.width - 148,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Container(
                                                        width: trainers[index]
                                                                    ['trainer']
                                                                ['is_insured']
                                                            ? Get.width - 278
                                                            : Get.width - 220,
                                                        child: Text(
                                                          trainers[index]
                                                                  ['name']
                                                              .toString()
                                                              .capitalizeFirst
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style:
                                                              TypographyStyles
                                                                  .title(16),
                                                        )),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Visibility(
                                                      visible: trainers[index]
                                                              ['trainer']
                                                          ['is_insured'],
                                                      child: Container(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  vertical: 2,
                                                                  horizontal:
                                                                      8),
                                                          child: Text(
                                                            "INSURED",
                                                            style: TypographyStyles
                                                                .boldText(
                                                                    10,
                                                                    AppColors
                                                                        .textOnAccentColor),
                                                          ),
                                                        ),
                                                        decoration: BoxDecoration(
                                                            color: Color(
                                                                0xFF68FC80),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        50)),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.star,
                                                      color:
                                                          AppColors.accentColor,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Text(
                                                      trainers[index]['trainer']
                                                              ['rating']
                                                          .toStringAsFixed(1)
                                                          .toString(),
                                                      style: TypographyStyles
                                                          .title(16),
                                                    )
                                                  ],
                                                )
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: trainers[index][
                                                                  'qualifications']
                                                              .length !=
                                                          0
                                                      ? Text(
                                                          "${trainers[index]['qualifications'][0]['title'].toString().capitalize} - ${trainers[index]['qualifications'][0]['description'].toString().capitalize}",
                                                          style:
                                                              TypographyStyles
                                                                  .text(14),
                                                          overflow:
                                                              TextOverflow.clip,
                                                        )
                                                      : Text(
                                                          "No Qualifications",
                                                          style:
                                                              TypographyStyles
                                                                  .text(14),
                                                        ),
                                                ),
                                                Text(
                                                    "Classes: ${trainers[index]['trainer_classes'].length}")
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );

                            return InkWell(
                              onTap: () {
                                Get.to(() =>
                                    TrainerView(trainerObj: trainers[index]));
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 5, horizontal: 15),
                                child: Container(
                                  height: 160,
                                  child: Stack(
                                    children: [
                                      Column(
                                        children: [
                                          Flexible(
                                            flex: 1,
                                            child: Container(
                                              color: Colors.transparent,
                                            ),
                                          ),
                                          Flexible(
                                            flex: 5,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Get.isDarkMode
                                                    ? colors.Colors()
                                                        .deepGrey(1)
                                                    : colors.Colors()
                                                        .lightCardBG,
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              flex: 3,
                                              fit: FlexFit.tight,
                                              child: CircleAvatar(
                                                radius: 36,
                                                backgroundImage:
                                                    CachedNetworkImageProvider(
                                                  "${HttpWidget.HttpClient.s3ResourcesBaseUrl}avatars/${trainers[index]['avatar_url']}",
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              flex: 4,
                                              child: Container(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Flexible(
                                              flex: 1,
                                              fit: FlexFit.tight,
                                              child: SizedBox(),
                                            ),
                                            Flexible(
                                              flex: 4,
                                              child: Padding(
                                                padding:
                                                    EdgeInsets.only(top: 10),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Visibility(
                                                          visible: trainers[
                                                                      index]
                                                                  ['trainer']
                                                              ['is_insured'],
                                                          child: Container(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      vertical:
                                                                          2,
                                                                      horizontal:
                                                                          8),
                                                              child: Text(
                                                                "INSURED",
                                                                style: TypographyStyles
                                                                    .boldText(
                                                                        10,
                                                                        Themes
                                                                            .mainThemeColorAccent
                                                                            .shade100),
                                                              ),
                                                            ),
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .green,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            50)),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        RatingBarIndicator(
                                                          rating: double.parse(
                                                              trainers[index][
                                                                          'trainer']
                                                                      ['rating']
                                                                  .toString()),
                                                          itemBuilder: (context,
                                                                  index) =>
                                                              Icon(
                                                            Icons.star,
                                                            color:
                                                                colors.Colors()
                                                                    .deepYellow(
                                                                        1),
                                                          ),
                                                          itemCount: 5,
                                                          itemSize: 15.0,
                                                          direction:
                                                              Axis.horizontal,
                                                          unratedColor: Get
                                                                  .isDarkMode
                                                              ? colors.Colors()
                                                                  .darkGrey(1)
                                                              : Colors
                                                                  .grey[400],
                                                        ),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                        Text(
                                                          "${double.parse(trainers[index]['trainer']['rating'].toString()).toStringAsFixed(1)}",
                                                          style: TextStyle(
                                                            color: Get
                                                                    .isDarkMode
                                                                ? Themes
                                                                    .mainThemeColorAccent
                                                                    .shade100
                                                                    .withOpacity(
                                                                        0.5)
                                                                : colors.Colors()
                                                                    .lightBlack(
                                                                        1),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 20),
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                            child: Text(
                                                                "${trainers[index]['name'].toString().capitalize}",
                                                                style:
                                                                    TypographyStyles
                                                                        .title(
                                                                            20))),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    trainers[index]['qualifications']
                                                                .length !=
                                                            0
                                                        ? Text(
                                                            "${trainers[index]['qualifications'][0]['title'].toString().capitalize} - ${trainers[index]['qualifications'][0]['description'].toString().capitalize}",
                                                            style: TextStyle(
                                                              color: Get
                                                                      .isDarkMode
                                                                  ? Colors
                                                                      .grey[500]
                                                                  : colors.Colors()
                                                                      .lightBlack(
                                                                          1),
                                                            ),
                                                          )
                                                        : Text(
                                                            "No Qualifications",
                                                            style: TextStyle(
                                                              color: Get
                                                                      .isDarkMode
                                                                  ? Themes
                                                                      .mainThemeColorAccent
                                                                      .shade100
                                                                      .withOpacity(
                                                                          0.3)
                                                                  : colors.Colors()
                                                                      .lightBlack(
                                                                          0.5),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text('No Trainers Found'),
                      )
                : Center(child: CircularProgressIndicator())),
          )
        ],
      ),
    );
  }
}
