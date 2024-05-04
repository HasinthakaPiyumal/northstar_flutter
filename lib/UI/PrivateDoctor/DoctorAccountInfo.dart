import 'package:country_currency_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonProfileUpdate.dart';

import '../../Styles/AppColors.dart';
import '../../components/Buttons.dart';

class DoctorAccountInfo extends StatelessWidget {

  const DoctorAccountInfo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxBool ready = false.obs;
    var data = {};

    void getProfile() async{
      ready.value = false;
      Map res = await httpClient.getMyProfile();
      if (res['code'] == 200) {
        data = res['data'];
        print(data);
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    getProfile();

    return Scaffold(
      appBar: AppBar(
        title: Text("Account Information"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Obx(()=>ready.value ? Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors().getSecondaryColor(),borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        SizedBox(height: 16,),
                        Row(mainAxisAlignment: MainAxisAlignment.center,children: [SvgPicture.asset("assets/svgs/profile-outline.svg",width: 24,height: 24,),SizedBox(width: 8,),Text("About",style: TypographyStyles.text(16),)],),
                        SizedBox(height: 32,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Phone', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Birthday', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Email', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Gender', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('NIC/Passport', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Country', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text('Registered Date', style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(data['name'], style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text(data['phone'], style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text(data['birthday'], style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text(data['email'], style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text("${data['gender'].toString().capitalizeFirst}", style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text(data['nic'], style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                                Text(CountryPickerUtils.getCountryByIsoCode(data['country_code']).name! , style: TypographyStyles.text(14)),
                                // Text(CountryPickerUtils.getCountryByIsoCode("ad").name! , style: TypographyStyles.title(16)),
                                SizedBox(height: 24),
                                Text( DateFormat('yyyy-MM-dd').format(
                                  DateTime.parse(data['created_at']),
                                ) , style: TypographyStyles.text(14)),
                                SizedBox(height: 24),
                              ],
                            ),
                          ],
                        ),
                        Buttons.yellowFlatButton(onPressed: (){
                          Get.to(CommonProfileUpdate(userObj: authUser.role == 'client' ? data: data))?.then((value){
                            getProfile();
                          });
                          },label: "Edit your information")
                      ],
                    ),
                  ),
                  // Row(
                  //   children: [
                  //     Text('ABOUT', style: TypographyStyles.title(18)),
                  //     Spacer(),
                  //     IconButton(
                  //       icon: Icon(Icons.edit, color: Themes.mainThemeColor,),
                  //       onPressed: (){
                  //         print('data===');
                  //         print(data);
                  //         Get.to(CommonProfileUpdate(userObj: authUser.role == 'client' ? data: data))?.then((value){
                  //           getProfile();
                  //         });
                  //       },
                  //     )
                  //   ],
                  // ),
                  // SizedBox(height: 16),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.start,
                  //       children: [
                  //         Text('Name', style: TypographyStyles.title(16)),
                  //         SizedBox(height: 24),
                  //         Text('Phone', style: TypographyStyles.title(16)),
                  //         SizedBox(height: 24),
                  //         Text('Birthday', style: TypographyStyles.title(16)),
                  //         SizedBox(height: 24),
                  //         Text('Email', style: TypographyStyles.title(16)),
                  //         SizedBox(height: 24),
                  //         Text('Gender', style: TypographyStyles.title(16)),
                  //         SizedBox(height: 24),
                  //         Text('NIC/Passport', style: TypographyStyles.title(16)),
                  //         SizedBox(height: 24),
                  //         Text('Country', style: TypographyStyles.title(16)),
                  //         SizedBox(height: 24),
                  //         Text('Registered Date', style: TypographyStyles.title(16)),
                  //         SizedBox(height: 24),
                  //       ],
                  //     ),
                  //     Column(
                  //       crossAxisAlignment: CrossAxisAlignment.end,
                  //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //       children: [
                  //         Text(data['name'], style: TypographyStyles.text(14)),
                  //         SizedBox(height: 27),
                  //         Text(data['phone'], style: TypographyStyles.text(14)),
                  //         SizedBox(height: 27),
                  //         Text(data['birthday'], style: TypographyStyles.text(14)),
                  //         SizedBox(height: 27),
                  //         Text(data['email'], style: TypographyStyles.text(14)),
                  //         SizedBox(height: 27),
                  //         Text("${data['gender'].toString().capitalizeFirst}", style: TypographyStyles.text(14)),
                  //         SizedBox(height: 27),
                  //         Text(data['nic'], style: TypographyStyles.text(14)),
                  //         SizedBox(height: 27),
                  //         Text(data['country_code'], style: TypographyStyles.text(14)),
                  //         SizedBox(height: 27),
                  //         Text( DateFormat('yyyy-MM-dd').format(
                  //           DateTime.parse(data['created_at']),
                  //         ), style: TypographyStyles.text(14)),
                  //         SizedBox(height: 27),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  // Divider(),
                  // SizedBox(height: 16),
                ],
              ): Center(child: CircularProgressIndicator(),)),
            ],
          ),
        ),
      ),
    );
  }
}
