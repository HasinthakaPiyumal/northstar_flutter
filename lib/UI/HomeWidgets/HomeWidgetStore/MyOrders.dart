import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';

import '../../../Models/StoreHelper.dart';
import '../../../Styles/AppColors.dart';
import '../../../Styles/Themes.dart';
import '../../../Styles/TypographyStyles.dart';

class MyOrders extends StatelessWidget {
  const MyOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList orders = [].obs;
    void getOrders() async {
      Map res = await httpClient.getOrderHistory();
      print(res['code'] == 200);
      if (res['code'] == 200) {
        orders.value = res['data'];
        print('order history');
        print(res['data']);
        print('order history');
      }
    }

    getOrders();
    storeHelper.refreshCart();
    return Scaffold(
      appBar: AppBar(
        title: Text('Order History'),
      ),
      body: Center(
          child: Obx(
        () => orders.length > 0
            ? ListView.builder(
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  dynamic product = orders[index]['prouct'];
                  String createdAtString = orders[index]['created_at'];
                  DateTime createdAt = DateTime.parse(createdAtString).toLocal();

                  String formattedDate = DateFormat('dd MMM, yyyy').format(createdAt);
                  String formattedTime = DateFormat('hh:mm a').format(createdAt);
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                    padding: EdgeInsets.symmetric(horizontal: 8,vertical: 8),
                    decoration: BoxDecoration(
                      color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                      borderRadius: BorderRadius.circular(5)
                    ),                    
                    width: 20,
                    // height: 20,
                    child: Row(children: [
                      Container(
                        width: 70,
                        child: ClipRRect(
                            borderRadius:
                            BorderRadius.circular(
                                8.0),
                          child: CachedNetworkImage(
                            imageUrl: HttpClient.s3ResourcesBaseUrl+product['image_path'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8,),
                      Container(
                        width: Get.width-154,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${product['name'].toString().capitalizeFirst}', style: TypographyStyles.text(18),textAlign: TextAlign.start,),
                               Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentColor,
                                    borderRadius: BorderRadius.circular(10)
                                  ),
                                  child: Text(orders[index]['product_id'].toString(),style: TypographyStyles.text(13).copyWith(color: AppColors.textOnAccentColor),),
                                ),
                            ],
                          ),
                          SizedBox(height: 8,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("MVR "+'${product['price']}', style: TypographyStyles.title(15),textAlign: TextAlign.start,),
                              Text("X "+'${orders[index]['quantity']}', style: TypographyStyles.title(15),textAlign: TextAlign.start,),
                            ],),
                          // SizedBox(height: 2,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                            Text(formattedDate, style: TypographyStyles.text(14),),
                            Text(formattedTime, style: TypographyStyles.text(14),),
                          ],)
                        ],),
                      )
                    ],),
                  );
                })
            : LoadingAndEmptyWidgets.emptyWidget(),
      )),
    );
  }
}
