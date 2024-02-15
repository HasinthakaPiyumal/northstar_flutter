import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Members/UserView.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';

class Pending extends StatelessWidget {
  const Pending({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList requests = [].obs;
    TextEditingController reason = TextEditingController();

    void getPending() async {
      ready.value = false;
      Map res = await httpClient.getDoctorPending();
      print(res);
      if (res['code'] == 200) {
        requests.value = res['data']['meetings'];
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    void accept(int id, int clientID) async {
      ready.value = false;
      Map res = await httpClient.acceptDocMeetings(id);
print('accepting-->$res');
      if (res['code'] == 200) {
        httpClient.sendNotification(
            clientID,
            'Appointment Accepted',
            'Your appointment has been Accepted by the Doctor.',
            NSNotificationTypes.DoctorAppointmentAccepted, {
          'doctor_id': authUser.id,
          'doctor_name': authUser.name,
        });
        getPending();
      } else {
        ready.value = true;
      }
    }

    void reject(id, int clientID) async {
      ready.value = false;
      Map res = await httpClient.rejectDocMeetings(id);

      if (res['code'] == 200) {
        httpClient.sendNotification(clientID, 'Appointment Rejected',
            'Your appointment has been Rejected by the Doctor.',
            NSNotificationTypes.DoctorAppointmentDeclined,
            {
              'doctor_id': authUser.id,
              'doctor_name': authUser.name,
            });
        getPending();
      } else {
        ready.value = true;
      }
    }

    void cancelingReason(id, int clientID) async {
      Get.defaultDialog(
          radius: 8,
          title: 'Canceling Reason',
          content: TextField(
            controller: reason,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Reason',
            ),
          ),
          actions: [
            ElevatedButton(
                style: ButtonStyles.bigBlackButton(),
                child: Text('Confirm Canceling'),
                onPressed: () {
                  if (reason.text.isNotEmpty) {
                    reject(id, clientID);
                    Get.back();
                  } else {
                    showSnack('Rejection Reason is Required!',
                        'Rejection Reason is Required!');
                  }
                }),
          ]);
    }

    getPending();

    return Scaffold(
      body: Obx(() => ready.value
          ? requests.length == 0
              ? Center(
                  child: Text(
                    'No Pending Appointments',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 25),
                      child: Text(
                        'Requests',
                        style: TypographyStyles.title(25),
                      ),
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Expanded(
                        child: ListView.builder(
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 13),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Get.isDarkMode
                                  ? colors.Colors().deepGrey(1)
                                  : colors.Colors().lightCardBG,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(20, 20, 20, 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  InkWell(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 26,
                                              backgroundImage:
                                                  CachedNetworkImageProvider(
                                                      'https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/avatars/' +
                                                          requests[index]
                                                                  ['client']
                                                              ['avatar_url']),
                                            ),
                                            SizedBox(width: 20),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    requests[index]['client']
                                                        ['name'],
                                                    style:
                                                        TypographyStyles.title(
                                                            20)),
                                                SizedBox(height: 5),
                                                Text(
                                                    (DateTime.now()
                                                                    .difference(DateTime.parse(requests[index]
                                                                            [
                                                                            'client']
                                                                        [
                                                                        'birthday']))
                                                                    .inDays ~/
                                                                365)
                                                            .toString() +
                                                        ' Years Old',
                                                    style:
                                                        TypographyStyles.text(
                                                            14)),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Image.asset(
                                          "assets/icons/externallink.png",
                                          color: Get.isDarkMode
                                              ? Themes
                                                  .mainThemeColorAccent.shade100
                                                  .withOpacity(0.5)
                                              : colors.Colors().lightBlack(1),
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Get.to(() => UserView(
                                          userID: requests[index]['client']
                                              ['id']));
                                    },
                                  ),
                                  SizedBox(height: 5),
                                  Divider(),
                                  SizedBox(height: 7),
                                  Row(
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Date',
                                              style: TypographyStyles.boldText(
                                                12,
                                                Get.isDarkMode
                                                    ? Themes
                                                        .mainThemeColorAccent
                                                        .shade100
                                                        .withOpacity(0.7)
                                                    : colors.Colors()
                                                        .lightBlack(0.6),
                                              )),
                                          SizedBox(height: 5),
                                          Text(
                                            "${DateFormat("MMM dd,yyyy").format(DateTime.parse(requests[index]['start_time']))}",
                                            style: TypographyStyles.title(16),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 25),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text('Time',
                                              style: TypographyStyles.boldText(
                                                12,
                                                Get.isDarkMode
                                                    ? Themes
                                                        .mainThemeColorAccent
                                                        .shade100
                                                        .withOpacity(0.7)
                                                    : colors.Colors()
                                                        .lightBlack(0.6),
                                              )),
                                          SizedBox(height: 5),
                                          Text(
                                            "${DateFormat("hh:mm a").format(DateTime.parse(requests[index]['start_time']))}",
                                            style: TypographyStyles.title(16),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 15),
                                  Text(requests[index]['title'],
                                      style: TypographyStyles.title(16)),
                                  SizedBox(height: 10),
                                  Text(
                                    requests[index]['description'],
                                    style: TypographyStyles.normalText(
                                      14,
                                      Get.isDarkMode
                                          ? Themes.mainThemeColorAccent.shade100
                                              .withOpacity(0.7)
                                          : colors.Colors().lightBlack(0.6),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 20),
                                            child: Text(
                                              'Reject',
                                              style: TypographyStyles.boldText(
                                                  15, Colors.white),
                                            ),
                                          ),
                                          style: ButtonStyles.matRadButton(
                                              Colors.black, 5, 12),
                                          onPressed: () {
                                            CommonConfirmDialog.confirm(
                                                    'Reject')
                                                .then((value) {
                                              if (value) {
                                                cancelingReason(
                                                    requests[index]['id'],
                                                    requests[index]
                                                        ['client_id']);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: ElevatedButton(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 20),
                                            child: Text(
                                              'Accept',
                                              style: TypographyStyles.boldText(
                                                  15, Colors.black),
                                            ),
                                          ),
                                          style: ButtonStyles.matRadButton(
                                              Themes.mainThemeColor.shade500,
                                              5,
                                              12),
                                          onPressed: () {
                                            CommonConfirmDialog.confirm(
                                                    'Accept')
                                                .then((value) {
                                              if (value) {
                                                accept(
                                                    requests[index]['id'],
                                                    requests[index]
                                                        ['client_id']);
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ))
                  ],
                )
          : LinearProgressIndicator()),
    );
  }
}
