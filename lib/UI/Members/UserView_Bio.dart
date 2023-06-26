import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class UserViewBio extends StatelessWidget {
  const UserViewBio({Key? key, required this.data}) : super(key: key);

  final data;

  @override
  Widget build(BuildContext context) {

    print(data);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16,),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phone',
                    style: TextStyle(
                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                          onPressed: () async{
                            launchUrl(Uri.parse('tel:'+ data['phone']));
                          },
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size(50, 25),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                            'Direct Call: '+ data['phone'].toString(),
                            style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                          ),
                      ),
                      Text('*Standard calling rates apply', style: TextStyle(
                        color: Colors.grey[700],
                      ),),
                    ],
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Birthday',
                    style: TextStyle(
                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1),
                    ),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1),
                    ),
                  ),
                  TextButton(
                      onPressed: () async{
                        if (!await launchUrl(Uri.parse('mailto:'+ data['email']))) throw 'Could not Open Call';
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero
                      ),
                      child: Text(
                        data['email'],
                        style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                      )
                  ),

                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Gender',
                    style: TextStyle(
                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1),
                    ),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'NIC',
                    style: TextStyle(
                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1),
                    ),
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Country',
                    style: TextStyle(
                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1),
                    ),
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
            Divider(thickness: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Emergency Contact',
                    style: TextStyle(
                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1),
                    ),
                  )
                ],
              ),
            ),
            data['role'] == 'client' ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        data['client']['emergency_contact_name'],
                        style: TextStyle(
                          color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1),
                        ),
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
                data['client']['health_conditions'] != null ?
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Health Conditions',
                            style: TextStyle(
                              color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade500 : colors.Colors().darkGrey(1),
                            ),
                          ),
                          Text('(${data['client']['health_conditions'].length})')
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: data['client']['health_conditions'].length,
                        itemBuilder: (_,index){
                          return Container(
                            margin: EdgeInsets.only(bottom: 8),
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '⏺  ' + data['client']['health_conditions'][index],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ):Container(),
              ],
            ) : Container(),
          ],
        )
      ),
    );
  }
}
