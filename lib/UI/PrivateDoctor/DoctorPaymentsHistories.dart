import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class DoctorPaymentHistories extends StatelessWidget {
  const DoctorPaymentHistories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList payments = [].obs;

    void getPaymentHistories() async{
      Map data = await httpClient.getMyPaymentHistories();
      print(data);
      if(data['code'] == 200){
        payments.value = data['data'];
      }
    }

    getPaymentHistories();


    return Scaffold(
      appBar: AppBar(
        title: Text('Payment Histories'),
      ),
      body: Obx(()=> payments.length > 0 ? ListView.builder(
        itemCount: payments.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(
                              HttpClient.s3BaseUrl +  payments[index]['client']['avatar_url']
                          ),
                        ),
                        SizedBox(width: 15,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${payments[index]['client']['name']}',
                              style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                            ),
                            SizedBox(height: 5,),
                            Text("${DateFormat("dd-MM-yyyy h:mma").format(DateTime.parse(payments[index]['created_at']).toLocal())}",
                              style: TypographyStyles.normalText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(0.7),),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Text('MVR ${payments[index]['amount'].toStringAsFixed(2)}',
                      style: TypographyStyles.boldText(16, Colors.green),
                    ),
                  ],
                ),
                SizedBox(height: 10,),
                Divider(
                  thickness: 1,
                  color: Themes.mainThemeColorAccent.shade100.withOpacity(0.2),
                )
              ],
            ),
          );
        },
      ): LoadingAndEmptyWidgets.emptyWidget()),
    );
  }
}
