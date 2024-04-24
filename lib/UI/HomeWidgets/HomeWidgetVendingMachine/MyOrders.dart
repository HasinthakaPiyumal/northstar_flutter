import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';

import '../../../Models/HttpClient.dart';
import '../../../Styles/AppColors.dart';
import '../../../Styles/TypographyStyles.dart';

class HomeWidgetVendingMachineMyOrders extends StatelessWidget {
  const HomeWidgetVendingMachineMyOrders({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList orders = [].obs;
    Future<void> getOrders() async {
      Map res = await httpClient.getVendingOrderHistory();
      print(res['code'] == 200);
      if (res['code'] == 200) {
        orders.value = res['data'];
        print('Order data==');
        print(res['data']);
      }
    }

    getOrders();
    return RefreshIndicator(
      onRefresh: () async{ await getOrders(); },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Order History'),
        ),
        body: Center(
            child: Obx(
                  () => orders.length > 0
                  ? ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    dynamic product = orders[index];
                    String createdAtString = orders[index]['created_at'];
                    DateTime createdAt = DateTime.parse(createdAtString).toLocal();

                    String formattedDate = DateFormat('dd MMM, yyyy').format(createdAt);
                    String formattedTime = DateFormat('hh:mm a').format(createdAt);
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 16,vertical: 5),
                      padding: EdgeInsets.symmetric(horizontal: 10,vertical: 8),
                      decoration: BoxDecoration(
                          color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      width: 20,
                      // height: 20,
                      child: Row(children: [
                        // Container(
                        //   width: 70,
                        //   child: ClipRRect(
                        //     borderRadius:
                        //     BorderRadius.circular(
                        //         8.0),
                        //     child: product['status']==0?Lottie.asset(
                        //       'assets/lotties/drink_making.json',
                        //       width: 70, // Adjust size as needed
                        //       height: 70,
                        //       fit: BoxFit.contain, // Ensure animation fits within space
                        //     ):SvgPicture.asset(
                        //       "assets/svgs/done.svg",
                        //       width: 70,
                        //       height: 70,
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(width: 20,),
                        Container(
                          width: Get.width-52,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${product['name'].toString().capitalizeFirst}', style: TypographyStyles.text(18),textAlign: TextAlign.start,),
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
                                ],),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Status", style: TypographyStyles.text(14),),
                                  Text(product['released_status']=='1'?"Success":product['released_status']=='0'?'Making':'Failed', style: TypographyStyles.text(14).copyWith(color: product['released_status']=='1'?Colors.green:product['released_status']=='0'?Colors.lightBlueAccent:Colors.red),),
                                ],),
                            ],),
                        )
                      ],),
                    );
                  })
                  : LoadingAndEmptyWidgets.emptyWidget(),
            )),
      ),
    );
  }
}
