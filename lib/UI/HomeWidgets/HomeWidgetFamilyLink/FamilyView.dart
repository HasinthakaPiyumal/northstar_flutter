import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/Buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../components/ConfirmDialogs.dart';
import '../../../components/DropDownButtonWithBorder.dart';
import '../../../components/MaterialBottomSheet.dart';

class FamilyView extends StatelessWidget {
  final dynamic familyLink;
  const FamilyView({Key? key, this.familyLink}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    RxInt _currentTab = 0.obs;
    RxString _assignFilterDropdown = 'All'.obs;
    String preferenceName = "familyViewTabIndex";

    RxList members = [].obs;
    RxList assigns = [].obs;

    TextEditingController _addMemberName = TextEditingController();
    TextEditingController _addMemberNickName = TextEditingController();
    TextEditingController _addMemberEmail = TextEditingController();

    TextEditingController _addAssignTitle = TextEditingController();
    TextEditingController _addAssignDescription = TextEditingController();
    RxString _addAssignWho = "0".obs;
    RxString _addAssignTo = "0".obs;

    TextEditingController _updateFamilyName = TextEditingController(text: familyLink['title']);
    TextEditingController _updateFamilyDescription = TextEditingController(text: familyLink['description']);
    RxBool isChangedFamilySettings = (!(_updateFamilyDescription.text == familyLink['description'] && _updateFamilyName==familyLink['title'])).obs;

    print("familyLinkfamilyLink");
    print(familyLink);
    Future<int?> retrieveSelectedTabIndex() async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int val = prefs.getInt(preferenceName)!;
      _currentTab.value = val;
      print('$preferenceName $val ------> Getting');
      return prefs.getInt(preferenceName);
    }

