import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/components/Buttons.dart';

import '../../Styles/TypographyStyles.dart';
import '../SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'HomeWidgetFamilyLink/CreateNewFamilyLink.dart';
import 'HomeWidgetFamilyLink/FamilyView.dart';

class FamilyLink extends StatefulWidget {

  @override
  State<FamilyLink> createState() => _FamilyLinkState();
}

class _FamilyLinkState extends State<FamilyLink> {
  RxList familyLinkList = [].obs;
  RxBool ready = false.obs;

  void getFamilyLinks() async{
    ready.value= false;
    const data = {
      "search":""
    };
    var res = await httpClient.getFamiliLinks(data);
    if(res['code'] ==200){
      familyLinkList.value = res['data'];
    }
    ready.value = true;
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call your function here
    getFamilyLinks();
    print("Calling again");
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Family Link'),
      ),
      body: SingleChildScrollView(
        child: Obx(()=>
            ready.value?Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Column(
                children:
                List.generate(familyLinkList.length,(int index){
                    return Container(
                      width: Get.width - 32,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                          color:
                          Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                          borderRadius: BorderRadius.circular(10)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              "${familyLinkList[index]['title']}".capitalize as String,
                              style: TypographyStyles.title(20),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              "${familyLinkList[index]['description']}".capitalizeFirst as String,
                              style: TypographyStyles.text(16),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          // Padding(
                          //     padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          //     child:Container(
                          //       width: double.infinity,
                          //       child: Stack(
                          //         children: [
                          //           Positioned(
                          //             left: 60,
                          //             child: ClipOval(
                          //               child: CachedNetworkImage(
                          //                 imageUrl: "https://fastly.picsum.photos/id/679/200/200.jpg?hmac=sPsw4YJPQkWFqo2k5UycejGhY4UXvaDXStGmvJEhFBA",
                          //                 width: 36,
                          //                 height: 36,
                          //               ),
                          //             ),
                          //           ),
                          //           Positioned(
                          //             left: 30,
                          //             child: ClipOval(
                          //               child: CachedNetworkImage(
                          //                 imageUrl: "https://fastly.picsum.photos/id/976/200/200.jpg?hmac=xz9CTpScnLHQm_wNTcJmz8bQM6-ApTQnof5-4LGtu-s",
                          //                 width: 36,
                          //                 height: 36,
                          //               ),
                          //             ),
                          //           ),Positioned(
                          //             child: ClipOval(
                          //               child: CachedNetworkImage(
                          //                 imageUrl: "https://fastly.picsum.photos/id/318/200/200.jpg?hmac=bXfpcSpOySqXMIev1AISKO15vvxPgau4JEA36kuhG1Y",
                          //                 width: 36,
                          //                 height: 36,
                          //               ),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     )
                          //
                          // ),
                          SizedBox(
                            height: 24,
                          ),
                          Buttons.yellowFlatButton(
                              onPressed: () {
                                print(familyLinkList[index]);
                                Get.to(FamilyView(familyLink:familyLinkList[index]))?.then((value) =>getFamilyLinks() );
                              }, label: "View", width: Get.width - 72),
                        ],
                      ),
                    );
                  }),

              ),

              SizedBox(
                width: Get.width,
                height: 70,
              ),
              Buttons.yellowFlatButton(
                  onPressed: () {
                    Get.to(CreateNewFamilyLink())?.then((value) =>getFamilyLinks() );
                  }, label: "Create New Family Link"),
            ],
          ),
        ):LoadingAndEmptyWidgets.loadingWidget()),
      ),
    );
  }
}
