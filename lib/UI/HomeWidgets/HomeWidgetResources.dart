import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetResources/ViewNewsLetters.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetResources/ViewResourceDoc.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../Styles/ButtonStyles.dart';

class HomeWidgetResources extends StatelessWidget {
  const HomeWidgetResources({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList resources = [].obs;

    RxList categories = [].obs;
    RxString selectedCategory = "All".obs;
    RxList selectedCategoryResources = [].obs;

    Future<List> searchResources(String pattern) async{
      ready.value = false;
      if (pattern.isEmpty) {
        Map res = await httpClient.resourceSearch('ALL');
        resources.value = res['data'];
        selectedCategoryResources.value = resources;
        ready.value = true;
        return [];
      } else {
        Map res = await httpClient.resourceSearch(pattern);
        resources.value = res['data'];
        selectedCategoryResources.value = resources;
        print(
          'Search Results: ${resources.length}' +
          'Search Results2 ${selectedCategoryResources.length}'
        );
        ready.value = true;
        return [];
      }
    }

    Future<void> sortCategoryNames() async {
      categories.value = [];
      categories.add("All");
      for (var element in resources) {
        categories.add(element['category']);
      }
      categories.value = categories.toSet().toList();
      print(categories);
    }

    Future<void> sortResourcesToSelectedCategory() async {
      selectedCategoryResources.value = [];
      for (var element in resources) {
        if(selectedCategory.value == "All"){
          selectedCategoryResources.add(element);
        } else {
          if(element['category'] == selectedCategory.value){
            selectedCategoryResources.add(element);
          }
        }
      }
    }

    searchResources('ALL').then((value) => sortCategoryNames());

    return Scaffold(
      appBar: AppBar(title: Text('Resources')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: Get.width,
              height: 64,
              child: TextButton(
                style: TextButton.styleFrom(
                    backgroundColor: Get.isDarkMode ? colors.Colors().darkGrey(1) : colors.Colors().selectedCardBG,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)
                    )
                ),
                onPressed: (){
                  Get.to(()=>ViewNewsLetters());
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Newsletter',style: TypographyStyles.normalText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),),
                      Icon(Icons.arrow_forward,color: Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1),),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16),
            TypeAheadField(
              hideOnEmpty: true,
              hideOnError: true,
              hideOnLoading: true,
              textFieldConfiguration: TextFieldConfiguration(
                  autofocus: false,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search Resources...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  )
              ),
              suggestionsCallback: (pattern) async {
                return await searchResources(pattern);
              },
              itemBuilder: (context, suggestion) {
                return Container();
              },
              onSuggestionSelected: (suggestion) {},
            ),
            SizedBox(height: 16),

            SizedBox(
              height: 40,
              child: Obx(() => ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Obx(()=>Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                              style: selectedCategory.value == categories[index] ? ButtonStyles.selectedBookingButton(50) : Get.isDarkMode ? ButtonStyles.notSelectedBookingButton(50) : ButtonStyles.notSelectedBookingButtonLightTheme(50),
                              onPressed: (){
                                selectedCategory.value = categories[index];
                                sortResourcesToSelectedCategory();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5,),
                                child: Text(
                                  categories[index],
                                  style: TypographyStyles.boldText(16, Get.isDarkMode ? Themes.mainThemeColorAccent.shade100 : colors.Colors().lightBlack(1)),
                                ),
                              )
                          ),
                          SizedBox(width: 5,),
                        ],
                      )),
                    ],
                  );
                },
              ),),
            ),

            SizedBox(height: 16),

            Expanded(
              child: Obx(()=> ready.value ? MasonryGridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 10.0,
                itemCount: selectedCategoryResources.length,
                itemBuilder: (_,index){
                  return InkWell(
                    onTap: (){
                      print(selectedCategoryResources[index]);
                      Get.to(()=> ViewResourceDoc(data: selectedCategoryResources[index], image: selectedCategoryResources[index]['image'], index: index,));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: Get.width/100*50,
                          height: Get.width/100*50 - 24,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Hero(
                              tag: 'image$index',
                              child: CachedNetworkImage(
                                imageUrl: HttpClient.s3ResourcesBaseUrl + selectedCategoryResources[index]['image'],
                                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                                errorWidget: (context, url, error) => Icon(Icons.error),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(selectedCategoryResources[index]['title'], textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  );
                },
              ): Center(child: CircularProgressIndicator()),
              ),
            )
          ],
        ),
      ),
    );
  }
}
