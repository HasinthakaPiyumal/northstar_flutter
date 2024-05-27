import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/StoreHelper.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetStore/MyOrders.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/components/Buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../Models/HttpClient.dart';
import '../../../Styles/SignUpStyles.dart';
import '../../../Styles/Themes.dart';
import '../../../Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../../Utils/PopUps.dart';
import '../../Layout.dart';
import '../../SharedWidgets/PaymentSummary.dart';
import '../../SharedWidgets/PaymentVerification.dart';
class StoreCart extends StatelessWidget {
  const StoreCart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxMap walletData = {}.obs;

    void refreshCart() async {
      await storeHelper.refreshCart();
      ready.value = true;
    }

    void payByCard()async {
      Map res = await httpClient.purchaseCart({'payment_type':1});
      if(res['code']==200){
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString("lastTransactionId", res['data']['id']);
        await prefs.setString("lastTransactionUrl", res['data']['url']);
        Get.to(()=>PaymentVerification());
      }else{
        showSnack("Booking Failed",res['data']['message'] );
      }
      print('===res');
      print(res);
    }

    void payWithWallet()async{
      Map res = await httpClient.purchaseCart({'payment_type':2});
      print(res);
      if (res['code'] == 200) {
        Get.off(() => MyOrders());
        print('Purchasing Success ---> $res');
        showSnack('Purchasing Successful', 'Your cart has been successfully Purchased.');
      } else {
        showSnack('Purchasing Failed',
            'Something went wrong. Please try again later.');
      }
    }

