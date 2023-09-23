import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/PrivateUser/CaloriesManager/NewFood.dart';
import 'package:north_star/UI/PrivateUser/CaloriesManager/NewIngredientsFood.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../../Styles/AppColors.dart';
import '../../../components/Buttons.dart';

class EditMeal extends StatelessWidget {
  const EditMeal({Key? key, required this.foodList, required this.mealID, required this.selectedDay, required this.editMode}) : super(key: key);

  final List foodList;
  final int mealID;
  final Map selectedDay;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    RxList foods = [].obs;
    RxBool ready = false.obs;
    RxBool changesSaved = true.obs;

    Future<List> searchFoods(pattern) async{
      Map res = await httpClient.searchFoods(pattern);

      if (res['code'] == 200) {
        return res['data'];
      } else {
        return [];
      }
    }

    void saveMeal() async {
      ready.value = false;
      changesSaved.value = true;
      Map res = await httpClient.editMeals({
        'meal_id': mealID.toString(),
        'food_data': json.encode(foods.value),
        'day': selectedDay['value']
      });

      if (res['code'] == 200) {
        print(res);
        Get.back();
        showSnack('Success!', 'Your meal has been saved.');
        ready.value = true;
      } else {
        ready.value = true;
      }
    }

    void deleteMeal(mealID) async{
      CommonConfirmDialog.confirm('Delete').then((value) async {
        if(value) {
          Map res = await httpClient.deleteMeal(mealID);
          print(res);
          if(res['code'] == 200){
            Get.back();
            showSnack('Success!', 'Your meal has been deleted.');
          }
        }
      });

    }

    void assignFood() {
      foods.value = foodList;
    }

    void removeFood(index) {
      CommonConfirmDialog.confirm('Remove This Food').then((value) async {
        if(value) {
          foods.removeAt(index);
          changesSaved.value = false;
        }
      });
    }

    assignFood();

