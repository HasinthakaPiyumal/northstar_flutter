import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDoctors/DoctorProfile.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';

class DoctorsList extends StatelessWidget {
  const DoctorsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList doctors = [].obs;

    Future<List> searchDoctors(String pattern) async {
      Map res = await httpClient.searchDoctors(pattern);
      if (res['code'] == 200) {
        doctors.value = res['data'];
        ready.value = true;
        return [];
      } else {
        ready.value = true;
        return [];
      }
    }

    searchDoctors('');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(
          'Medical Professionals',
          style: TypographyStyles.title(20),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: TypeAheadField(
                hideOnEmpty: true,
                hideOnError: true,
                hideOnLoading: true,
                textFieldConfiguration: TextFieldConfiguration(
                    autofocus: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search,
                          color: Get.isDarkMode
                              ? AppColors.textColorDark
                              : AppColors.textColorLight),
                      labelText: 'Search Medical Professionals...',
                      labelStyle: TypographyStyles.title(16),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    )),
                suggestionsCallback: (pattern) async {
                  return await searchDoctors(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return Container();
                },
                onSuggestionSelected: (suggestion) {},
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: Obx(
                () => ready.value
                    ? doctors.length > 0
                        ? ListView.builder(
                            itemCount: doctors.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Get.to(() =>
                                      DoctorProfile(doctor: doctors[index]));
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 15),
                                  child: Container(
                                    width: 398,
                                    // height: 131,
                                    padding: const EdgeInsets.all(10),
                                    decoration: ShapeDecoration(
                                      color: Get.isDarkMode?AppColors.primary2Color:Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          child: Stack(
                                            children: [
                                              Positioned(
                                                left: 0,
                                                top: 0,
                                                child: Container(
                                                  width: 64,
                                                  height: 64,
                                                  decoration: ShapeDecoration(
                                                    image: DecorationImage(
                                                      image: CachedNetworkImageProvider(
                                                          "${HttpClient.s3BaseUrl}${doctors[index]['avatar_url']}"),
                                                      fit: BoxFit.fill,
                                                    ),
                                                    shape: OvalBorder(),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                left: 45,
                                                top: 48,
                                                child: Container(
                                                  width: 16,
                                                  height: 16,
                                                  decoration: ShapeDecoration(
                                                    color: doctors[index]
                                                            ['doctor']['online']
                                                        ? Color(0xFF05FF00)
                                                        : Color(0xFF636363),
                                                    shape: OvalBorder(),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          width: 12,
                                        ),
                                        Expanded(
                                          child: Container(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  height: 78,
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Container(
                                                        width: double.infinity,
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 10,
                                                                top: 10,
                                                                bottom: 4),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                "${doctors[index]['doctor']['speciality'].toString().capitalizeFirst}",
                                                                style:
                                                                    TextStyle(
                                                                  color: Color(
                                                                      0xFFFFB700),
                                                                  fontSize: 16,
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w700,
                                                                      overflow: TextOverflow.ellipsis
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  left: 10),
                                                          child: Text(
                                                            "Dr. ${doctors[index]['name'].toString().capitalize}",
                                                            style:
                                                                TypographyStyles
                                                                    .title(20),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4,
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10),
                                                  child: SizedBox(
                                                    child: doctors[index][
                                                                    'qualifications']
                                                                .length !=
                                                            0
                                                        ? Text(
                                                            "${doctors[index]['qualifications'][0]['title'].toString().capitalize} - ${doctors[index]['qualifications'][0]['description'].toString().capitalize}",
                                                            style: TypographyStyles
                                                                .textWithWeight(
                                                                    14,
                                                                    FontWeight
                                                                        .w300),
                                                          )
                                                        : Text(
                                                            "No Qualifications",
                                                            style: TypographyStyles
                                                                .textWithWeight(
                                                                    14,
                                                                    FontWeight
                                                                        .w300),
                                                          ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // child: Container(
                                  //   height: 150,
                                  //   child: Stack(
                                  //     children: [
                                  //       Column(
                                  //         children: [
                                  //           Flexible(
                                  //             flex: 5,
                                  //             child: Container(
                                  //               padding: EdgeInsets.symmetric(
                                  //                   horizontal: 16,
                                  //                   vertical: 2),
                                  //               decoration: BoxDecoration(
                                  //                 color: Get.isDarkMode
                                  //                     ? AppColors.primary2Color
                                  //                     : Colors.white,
                                  //                 borderRadius:
                                  //                     BorderRadius.circular(5),
                                  //               ),
                                  //             ),
                                  //           ),
                                  //         ],
                                  //       ),
                                  //       Padding(
                                  //         padding: EdgeInsets.symmetric(
                                  //             horizontal: 15),
                                  //         child: Column(
                                  //           crossAxisAlignment:
                                  //               CrossAxisAlignment.end,
                                  //           children: [
                                  //             Flexible(
                                  //                 flex: 3,
                                  //                 fit: FlexFit.tight,
                                  //                 child: Stack(
                                  //                   children: [
                                  //                     CircleAvatar(
                                  //                       radius: 36,
                                  //                       backgroundImage:
                                  //                           NetworkImage(
                                  //                         "${HttpClient.s3BaseUrl}${doctors[index]['avatar_url']}",
                                  //                         scale: 0.1,
                                  //                       ),
                                  //                     ),
                                  //                     Positioned(
                                  //                       left: -4,
                                  //                       bottom: -4,
                                  //                       child: CircleAvatar(
                                  //                         radius: 12,
                                  //                         backgroundColor: Get
                                  //                                 .isDarkMode
                                  //                             ? colors.Colors()
                                  //                                 .deepGrey(1)
                                  //                             : colors.Colors()
                                  //                                 .lightCardBG,
                                  //                         child: CircleAvatar(
                                  //                           radius: 8,
                                  //                           backgroundColor: doctors[
                                  //                                           index]
                                  //                                       [
                                  //                                       'doctor']
                                  //                                   ['online']
                                  //                               ? Colors.green
                                  //                               : Get.isDarkMode
                                  //                                   ? Colors.grey[
                                  //                                       600]
                                  //                                   : Colors.grey[
                                  //                                       400],
                                  //                         ),
                                  //                       ),
                                  //                     ),
                                  //                   ],
                                  //                 )),
                                  //             Flexible(
                                  //               flex: 4,
                                  //               child: Container(),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //       Padding(
                                  //         padding: EdgeInsets.symmetric(
                                  //             horizontal: 15),
                                  //         child: Column(
                                  //           crossAxisAlignment:
                                  //               CrossAxisAlignment.start,
                                  //           children: [
                                  //             Flexible(
                                  //               flex: 1,
                                  //               fit: FlexFit.tight,
                                  //               child: SizedBox(),
                                  //             ),
                                  //             Flexible(
                                  //               flex: 10,
                                  //               child: Padding(
                                  //                 padding:
                                  //                     EdgeInsets.only(top: 8),
                                  //                 child: Column(
                                  //                   crossAxisAlignment:
                                  //                       CrossAxisAlignment
                                  //                           .start,
                                  //                   mainAxisAlignment:
                                  //                       MainAxisAlignment
                                  //                           .center,
                                  //                   children: [
                                  //                     Text(
                                  //                       "${doctors[index]['doctor']['speciality'].toString().capitalizeFirst}",
                                  //                       style: TextStyle(
                                  //                         fontSize: 16,
                                  //                         color: Get.isDarkMode
                                  //                             ? colors.Colors()
                                  //                                 .deepYellow(1)
                                  //                             : Colors.black,
                                  //                       ),
                                  //                     ),
                                  //                     SizedBox(height: 5),
                                  //                     Text(
                                  //                         "Dr. ${doctors[index]['name'].toString().capitalize}",
                                  //                         style:
                                  //                             TypographyStyles
                                  //                                 .title(20)),
                                  //                     SizedBox(height: 15),
                                  //                     doctors[index]['qualifications']
                                  //                                 .length !=
                                  //                             0
                                  //                         ? Text(
                                  //                             "${doctors[index]['qualifications'][0]['title'].toString().capitalize} - ${doctors[index]['qualifications'][0]['description'].toString().capitalize}",
                                  //                             style: TextStyle(
                                  //                               color: Get
                                  //                                       .isDarkMode
                                  //                                   ? Colors.grey[
                                  //                                       500]
                                  //                                   : Colors.grey[
                                  //                                       700],
                                  //                             ),
                                  //                           )
                                  //                         : Text(
                                  //                             "No Qualifications",
                                  //                             style: TextStyle(
                                  //                                 color: colors
                                  //                                         .Colors()
                                  //                                     .darkGrey(
                                  //                                         1)),
                                  //                           ),
                                  //                   ],
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                ),
                              );
                            },
                          )
                        : LoadingAndEmptyWidgets.emptyWidget()
                    : LoadingAndEmptyWidgets.loadingWidget(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
