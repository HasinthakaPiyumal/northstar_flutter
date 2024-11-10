import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Members/AddMember.dart';
import 'package:north_star/UI/Members/UserView.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/components/Buttons.dart';

import '../Styles/AppColors.dart';

class Members extends StatelessWidget {
  const Members({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList members = [].obs;
    RxBool ready = false.obs;

    Future<List> searchMembers(String pattern) async {
      Map res = await httpClient.searchMembers(pattern,onlyContracted: 'ALL');
      if (res['code'] == 200) {
        members.value = res['data'];
      }
      ready.value = true;
      return [];
    }

    searchMembers('');

    return Scaffold(
      floatingActionButton: Visibility(
        visible: authUser.role == 'trainer',
        child: Buttons.yellowTextIconButton(
            onPressed: () {
              Get.to(() => AddMember());
            },
            icon: Icons.add,
            label: "Add Member",
            width: 140),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TypeAheadField(
                hideOnEmpty: true,
                hideOnError: true,
                hideOnLoading: true,
                textFieldConfiguration: TextFieldConfiguration(
                    autofocus: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search Members...',
                      border: UnderlineInputBorder(),
                    )),
                suggestionsCallback: (pattern) async {
                  return await searchMembers(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return Container();
                },
                onSuggestionSelected: (suggestion) {},
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Container(
                child: Obx(() => ready.value
                    ? members.length > 0
                        ? ListView.builder(
                            itemCount: members.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 4),
                                child: Material(
                                  borderRadius: BorderRadius.circular(10),
                                  color: AppColors.primary2Color,
                                  child: Column(
                                    children: [
                                      ListTile(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        onTap: () {
                                          Get.to(() => UserView(
                                              userID: members[index]
                                                  ['user_id']));
                                        },
                                        contentPadding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        leading: CircleAvatar(
                                            radius: 32,
                                            backgroundImage:
                                                CachedNetworkImageProvider(
                                              HttpClient.s3BaseUrl +
                                                  members[index]['user']
                                                      ['avatar_url'],
                                            )),
                                        isThreeLine: members[index]
                                                ['health_conditions'] !=
                                            null,
                                        title: Row(
                                          children: [
                                            Text(
                                                members[index]['user']['name']),
                                            Tooltip(
                                                message: members[index][
                                                            'physical_trainer_id'] ==
                                                        authUser.id
                                                    ? "Physical Trainer"
                                                    : "Secondary Trainer",
                                                child: Text(members[index][
                                                            'physical_trainer_id'] ==
                                                        authUser.id
                                                    ? " (P)"
                                                    : " (S)")),
                                          ],
                                        ),
                                        subtitle: members[index]
                                                    ['health_conditions'] !=
                                                null
                                            ? Text(members[index]['user']
                                                    ['email'] +
                                                '\n' +
                                                'Has ' +
                                                members[index]
                                                        ['health_conditions']
                                                    .length
                                                    .toString() +
                                                ' Health Conditions')
                                            : Text(members[index]['user']
                                                ['email']),
                                        trailing: Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,

                                          children: [
                                            GestureDetector(
                                              onTap: (){
                                                Get.to(AddMember(extend: true,extendingId: members[index]['user']['id'],extendingEmail: members[index]['user']['email'],));
                                              },
                                              child: Container(
                                                width: 23,
                                                height: 23,
                                                margin: EdgeInsets.only(bottom: 5),
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(5),
                                                    color: AppColors.accentColor),
                                                child: Icon(Icons.edit,size: 15,color: AppColors.textOnAccentColor,),
                                              ),
                                            ),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5),
                                                color: Get.isDarkMode
                                                    ? AppColors.primary1Color
                                                    : AppColors.baseColor,
                                              ),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 8, vertical: 4),
                                              child: Text('ID: ' +
                                                  members[index]['user_id']
                                                      .toString()),
                                            ),
                                          ],
                                        ),
                                      ),
                                      !members[index]['trainer_contract'].isEmpty? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Package Time',
                                                style: TypographyStyles.text(14),
                                              ),
                                              Text('${DateTime.parse(members[index]['trainer_contract'][0]['valid_till']).difference(DateTime.now()).inDays} days remaining'),
                                            ],
                                          ),
                                        ):SizedBox(),

                                        !members[index]['trainer_contract'].isEmpty? Padding(
                                          padding: const EdgeInsets.only(
                                              left: 14,
                                              right: 14,
                                              top: 8,
                                              bottom: 20),
                                          child: SizedBox(
                                            height: 10,
                                            width: Get.width,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  width: Get.width,
                                                  decoration: BoxDecoration(
                                                    color: AppColors()
                                                        .getPrimaryColor(
                                                            reverse: true),
                                                    borderRadius:
                                                        BorderRadius.circular(50),
                                                  ),
                                                ),
                                                Container(
                                                  width: (Get.width - 56) /
                                                      100 *
                                                      ((DateTime.parse(members[index]['trainer_contract'][0]['valid_till'])
                                                              .difference(
                                                                  DateTime.now())
                                                              .inDays) /
                                                          (DateTime.parse(members[index]['trainer_contract'][0]['valid_till']).difference(DateTime.parse(members[index]['trainer_contract'][0]['created_at'])).inDays )*100),
                                                  decoration: BoxDecoration(
                                                    color: Color(0xff68FC80),
                                                    borderRadius:
                                                        BorderRadius.circular(50),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ):SizedBox()
                                    ],
                                  ),
                                ),
                              );
                            },
                          )
                        : LoadingAndEmptyWidgets.emptyWidget()
                    : LoadingAndEmptyWidgets.loadingWidget()),
              ),
            )
          ],
        ),
      ),
    );
  }
}
