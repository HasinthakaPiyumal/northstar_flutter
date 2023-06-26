import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonProfileUpdate.dart';

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
                  Row(
                    children: [
                      Text('ABOUT', style: TypographyStyles.title(18)),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.edit, color: Themes.mainThemeColor,),
                        onPressed: (){
                          Get.to(CommonProfileUpdate(userObj: authUser.role == 'client' ? data['user']: data))?.then((value){
                            getProfile();
                          });
                        },
                      )
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name', style: TypographyStyles.text(16).copyWith(color: Themes.mainThemeColorAccent.shade300)),
                          SizedBox(height: 24),
                          Text('Phone', style: TypographyStyles.text(16).copyWith(color: Themes.mainThemeColorAccent.shade300)),
                          SizedBox(height: 24),
                          Text('Birthday', style: TypographyStyles.text(16).copyWith(color: Themes.mainThemeColorAccent.shade300)),
                          SizedBox(height: 24),
                          Text('Email', style: TypographyStyles.text(16).copyWith(color: Themes.mainThemeColorAccent.shade300)),
                          SizedBox(height: 24),
                          Text('Gender', style: TypographyStyles.text(16).copyWith(color: Themes.mainThemeColorAccent.shade300)),
                          SizedBox(height: 24),
                          Text('NIC/Passport', style: TypographyStyles.text(16).copyWith(color: Themes.mainThemeColorAccent.shade300)),
                          SizedBox(height: 24),
                          Text('Country', style: TypographyStyles.text(16).copyWith(color: Themes.mainThemeColorAccent.shade300)),
                          SizedBox(height: 24),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(data['name'], style: TypographyStyles.title(16)),
                          SizedBox(height: 24),
                          Text(data['phone'], style: TypographyStyles.title(16)),
                          SizedBox(height: 24),
                          Text(data['birthday'], style: TypographyStyles.title(16)),
                          SizedBox(height: 24),
                          Text(data['email'], style: TypographyStyles.title(16)),
                          SizedBox(height: 24),
                          Text("${data['gender'].toString().capitalizeFirst}", style: TypographyStyles.title(16)),
                          SizedBox(height: 24),
                          Text(data['nic'], style: TypographyStyles.title(16)),
                          SizedBox(height: 24),
                          Text(data['country_code'], style: TypographyStyles.title(16)),
                          SizedBox(height: 24),
                        ],
                      ),
                    ],
                  ),
                  Divider(),
                  SizedBox(height: 16),
                ],
              ): Center(child: CircularProgressIndicator(),)),
            ],
          ),
        ),
      ),
    );
  }
}
