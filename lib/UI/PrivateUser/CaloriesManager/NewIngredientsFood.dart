import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class NewIngredientsFood extends StatelessWidget {
  const NewIngredientsFood({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxList foods = [].obs;

    Future<List> searchIngredients(pattern) async {
      Map res = await httpClient.searchFoods(pattern);
      if (res['code'] == 200) {
        return res['data'];
      } else {
        return [];
      }
    }

    TextEditingController nameController = TextEditingController();
    TextEditingController potionController = TextEditingController();

    void saveFood() async {
      double calories = 0;
      double carbs = 0;
      double proteins = 0;
      double fat = 0;
      double satFat = 0;
      double fibers = 0;
      List ingredients = [];

      foods.forEach((element) {
        calories += double.parse(element['calories'].toString()) *
            element['no_of_potions'];
        carbs += double.parse(element['carbs'].toString()) *
            element['no_of_potions'];
        proteins += double.parse(element['proteins'].toString()) *
            element['no_of_potions'];
        fat +=
            double.parse(element['fat'].toString()) * element['no_of_potions'];
        satFat += double.parse(element['sat_fat'].toString()) *
            element['no_of_potions'];
        fibers += double.parse(element['fibers'].toString()) *
            element['no_of_potions'];
        ingredients.add({
          'id': element['id'],
          'name': element['name'],
          'no_of_potions': element['no_of_potions'],
          'potion': element['potion'],
          'total_calories': double.parse(element['calories'].toString()) *
              element['no_of_potions'],
        });
      });

      if (nameController.text.isNotEmpty && potionController.text.isNotEmpty) {
        Map res = await httpClient.saveCustomFood({
          'name': nameController.text,
          'potion': potionController.text,
          'calories': calories,
          'carbs': carbs,
          'proteins': proteins,
          'fat': fat,
          'sat_fat': satFat,
          'fibers': fibers,
          'ingredients': ingredients
        });
        print(res);
        if (res['code'] == 200) {
          Map backData = res['data']['food'];
          backData['no_of_potions'] = 1;
          Get.back(result: [backData]);
          showSnack('Food Submitted!', 'Food Submitted for admin Approval');
        } else {
          showSnack('Error', 'Error Submitting Food');
        }
      } else {
        showSnack('Fill All the Fields!',
            'Name and Potion information are required!');
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('New Food via Ingredients'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Name',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: potionController,
              decoration: InputDecoration(
                labelText: 'Potion Size (eg: 1 Cup)',
              ),
            ),
            SizedBox(height: 25),
            Text(
              "ADD INGREDIENTS",
              style: TypographyStyles.boldText(
                14,
                Get.isDarkMode
                    ? Themes.mainThemeColorAccent.shade100
                    : colors.Colors().lightBlack(1),
              ),
              textAlign: TextAlign.left,
            ),
            SizedBox(height: 15),
            TypeAheadField(
              hideOnEmpty: true,
              hideOnError: true,
              hideOnLoading: true,
              builder: (context, controller, focusNode) {
                return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search Ingredients...',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                    ));
              },
              suggestionsCallback: (pattern) async {
                return await searchIngredients(pattern);
              },
              itemBuilder: (context, suggestion) {
                var jsonObj = jsonDecode(jsonEncode(suggestion));

                return ListTile(
                  title: Text(jsonObj['name']),
                  subtitle: Text(jsonObj['calories'].toString() + ' Cals'),
                );
              },
              onSelected: (suggestion) {
                var jsonObj = jsonDecode(jsonEncode(suggestion));

                var already = foods.firstWhereOrNull(
                    (element) => element['id'] == jsonObj['id']);
                if (already == null) {
                  jsonObj['no_of_potions'] = 1;
                  foods.add(jsonObj);
                } else {
                  print('already added');
                }
              },
            ),
            Divider(),
            Expanded(
              child: Obx(() => ListView.builder(
                    itemCount: foods.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.transparent,
                            isScrollControlled: true,
                            builder: (BuildContext bc) {
                              return SafeArea(
                                child: Container(
                                  width: Get.width,
                                  decoration: BoxDecoration(
                                    color: Get.isDarkMode
                                        ? colors.Colors().deepGrey(1)
                                        : colors.Colors().lightCardBG,
                                    borderRadius: new BorderRadius.only(
                                      topLeft: const Radius.circular(25.0),
                                      topRight: const Radius.circular(25.0),
                                    ),
                                  ),
                                  child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                margin: EdgeInsets.only(top: 8),
                                                width: 64,
                                                height: 4,
                                                decoration: BoxDecoration(
                                                  color: Colors.grey.shade600,
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 16),
                                          Container(
                                            width: Get.width,
                                            decoration: BoxDecoration(
                                              color: Get.isDarkMode
                                                  ? Themes.mainThemeColorAccent
                                                  : colors.Colors()
                                                      .selectedCardBG,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 25, horizontal: 20),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Calories ${foods[index]['calories']}",
                                                    style: TypographyStyles
                                                        .boldText(
                                                      18,
                                                      Get.isDarkMode
                                                          ? Themes
                                                              .mainThemeColorAccent
                                                              .shade100
                                                          : colors.Colors()
                                                              .lightBlack(1),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    "(Based on 1 Portion)",
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 15),
                                            child: Text(
                                              "Nutrition Facts",
                                              style: TypographyStyles.boldText(
                                                16,
                                                Get.isDarkMode
                                                    ? Themes
                                                        .mainThemeColorAccent
                                                        .shade100
                                                    : colors.Colors()
                                                        .lightBlack(1),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: Get.width,
                                            decoration: BoxDecoration(
                                              color: Get.isDarkMode
                                                  ? Themes.mainThemeColorAccent
                                                      .withOpacity(0.3)
                                                  : colors.Colors()
                                                      .selectedCardBG,
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                            ),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 25, horizontal: 20),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text("Carbohydrates"),
                                                        Text(
                                                            "${foods[index]['carbs'].toString()}g"),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text("Proteins"),
                                                        Text(
                                                            "${foods[index]['proteins'].toString()}g"),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text("Fat"),
                                                        Text(
                                                            "${foods[index]['fat'].toString()}g"),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text("Saturated Fat"),
                                                        Text(
                                                            "${foods[index]['sat_fat'].toString()}g"),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: 10),
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text("Fibers"),
                                                        Text(
                                                            "${foods[index]['fibers'].toString()}g"),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 5),
                                            child: Divider(
                                              thickness: 1,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Container(
                                                  padding: EdgeInsets.only(
                                                      right: 20),
                                                  child: Column(
                                                    children: [
                                                      Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "Portion Size",
                                                            style:
                                                                TypographyStyles
                                                                    .normalText(
                                                              18,
                                                              Get.isDarkMode
                                                                  ? Themes
                                                                      .mainThemeColorAccent
                                                                      .shade100
                                                                  : colors.Colors()
                                                                      .darkGrey(
                                                                          1),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 10,
                                                          ),
                                                          Text(
                                                            "${foods[index]['potion']}",
                                                            style:
                                                                TypographyStyles
                                                                    .boldText(
                                                              20,
                                                              Get.isDarkMode
                                                                  ? Themes
                                                                      .mainThemeColorAccent
                                                                      .shade100
                                                                  : colors.Colors()
                                                                      .darkGrey(
                                                                          1),
                                                            ),
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
                                                    color: Get.isDarkMode
                                                        ? Themes
                                                            .mainThemeColorAccent
                                                        : colors.Colors()
                                                            .selectedCardBG,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 10,
                                                            horizontal: 10),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "Portions",
                                                          style:
                                                              TypographyStyles
                                                                  .boldText(
                                                            18,
                                                            Get.isDarkMode
                                                                ? Themes
                                                                    .mainThemeColorAccent
                                                                    .shade100
                                                                : colors.Colors()
                                                                    .darkGrey(
                                                                        1),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 5,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Expanded(
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  if (foods[index]
                                                                          [
                                                                          'no_of_potions'] >
                                                                      1) {
                                                                    foods[index]
                                                                        [
                                                                        'no_of_potions'] -= 1;
                                                                    foods.add({
                                                                      'id':
                                                                          'DUMMY',
                                                                      'name':
                                                                          'DUMMY',
                                                                    });
                                                                    foods
                                                                        .removeLast();
                                                                  }
                                                                },
                                                                child: Icon(
                                                                    Icons
                                                                        .remove,
                                                                    color: Colors
                                                                        .white),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  shape:
                                                                      CircleBorder(),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  backgroundColor: Get
                                                                          .isDarkMode
                                                                      ? colors.Colors()
                                                                          .deepGrey(
                                                                              1)
                                                                      : colors.Colors()
                                                                          .deepGrey(
                                                                              0.6),
                                                                  foregroundColor:
                                                                      colors.Colors()
                                                                          .deepYellow(
                                                                              1),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 16),
                                                            Obx(() => Text(
                                                                foods[index][
                                                                        'no_of_potions']
                                                                    .toString(),
                                                                style: TypographyStyles
                                                                        .title(
                                                                            21)
                                                                    .copyWith(
                                                                  color: Get
                                                                          .isDarkMode
                                                                      ? colors.Colors()
                                                                          .deepYellow(
                                                                              1)
                                                                      : colors.Colors()
                                                                          .lightBlack(
                                                                              1),
                                                                ))),
                                                            SizedBox(width: 16),
                                                            Expanded(
                                                              child:
                                                                  ElevatedButton(
                                                                onPressed: () {
                                                                  if (foods[index]
                                                                          [
                                                                          'no_of_potions'] <
                                                                      16) {
                                                                    foods[index]
                                                                        [
                                                                        'no_of_potions'] += 1;
                                                                    foods.add({
                                                                      'id':
                                                                          'DUMMY',
                                                                      'name':
                                                                          'DUMMY',
                                                                    });
                                                                    foods
                                                                        .removeLast();
                                                                  }
                                                                },
                                                                child: Icon(
                                                                    Icons.add,
                                                                    color: Colors
                                                                        .white),
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  shape:
                                                                      CircleBorder(),
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  backgroundColor: Get
                                                                          .isDarkMode
                                                                      ? colors.Colors()
                                                                          .deepGrey(
                                                                              1)
                                                                      : colors.Colors()
                                                                          .deepGrey(
                                                                              0.6),
                                                                  foregroundColor: colors
                                                                          .Colors()
                                                                      .deepYellow(
                                                                          1), // <-- Splash color
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
                                      )),
                                ),
                              );
                            },
                          );
                        },
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(
                                foods[index]['name'],
                                style: TypographyStyles.title(16),
                              ),
                              subtitle: Text(foods[index]['calories']
                                      .toString() +
                                  ' Cals' +
                                  " (${foods[index]['potion'].toString()})"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                      'Portions: ${foods[index]['no_of_potions'].toString()}'),
                                  SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(Icons.highlight_remove_rounded,
                                        color: Colors.red),
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text("NOTE !"),
                                          content: Text(
                                              "You're About to remove this meal from your list."),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                foods.removeAt(index);
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Remove",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge!
                                                    .copyWith(fontSize: 17),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "Keep",
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .labelLarge!
                                                    .copyWith(
                                                        fontSize: 17,
                                                        color: colors.Colors()
                                                            .deepYellow(1)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
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
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Container(
          margin: EdgeInsets.only(top: 8),
          width: Get.width,
          height: 44,
          child: ElevatedButton(
            style: ButtonStyles.primaryButton(),
            child: Text('Save'),
            onPressed: () {
              if (foods.length > 0) {
                saveFood();
              } else {
                showSnack('No Ingredients Added!',
                    'Please add some Ingredients to your Food');
              }
            },
          ),
        ),
      ),
    );
  }
}
