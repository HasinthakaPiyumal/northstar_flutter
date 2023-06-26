import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Controllers/ClientNotesController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClientNotes.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClientNotes/SelectedClientNotes.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class Wallet extends StatelessWidget {
  const Wallet({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxBool ready = false.obs;

    RxMap data = {}.obs;
    RxList transactions = [].obs;
    TextEditingController topUpAmount = TextEditingController(text: '99');
    RxList clientNotes = [].obs;

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

    void topUp(String amount) async{
      ready.value = false;
      int amountInt = int.parse(amount.toString());
      Map res = await httpClient.topUpWallet({
        'amount': amountInt * 100,
      });
      if(res['code'] == 200){
        await launchUrl(Uri.parse(res['data']['url']));
      } else {
        print(res);
      }
      ready.value = true;
    }

    void getWallet() async{
      ready.value = false;
      Map res = await httpClient.getWallet();

      if (res['code'] == 200) {
        data.value = res['data'];
        getTransactions();
        await ClientNotesController.getClientNotes();
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    getWallet();


    return Scaffold(
      body: Obx(()=> ready.value ? SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 16, left: 16, right: 16),
            child: Column(
              children: [

                authUser.role != 'trainer' ? Row(
                  children: [
                    IconButton(
                      onPressed: (){Get.back();},
                      icon: Icon(Icons.arrow_back),
                    )
                  ],
                ): SizedBox(height: 5),

                Container(
                  width: Get.width,
                  margin: const EdgeInsets.all(0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Available Balance', style: TypographyStyles.title(18)),
                          SizedBox(height: 4),
                          Obx(()=>ready.value ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: "Rf ",
                                  style: TypographyStyles.normalText(22, Get.isDarkMode ? Colors.white : Colors.black),
                                  children: [
                                    TextSpan(
                                      text: Utils.currencyFmt.format(data['balance']/100),
                                      style: TypographyStyles.title(48),
                                    ),
                                  ]
                                ),
                              ),
                            ],
                          ): Center(child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: CircularProgressIndicator()),
                          )),
                          SizedBox(height: 4),
                          Obx(()=> ready.value ? Text('Last update on ' + data['updated_at'].split('T')[0], style: TypographyStyles.normalText(13, Color(0xFF8D8D8D), )):Container(),),
                          SizedBox(height: 15),
                          SizedBox(
                            width: Get.width,
                            child: Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: (){
                                        Get.defaultDialog(
                                          radius: 8,
                                          title: 'TopUp Amount',
                                          content: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
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
                                                SizedBox(height: 16),
                                                TextField(
                                                  controller: topUpAmount,
                                                  keyboardType: TextInputType.number,
                                                  decoration: InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    labelText: 'TopUp Amount',
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          actions: [
                                            Container(
                                              width: Get.width,
                                              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                              child: ElevatedButton(
                                                onPressed: (){
                                                  Get.back();
                                                  topUp(topUpAmount.text);
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
                                                        Text('TopUp with Card',
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
                                          ]
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.black,
                                        foregroundColor: Colors.white,
                                        shape: Themes().roundedBorder(16),
                                      ),
                                      child: Text('TOPUP CREDITS'),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Container(
                                  height: 56,
                                  width: 56,
                                  child: ElevatedButton(
                                    onPressed: (){
                                      getWallet();
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: Themes().roundedBorder(16),
                                    ),
                                    child: Icon(Icons.refresh),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16),

                Visibility(
                  visible: authUser.role == 'client',
                  child:  SizedBox(
                    width: Get.width,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 90,
                            child: ElevatedButton(
                              style: ButtonStyles.bigBlackButton(),
                              onPressed: (){
                                Get.to(() => HomeWidgetClientNotes());
                              },
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 8,),
                                  SizedBox(
                                    height: 40,
                                    child: Image.asset("assets/home/note.png", fit: BoxFit.fitHeight,),
                                  ),
                                  SizedBox(height: 10,),
                                  Text("Payment Requests",
                                    style: TypographyStyles.boldText(10, Get.isDarkMode ? Colors.white : Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Container(
                            height: 90,
                            child: ElevatedButton(
                              style: ButtonStyles.bigBlackButton(),
                              onPressed: null,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(height: 8,),
                                  SizedBox(
                                    height: 40,
                                    child: Image.asset("assets/home/trans.png", fit: BoxFit.fitHeight,),
                                  ),
                                  SizedBox(height: 10,),
                                  Text("Transactions",
                                    style: TypographyStyles.boldText(10, Get.isDarkMode ? Colors.white : Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: authUser.role == 'trainer' ? 0 : 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Recent Transactions', style: TypographyStyles.title(18),)
                  ],
                ),
                SizedBox(height: 16),
                transactions.isEmpty ? LoadingAndEmptyWidgets.emptyWidget(): ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: transactions.length,
                  separatorBuilder: (context, index){
                    return Divider(color: colors.Colors().darkGrey(1),);
                  },
                  itemBuilder: (context,index){
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 5),
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
                ),
              ],
            ),
          ),
        ),
      ): LoadingAndEmptyWidgets.loadingWidget()),
    );
  }
}
