import 'package:cached_network_image/cached_network_image.dart';
import 'package:country_currency_pickers/country.dart';
import 'package:country_currency_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetGym/GymView.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class ExclusiveGyms extends StatelessWidget {
  const ExclusiveGyms({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList gyms = [].obs;
    RxList allGyms = [].obs;

    RxString country = "".obs;
    RxString countryName = "".obs;
    RxList countryList = [].obs;

    Future<List> searchGyms(String pattern) async {
      Map res = await httpClient.searchGyms(pattern, 'exclusive');
      gyms.value = res['data'];
      print(res['data']);
      print('value----------');
      if(pattern==''){
        allGyms.value = res['data'];

        List tempList = [];
        res['data'].forEach((value) {
          String isoCode = value["gym_country"];
          if (tempList.contains(isoCode)) {
            tempList.add(isoCode);
          }
        });
        countryList.value = tempList;
        print("setting country list");
        print(tempList);
      }

      ready.value = true;
      return [];
    }

    Widget _buildDropdownItem(Country country) => Container(
          child: Row(
            children: <Widget>[
              CountryPickerUtils.getDefaultFlagImage(country),
              SizedBox(
                width: 8.0,
              ),
              Flexible(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text("${country.name}  (${country.isoCode})"),
                ),
              ),
            ],
          ),
        );

    void filterGyms() {
      showDialog(
        context: context,
        builder: (context) => Theme(
          data: Theme.of(context).copyWith(
              dialogBackgroundColor:
                  Get.isDarkMode ? AppColors.primary2Color : Colors.white),
          child: Container(
            height: Get.height / 2,
            child: CountryPickerDialog(
              titlePadding: EdgeInsets.all(8.0),
              searchCursorColor: colors.Colors().deepYellow(1),
              searchInputDecoration: InputDecoration(hintText: 'Search...'),
              isSearchable: true,
              itemFilter: (c) {
                List tempList = [];
                allGyms.forEach((value) {
                  String isoCode = value["gym_country"];
                  if (!tempList.contains(isoCode)) {
                    tempList.add(isoCode);
                  }
                });
                return tempList.contains(c.isoCode);
              },
              title: Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Filter by Country'),
                    InkWell(
                      onTap: () {
                        Get.back();
                      },
                      child: Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              onValuePicked: (Country c) async {
                country.value = c.isoCode!;
                countryName.value = c.name!;

                await searchGyms('');
                gyms.value = gyms
                    .where((gym) => gym['gym_country'] == country.value)
                    .toList();
              },
              itemBuilder: _buildDropdownItem,
            ),
          ),
        ),
      );
    }

    searchGyms('');

    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text('Exclusive Gyms', style: TypographyStyles.title(20))),
      body: Column(
        children: [
          Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TypeAheadField(
                          hideOnEmpty: true,
                          hideOnError: true,
                          hideOnLoading: true,
                          textFieldConfiguration: TextFieldConfiguration(
                              decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search),
                                suffixIcon: IconButton(color: AppColors.accentColor,onPressed: () { filterGyms(); }, icon: Container(padding: EdgeInsets.all(8),decoration:BoxDecoration(borderRadius:BorderRadius.circular(5),color:AppColors.accentColor,),child: SvgPicture.asset("assets/svgs/mi_filter.svg")),),
                            labelText: 'Search Gyms...',
                            border: UnderlineInputBorder(
                          ))),
                          suggestionsCallback: (pattern) async {
                            return await searchGyms(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return Container();
                          },
                          onSuggestionSelected: (suggestion) {},
                        ),
                      ),

                    ],
                  ),
                  Obx(
                    () => Visibility(
                      visible: country.value != "",
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                '${gyms.length} gym(s) found in "${countryName.value}"',
                                style: TypographyStyles.normalText(
                                    16,
                                    Themes.mainThemeColorAccent.shade100
                                        .withOpacity(0.7)),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () async {
                                country.value = "";
                                await searchGyms('');
                              },
                              color: Colors.black,
                              shape: StadiumBorder(),
                              child: Text(
                                "Reset",
                                style: TypographyStyles.boldText(
                                    14, Themes.mainThemeColorAccent.shade100),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              )),
          Expanded(
            child: Obx(() => ready.value
                ? ListView.builder(
                    itemCount: gyms.length,
                    itemBuilder: (_, index) {
                      return Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                        child: Card(
                          shadowColor: Colors.black.withOpacity(0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          color: Get.isDarkMode
                              ? AppColors.primary2Color
                              : Colors.white,
                          child: InkWell(
                              onTap: () {
                                Get.to(() => GymView(gymObj: gyms[index]));
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                  leading: CircleAvatar(
                                    radius: 28,
                                    child: ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: HttpClient.s3BaseUrl +gyms[index]['user']['avatar_url'],
                                        placeholder: (context, url) =>
                                            Container(
                                          height: 28,
                                          width: 28,
                                          child: CircularProgressIndicator(),
                                        ),
                                        width: 56,
                                        height: 56,
                                        fit: BoxFit.cover,
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      ),
                                    ),
                                  ),
                                  title: Text(gyms[index]['gym_name'],
                                      style: TypographyStyles.title(18)),
                                  subtitle: Padding(
                                    padding: EdgeInsets.only(top: 5),
                                    child: Text(
                                        "${gyms[index]['gym_city']}, ${CountryPickerUtils.getCountryByIsoCode(gyms[index]['gym_country']).name}"),
                                  ),
                                ),
                              )),
                        ),
                      );
                    },
                  )
                : Center(child: CircularProgressIndicator())),
          )
        ],
      ),
    );
  }
}
