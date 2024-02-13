import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Models/HttpClient.dart';

class ViewGymLibrary extends StatelessWidget {
  const ViewGymLibrary({Key? key, this.workout}) : super(key: key);
  final workout;
  @override
  Widget build(BuildContext context) {

    print(workout);

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: Get.width,
                height: Get.width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.grey[400],
                  image: DecorationImage(
                    image: CachedNetworkImageProvider(
                      HttpClient.s3ResourcesBaseUrl + "${workout['animation_url']}",
                    ),
                    fit: BoxFit.fitWidth,
                  )
                ),
              ),
              SizedBox(height: 16),
              Text(
                workout['title'],
                style: TypographyStyles.title(20),
              ),
              SizedBox(height: 16),
              Text(
                workout['description'],
                style: TypographyStyles.text(16),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: Get.width,
                height: 32,
                child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: workout['categories'].length,
                itemBuilder: ((context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Chip(padding: EdgeInsets.all(4),backgroundColor: Get.isDarkMode?AppColors.primary2Color:Colors.white,label: Text(workout['categories'][index],style: TypographyStyles.textWithWeight(13, FontWeight.w300),),),
                  );
                }),
              ),
              ),
              SizedBox(height: 16),
              workout['optional']['enabled'] ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Limitations', style: TypographyStyles.title(16)),
                  Text(workout['optional']['limitations']),
                  SizedBox(height: 8),
                  Text('Dos', style: TypographyStyles.title(16)),
                  Text(workout['optional']['dos']),
                  SizedBox(height: 8),
                  Text('Dont\'s', style: TypographyStyles.title(16)),
                  Text(workout['optional']['donts']),
                  SizedBox(height: 8),
                  Text('Recommendations', style: TypographyStyles.title(16)),
                  Text(workout['optional']['recommendations']),
                  SizedBox(height: 8),
                  Text('Common Mistakes', style: TypographyStyles.title(16)),
                  Text(workout['optional']['commonMistakes']),
                  SizedBox(height: 8),
                ],
              ) : SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
