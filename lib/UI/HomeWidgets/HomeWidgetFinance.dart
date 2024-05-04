import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Controllers/ClientNotesController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Plugins/Utils.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/SignUpStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClientNotes.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClientNotes/SelectedClientNotes.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetFinance/Reports.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetFinance/Transactions.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class HomeWidgetFinance extends StatelessWidget {
  const HomeWidgetFinance({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxBool ready = false.obs;
    RxList transactions = [].obs;
    RxInt income = 0.obs;
    RxInt expense = 0.obs;
    TextEditingController topUpAmount = TextEditingController(text: '99');
    RxList clientNotes = [].obs;

    void getTransactions() async{
      ready.value = false;
      Map res = await httpClient.getTransactions();
      if (res['code'] == 200) {
        transactions.value = res['data'];
        await ClientNotesController.getClientNotes();
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    void getSummary()async {
      ready.value = false;
      Map res = await httpClient.getFinanceSummary();
      print("=========Summary");
      print(res);
      income.value = res['income'];
      expense.value = res['expense'];
      print('income.value');
      print(income.value);
      ready.value = true;
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

    RxList clientIds = [].obs;
    RxList clientDetails = [].obs;

    void getClientNotes() async {
      ready.value = false;
      Map res = await httpClient.getClientNotes({
        'trainer_id': authUser.id,
      });
      if (res['code'] == 200) {



        clientNotes.value = [];
        clientIds.value = [];
        clientDetails.value = [];

        clientNotes.value = res['data'];
        clientNotes.forEach((element) {
          clientIds.add(element["client_id"]);
        });

        clientIds.value = clientIds.toSet().toList();
        //print(clientNotes[0]);

        clientIds.forEach((clientId) {
          double tmpTotal = 0.0;
          String name = "";
          String url = "";
          clientNotes.forEach((element) {
            if(element["client_id"] == clientId){
              tmpTotal = tmpTotal + element["monthly_fee"];
              name = element["client"]["name"];
              url = element["client"]["avatar_url"];
            }
          });
          clientDetails.add({
            "id" : clientId,
            "name": name,
            "url" : url,
            "value" : tmpTotal,
          });
        });
        ready.value = true;
      } else {
        print(res);
        ready.value = true;
      }
    }

    getTransactions();
    getSummary();

    return Scaffold(
      appBar: AppBar(),
      body: Obx(()=> ready.value ? SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 0, bottom: 16, left: 16, right: 16),
            child: Column(
              children: [
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
                          Text('Profit Earned', style: TypographyStyles.text(16)),
                          SizedBox(height: 4),
                          Obx(()=>ready.value ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Obx(()=>RichText(
                                text: TextSpan(
                                    text: "MVR ",
                                    style: TypographyStyles.text(16).copyWith(color: AppColors.accentColor),
                                    children: [
                                      TextSpan(
                                        text: Utils.currencyFmt.format(income.value-expense.value),
                                        style: TypographyStyles.smallBoldTitle(26).copyWith(color: AppColors.accentColor),
                                      ),
                                    ]
                                ),
                              ),

                              ),
                            ],
                          ): Center(child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: CircularProgressIndicator()),
                          )),
                          SizedBox(height: 4),
                          // Obx(()=> ready.value ? Text('Tax - MVR15,920.00', style: TypographyStyles.boldText(16, Colors.white, )):Container(),),
                          SizedBox(height: 15),
                          SizedBox(
                            width: Get.width,
                            child: Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: (){

                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.greenAccent,
                                      foregroundColor: Colors.white,
                                      shape: Themes().roundedBorder(12),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("Income",
                                                style: TypographyStyles.text(16).copyWith(color: AppColors.textOnAccentColor),
                                              ),
                                              SizedBox(width: 10,),
                                              Container(
                                                padding: EdgeInsets.all(3),
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(100),
                                                  color: AppColors.textOnAccentColor
                                                ),
                                                child: SvgPicture.asset("assets/svgs/arrow-growth.svg",),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4,),
                                          RichText(
                                            text: TextSpan(
                                                text: "MVR ",
                                                style: TypographyStyles.text(14).copyWith(color: AppColors.textOnAccentColor),
                                                children: [
                                                  TextSpan(
                                                    text: Utils.currencyFmt.format(income.value),
                                                    style: TypographyStyles.title(20).copyWith(color: AppColors.textOnAccentColor),
                                                  ),
                                                ]
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10,),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: (){

                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.redAccent,
                                      foregroundColor: Colors.white,
                                      shape: Themes().roundedBorder(12),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text("Expenses",
                                                style: TypographyStyles.text(16).copyWith(color: AppColors.textOnAccentColor),
                                              ),
                                              SizedBox(width: 10,),
                                              Transform.rotate(
                                                angle: 1.1,
                                                child: Container(
                                                  padding: EdgeInsets.all(3),
                                                  width: 24,
                                                  height: 24,
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(100),
                                                      color: AppColors.textOnAccentColor
                                                  ),
                                                  child: SvgPicture.asset("assets/svgs/arrow-growth.svg",color: AppColors.redAccent,),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4,),
                                          RichText(
                                            text: TextSpan(
                                                text: "MVR ",
                                                style: TypographyStyles.text(14).copyWith(color: AppColors.textOnAccentColor),
                                                children: [
                                                  TextSpan(
                                                    text: Utils.currencyFmt.format(expense.value),
                                                    style: TypographyStyles.title(20).copyWith(color: AppColors.textOnAccentColor),
                                                  ),
                                                ]
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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

                SizedBox(
                  width: Get.width,
                  child: Row(
                    children: [

                      Visibility(
                        visible: authUser.role == 'trainer',
                        child: Expanded(
                          child: Container(
                            height: 90,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith((states) => AppColors().getSecondaryColor())
                              ),
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
                                    child: Image.asset("assets/icons/client.png", fit: BoxFit.fitHeight,),
                                  ),
                                  SizedBox(height: 10,),
                                  Text("Clients",
                                    style: TypographyStyles.boldText(10, Get.isDarkMode ? Colors.white : Colors.black),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      Visibility(
                        visible: authUser.role == 'trainer',
                        child: SizedBox(width: 8),
                      ),

                      Expanded(
                        child: Container(
                          height: 90,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith((states) => AppColors().getSecondaryColor())
                            ),
                            onPressed: (){
                              Get.to(() => Transactions());
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 8,),
                                SizedBox(
                                  height: 40,
                                  child: Image.asset("assets/icons/transaction.png", fit: BoxFit.fitHeight,),
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
                      // SizedBox(width: 4),
                      // Expanded(
                      //   child: Container(
                      //     height: 90,
                      //     child: ElevatedButton(
                      //       style: ButtonStyles.primaryButton(),
                      //       onPressed: (){},
                      //       child: Column(
                      //         mainAxisSize: MainAxisSize.min,
                      //         mainAxisAlignment: MainAxisAlignment.center,
                      //         crossAxisAlignment: CrossAxisAlignment.center,
                      //         children: [
                      //           SizedBox(height: 8,),
                      //           SizedBox(
                      //             height: 40,
                      //             child: Image.asset("assets/home/tax.png", fit: BoxFit.fitHeight,),
                      //           ),
                      //           SizedBox(height: 10,),
                      //           Text("Tax",
                      //             style: TypographyStyles.boldText(10, Get.isDarkMode ? Colors.white : Colors.black),
                      //             textAlign: TextAlign.center,
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 90,
                          child: ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: MaterialStateColor.resolveWith((states) => AppColors().getSecondaryColor())
                            ),
                            onPressed: (){
                              Get.to(() => Reports());
                            },
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(height: 8,),
                                SizedBox(
                                  height: 40,
                                  child: Image.asset("assets/icons/report.png", fit: BoxFit.fitHeight,),
                                ),
                                SizedBox(height: 10,),
                                Text("Reports",
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
                              style: ButtonStyles.primaryButton(),
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
                              style: ButtonStyles.primaryButton(),
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

                SizedBox(height: authUser.role == 'trainer' ? 10 : 24),

                Visibility(
                  visible: authUser.role == 'trainer',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Clients",
                            style: TypographyStyles.boldText(16, Get.isDarkMode ? Colors.white : Colors.black),
                          ),
                          TextButton(
                            onPressed: (){
                              Get.to(() => HomeWidgetClientNotes());
                            },
                            child: Text("View All",
                              style: TypographyStyles.boldText(14, Get.isDarkMode ? Colors.white : Colors.black),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 5),
                      SizedBox(
                          height: ClientNotesController.clientNotes.length > 0?90:230,
                          width: Get.width,
                          child: Obx(() => ClientNotesController.clientNotes.length > 0 ? ListView.separated(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: ClientNotesController.getUniqueClientsCount(),
                            separatorBuilder: (context, index) {
                              return SizedBox(width: 10,);
                            },
                            itemBuilder: (context, index) {

                              NumberFormat valueFmt = NumberFormat("###,###,###.##");
                              Map<String,dynamic> client = ClientNotesController.getUniqueClientsWithIncome()[index];

                              return ElevatedButton(
                                onPressed: (){
                                  Get.to(() => SelectedClientNote(clientId: client['client']['id'],));
                                },
                                style: ButtonStyles.matButton(colors.Colors().deepGrey(1), 0),
                                child: Container(
                                  width: Get.width-64,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        radius: 25,
                                        backgroundImage: CachedNetworkImageProvider(HttpClient.s3BaseUrl + client['client']['avatar_url']),
                                      ),
                                      SizedBox(width: 10,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("${client['client']['name'].toString().capitalize}", textAlign: TextAlign.center,style: TypographyStyles.text(16),),
                                          SizedBox(height: 4,),
                                          Text("MVR ${valueFmt.format(client['income'])}",
                                            style: TypographyStyles.text(14),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ): LoadingAndEmptyWidgets.emptyWidget())
                      ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
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
                    return SizedBox(height: 8,);
                  },
                  itemBuilder: (context,index){
                    // return Padding(
                    //   padding: EdgeInsets.symmetric(vertical: 5),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Expanded(
                    //         child: Column(
                    //           mainAxisSize: MainAxisSize.min,
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             SizedBox(
                    //               child: Text('${transactions[index]['type']} - ${transactions[index]['description']}',
                    //                 style: TypographyStyles.normalText(16, Get.isDarkMode ? Colors.white : Colors.black),
                    //                 overflow: TextOverflow.ellipsis,
                    //               ),
                    //               width: Get.width/100*70,
                    //             ),
                    //             SizedBox(height: 2,),
                    //             Text("${DateFormat("MMM dd,yyyy - HH:mm").format(DateTime.parse(transactions[index]['created_at']))}",
                    //               style: TypographyStyles.normalText(12, Get.isDarkMode ? colors.Colors().lightCardBG.withOpacity(0.6) : colors.Colors().darkGrey(0.7),),
                    //             )
                    //           ],
                    //         ),
                    //       ),
                    //       Text((Utils.formatCurrency.format(transactions[index]['amount'])).toString(),style: TypographyStyles.walletTransactions(16, transactions[index]['type']),),
                    //     ],
                    //   ),
                    // );
                    return  Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors().getSecondaryColor(),borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    child: Text('${transactions[index]['type']} - ${transactions[index]['description']}',
                                      style: TypographyStyles.normalText(16, Get.isDarkMode ? Colors.white : Colors.black),
                                    ),
                                    width: Get.width/100*70,
                                  ),
                                  SizedBox(height: 8,),
                                  Text("${DateFormat("MMM dd,yyyy - HH:mm").format(DateTime.parse(transactions[index]['created_at']).toLocal())}",
                                    style: TypographyStyles.text(14),
                                  )
                                ],
                              ),
                            ),
                            Text((Utils.formatCurrency.format(transactions[index]['amount'])).toString(),style: TypographyStyles.walletTransactions(16, transactions[index]['type']),),
                          ],
                        ),
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
