import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

import 'HomeWidgetVendingMachine/MyOrders.dart';
import 'HomeWidgetVendingMachine/QrScan.dart';

class HomeWidgetVendingMachine extends StatelessWidget {
  const HomeWidgetVendingMachine({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList<dynamic> cat = RxList<dynamic>([
      {"url": "https://via.placeholder.com/75x70"},
      {"url": "https://via.placeholder.com/75x70"},
      {"url": "https://via.placeholder.com/75x70"},
      {"url": "https://via.placeholder.com/75x70"},
      {"url": "https://via.placeholder.com/75x70"}
    ]);
    RxList<dynamic> pro = RxList<dynamic>([
      {"url": "https://via.placeholder.com/398x124"},
      {"url": "https://via.placeholder.com/398x124"},
      {"url": "https://via.placeholder.com/398x124"},
      {"url": "https://via.placeholder.com/398x124"},
      {"url": "https://via.placeholder.com/398x124"}
    ]);
    return Scaffold(
      appBar: AppBar(
        title: Text('Vending Machine'),
        actions: [
          IconButton(
            icon: Icon(Icons.paste_rounded),
            onPressed: () {
              Get.to(HomeWidgetVendingMachineMyOrders());
            },
          )
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color:AppColors.accentColor
        ),

        child: IconButton(
          icon: Icon(Icons.qr_code_scanner_outlined),
            color:AppColors.textOnAccentColor,
          onPressed: () {
            Get.to(VendingQr());
          },
        ),
      ),
      body: Column(
        children: [
          Obx(
            () => Container(
              height: 160,
              child: Row(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: cat.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return Obx(() => InkWell(
                              onTap: () {
                                print(cat[index][
                                    'url']); // Changed to 'url' instead of 'id'
                              },
                              child: Container(
                                  margin: EdgeInsets.only(
                                      right: cat.length - 1 == index ? 16 : 8,
                                      left: index == 0 ? 16 : 8),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10)),
                                  width: 160,
                                  height: 160,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.0),
                                    child: Image.network(
                                      cat[index]['url'],
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                              // Display image or content
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ));
                      },
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Container(
              width: Get.width - 32,
              child: Text(
                "Products",
                style: TypographyStyles.title(20),
                textAlign: TextAlign.start,
              )),
          SizedBox(
            height: 10,
          ),
          Obx(
            () => Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  itemCount: pro.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    return Obx(() => InkWell(
                          onTap: () {
                            print(pro[index]
                                ['url']); // Changed to 'url' instead of 'id'
                          },
                          child: Container(
                              margin: EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10)),
                              width: 160,
                              height: 160,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Image.network(
                                  pro[index]['url'],
                                  fit: BoxFit.cover,
                                ),
                              )),
                          // Display image or content
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ));
                  },
                  scrollDirection: Axis.vertical,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
