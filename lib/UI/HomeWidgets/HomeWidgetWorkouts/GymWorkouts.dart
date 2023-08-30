import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetWorkouts/ViewGymLibrary.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Styles/AppColors.dart';
class GymWorkouts extends StatelessWidget {
  const GymWorkouts({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<String> categories = [
      'Compound',
      'Isolation',
      'Push',
      'Pull',
      'Lift',
      'Chest',
      'Shoulder',
      'Back',
      'Leg',
      'Arms',
      'Abdominal & Core',
      'Corrective',
      'Isometric',
      'Stretches',
      'Cardio',
      'Body Weight',
      'Machine',
      'Plyometrics',
      'Unilateral',
      'Bilateral',
      'Other',
    ];
    RxList workouts = [].obs;
    RxList selectedCategories = [].obs;
    RxBool ready = false.obs;
    String searchPattern = 'LIMIT25RESULTS';

    Future<List> searchWorkouts(pattern) async {
      print('PATTERN: ' + pattern);
      if (pattern == '') {
        pattern = 'LIMIT25RESULTS';
      }
      Map res = await httpClient.workoutsSearch(pattern);

      if (res['code'] == 200) {
        workouts.value = res['data'];
        print(res['data'][0]);
        ready.value = true;
        searchPattern = 'LIMIT25RESULTS';
        return res['data'];
      } else {
        print(res);
        ready.value = true;
        return [];
      }
    }


    void filterAll(String pattern) async{
      ready.value = false;
      List workoutsFresh = await searchWorkouts(pattern);

      workouts.value = [];
      workoutsFresh.forEach((element) {
        List cats = element['categories'];
        cats.removeWhere((item) => !selectedCategories.contains(item));
        if(cats.length == selectedCategories.length){
          workouts.add(element);
          print('Filtered');          
        }
      });
      ready.value= true;
    }

    

    void showFilter(){
      Get.bottomSheet(
        Card(
          color: Get.isDarkMode?AppColors.primary2Color:Colors.white,
        child: Column(
          children: [
            SizedBox(height: 16),
            Row(
              children: [
                SizedBox(width: 8),
                Text('Select Categories', style: TypographyStyles.title(18)),
                Spacer(),
                TextButton(
                  child: Text('Done'),
                  onPressed: () {
                    filterAll(searchPattern);
                    Get.back();
                  },
                ),
                SizedBox(width: 8),
              ],
            ),
            SizedBox(height: 8),
            Divider(),

            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: ((context, index) {
                  return Obx(()=>CheckboxListTile(
                    checkColor: Colors.white,
                    activeColor: Themes.mainThemeColor,
                    value: selectedCategories.contains(categories[index]),
                    title: Text(categories[index]),
                    onChanged: (bool? value) {
                      if (value == true) {
                        selectedCategories.add(categories[index]);
                      } else {
                        selectedCategories.remove(categories[index]);
                      }
                    },
                  ));
                }),
              ),
            )
          ],
        ),
      ),
      isDismissible: false,

      );
    }

    

    searchWorkouts('LIMIT25RESULTS');

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Gym Bank',style: TypographyStyles.title(20),),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 15,
          ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 4
                  ),
                  child: TypeAheadField(
                    hideOnEmpty: true,
                    hideOnError: true,
                    hideOnLoading: true,
                    textFieldConfiguration: TextFieldConfiguration(
                        autofocus: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          labelText: 'Search Workouts...',
                          border: UnderlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                        )),
                    suggestionsCallback: (pattern) async {
                      searchPattern = pattern;
                      return await searchWorkouts(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return Container();
                    },
                    onSuggestionSelected: (suggestion) {},
                  ),
                ),
              ),
              Container(
                height: 26,
                width: 26,
                child: InkWell(
                  child: SvgPicture.asset('assets/svgs/filter.svg'),
                  onTap: () {
                    showFilter();
                  },
                ),
              ),
              SizedBox(width: 8)
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Obx(() => ready.value
                  ? GridView.builder(
                      itemCount: workouts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisExtent: 256,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                      ),
                      itemBuilder: (context, index) {
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                          ),
                          color: Get.isDarkMode?AppColors.primary2Color:Colors.white,
                          child: InkWell(
                            onTap: () {
                              Get.to(() =>
                                  ViewGymLibrary(workout: workouts[index]));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.fromLTRB(5, 5, 5, 0),
                                  child: Container(
                                    width: Get.width,
                                    height: 160,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.grey[400],
                                        image: DecorationImage(
                                            image: CachedNetworkImageProvider(
                                                HttpClient.s3ResourcesBaseUrl +
                                                    "${workouts[index]['preview_animation_url']}"),
                                            fit: BoxFit.contain)),
                                  ),
                                ),
                                Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(8, 10, 8, 8),
                                    child: Center(
                                      child: Text(
                                            workouts[index]['title'],
                                            textAlign: TextAlign.center,
                                            style: TypographyStyles.title(14),
                                          ),
                                    ))
                              ],
                            ),
                          ),
                        );
                      },
                    )
                  : Center(child: CircularProgressIndicator())),
            ),
          )
        ],
      ),
    );
  }
}