    void validateAndGo(){

      if(storeHelper.cart.length==0){
        showSnack("Cart is empty", "Please add items for cart and try again.",status: PopupNotificationStatus.warning);
        return;
      }

      Widget headerWidget = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: ListView.separated(
          separatorBuilder: (context,index){
            return SizedBox();
          },
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
                margin: EdgeInsets.symmetric(vertical: 4),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary2Color,
                  borderRadius: BorderRadius.circular(5)
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                      ClipRRect(
                        borderRadius:BorderRadius.circular(5),
                        child: CachedNetworkImage(
                          imageUrl: HttpClient.s3ResourcesBaseUrl+storeHelper.cart[index]['product']
                            ['image_path'],
                            placeholder: (context, url) =>
                                CircularProgressIndicator(),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                        ),
                      ),

                    SizedBox(width: 20,),
                    Container(
                      width: Get.width-148,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(storeHelper.cart[index]['product']['name'].toString().capitalize.toString(),style: TypographyStyles.title(16),),
                          // SizedBox(height: 8,),
                          (Get.width-148)/7<storeHelper.cart[index]['product']['description'].length?Container(width:Get.width-148,height: 20,child: Marquee(blankSpace: 20,pauseAfterRound: Duration(seconds: 10),text: '${storeHelper.cart[index]['product']['description']}',style: TypographyStyles.text(14),)):Text('${storeHelper.cart[index]['product']['description']}',style: TypographyStyles.text(14),),
                          Text('MVR ${storeHelper.cart[index]['product']['price']}',style: TypographyStyles.smallBoldTitle(20),),
                          // Row(
                          //   children: [
                          //     Spacer(),
                          //     // Text('X ${storeHelper.cart[index]['product']['quantity']}',style: TypographyStyles.text(14),),
                          //   ],
                          // )
                        ],
                      ),
                    )
                  ],
                ),
            );
          }, itemCount:storeHelper.cart.length,
        ),
      );

      Get.to(()=>PaymentSummary(
        orderDetails: [
          SummaryItem(head: 'Item count',value: '${storeHelper.cart.length}',),
        ],
        total: storeHelper.getCartTotal(),
        payByCard: (){payByCard();},
        payByWallet: (){payWithWallet();},
        headerWidget:headerWidget ,
      ));
    }

    void confirmAndPay() async{

      Map res = await httpClient.getWallet();

      if (res['code'] == 200) {
        print(res);
        walletData.value = res['data'];
      } else {
        print(res);
      }

      Get.defaultDialog(
          radius: 8,
          title: '',
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.symmetric(horizontal: 20,),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("BOOKING SUMMARY",
                style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Item count',
                    style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1)),
                  ),
                  Text(
                    '${storeHelper.cart.length}',
                    style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade300 : colors.Colors().lightBlack(1)),
                  ),
                ],
              ),
              Divider(
                thickness: 1,
                color: Themes.mainThemeColorAccent.shade300.withOpacity(0.2),
              ),
              SizedBox(height: 7,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total to be paid',
                    style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                  ),
                  Text(
                    'MVR ${storeHelper.getCartTotal()}',
                    style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                  ),
                ],
              ),
              SizedBox(height: 30),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  text: 'By clicking Pay with Card, you are agreeing to our ',
                  style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Terms & Conditions',
                      style: TypographyStyles.normalText(12, Themes.mainThemeColor),
                      recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse('https://northstar.mv/terms-conditions/')),
                    ),
                    TextSpan(
                      text: " & ",
                      style: TypographyStyles.normalText(12, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                    ),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: TypographyStyles.normalText(12, Themes.mainThemeColor),
                      recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse('https://northstar.mv/privacy-policy')),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
          actions: [
            Container(
              width: Get.width,
              child: ElevatedButton(
                onPressed: () async {
                  if (walletData.value['balance'] >= storeHelper.getCartTotal()) {
                    Map res = await httpClient.purchaseCart({'payment_type':2});
                    print(res);
                    if (res['code'] == 200) {
                      Get.off(() => MyOrders());
                      print('Purchasing Success ---> $res');
                      showSnack('Purchasing Successful', 'Your cart has been successfully Purchased.');
                    } else {
                      showSnack('Purchasing Failed',
                          'Something went wrong. Please try again later.');
                    }
                  } else {
                    showSnack('Not Enough Balance',
                        'You do not have enough balance to pay for this Purchasing');
                  }
                },
                style: ButtonStyles.matButton(Themes.mainThemeColor.shade500, 0),
                child: Obx(() => ready.value ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Pay with eWallet',
                        style: TypographyStyles.boldText(16, Colors.black),
                      ),
                      SizedBox(height: 3,),
                      Text('(eWallet Balance: ${walletData['balance'].toStringAsFixed(2)})',
                        style: TypographyStyles.normalText(13, Colors.black),
                      ),
                    ],
                  ),
                ) : LoadingAndEmptyWidgets.loadingWidget()),
              ),
            ),
            Container(
              width: Get.width,
              padding: EdgeInsets.only(top: 3),
              child: ElevatedButton(
                onPressed: (){
                  num amt = storeHelper.getCartTotal();
                  int payAmt = (amt).toInt();
                  payByCard();
                },
                style: SignUpStyles.selectedButton(),
                child: Obx(() => ready.value ? Padding(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children:[
                        Container(
                          width: 32,
                          height: 32,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.asset('assets/BMLLogo.jpeg'),
                          ),
                        ),
                        SizedBox(width: 16),
                        Text('Pay with Card',
                          style: TypographyStyles.boldText(15, Themes.mainThemeColor.shade500),
                        )
                      ]
                  ),
                ) : LoadingAndEmptyWidgets.loadingWidget()),
              ),
            ),
            Container(
              height: 48,
              width: Get.width,
              child: TextButton(onPressed: ()=>Get.back(), child: Text('Cancel', style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),)),
            ),
            SizedBox(height: 4),
          ]
      );
    }


    refreshCart();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Obx(() => ready.value
          ? storeHelper.cart.isNotEmpty
              ? Column(
                  children: <Widget>[
                    Expanded(
                      child: Obx(() => ListView.builder(
                            itemCount: storeHelper.cart.length,
                            itemBuilder: (context, index) {
                              print(storeHelper.cart[index]);
                              return Container(
                                margin: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5)
                                ),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0), // Adjust the radius as needed
                                  ),
                                  leading: ClipRRect(
                                    child: CachedNetworkImage(
                                      imageUrl: HttpClient.s3ResourcesBaseUrl+storeHelper.cart[index]['product']
                                          ['image_path'],
                                      placeholder: (context, url) =>
                                          CircularProgressIndicator(),
                                      errorWidget: (context, url, error) =>
                                          Icon(Icons.error),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  title: Text(
                                      storeHelper.cart[index]['product']['name'],style: TypographyStyles.text(16),),
                                  subtitle: Text(
                                      // 'Quantity: ${storeHelper.cart[index]['quantity']} \nU. Price: ${authUser.user['currency']} ${storeHelper.cart[index]['product']['price']}'),
                                      'Quantity: ${storeHelper.cart[index]['quantity']} \nU. Price: MVR ${storeHelper.cart[index]['product']['price']}'),
                                  trailing: Container(
                                    width: 40,
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        padding: EdgeInsets.all(0),
                                      ),
                                      child:
                                          Icon(Icons.delete, color: Colors.white),
                                      onPressed: () {
                                        CommonConfirmDialog.confirm('Remove')
                                            .then((confirmed) {
                                          if (confirmed) {
                                            storeHelper.removeFromCart(
                                                storeHelper.cart[index]['id']);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          )),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: Get.isDarkMode
                          ? AppColors.primary2Color
                          : Colors.white,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Order Summary',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Total:'),
                              Text(
                                // '${authUser.user['currency']} ${storeHelper.getCartTotal()}',
                                'MVR ${storeHelper.getCartTotal()}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    storeHelper.cart.length > 0
                        ? Container(
                            color: Get.isDarkMode
                                ? AppColors.primary2Color
                                : Colors.white,
                            width: Get.width,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Buttons.yellowFlatButton(
                                onPressed: validateAndGo, label: "Purchase"))
                        : Container(
                            color: Get.isDarkMode
                                ? AppColors.primary2Color
                                : Colors.white,
                            height: 64,
                            width: Get.width,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: ElevatedButton(
                              onPressed: null,
                              style: ButtonStyles.primaryButton(),
                              child: Text('BUYING UNAVAILABLE'),
                            ),
                          ),
                    Container(
                        color: Get.isDarkMode
                            ? AppColors.primary2Color
                            : Colors.white,
                        height: 16),
                  ],
                )
              : Center(
                  child: LoadingAndEmptyWidgets.emptyWidget(),
                )
          : Center(
              child: LoadingAndEmptyWidgets.loadingWidget(),
            )),
    );
  }
}
