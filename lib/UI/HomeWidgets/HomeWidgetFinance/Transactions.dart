import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class Transactions extends StatelessWidget {
  const Transactions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxBool ready = false.obs;
    RxList transactions = [].obs;

    void getTransactions() async{
      ready.value = false;
      Map res = await httpClient.getTransactions();
      if (res['code'] == 200) {
        transactions.value = res['data'];
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    getTransactions();

    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Recent Transactions', style: TypographyStyles.title(18),)
              ],
            ),
          ),
          Expanded(
            child: Obx(() => ready.value ? transactions.isNotEmpty ? ListView.separated(
              shrinkWrap: true,
              itemCount: transactions.length,
              separatorBuilder: (context, index){
                return Divider(color: colors.Colors().darkGrey(1),);
              },
              itemBuilder: (context,index){
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            child: Text('${transactions[index]['type']} - ${transactions[index]['description']}',
                              style: TypographyStyles.normalText(16, Get.isDarkMode ? Colors.white : Colors.black),
                            ),
                            width: Get.width/100*70,
                          ),
                          SizedBox(height: 2,),
                          Text("${DateFormat("MMM dd,yyyy - HH:mm").format(DateTime.parse(transactions[index]['created_at']))}",
                            style: TypographyStyles.normalText(12, Get.isDarkMode ? colors.Colors().lightCardBG.withOpacity(0.6) : colors.Colors().darkGrey(0.7),),
                          )
                        ],
                      ),
                      Text((Utils.formatCurrency.format(transactions[index]['amount']/100)).toString(),style: TypographyStyles.walletTransactions(16, transactions[index]['type']),),
                    ],
                  ),
                );
              },
            ) : LoadingAndEmptyWidgets.emptyWidget() : LoadingAndEmptyWidgets.loadingWidget()),
          ),
        ],
      )
    );
  }
}
