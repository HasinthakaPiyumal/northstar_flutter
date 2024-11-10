import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Members/UserView_Bio.dart';
import 'package:north_star/UI/Members/UserView_Diet.dart';
import 'package:north_star/UI/Members/UserView_Health.dart';
import 'package:north_star/UI/Members/UserView_Progress.dart';
import 'package:north_star/UI/PrivateTrainer/TrainerHealth_Bio.dart';
import 'package:north_star/UI/PrivateTrainer/TrainerHealth_Health.dart';
import 'package:north_star/UI/PrivateTrainer/TrainerHealth_Progress.dart';

class TrainerHealth extends StatelessWidget {
  const TrainerHealth({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {

    int userID = authUser.id;
    var data = {};
    RxBool ready = false.obs;
    RxBool complete = false.obs;
    RxString viewUser = 'client'.obs;

    void getData() async {
      Map res = await httpClient.getOneUser(userID.toString());
      print(res);
      if (res['code'] == 200) {
        data = res['data'];
        print('User View data--->$data');
        print('id data type--->${data['user']['id'].runtimeType}');
        viewUser.value = data['user']['client']!=null?'client':'trainer';
        complete.value = data['user'][viewUser]['is_complete'] == 1;
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    getData();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        toolbarHeight: 150,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Obx(
          () => ready.value
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: CachedNetworkImageProvider(
                        HttpClient.s3BaseUrl + data['user']['avatar_url'],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      data['user']['name'],
                      style: TypographyStyles.title(20),
                    ),
                    Text(
                      data['user']['email'].toString(),
                      style:
                          TypographyStyles.textWithWeight(13, FontWeight.w300),
                    ),
                    data['user'][viewUser]['health_conditions'] != null
                        ? Text(
                            'Has ' +
                                data['user'][viewUser]['health_conditions']
                                    .length
                                    .toString() +
                                ' Health Conditions',
                            style: TypographyStyles.text(14),
                          )
                        : Container(),
                  ],
                )
              : SizedBox(),
        ),
      ),
      body: DefaultTabController(
        length: 4,
        initialIndex: 0,
        child: Obx(
          () => ready.value
              ? Column(
                  children: [
                    Visibility(
                      visible: !complete.value,
                      child: SizedBox(
                        height: 15,
                      ),
                    ),
                    // Visibility(
                    //   visible: !complete.value,
                    //   child: Container(
                    //     width: Get.width,
                    //     color: Themes.mainThemeColor.shade500.withOpacity(0.2),
                    //     child: Padding(
                    //       padding: EdgeInsets.symmetric(vertical: 15),
                    //       child: Column(
                    //         mainAxisSize: MainAxisSize.min,
                    //         crossAxisAlignment: CrossAxisAlignment.center,
                    //         mainAxisAlignment: MainAxisAlignment.center,
                    //         children: [
                    //           Row(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Text(
                    //                 "INCOMPLETE DETAILS",
                    //                 style: TypographyStyles.boldText(
                    //                     16, Themes.mainThemeColor.shade500),
                    //               ),
                    //               SizedBox(
                    //                 width: 5,
                    //               ),
                    //               Icon(
                    //                 Icons.warning,
                    //                 size: 20,
                    //                 color: Themes.mainThemeColor.shade500,
                    //               ),
                    //             ],
                    //           ),
                    //           SizedBox(
                    //             height: 5,
                    //           ),
                    //           Text(
                    //             "You have not yet completed your health\ncondition details",
                    //             style: TypographyStyles.normalText(
                    //                 14, Themes.mainThemeColor.shade500),
                    //             textAlign: TextAlign.center,
                    //           )
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      height: 10,
                    ),
                    TabBar(
                      indicatorColor: Themes.mainThemeColor,
                      labelStyle: TextStyle(fontWeight: FontWeight.bold),
                      tabs: [
                        Tab(
                          child: Text("Health"),
                        ),
                        Tab(
                          child: Text(
                            "Bio",
                          ),
                        ),
                        Tab(
                          child: Text(
                            "Reports",
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        children: [
                          TrainerHealthView(userID: data['user']['id'],data: data['user']),
                          TrainerHealthBio(data: data['user']),
                          TrainerHealthProgress(userId: data['user']['id']),
                        ],
                      ),
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}
