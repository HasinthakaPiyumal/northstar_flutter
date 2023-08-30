import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/UI/Members/VoiceCallUI.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';

class Dialer extends StatelessWidget {
  const Dialer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList contacts = [].obs;
    Map data = {};

    void searchMembers(pattern) async {
      Map res = await httpClient.searchMembers(pattern);
      if (res['code'] == 200) {
        contacts.value = res['data'];
      }
    }

    void getTrainers() async {
      Map res = await httpClient.getMyProfile();
      if (res['code'] == 200) {
        data = res['data'];

        print(data);
        if (data['diet_trainer'] != null) {
          contacts.add({"user": data['diet_trainer']});
        }
        if (data['physical_trainer'] != null) {
          contacts.add({"user": data['physical_trainer']});
        }
      }
    }

    if (authUser.role == 'client') {
      getTrainers();
    } else if (authUser.role == 'trainer') {
      searchMembers('');
    }

    return Scaffold(
      body: Obx(() => contacts.isEmpty
          ? LoadingAndEmptyWidgets.emptyWidget()
          : ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    tileColor:
                        Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                    leading: CircleAvatar(
                      radius: 25,
                      backgroundImage: CachedNetworkImageProvider(
                        '${HttpClient.s3BaseUrl}${contacts[index]['user']['avatar_url']}',
                      ),
                    ),
                    title: Text(contacts[index]['user']['name']),
                    trailing: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(200),
                        color: AppColors.accentColor,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.call,size:20,
                            color: AppColors.textOnAccentColor),
                        onPressed: () {
                          Get.to(() =>
                                  VoiceCallUI(user: contacts[index]['user']))
                              ?.then((value) {
                            // Get.back();
                            // print(value);
                          });
                        },
                      ),
                    ),
                  ),
                );
              },
            )),
    );
  }
}
