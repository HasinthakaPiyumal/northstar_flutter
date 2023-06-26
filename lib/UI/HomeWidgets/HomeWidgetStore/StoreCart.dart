import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/StoreHelper.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';

class StoreCart extends StatelessWidget {
  const StoreCart({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;

    void refreshCart() async{
      await storeHelper.refreshCart();
      ready.value = true;
    }

    refreshCart();

    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Obx(()=> ready.value ? storeHelper.cart.isNotEmpty ? Column(
        children: <Widget>[
          Expanded(
            child: Obx(()=>ListView.builder(
              itemCount: storeHelper.cart.length,
              itemBuilder: (context, index) {

                print(storeHelper.cart[index]);
                return ListTile(
                  leading: ClipRRect(
                    child: CachedNetworkImage(
                      imageUrl: storeHelper.cart[index]['product']['image_path'],
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  title: Text(storeHelper.cart[index]['product']['name']),
                  subtitle: Text('Quantity: ${storeHelper.cart[index]['quantity']} \nU. Price: ${authUser.user['currency']} ${storeHelper.cart[index]['product']['price']}'),
                  trailing: Container(
                    width: 40,
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.all(0),
                      ),
                      child: Icon(Icons.delete, color: Colors.white),
                      onPressed: (){
                        CommonConfirmDialog.confirm('Remove').then((confirmed){
                          if(confirmed){
                            storeHelper.removeFromCart(storeHelper.cart[index]['id']);
                          }
                        });
                      },
                    ),
                  ),
                );
              },
            )),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
            color: Colors.grey[800],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order Summary',
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
                    Text('${authUser.user['currency']} ${storeHelper.getCartTotal()}',
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
          Container(
            color: Colors.grey[800],
            height: 64,
            width: Get.width,
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton(
              onPressed: null,
              style: ButtonStyles.bigBlackButton(),
              child: Text('BUYING UNAVAILABLE'),
            ),
          ),
          Container(
              color: Colors.grey[800],
              height: 16),
        ],
      ): Center(
        child: LoadingAndEmptyWidgets.emptyWidget(),
      ): Center(
        child: LoadingAndEmptyWidgets.loadingWidget(),
      )),
    );
  }
}
