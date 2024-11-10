import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:url_launcher/url_launcher.dart';

class TrainerHealthBio extends StatelessWidget {
  const TrainerHealthBio({Key? key, required this.data}) : super(key: key);

  final data;

  @override
  Widget build(BuildContext context) {
    print(data);

    return Scaffold(
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            SizedBox(
              height: 16,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phone',
                    style: TypographyStyles.title(14),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () async {
                          launchUrl(Uri.parse('tel:' + data['phone']));
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(50, 25),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Direct Call: ' + data['phone'].toString(),
                          style: TypographyStyles.boldText(
                              16,
                              Get.isDarkMode
                                  ? Themes.mainThemeColorAccent.shade100
                                  : colors.Colors().lightBlack(1)),
                        ),
                      ),
                      Text(
                        '*Standard calling rates apply',
                        style: TypographyStyles.textWithWeight(
                            12, FontWeight.w300),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Birthday',
                      style: TypographyStyles.title(14),
                  ),
                  Text(
                    data['birthday'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(16), decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
            ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Email',
                    style: TypographyStyles.title(14),
                  ),
                  TextButton(
                      onPressed: () async {
                        if (!await launchUrl(
                            Uri.parse('mailto:' + data['email'])))
                          throw 'Could not Open Call';
                      },
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: Text(
                        data['email'],
                        style: TypographyStyles.boldText(
                            16,
                            Get.isDarkMode
                                ? Themes.mainThemeColorAccent.shade100
                                : colors.Colors().lightBlack(1)),
                      )),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gender',
                    style: TypographyStyles.title(14),
                  ),
                  Text(
                    "${data['gender'].toString().capitalize}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(16), decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
            ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NIC',
                    style: TypographyStyles.title(14),
                  ),
                  Text(
                    data['nic'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Country',
                    style: TypographyStyles.title(14),
                  ),
                  Text(
                    data['country_code'],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
            Divider(thickness: 1,height: 20,),
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Emergency Contact',
                    style: TypographyStyles.title(20),
                  )
                ],
              ),
            ),
            data['role'] == 'client'
                ? Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              data['client']['emergency_contact_name'],
                              style: TypographyStyles.title(14),
                            ),
                            Text(
                              data['client']['emergency_contact_phone'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        ),
                      ),
          SizedBox(
            height: 10,
          ),
                      data['client']['health_conditions'] != null
                          ? Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Health Conditions',
                                        style: TypographyStyles.title(14),
                                      ),
                                      Text(
                                          '(${data['client']['health_conditions'].length})')
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top:16),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: data['client']
                                            ['health_conditions']
                                        .length,
                                    itemBuilder: (_, index) {
                                      return Container(
                                        margin: EdgeInsets.only(bottom: 8),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: Row(
                                          children: [
                                            Container(margin:EdgeInsets.only(right: 10), width:10,height: 10,decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),color: AppColors.accentColor),),
                                            Text(                                             
                                                  data['client']
                                                      ['health_conditions'][index],
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  )
                : Container(),
          ],
        ),
      )),
    );
  }
}
