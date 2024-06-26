import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';


class CallHistory extends StatelessWidget {
  const CallHistory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList callHistory = [].obs;

    Future<void> getCallHistory() async {
      print('call hsitory');
      Map res = await httpClient.getCallHistory();
      print('call hsitory');
      if (res['code'] == 200) {
        callHistory.value = res['data'];
        print('call history');
        print(res['data']);
      }
      else print(res);

    }
    String formatSecondsToMinSize(int seconds) {
      int minutes = seconds ~/ 60;
      int remainingSeconds = seconds % 60;

      if (minutes == 0) {
        return "$remainingSeconds sec";
      } else if (remainingSeconds == 0) {
        return "$minutes min";
      } else {
        return "$minutes min $remainingSeconds sec";
      }
    }

    getCallHistory();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: ()async {
          await getCallHistory();
        },
        child: Obx(() => callHistory.isEmpty
            ? LoadingAndEmptyWidgets.emptyWidget()
            : ListView.builder(
                itemCount: callHistory.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        margin: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? AppColors.primary2Color
                                : Colors.white,
                            borderRadius: BorderRadius.circular(5)),
                        // child: ListTile(
                        //   title: Text('Calling ' +
                        //       callHistory[index]['receiver']['name']),
                        //   subtitle: Text(
                        //       callHistory[index]['created_at'].split('T')[0] +
                        //           ' ' +
                        //           callHistory[index]['created_at']
                        //               .split('T')[1]
                        //               .split('.')[0]),
                        //   trailing: Text(
                        //       callHistory[index]['duration'].toString() +
                        //           ' seconds'),
                        // ),
                        child: ListTile(
                          contentPadding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          tileColor: Get.isDarkMode
                              ? AppColors.primary2Color
                              : Colors.white,
                          leading: CircleAvatar(
                            radius: 25,
                            backgroundImage: CachedNetworkImageProvider(
                              '${HttpClient.s3BaseUrl}${callHistory[index][authUser.id==callHistory[index]['caller_id']?'receiver':'caller']['avatar_url']}',
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                callHistory[index][authUser.id==callHistory[index]['caller_id']?'receiver':'caller']['name'].toString().capitalize.toString(),
                                style: TypographyStyles.textWithWeight(
                                    16, FontWeight.w400),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Text(callHistory[index]['created_at'].split('T')[0]+callHistory[index]['created_at']
                                  //     .split('T')[1].split('.')[0]),
                                  Text(DateFormat('d MMM, y H:mm').format(
                                      DateTime.parse(
                                          callHistory[index]['created_at']).toLocal()),style:TypographyStyles.textWithWeight(14, FontWeight.w400)),
                                ],
                              ),
                                  Text(formatSecondsToMinSize(callHistory[index]['duration']),style:TypographyStyles.textWithWeight(14, FontWeight.w400)),
                            ],
                          ),
                          trailing: ZegoSendCallInvitationButton(
                            isVideoCall: false,
                            //You need to use the resourceID that you created in the subsequent steps.
                            //Please continue reading this document.
                            resourceID: "NS_Signal",
                            buttonSize: Size(36,36),
                            iconSize: Size(36,36),
                            unclickableBackgroundColor: AppColors.accentColor,
                            invitees: [
                              ZegoUIKitUser(
                                id: '${callHistory[index]['receiver']['id']}',
                                name: callHistory[index]['receiver']['name'],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                    ],
                  );
                },
              )),
      ),
    );
  }
}
