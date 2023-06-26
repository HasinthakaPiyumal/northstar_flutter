import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Controllers/NotificationsController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:url_launcher/url_launcher.dart';

class RequestsNotifications extends StatelessWidget {
  const RequestsNotifications({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {


    void sendInvite(NSNotification notification) async{
      String email = notification.data['sender_email'];
      CommonConfirmDialog.confirm('Invite').then((value) async {
        if(value){
          Map res = await httpClient.inviteMember({
            'email': email,
            'trainer_id': authUser.id.toString(),
            'trainer_type': authUser.user['trainer']['type'],
          });

          if (res['code'] == 200) {
            Get.back();
            showSnack('Success!', 'Client Invited!');
            print(res);
          } else {
            showSnack('Error!', 'Client does not exist or something went wrong!');
          }
        }
      });
    }



    return Obx(()=> NotificationsController.notifications.length > 0 ? Padding(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 0),
      child: Obx(()=>ListView.builder(
        itemCount: NotificationsController.getRequestNotifications().length,
        itemBuilder: (_,index){

          NSNotification notification = NotificationsController.getRequestNotifications()[index];

          return Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: notification.hasSeen ? Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().lightCardBG : Get.isDarkMode ? Color(0xFF6D5D4A) : colors.Colors().selectedCardBG,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(notification.title,
                              style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(0.7)),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: notification.hasSeen ? null : Icon(Icons.circle, size: 10, color: Get.isDarkMode ? Themes.mainThemeColor.shade600 : colors.Colors().lightBlack(1),),
                            ),
                          ],
                        ),
                        SizedBox(height: 10,),
                        Text(notification.description,
                          style: TypographyStyles.normalText(15, Get.isDarkMode ? Colors.white54 : colors.Colors().darkGrey(0.7)),
                        ),
                        SizedBox(height: 10,),
                        Text("${DateFormat("dd-MMM-yyyy").format(notification.createdAt)} | ${DateFormat("HH:mm").format(notification.createdAt)}",
                          style: TypographyStyles.boldText(12, Get.isDarkMode ? Colors.white30 : colors.Colors().darkGrey(0.5)),
                        ),
                        SizedBox(height: 10),
                        Divider(
                          color: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().darkGrey(1).withOpacity(0.6),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            ElevatedButton(
                              onPressed: (){
                                String phone = notification.data['sender_phone'];
                                launchUrl(Uri.parse('tel:'+ phone.toString()));
                              },
                              style: ButtonStyles.matButton(Colors.transparent, 0),
                              child: Row(
                                children: [
                                  Icon(Icons.call,
                                    color: Get.isDarkMode ? Colors.white : colors.Colors().lightBlack(1),
                                  ),
                                  SizedBox(width: 7,),
                                  Text("Call",
                                    style: TextStyle(
                                      color: Get.isDarkMode ? Colors.white : colors.Colors().lightBlack(1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5,),
                            ElevatedButton(
                              onPressed: (){
                                String email = notification.data['sender_email'];
                                launchUrl(Uri.parse('mailto:'+ email.toString()));
                              },
                              style: ButtonStyles.matButton(Colors.transparent, 0),
                              child: Row(
                                children: [
                                  Icon(Icons.email,
                                    color: Get.isDarkMode ? Colors.white : colors.Colors().lightBlack(1),
                                  ),
                                  SizedBox(width: 7,),
                                  Text("Email",
                                    style: TextStyle(
                                      color: Get.isDarkMode ? Colors.white : colors.Colors().lightBlack(1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 5,),
                            ElevatedButton(
                              onPressed: notification.type != NSNotificationTypes.ClientRequestWeb ? (){
                                sendInvite(notification);
                              }: null,
                              style: ButtonStyles.matButton(Themes.mainThemeColor.shade500, 3),
                              child: Row(
                                children: [
                                  Icon(Icons.person_add_alt_rounded,
                                    color: colors.Colors().lightBlack(1),
                                  ),
                                  SizedBox(width: 7,),
                                  Text("Invite",
                                    style: TextStyle(
                                      color: colors.Colors().lightBlack(1),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      )),
    ): LoadingAndEmptyWidgets.emptyWidget(),);
  }
}
