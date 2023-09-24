import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Models/StoreHelper.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetStore/MyOrders.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetStore/StoreCart.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetStore/StoreItemView.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../Styles/AppColors.dart';

class HomeWidgetStore extends StatelessWidget {

  const HomeWidgetStore({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final List cat = ["Merch", "Food", "Beverages", "Supplements", "Accessories",];

    RxBool ready = false.obs;
    RxList products = [].obs;

    Future<List> searchStore(pattern) async {
      ready.value = false;
      Map res = await httpClient.searchStore(pattern);
      if (res['code'] == 200) {
        products.value = res['data'];
      }
      print(res);
      ready.value = true;
      return [];
    }

    searchStore('');

    storeHelper.refreshCart();

    return Scaffold(
      appBar: AppBar(
        title: Text('Store'),
        actions: [
          TextButton(onPressed: (){
            Get.to(MyOrders());
          }, child: Text('My Orders'))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Get.to(()=>StoreCart());
        },
        backgroundColor: AppColors.accentColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 5.0),
              child: Icon(Icons.shopping_cart_outlined,size: 30, color: AppColors.primary2Color,),
            ),
            Positioned(
              top: 5,
              right: 8,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.circle, size: 22, color: AppColors.primary2Color),
                  Obx(() => Text(
                    storeHelper.cart.length.toString(),
                    style: TypographyStyles.boldText(12, AppColors.accentColor,),
                  ))
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: ListView(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TypeAheadField(
                hideOnEmpty: true,
                hideOnError: true,
                hideOnLoading: true,
                textFieldConfiguration: TextFieldConfiguration(
                    autofocus: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search Store...',
                      border:
                        UnderlineInputBorder()
                    )),
                suggestionsCallback: (pattern) async {
                  return await searchStore(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return Container();
                },
                onSuggestionSelected: (suggestion) {},
              ),
            ),
            SizedBox(height: 16.0),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Categories', style: TypographyStyles.title(16)),
                ],
              ),
            ),

            SizedBox(
              height: 4,
            ),

            Container(
              height: Get.height*12/100,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ListView.builder(
                      itemCount: cat.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: (){},
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Container(
                            margin: index == 0 ? EdgeInsets.only(left: 15) : EdgeInsets.only(left: 8),
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(
                              color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 25,
                                  child: Image(
                                    image: AssetImage("assets/icons/shirt.png",),
                                    color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(0.4),
                                  ),
                                ),
                                SizedBox(height: 8,),
                                SizedBox(
                                  width: 70,
                                  height: 15,
                                  child: cat[index].length > 5 ? Marquee(
                                    style: TextStyle(
                                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),
                                    ),
                                    text: "${cat[index]}",
                                    scrollAxis: Axis.horizontal,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    blankSpace: 10.0,
                                    velocity: 30.0,
                                    pauseAfterRound: Duration(milliseconds: 500),
                                    //startPadding: 10.0,
                                    accelerationDuration: Duration(milliseconds: 200),
                                    accelerationCurve: Curves.linear,
                                    decelerationDuration: Duration(milliseconds: 200),
                                    decelerationCurve: Curves.easeOut,
                                  ) : Text(cat[index],
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      scrollDirection: Axis.horizontal,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.0),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('More To Love', style: TypographyStyles.title(16)),
                ],
              ),
            ),

            SizedBox(height: 16.0),

            Obx(() => ready.value ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                MasonryGridView.count(
                  crossAxisCount: 2,
                  itemCount: products.length,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (_, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8.0),
                          onTap: () {
                            Get.to(() => StoreItemView(product: products[index]));
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding:
                                      EdgeInsets.fromLTRB(0, 8, 0, 0),
                                      width: Get.width,
                                      height: Get.height * 0.2,
                                      child: ClipRRect(
                                        borderRadius:
                                        BorderRadius.circular(8.0),
                                        child: CachedNetworkImage(
                                          imageUrl: HttpClient.s3ResourcesBaseUrl+ products[index]
                                          ['image_path'],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              LoadingAndEmptyWidgets
                                                  .loadingWidget(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      "${products[index]['name']}",
                                      style: TypographyStyles.text(14),
                                    ),
                                    SizedBox(height: 8),
                                  ],
                                ),
                                Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    authUser.user['currency'] +
                                        ' ' +
                                        products[index]['price'].toString(),
                                    style: TypographyStyles.title(16),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ) : LoadingAndEmptyWidgets.loadingWidget(),
              ),
          ],
        ),
      ),
    );
  }
}
