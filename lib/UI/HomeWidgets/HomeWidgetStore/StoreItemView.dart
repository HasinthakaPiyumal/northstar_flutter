import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/StoreHelper.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetStore/StoreCart.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class StoreItemView extends StatelessWidget {
  const StoreItemView({Key? key, this.product}) : super(key: key);
  final product;
  @override
  Widget build(BuildContext context) {
    RxInt quantity = 1.obs;

    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Container(
                width: Get.width,
                height: Get.height / 2,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: HttpClient.s3ResourcesBaseUrl+product['image_path'],
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20,),

              Container(
                width: double.infinity,
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ?AppColors.primary2Color :Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'], style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),),
                    SizedBox(height: 16,),
                    // Text(authUser.user['currency'] + '. ' + product['price'].toString(),style: TypographyStyles.boldText(20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),),
                    Text( 'MVR ' + product['price'].toString(),style: TypographyStyles.boldText(20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),),
                  ],
                ),
              ),

              SizedBox(height: 10,),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 25),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ?AppColors.primary2Color :Colors.white,
                ),
                child: Text(product['description'], textAlign: TextAlign.justify,
                ),
              ),

              SizedBox(height: 80,)
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.transparent,
        child: Container(
          width: Get.width,
          decoration: BoxDecoration(
            color: Get.isDarkMode ? AppColors.primary2Color :Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: const Radius.circular(20.0),
              topRight: const Radius.circular(20.0),
            ),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: Get.width / 3,
                  height: 52,
                  child: ElevatedButton(
                    style: ButtonStyles.matButton(Get.isDarkMode ? Themes.mainThemeColorAccent.shade300.withOpacity(0.5) : colors.Colors().lightCardBG, 5),
                    onPressed: (){
                      Get.bottomSheet(
                        Container(
                          height: Get.height / 2,
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              )
                            ),
                            child: ListView.builder(
                              itemCount: 8,
                              itemBuilder: (context, index){
                                return ListTile(
                                  onTap: (){
                                    quantity.value = index + 1;
                                    Get.close(1);
                                  },
                                  title: Text('${index + 1}'),
                                );
                              },
                            ),
                          ),
                        )
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(()=>Text('Quantity ${quantity.value}')),
                        Icon(Icons.arrow_drop_down_rounded)
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                SizedBox(
                  width: 60,
                  child: ElevatedButton(
                    style: ButtonStyles.matButton(Get.isDarkMode ? Themes.mainThemeColorAccent.shade300.withOpacity(0.5) : colors.Colors().lightCardBG, 5),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Icon(Icons.add_shopping_cart),
                    ),
                    onPressed: () async {
                      storeHelper.addToCart(product['id'], quantity.value);
                    },
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ButtonStyles.primaryButton(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 18),
                      child: Text('BUY NOW', style: TypographyStyles.boldText(14, Themes.mainThemeColorAccent.shade100)),
                    ),
                    onPressed: () async{
                      await storeHelper.addToCart(product['id'], quantity.value);
                      Get.off(()=>StoreCart());
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