    Future<void> saveSelectedTabIndex(int index) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      print('$preferenceName $index ------> Setting');
      prefs.setInt(preferenceName, index);
    }

    void getMembers() async {
      Map res = await httpClient.getFamilyMembers(familyLink['family_id']);
      if (res['code'] == 200) {
        members.value = res['data'];
      } else {
        showSnack("Error", res['data']['message']);
      }
    }
    void getAssigns() async {
      Map res = await httpClient.getAssignListFamilyLink(familyLink['family_id']);
      if (res['code'] == 200) {
        assigns.value = res['data'];
      } else {
        showSnack("Error", res['data']['message']);
      }
    }

    void addNewMember() async {
      MaterialBottomSheet("add new member",
          child: Column(
            children: [
              TextField(
                maxLength: 50,
                controller: _addMemberName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Name",
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                maxLength: 50,
                controller: _addMemberNickName,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Nick Name",
                ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                maxLength: 50,
                controller: _addMemberEmail,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Email",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Buttons.yellowFlatButton(
                  onPressed: ()async {
                    Map res = await httpClient.inviteFamilyMember({
                      "name":_addMemberName.text,
                      "nick_name":_addMemberNickName.text,
                      "email":_addMemberEmail.text,
                      "family_id":familyLink['family_id']
                    });
                    print(res);
                    if(res['code']==200){
                      getMembers();
                      Get.back();
                    }else{
                      showSnack("Failed", res['data']['message']);
                    }
                  }, label: "Invite", width: Get.width * 0.6),
            ],
          ));
    }

    void createNewAssign() {
      List<DropdownMenuItem<String>> memberDropDown = members.value.map<DropdownMenuItem<String>>((dynamic member) {
        return DropdownMenuItem<String>(
          value: '${member['userID']}',
          child: Text('${member['user_name']}${member['userID']}'),
        );
      }).toList();
      List<DropdownMenuItem<String>> assignWhoDropDown = memberDropDown.toList();
      List<DropdownMenuItem<String>> assignToDropDown = memberDropDown.toList();
      assignWhoDropDown.insert(0, DropdownMenuItem<String>(
        value: "0",
        child: Text('Assign Who'),
      ));
      assignToDropDown.insert(0, DropdownMenuItem<String>(
        value: "0",
        child: Text('Assign To'),
      ));
      MaterialBottomSheet("create new assign",
          child: Column(
            children: [
              TextField(
                controller: _addAssignTitle,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Assign What?",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                maxLength: 500,
                maxLines: 3,
                controller: _addAssignDescription,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Description",
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Obx(()=> DropdownButtonWithBorder(
                  items: [],
                  preBuildItems:assignWhoDropDown,
                  selectedValue: _addAssignWho.value,
                  isPreBuildItems:true,
                  onChanged:(String val) {
                    _addAssignWho.value = val;
                  },
                  width: Get.width,
                ),
              ),
              SizedBox(height: 20),
              Obx(()=> DropdownButtonWithBorder(
                  items: [],
                  preBuildItems:assignToDropDown,
                  selectedValue: _addAssignTo.value,
                  isPreBuildItems:true,
                  onChanged: (String val) {
                    _addAssignTo.value = val;
                  },
                  width: Get.width,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Buttons.yellowFlatButton(
                  onPressed: () async{
                    Map res = await httpClient.createAssignFamilyLink({
                      "family_id":familyLink['family_id'],
                      "title":_addAssignTitle.text,
                      "description":_addAssignDescription.text,
                      "asin_who":_addAssignWho.value,
                      "asin_to":_addAssignTo.value
                    });
                    if(res['code']==200){
                      Get.back();
                      getAssigns();
                      showSnack("Success", "Successfully created assign");
                    }else{
                      showSnack("Failed", res['data']['message']);
                    }
                  }, label: "Assign", width: Get.width * 0.6),
            ],
          ));
    }

    void editAssign() {
      MaterialBottomSheet("edit assigning",
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Assign What?",
                ),
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                maxLength: 500,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Description",
                ),
              ),
              SizedBox(
                height: 10,
              ),
              DropdownButtonWithBorder(
                items: ["Assign who"],
                selectedValue: 'Assign who',
                onChanged: (String) {},
                width: Get.width,
              ),
              SizedBox(height: 20),
              DropdownButtonWithBorder(
                items: ["Assign to"],
                selectedValue: 'Assign to',
                onChanged: (String) {},
                width: Get.width,
              ),
              SizedBox(
                height: 30,
              ),
              Buttons.yellowFlatButton(
                  onPressed: () {}, label: "Invite", width: Get.width * 0.6),
            ],
          ));
    }

    void viewAssign() {
      String title = "manage father schedules";
      String description =
          "Lorem ipsum dolor sit amet consectetur. Amet gravida ut senectus tortor ut. Molestie libero et nulla a consequat viverra molestie quis. Bibendum nec tincidunt in sed imperdiet purus nulla orci suscipit.";
      String assignee = "jason andrew";
      String date = "2023/04/05";

      MaterialBottomSheet("Manage father schedule",
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: double.infinity,
                // height: 119,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      // height: 84,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Container(
                                    // height: 34,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 5),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            child: Text(
                                              "Ongoing",
                                              style: TypographyStyles
                                                  .textWithWeight(
                                                      16, FontWeight.w400),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 22),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    child: Text(
                                      description.capitalizeFirst as String,
                                      style: TypographyStyles.textWithWeight(
                                          12, FontWeight.w300),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Container(
                              height: 31,
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'Assign to : ',
                                              style: TypographyStyles
                                                  .textWithWeight(
                                                      14, FontWeight.w300),
                                            ),
                                            TextSpan(
                                              text:
                                                  assignee.capitalize as String,
                                              style: TypographyStyles
                                                  .textWithWeight(
                                                      14, FontWeight.w500),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Date : $date',
                                  style: TypographyStyles.textWithWeight(
                                      14, FontWeight.w300),
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
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Buttons.yellowFlatButton(
                        onPressed: editAssign, label: "Edit"),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Buttons.outlineButton(
                        onPressed: () {}, label: "End Assign"),
                  ),
                ],
              ),
            ],
          ));
    }

    void callConfirmVoice() {
      ConfirmDialogs(
          buttonLabel: 'make a voice call',
          action: 'make a voice call',
          onPressed: () {});
    }

    void callConfirmVideo() {
      ConfirmDialogs(
          buttonLabel: 'make a video call',
          action: 'make a voice call',
          onPressed: () {});
    }

    void confirmAssignEnd() {
      ConfirmDialogs(
          buttonLabel: 'end assign', action: 'end assign', onPressed: () {});
    }

    void confirmDeleteFamilyLink() {
      ConfirmDialogs(
          buttonLabel: 'delete family link',
          action: 'delete',
          onPressed: () async {
            // await httpClient.
          });
    }

    getMembers();
    getAssigns();

    retrieveSelectedTabIndex();
    return Scaffold(
      body: Obx(() => CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                pinned: true,
                expandedHeight: 110.0,
                centerTitle: true,
                // title: Text(
                //   '${familyLink['title']} hhhhh'.capitalize as String,
                //   textAlign: TextAlign.center,
                //   style: TypographyStyles.title(20),
                // ),
                flexibleSpace: Padding(
                  padding: const EdgeInsets.only(right: 74.0),
                  child: FlexibleSpaceBar(
                    centerTitle: true,
                    expandedTitleScale: 1.3,
                    title: Text(
                      '${familyLink['title']}'.capitalize as String,
                      textAlign: TextAlign.center,
                      style: TypographyStyles.title(20),
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            '${familyLink['description']}'.capitalize as String,
                            textAlign: TextAlign.center,
                            style: TypographyStyles.text(16),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Container(
                          //   width: 36 * 3 - 12,
                          //   child: Stack(
                          //     children: [
                          //       SizedBox(
                          //         width:100,
                          //         child: ListView.builder(
                          //           shrinkWrap: true,
                          //           itemCount:members.length>3?3:members.length,
                          //           // scrollDirection: Axis.horizontal,
                          //           itemBuilder: (context,index) {
                          //             return Positioned(
                          //               left: 60,
                          //               child: Container(
                          //                 width: 36,
                          //                 height: 36,
                          //                 decoration: BoxDecoration(
                          //                   shape: BoxShape.circle,
                          //                 ),
                          //                 child: CircleAvatar(
                          //                   child: ClipOval(
                          //                     child: CachedNetworkImage(
                          //                       imageUrl:
                          //                       HttpClient.s3ResourcesBaseUrl+"avatars/"+members[index]["avatar_url"],
                          //                       width: 36,
                          //                       height: 36,
                          //                     ),
                          //                   ),
                          //                 ),
                          //               ),
                          //             );
                          //           }
                          //         ),
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              SliverPersistentHeader(
                delegate: _StickyContainerDelegate(
                  child: PreferredSize(
                    preferredSize: Size(Get.width, 64),
                    child: Material(
                      elevation: 1,
                      color: AppColors.primary1Color,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 4),
                        child: Container(
                          width: Get.width,
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                            color: Color(0xFF1E2630),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Obx(() => Row(
                                children: [
                                  _buildButton('member', _currentTab.value == 0,
                                      onTap: () {
                                    _currentTab.value = 0;
                                    saveSelectedTabIndex(0);
                                  }),
                                  SizedBox(width: 8),
                                  _buildButton('assign', _currentTab.value == 1,
                                      onTap: () {
                                    _currentTab.value = 1;
                                    saveSelectedTabIndex(1);
                                  }),
                                  SizedBox(width: 8),
                                  _buildButton('info', _currentTab.value == 2,
                                      onTap: () {
                                    _currentTab.value = 2;
                                    saveSelectedTabIndex(2);
                                  }),
                                ],
                              )),
                        ),
                      ),
                    ),
                  ),
                ),
                pinned: true, // Make the container sticky
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5.0),
                          child: Column(
                            children: [
                              Visibility(
                                  visible: _currentTab.value == 0,
                                  child: Container(
                                      // child: ListView.builder(
                                      //   shrinkWrap: true,
                                      //     physics: NeverScrollableScrollPhysics(),
                                      //     itemCount: 40,
                                      //     itemBuilder: (context, index) {
                                      //       return CustomProfileContainer(
                                      //         imageUrl:
                                      //             "https://fastly.picsum.photos/id/679/200/200.jpg?hmac=sPsw4YJPQkWFqo2k5UycejGhY4UXvaDXStGmvJEhFBA",
                                      //         name: "Mark Andrew",
                                      //         description:
                                      //             "Adventurous spirit seeking life's wonders",
                                      //         isAdmin: true,
                                      //       );
                                      //     })

                                          child: Column(
                                        children: [
                                          // Row(
                                          //   mainAxisAlignment:
                                          //       MainAxisAlignment.end,
                                          //   children: [
                                          //     Buttons.iconButton(
                                          //         icon: Icons.call,
                                          //         onPressed: callConfirmVoice),
                                          //     SizedBox(
                                          //       width: 8,
                                          //     ),
                                          //     Buttons.iconButton(
                                          //         icon: Icons.video_call_rounded,
                                          //         onPressed: callConfirmVideo),
                                          //   ],
                                          // ),
                                          ListView.builder(
                                            shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                                itemCount: members.length,
                                              itemBuilder: (context,index) {
                                              print(members[index]);
                                                return CustomProfileContainer(
                                                  imageUrl:
                                                      HttpClient.s3ResourcesBaseUrl+"avatars/"+members[index]["avatar_url"],
                                                  name: members[index]["user_name"],
                                                  description:
                                                  members[index]["email"],
                                                  isAdmin: members[index]["admin"]=="1",
                                                );
                                              }
                                            ),

                                          SizedBox(
                                            height: 20,
                                          ),
                                          // Modal(),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Buttons.yellowFlatButton(
                                                    onPressed: addNewMember,
                                                    label: "Add New Member",
                                                    width: 171),
                                              ])
                                        ],
                                      )
                                      )),
                              Visibility(
                                  visible: _currentTab.value == 1,
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Your Assign List',
                                            style: TypographyStyles.title(20),
                                          ),
                                          DropdownButtonWithBorder(
                                            items: [
                                              'All',
                                              'Ongoing',
                                              'Pending',
                                              'Rejected'
                                            ],
                                            selectedValue:
                                                _assignFilterDropdown.value,
                                            onChanged: (newValue) {
                                              _assignFilterDropdown.value =
                                                  newValue;
                                            },
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      ListView.builder(
                                        itemCount: assigns.length,
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemBuilder: (context,index) {
                                          return TaskCard(
                                            title: assigns[index]['title'],
                                            status: assigns[index]['status'],
                                            description: assigns[index]['description'],
                                            assignee: assigns[index]['description'],
                                            date: assigns[index]['date'],
                                            onButtonPress: () {
                                              // Handle cancel button press
                                            },
                                            actionButtonLabel: "Cancel",
                                          );
                                        }
                                      ),
                                      TaskCard(
                                        title: 'manage father schedules',
                                        status: 'ongoing',
                                        description:
                                            'Lorem ipsum dolor sit amet consectetur. Neque feugiat pellentesque nibh in in id nec.',
                                        assignee: 'jason andrew',
                                        date: '2023/04/05',
                                        onButtonPress: viewAssign,
                                        actionButtonLabel: "View",
                                        statusColor: Color(0xFF67FB7F),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Buttons.yellowFlatButton(
                                          onPressed: createNewAssign,
                                          label: "Create New Assign",
                                          width: Get.width),
                                    ],
                                  )),
                              Visibility(
                                  visible: _currentTab.value == 2,
                                  child: Column(
                                    children: [Container(
                                            padding: EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color: Get.isDarkMode
                                                    ? AppColors.primary2Color
                                                    : Colors.white),
                                            child: Column(
                                              children: [
                                                TextField(
                                                  onChanged: (val){
                                                    if(_updateFamilyDescription.text == familyLink['description'] && _updateFamilyName==familyLink['title']){
                                                      isChangedFamilySettings.value = false;
                                                    }else{
                                                      isChangedFamilySettings.value = true;
                                                    }
                                                    print(isChangedFamilySettings.value);
                                                  },
                                                  controller:_updateFamilyName,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    label: Text("Name of family"),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                TextField(
                                                  maxLength: 500,
                                                  maxLines: 2,
                                                  onChanged: (val){
                                                    print(_updateFamilyDescription.text == familyLink['description']);
                                                    if(_updateFamilyDescription.text == familyLink['description'] && _updateFamilyName==familyLink['title']){
                                                      isChangedFamilySettings.value = false;
                                                    }else{
                                                      isChangedFamilySettings.value = true;
                                                    }
                                                  },
                                                  controller:_updateFamilyDescription,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    label: Text("Name"),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Buttons.yellowFlatButton(
                                                          onPressed: () async{
                                                            Map res = await httpClient.updateFamilyLink({
                                                              "title":_updateFamilyName.text,
                                                              "description":_updateFamilyDescription.text,
                                                              "family_id":familyLink['family_id']
                                                            });
                                                            if(res['code']==200){
                                                              showSnack("Success", "Successfully saved family settings");
                                                            }else{
                                                              showSnack("Failed", res['data']['message']);
                                                            }
                                                          },
                                                          width: 120,
                                                          label: "Save"),

                                                  ],
                                                ),
                                              ],
                                            )),

                                      SizedBox(
                                        height: 40,
                                      ),
                                      Buttons.outlineTextIconButton(
                                          onPressed: confirmDeleteFamilyLink,
                                          width: Get.width,
                                          label: "Delete Family Link",
                                          icon: Icons.delete_outline_rounded)
                                    ],
                                  ))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),
              )
            ],
          )),
    );
  }

  Widget _buildButton(String text, bool isSelected, {required Function onTap}) {
    return Expanded(
      child: Buttons.yellowFlatButton(
          label: text.capitalize as String,
          onPressed: () {
            onTap();
          },
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
          backgroundColor:
              isSelected ? AppColors.accentColor : Colors.transparent,
          textColor: isSelected
              ? AppColors.textOnAccentColor
              : Get.isDarkMode
                  ? AppColors.textColorDark
                  : AppColors.textColorLight),
    );
  }
}

