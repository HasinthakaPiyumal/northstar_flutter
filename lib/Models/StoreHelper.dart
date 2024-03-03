import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Utils/PopUps.dart';

class StoreHelper{
  RxList cart = [].obs;

  Future refreshCart() async{
    Map res = await httpClient.getMyCart();

    print('cart====');
    print(res);
    if(res['code'] == 200){
      cart.value = res['data'];
    }
    return 0;
  }

  double getCartTotal(){
    double total = 0;
    cart.forEach((item){
      total += item['product']['price'] * item['quantity'];
    });
    return total;
  }

  Future addToCart(int productID, int quantity) async{
    Map res = await httpClient.addToCart(productID, quantity);
    if(res['code'] == 200){
      refreshCart();
      showSnack('Item Added to your Cart!', 'The item has been added to your cart.');
    } else {
      refreshCart();
      showSnack('Error', 'An error occurred while adding the item to your cart.');
    }
    return 0;
  }

  Future removeFromCart(int cartItemID) async{
    Map res = await httpClient.removeFromCart(cartItemID);
    if(res['code'] == 200){
      showSnack('Item Removed from your Cart!', 'The item has been removed from your cart.');
      refreshCart();
    } else {
      refreshCart();
      showSnack('Error', 'An error occurred while removing the item from your cart.');
    }
    return 0;
  }
}

StoreHelper storeHelper = new StoreHelper();
