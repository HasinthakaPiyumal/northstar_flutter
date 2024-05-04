import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Controllers/NotificationsController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/NSNotification.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDietaryConsultation.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../components/Buttons.dart';

class RequestsNotifications extends StatefulWidget {
  const RequestsNotifications({Key? key}) : super(key: key);

  @override
  State<RequestsNotifications> createState() => _RequestsNotificationsState();
}

class _RequestsNotificationsState extends State<RequestsNotifications> {

  Set<NSNotification> selectedList = <NSNotification>{};
  @override
  Widget build(BuildContext context) {

    void selectItem(NSNotification notification) {
      setState(() {
        if (selectedList.contains(notification)) {
          selectedList.remove(notification);
        } else {
          selectedList.add(notification);
        }
      });
    }

    void selectAll() {
      setState(() {
        selectedList =
        Set<NSNotification>.from(NotificationsController.getRequestNotifications());
      });
    }
    void deleteSelected(){
      selectedList.forEach((element) {
        element.deleteSelectedNotification();
      });
    }


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
              color: notification.hasSeen ? Get.isDarkMode ? AppColors.primary2Color : colors.Colors().lightCardBG : Get.isDarkMode ? Color(0xFF6D5D4A) : colors.Colors().selectedCardBG,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 12),
              child: InkWell(
                onLongPress: () {
                  NotificationsController.actions(notification,
                      selectItem, selectedList, selectAll,deleteSelected);
                },
                onTap: () {
                  if (selectedList.length > 0) {
                    selectItem(notification);
                  }else{
                    notification.readNotification(askConfirm: false);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Visibility(
                        visible: selectedList.length > 0,
                        child: Checkbox(
                          splashRadius: 15,
                          visualDensity: VisualDensity(
                              horizontal: -4.0, vertical: -4.0),
                          value:
                          selectedList.contains(notification),
                          onChanged: (bool? value) {
                            selectItem(notification);
                          },
                        )),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            notification.title,
                            style: TypographyStyles.boldText(
                                16,Get.isDarkMode?Colors.white:Colors.black),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            notification.description,
                            style: TypographyStyles.text(
                                14),),
                          SizedBox(
                            height: 8,
                          ),
                          Text(
                              "${DateFormat("dd MMMM yyyy - HH:mm").format(notification.createdAt)}",
                              style: TypographyStyles.text(
                                  14)
                          ),
                          SizedBox(height: 10),
                          Divider(
                            color: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().darkGrey(1).withOpacity(0.6),
                          ),
                          Visibility(visible: NSNotificationTypes.DietConsultationRequest==notification.type,child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Buttons.outlineButton(width: 120,label: "Add Plan",onPressed: (){notification.deleteSelectedNotification();Get.to(()=>HomeWidgetDietaryConsultation(userId: authUser.id,trainerId: notification.senderId,));}),
                            ],
                          )),
                          Visibility(
                            visible: ![NSNotificationTypes.DietConsultationRequest].contains(notification.type),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // ElevatedButton(
                                //   onPressed: (){
                                //     String phone = notification.data['sender_phone'];
                                //     launchUrl(Uri.parse('tel:'+ phone.toString()));
                                //   },
                                //   style: ButtonStyles.matButton(Colors.transparent, 0),
                                //   child: Row(
                                //     children: [
                                //       Icon(Icons.call,
                                //         color: Get.isDarkMode ? Colors.white : colors.Colors().lightBlack(1),
                                //       ),
                                //       SizedBox(width: 7,),
                                //       Text("Call",
                                //         style: TextStyle(
                                //           color: Get.isDarkMode ? Colors.white : colors.Colors().lightBlack(1),
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                                Expanded(
                                  child: Buttons.outlineTextIconButton(
                                      onPressed: (){
                                        String phone = notification.data['sender_phone'];
                                        launchUrl(Uri.parse('tel:'+ phone.toString()));
                                      },
                                      icon: Icons.phone,
                                      label:"Call"
                                  ),
                                ),
                                SizedBox(width: 5,),
                                Expanded(
                                  child: Buttons.outlineTextIconButton(
                                    onPressed: (){
                                      String email = notification.data['sender_email'];
                                      launchUrl(Uri.parse('mailto:'+ email.toString()));
                                    },
                                    icon: Icons.email,
                                    label:"Email"
                                  ),
                                ),
                                SizedBox(width: 5,),
                                Expanded(
                                  child: Buttons.yellowFlatButton(
                                    onPressed: notification.type != NSNotificationTypes.ClientRequestWeb ? (){
                                      notification.deleteSelectedNotification();
                                      sendInvite(notification);
                                    }:(){},
                                      label:"Invite"
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
            ),
          );
        },
      )),
    ): LoadingAndEmptyWidgets.emptyWidget(),);
  }
}
