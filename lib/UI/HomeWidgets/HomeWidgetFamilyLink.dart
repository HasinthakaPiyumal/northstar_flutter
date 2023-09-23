import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/components/Buttons.dart';

import '../../Styles/TypographyStyles.dart';
import 'HomeWidgetFamilyLink/CreateNewFamilyLink.dart';
import 'HomeWidgetFamilyLink/FamilyView.dart';

class FamilyLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Family Link'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: Get.width - 32,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
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
                        "Andrew’s Family",
                        style: TypographyStyles.title(20),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        "Our bond strengthens with each passing moment together.",
                        style: TypographyStyles.text(16),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child:Container(
                        width: double.infinity,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 60,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: "https://fastly.picsum.photos/id/679/200/200.jpg?hmac=sPsw4YJPQkWFqo2k5UycejGhY4UXvaDXStGmvJEhFBA",
                                  width: 36,
                                  height: 36,
                                ),
                              ),
                            ),
                            Positioned(
                              left: 30,
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: "https://fastly.picsum.photos/id/976/200/200.jpg?hmac=xz9CTpScnLHQm_wNTcJmz8bQM6-ApTQnof5-4LGtu-s",
                                  width: 36,
                                  height: 36,
                                ),
                              ),
                            ),Positioned(
                              child: ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: "https://fastly.picsum.photos/id/318/200/200.jpg?hmac=bXfpcSpOySqXMIev1AISKO15vvxPgau4JEA36kuhG1Y",
                                  width: 36,
                                  height: 36,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )

                    ),
                    SizedBox(
                      height: 24,
                    ),
                    Buttons.yellowFlatButton(
                        onPressed: () {
                          Get.to(FamilyView());
                        }, label: "View", width: Get.width - 72),
                  ],
                ),
              ),
              SizedBox(
                height: 90,
              ),
              Buttons.yellowFlatButton(
                  onPressed: () {
                    Get.to(CreateNewFamilyLink());
                  }, label: "Create New Family Link"),
            ],
          ),
        ),
      ),
    );
  }
}
