import 'package:north_star/Models/HttpClient.dart';

class TaxController{
  static int taxType = 1;
  static double taxPercentage = 0;
  static double taxRate = 0;

  void refresh()async{
    Map res = await httpClient.getTax();
    if(res['code']==200){
      taxType = int.parse(res['data'][0]['tax_type']);
      if(taxType==1){
        taxPercentage = res['data'][0]['percentage'].toDouble();
      }else if(taxType==2){
        taxRate = res['data'][0]['flat_rate'].toDouble();
      }
    }
  }
  double getCalculatedTax(double amount){
    if(taxType==1){
      return amount*taxPercentage/100;
    }else{
      return taxRate;
    }
  }
}

TaxController taxController = TaxController();