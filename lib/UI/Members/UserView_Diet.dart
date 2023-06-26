import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Members/User_DietFoodsView.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class UserViewDiet extends StatelessWidget {
  const UserViewDiet({Key? key, required this.data}) : super(key: key);

  final data;

  @override
  Widget build(BuildContext context) {
    RxList mealData = [].obs;
    RxBool ready = false.obs;

    void getData() async{
      ready.value = false;
      Map res = await httpClient.getLast30DayMeals(data['id']);
      if(res['code'] == 200){
        mealData.value = res['data'];
        print(res['data']);
      } else {
        print(res);
      }
      ready.value = true;
    }

    getData();

    return Scaffold(
      body: Obx(()=> ready.value ? mealData.length > 0 ? Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [

            SizedBox(height: 20,),

            Expanded(
              child: ListView.builder(
                itemCount: mealData.length,
                itemBuilder: (context, index){

                  print(mealData[index]);

                  var eatenCarbs = mealData[index]['carbs'];
                  var eatenFat = mealData[index]['fat'];
                  var eatenProteins =mealData[index]['protein'];

                  var targetCarbs = mealData[index]['macro_profile']['target_carbs'];
                  var targetFat = mealData[index]['macro_profile']['target_fat'];
                  var targetProtein = mealData[index]['macro_profile']['target_protein'];

                  return Padding(
                    padding: EdgeInsets.only(bottom: 15),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().lightCardBG,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Material(
                        color: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: (){
                            Get.to(()=>UserDietFoodsView(
                              mealData: mealData[index],
                              eatenCal: mealData[index]['calories'].ceil(),
                              targetCal: mealData[index]['macro_profile']['target_calories'].ceil(),
                              eatenCarbs: eatenCarbs.ceil(),
                              eatenFat: eatenFat.ceil(),
                              eatenProteins: eatenProteins.ceil(),
                              targetCarbs: targetCarbs.ceil(),
                              targetFat: targetFat.ceil(),
                              targetProteins: targetProtein.ceil(),
                            ));
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${mealData[index]['date']}',
                                  style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                ),
                                SizedBox(height: 10,),
                                Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Text("Eaten",
                                        style: TypographyStyles.boldText(15,  Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.5) : colors.Colors().lightBlack(0.6)),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text("${mealData[index]['calories'].ceil()} Cal",
                                            style: TypographyStyles.boldText(22, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                          ),
                                          Text("${-1*(mealData[index]['macro_profile']['target_calories'] - mealData[index]['calories']).ceil()} Cal",
                                            style: TypographyStyles.normalText(
                                              16, Themes.mainThemeColorAccent.shade100,
                                            ).copyWith(color: mealData[index]['macro_profile']['target_calories'] - mealData[index]['calories'] > 0 ? Colors.green : Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20,),
                                    Container(
                                      height: 80,
                                      width: 1,
                                      color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.3) : colors.Colors().lightBlack(0.5),
                                    ),
                                    SizedBox(width: 20,),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Carbs",
                                                style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.6) : colors.Colors().lightBlack(0.5)),
                                              ),
                                              Text("${eatenCarbs.toStringAsFixed(1)}g",
                                                style: TypographyStyles.boldText(14,
                                                  targetCarbs - eatenCarbs > 0 ? Colors.green : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Fat",
                                                style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.6) : colors.Colors().lightBlack(0.5)),
                                              ),
                                              Text("${eatenFat.toStringAsFixed(1)}g",
                                                style: TypographyStyles.boldText(14,
                                                  targetFat - eatenFat > 0 ? Colors.green : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 10,),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text("Protein",
                                                style: TypographyStyles.boldText(14, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100.withOpacity(0.6) : colors.Colors().lightBlack(0.5)),
                                              ),
                                              Text("${eatenProteins.toStringAsFixed(1)}g",
                                                style: TypographyStyles.boldText(14,
                                                  targetProtein - eatenProteins > 0 ? Colors.green : Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Expanded(
            //   child: ListView.builder(
            //     itemCount: mealData.length,
            //     itemBuilder: (context, index){
            //       return Card(
            //         margin: EdgeInsets.all(2),
            //         child: InkWell(
            //           onTap: (){},
            //           child: Padding(
            //             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            //             child: Row(
            //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //               children: [
            //                 Text(mealData[index]['created_at'].split('T')[0]),
            //                 Text(mealData[index]['calories'].toString()),
            //                 Text(mealData[index]['carbs'].toString()),
            //                 Text(mealData[index]['protein'].toString()),
            //                 Text(mealData[index]['fat'].toString()),
            //               ],
            //             ),
            //           ),
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        )
      ) : LoadingAndEmptyWidgets.emptyWidget():LoadingAndEmptyWidgets.loadingWidget()),
    );
  }
}
