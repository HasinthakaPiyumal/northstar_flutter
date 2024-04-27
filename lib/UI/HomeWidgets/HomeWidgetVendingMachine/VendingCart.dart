import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

class VendingCart extends StatelessWidget {
  const VendingCart({required this.orderDetails});
  final Map orderDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Your Order"),
      ),
      body: SingleChildScrollView(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.all(16),
            decoration:BoxDecoration(color: Get.isDarkMode?AppColors.primary2Color:Colors.white,borderRadius: BorderRadius.circular(5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Text("Order Summary",style: TypographyStyles.title(20),),
              SizedBox(height: 22,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Order Id:',
                      style: TypographyStyles.text(16)),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Text(
                        orderDetails['orderId'],
                        textAlign: TextAlign.end,
                      )),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Product Code:',
                      style: TypographyStyles.text(16)),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Text(
                        orderDetails['product_code'],
                        textAlign: TextAlign.end,
                      )),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Product Name:',
                      style:TypographyStyles.text(16)),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Text(
                        orderDetails['name'],
                        textAlign: TextAlign.end,
                      )),
                ],
              ),
              SizedBox(
                height: 4,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quantity:',
                      style: TypographyStyles.text(16)),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Text(
                        orderDetails['quantity'].toString(),
                        textAlign: TextAlign.end,
                      )),
                ],
              ),
              // SizedBox(height: 8,),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     Text('E-Wallet balance:',style: TextStyle(fontWeight: FontWeight.w300)),
              //     SizedBox(width: 10,),
              //     Expanded(child: Text("MVR ${walletData['balance'].toStringAsFixed(2)}",textAlign: TextAlign.end,)),
              //   ],
              // ),
              SizedBox(
                height: 8,
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total',
                      style:
                      TextStyle(
                        color: Get.isDarkMode? Colors.white : Colors.black,
                        fontSize: 20,
                        fontFamily: 'Bebas Neue',
                        fontWeight: FontWeight.w400,
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                      child: Text("MVR ${orderDetails['price']}",
                          textAlign: TextAlign.end,
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16))),
                ],
              ),
        
            ],),
          ),
            // Expanded(
            //   child: Container(
            //   ),
            // ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text("Your Payment Method",style: TypographyStyles.title(20),),
            ),
            SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                child: Row(
                  children: [
                    InkWell(

                      child:
                    Ink(
                      width: Get.width/2,
                      decoration:BoxDecoration(color: Get.isDarkMode?AppColors.primary2Color:Colors.white,borderRadius: BorderRadius.circular(8)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Image.asset(
                            "assets/icons/wallet.png",
                            width: 48,
                          ),
                          SizedBox(height: 8,),
                          Text("Ewallet",style: TypographyStyles.text(16),),
                          Text("Ewallet balance: MVR ${1000}",style: TypographyStyles.text(12),),

                        ],),
                      ),
                    ),),
                    Container(),
                  ],
                ),
              ),
            )
          ]
        ),
      ),
    );
  }
}
