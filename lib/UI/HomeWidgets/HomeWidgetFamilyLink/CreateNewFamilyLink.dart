import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/Buttons.dart';

class CreateNewFamilyLink extends StatelessWidget {
  RxInt familyMemberCount = 0.obs;
  RxInt expandedMember = 0.obs;
  TextEditingController familyMemberCountController =  new TextEditingController();
  TextEditingController familyNameCountController =  new TextEditingController();
  TextEditingController familyDescriptionCountController =  new TextEditingController();

  Future<void> createFamily() async{
    var data = {
      "title":familyNameCountController.text,
      "description":familyDescriptionCountController.text,
      "member_count":familyMemberCountController.text
    };
    var res = await httpClient.createFamilyLink(data);
    print(res);
    if(familyNameCountController.text.isEmpty || familyDescriptionCountController.text.isEmpty || familyMemberCountController.text.isEmpty){
      showSnack("Failed", "Please fill all text fields");
      return;
    }
    if(res['code']==200){
      showSnack("Success", "Family Creating Success");
    }else{
      showSnack("Failed", res['data'][0]['message']);
    }
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Family Link'),
      ),
      body: Obx(() => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: familyNameCountController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Name Of Family"),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: familyDescriptionCountController,
                maxLength: 50,
                maxLines: 2,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("Description"),
                ),
              ),
              SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.number,
                controller: familyMemberCountController,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1)
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  label: Text("How Many Members"),
                ),
              ),
              SizedBox(height: 20),
              Buttons.yellowFlatButton(
                  onPressed: () async{
                    await createFamily();
                      familyMemberCount.value = int.tryParse(familyMemberCountController.text) ?? 0;
                      FocusScope.of(context).unfocus();
                  },
                  label: "Create Family",
                  width: Get.width),
              SizedBox(height: 40),
              ...List.generate(familyMemberCount.value, (index) {
                return Container(
                  width: Get.width - 32,
                  margin: EdgeInsets.only(bottom: 40),
                  padding:
                  EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: Get.isDarkMode
                        ? AppColors.primary2Color
                        : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: Get.width,
                        height: 40,
                        margin: EdgeInsets.only(bottom: 20),
                        decoration: BoxDecoration(
                            color: AppColors.accentColor,
                            borderRadius: BorderRadius.circular(5)),
                        child: Center(
                            child: Text(
                              "Member ${index+1}",
                              style: TypographyStyles.boldText(
                                  20, AppColors.textOnAccentColor),
                            )),
                      ),
                      TextField(
                        maxLength: 50,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text("Name"),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        maxLength: 50,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text("Nick Name"),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      TextField(
                        maxLength: 50,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          label: Text("Email"),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Buttons.yellowFlatButton(
                          onPressed: () {},
                          label: "Invite",
                          width: Get.width * 0.6),
                    ],
                  ),
                );
              }),
              SizedBox(
                height: 90,
              ),
            ],
          ),
        ),
      )),
    );
  }
}




// ExpansionPanelList(
//   elevation: 0,
//   expandedHeaderPadding: EdgeInsets.all(0),
//   animationDuration: Duration(milliseconds: 500),
//   expansionCallback: (index, isExpanded) {
//     if (expandedMember.value == index) {
//       expandedMember.value = -1;
//     } else {
//       expandedMember.value = index;
//     }
//   },
//
//
//   dividerColor: Colors.transparent,
//
//   children: List.generate(
//     familyMemberCount.value,
//     (index) => FamilyMember(
//         headerValue: 'Member ${index + 1}',
//         expandedValue:
//             'This is item number ${index + 1}',
//         index: index),
//   ).map<ExpansionPanel>((FamilyMember member) {
//     return ExpansionPanel(
//       backgroundColor: AppColors.primary1Color,
//       headerBuilder:
//           (BuildContext context, bool isExpanded) {
//         return ListTile(
//           tileColor: AppColors.primary1Color,
//           title: Text(member.headerValue),
//         );
//       },
//       canTapOnHeader: true,
//       body: ListTile(
//         title: Text(member.expandedValue),
//       ),
//       isExpanded: expandedMember.value == member.index,
//     );
//   }).toList(),
// ),