class CustomProfileContainer extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String description;
  final bool isAdmin;

  CustomProfileContainer({
    required this.imageUrl,
    required this.name,
    required this.description,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Color(0xFF1E2630),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ),
            child: ClipOval(child: CachedNetworkImage(imageUrl: imageUrl)),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name.capitalize as String,
                      style: TypographyStyles.text(16),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Visibility(
                      visible: isAdmin,
                      child: Text(
                        "(Admin)",
                        style: TypographyStyles.textWithWeight(
                            12, FontWeight.w300),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TypographyStyles.textWithWeight(12, FontWeight.w300),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyContainerDelegate extends SliverPersistentHeaderDelegate {
  final PreferredSize child;

  _StickyContainerDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => child.preferredSize.height;

  @override
  double get minExtent => child.preferredSize.height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}

class TaskCard extends StatelessWidget {
  final String title;
  final String status;
  final String description;
  final String assignee;
  final String date;
  final String actionButtonLabel;
  final Function() onButtonPress;
  final Color statusColor;

  TaskCard({
    required this.title,
    required this.status,
    this.statusColor = const Color(0xFFFDF4AA),
    required this.description,
    required this.assignee,
    required this.date,
    required this.onButtonPress,
    required this.actionButtonLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      margin: EdgeInsets.only(bottom: 16),
      decoration: ShapeDecoration(
        color: Color(0xFF1E2630),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            // height: 119,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  // height: 84,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                // height: 34,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 5),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        child: Text(
                                          title.capitalize as String,
                                          style: TypographyStyles.text(16),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 22),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: ShapeDecoration(
                                color: statusColor,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    status.capitalizeFirst as String,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Color(0xFF1B1F24),
                                      fontSize: 14,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                      height: 0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: SizedBox(
                                child: Text(
                                  description.capitalizeFirst as String,
                                  style: TypographyStyles.textWithWeight(
                                      12, FontWeight.w300),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: double.infinity,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          height: 31,
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: SizedBox(
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Assign to : ',
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  14, FontWeight.w300),
                                        ),
                                        TextSpan(
                                          text: assignee.capitalize as String,
                                          style:
                                              TypographyStyles.textWithWeight(
                                                  14, FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Date : $date',
                              style: TypographyStyles.textWithWeight(
                                  14, FontWeight.w300),
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
          const SizedBox(height: 16),
          Buttons.yellowFlatButton(
              onPressed: onButtonPress, label: actionButtonLabel, width: 150),
        ],
      ),
    );
  }
}