    return WillPopScope(
      onWillPop: () async {
        if(foods.length > 0 && changesSaved.value) {
          return true;
        } else {
          CommonConfirmDialog.confirm('Discard Changes').then((value) async {
            if(value) {
              Get.back();
            }
          });
          return false;
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Edit Meal'),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteMeal(mealID);

              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: (){
              Get.defaultDialog(
                radius: 10,
                titlePadding: EdgeInsets.only(top: 20),
                contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 10),
                title: 'Custom Food',
                backgroundColor: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                content: Column(
                  children: [
                    Container(
                      height: 60,
                      width: Get.width,
                      child: ElevatedButton(
                        style: ButtonStyles.matRadButton(Get.isDarkMode ? AppColors.primary1Color: colors.Colors().selectedCardBG, 0, 5),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                          child: Text('Ingredients Based',style: TypographyStyles.title(14)),
                        ),
                        onPressed: (){
                          Get.back();
                          Get.to(()=>NewIngredientsFood())?.then((value){
                            if(value != null){
                              if(value.length > 0){
                                foods.add(value[0]);
                              }
                            }
                          });
                        },
                      ),
                    ),

                    SizedBox(height: 16),

                    Container(
                      height: 60,
                      width: Get.width,
                      child: ElevatedButton(
                        style: ButtonStyles.matRadButton(Get.isDarkMode ? AppColors.primary1Color : colors.Colors().selectedCardBG, 0, 5),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 20,),
                          child: Text('Nutrients Based',style: TypographyStyles.title(14),),
                        ),
                        onPressed: (){
                          Get.back();
                          Get.to(()=>NewFood())?.then((value){
                            if(value != null){
                              if(value.length > 0){
                                foods.add(value[0]);
                              }
                            }
                          });
                        },
                      ),
                    )
                  ],
                ),
              );
            },
            child: Icon(Icons.add, color: AppColors.textOnAccentColor),
            backgroundColor: AppColors.accentColor
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TypeAheadField(
                  hideOnEmpty: true,
                  hideOnError: true,
                  hideOnLoading: true,
                  textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search Foods...',
                        hintText: 'Start Typing to Search Foods...',
                        border: UnderlineInputBorder(),
                      )
                  ),
                  suggestionsBoxDecoration: SuggestionsBoxDecoration(color: Get.isDarkMode?AppColors.primary2Color:Colors.white),
                  suggestionsCallback: (pattern) async {
                    return await searchFoods(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    var jsonObj = jsonDecode(jsonEncode(suggestion));

                    return ListTile(
                      title: Text(jsonObj['name']),
                      subtitle: Text(jsonObj['calories'].toString() + ' Cals'),
                    );
                  },
                  onSuggestionSelected: (suggestion) {

                    var jsonObj = jsonDecode(jsonEncode(suggestion));

                    var already = foods.firstWhereOrNull((element) => element['id'] == jsonObj['id']);
                    if (already == null){
                      jsonObj['no_of_potions'] = 1;
                      foods.add(jsonObj);
                      changesSaved.value = false;
                    } else {
                      print('already added');
                    }
                  },
                ),
              ),
              Divider(),
              Expanded(
                child: Obx(()=> ListView.builder(
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: (){
                        print(foods[index]);
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          isScrollControlled: true,
                          builder: (BuildContext bc) {
                            return SafeArea(
                              child: Container(
                                width: Get.width,
                                decoration: BoxDecoration(
                                  color: Get.isDarkMode ? AppColors.primary2Color : Colors.white,
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(25.0),
                                    topRight: const Radius.circular(25.0),
                                  ),
                                ),
                                child: Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              margin: EdgeInsets.only(top: 8),
                                              width: 64,
                                              height: 4,
                                              decoration: BoxDecoration(
                                                color: AppColors.accentColor,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16),
                                        Container(
                                          width: Get.width,
                                          decoration: BoxDecoration(
                                            color: Get.isDarkMode ? AppColors.primary1Color : colors.Colors().selectedCardBG,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text("Calories ${foods[index]['calories']}",
                                                  style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                                                ),
                                                SizedBox(height: 5,),
                                                Text("(Based on 1 Portion)",),
                                              ],
                                            ),
                                          ),
                                        ),

                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                          child: Text("Nutrition Facts",
                                            style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                                          ),
                                        ),

                                        Container(
                                          width: Get.width,
                                          decoration: BoxDecoration(
                                            color: Get.isDarkMode ? AppColors.primary1Color : colors.Colors().selectedCardBG,
                                            borderRadius: BorderRadius.circular(15),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("Carbohydrates"),
                                                      Text("${foods[index]['carbs'].toString()}g"),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("Proteins"),
                                                      Text("${foods[index]['proteins'].toString()}g"),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("Fat"),
                                                      Text("${foods[index]['fat'].toString()}g"),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("Saturated Fat"),
                                                      Text("${foods[index]['sat_fat'].toString()}g"),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.only(bottom: 10),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    children: [
                                                      Text("Fibers"),
                                                      Text("${foods[index]['fibers'].toString()}g"),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),

                                        foods[index]['ingredients'].length > 0 ? Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                                          child: Text("Ingredients",
                                            style: TypographyStyles.boldText(16, Themes.mainThemeColorAccent.shade100),
                                          ),
                                        ) : SizedBox(),

                                        foods[index]['ingredients'].length > 0 ? Container(
                                          width: Get.width,
                                          height: Get.height/100*12,
                                          child: ListView.builder(
                                            itemCount: foods[index]['ingredients'].length,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, i) => Padding(
                                              padding: EdgeInsets.only(right: 7),
                                              child: Container(
                                                width: Get.width*0.55,
                                                decoration: BoxDecoration(
                                                  color: Themes.mainThemeColorAccent.withOpacity(0.3),
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Flexible(
                                                        child: Text("${foods[index]['ingredients'][i]['name'].toString()}",
                                                          style: TypographyStyles.boldText(16, Themes.mainThemeColorAccent.shade100),
                                                        ),
                                                      ),
                                                      SizedBox(height: 7,),
                                                      Flexible(
                                                        child: Text("${foods[index]['ingredients'][i]['no_of_potions']} - ${foods[index]['ingredients'][i]['total_calories']} Cal",
                                                          style: TypographyStyles.boldText(14, Themes.mainThemeColorAccent.shade100.withOpacity(0.5)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ) : SizedBox(),

                                        Padding(
                                          padding: EdgeInsets.symmetric(vertical: 5),
                                          child: Divider(
                                            thickness:1,
                                          ),
                                        ),

                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                padding: EdgeInsets.only(right: 20),
                                                child: Column(
                                                  children: [
                                                    Column(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Text("Portion Size",
                                                          style: TypographyStyles.normalText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().darkGrey(1),),
                                                        ),
                                                        SizedBox(height: 10,),
                                                        Text("${foods[index]['potion']}",
                                                          style: TypographyStyles.boldText(20, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().darkGrey(1),),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Get.isDarkMode ? AppColors.primary1Color : colors.Colors().selectedCardBG,
                                                  borderRadius: BorderRadius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    children: [
                                                      Text("Portions",
                                                        style: TypographyStyles.boldText(18, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().darkGrey(1),),
                                                      ),
                                                      SizedBox(height: 5,),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.center,
                                                        children: [
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                if (foods[index]['no_of_potions'] > 1){
                                                                  foods[index]['no_of_potions'] -= 1;
                                                                  foods.add({
                                                                    'id':'DUMMY',
                                                                    'name':'DUMMY',
                                                                  });
                                                                  foods.removeLast();
                                                                }
                                                              },
                                                              child: Icon(Icons.remove, color: Colors.white),
                                                              style: ElevatedButton.styleFrom(
                                                                shape: CircleBorder(),
                                                                padding: EdgeInsets.all(10),
                                                                backgroundColor: Get.isDarkMode ? AppColors.primary2Color : colors.Colors().deepGrey(0.6),
                                                                foregroundColor: colors.Colors().deepYellow(1),
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(width: 16),
                                                          Obx(()=> Text(foods[index]['no_of_potions'].toString(), style: TypographyStyles.title(21).copyWith(color: AppColors.accentColor))),
                                                          SizedBox(width: 16),
                                                          Expanded(
                                                            child: ElevatedButton(
                                                              onPressed: () {
                                                                if(foods[index]['no_of_potions'] < 16){
                                                                  foods[index]['no_of_potions'] += 1;
                                                                  foods.add({
                                                                    'id':'DUMMY',
                                                                    'name':'DUMMY',
                                                                  });
                                                                  foods.removeLast();
                                                                }
                                                              },
                                                              child: Icon(Icons.add, color: Colors.white),
                                                              style: ElevatedButton.styleFrom(
                                                                shape: CircleBorder(),
                                                                padding: EdgeInsets.all(10),
                                                                backgroundColor: Get.isDarkMode ? AppColors.primary2Color : colors.Colors().deepGrey(0.6),
                                                                foregroundColor: colors.Colors().deepYellow(1), // <-- Splash color
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    )
                                ),
                              ),
                            );
                          },
                        );
                      },
                      child: Column(
                        children: [
                          ListTile(
                            title: Text(foods[index]['name'], style: TypographyStyles.title(16),),
                            subtitle: Text(foods[index]['calories'].toString()+ ' Cals' + " (${foods[index]['potion'].toString()})"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Portions: ${foods[index]['no_of_potions'].toString()}'),
                                SizedBox(width: 8),
                                IconButton(
                                  icon: Icon(Icons.highlight_remove_rounded, color: Colors.red),
                                  onPressed: (){
                                    removeFood(index);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider()
                        ],
                      ),
                    );
                  },
                )),
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Container(
            margin: EdgeInsets.only(top: 8),
            width: Get.width,
            child: Obx(()=>foods.length>0?Buttons.yellowFlatButton(onPressed: (){
              saveMeal();

            },label: "save"):Buttons.yellowTextIconButton(onPressed: (){
              deleteMeal(mealID);
            },label: "delete",icon:Icons.delete_outline_rounded))
          ),
        ),
      ),
    );
  }
}
