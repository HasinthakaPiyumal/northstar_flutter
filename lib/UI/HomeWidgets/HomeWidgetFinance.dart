import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
                          Text('Profit Earned', style: TypographyStyles.boldText(18, Get.isDarkMode ? Color(0xFF8D8D8D) : Colors.black)),
                          SizedBox(height: 4),
                          Obx(()=>ready.value ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Obx(()=>RichText(
                                  text: TextSpan(
                                      text: "MVR ",
                                      style: TypographyStyles.normalText(22, Get.isDarkMode ? Colors.white : Colors.black),
                                      children: [
                                        TextSpan(
                                          text: Utils.currencyFmt.format(income.value-expense.value),
                                          style: TypographyStyles.title(48),
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
                                      backgroundColor: Get.isDarkMode?AppColors.primary2Color:Colors.white,
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
                                              Transform.rotate(
                                                angle: 1,
                                                child: Icon(Icons.arrow_upward, color: Colors.green, size: 18),
                                              ),
                                              Text("Income",
                                                style: TypographyStyles.normalText(14, Color(0xFF8D8D8D)),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 4,),
                                          RichText(
                                            text: TextSpan(
                                                text: "MVR ",
                                                style: TypographyStyles.normalText(14, Get.isDarkMode ? Colors.white : Colors.black),
                                                children: [
                                                  TextSpan(
                                                    text: Utils.currencyFmt.format(income.value),
                                                    style: TypographyStyles.title(18),
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
                                      backgroundColor: Get.isDarkMode?AppColors.primary2Color:Colors.white,
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
                                              Transform.rotate(
                                                angle: 2,
                                                child: Icon(Icons.arrow_upward, color: Colors.red, size: 18),
                                              ),
                                              Text("Expenses",
                                                style: TypographyStyles.normalText(14, Color(0xFF8D8D8D)),
                                              )
                                            ],
                                          ),
                                          SizedBox(height: 4,),
                                          RichText(
                                            text: TextSpan(
                                                text: "MVR ",
                                                style: TypographyStyles.normalText(14, Get.isDarkMode ? Colors.white : Colors.black),
                                                children: [
                                                  TextSpan(
                                                    text: Utils.currencyFmt.format(expense.value),
                                                    style: TypographyStyles.title(18),
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
                        child: SizedBox(width: 4),
                      ),

                      Expanded(
                        child: Container(
                          height: 90,
                          child: ElevatedButton(
                            style: ButtonStyles.bigBlackButton(),
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
                      // SizedBox(width: 4),
                      // Expanded(
                      //   child: Container(
                      //     height: 90,
                      //     child: ElevatedButton(
                      //       style: ButtonStyles.bigBlackButton(),
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
                      SizedBox(width: 4),
                      Expanded(
                        child: Container(
                          height: 90,
                          child: ElevatedButton(
                            style: ButtonStyles.bigBlackButton(),
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
                                  child: Image.asset("assets/home/report.png", fit: BoxFit.fitHeight,),
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
                          height: Get.height/100*16,
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
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 25,
                                      backgroundImage: CachedNetworkImageProvider(HttpClient.s3BaseUrl + client['client']['avatar_url']),
                                    ),
                                    SizedBox(height: 10,),
                                    SizedBox(
                                      width: Get.width/100*24,
                                      child: Text("${client['client']['name'].toString().split(" ").first}", textAlign: TextAlign.center,),
                                    ),
                                    SizedBox(height: 4,),
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text("MVR",
                                          style: TypographyStyles.normalText(12, Get.isDarkMode ? Colors.white : Colors.black),
                                        ),
                                        SizedBox(width: 3,),
                                        Text("${valueFmt.format(client['income'])}",
                                          style: TypographyStyles.boldText(18, Get.isDarkMode ? Colors.white : Colors.black),
                                        ),
                                      ],
                                    ),
                                  ],
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
