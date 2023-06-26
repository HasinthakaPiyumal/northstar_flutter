import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetDoctors/DoctorProfile.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;


class DoctorsList extends StatelessWidget {
  const DoctorsList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxBool ready = false.obs;
    RxList doctors = [].obs;

    Future<List> searchDoctors(String pattern) async{
      Map res = await httpClient.searchDoctors(pattern);
      if (res['code'] == 200){
        doctors.value = res['data'];
        ready.value = true;
        return [];
      } else {
        ready.value = true;
        return [];
      }
    }

    searchDoctors('');

    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Professionals'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0),
              child: TypeAheadField(
                hideOnEmpty: true,
                hideOnError: true,
                hideOnLoading: true,
                textFieldConfiguration: TextFieldConfiguration(
                    autofocus: false,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search Medical Professionals...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    )
                ),
                suggestionsCallback: (pattern) async {
                  return await searchDoctors(pattern);
                },
                itemBuilder: (context, suggestion) {
                  return Container();
                },
                onSuggestionSelected: (suggestion) {},
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: Obx(()=> ready.value ? doctors.length > 0 ? ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context,index){
                  return InkWell(
                    onTap: (){
                      Get.to(()=>DoctorProfile(doctor: doctors[index]));
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                      child: Container(
                        height: 150,
                        child: Stack(
                          children: [
                            Column(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.transparent,
                                      ),
                                    ),
                                    Flexible(
                                      flex: 5,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().lightCardBG,
                                          borderRadius: BorderRadius.circular(15),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Flexible(
                                    flex: 3,
                                    fit: FlexFit.tight,
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          radius: 36,
                                          backgroundImage: NetworkImage(
                                            "${HttpClient.s3BaseUrl}${doctors[index]['avatar_url']}",
                                            scale: 0.1,
                                          ),
                                        ),
                                        Positioned(
                                          left: -4,
                                          bottom: -4,
                                          child: CircleAvatar(
                                            radius: 12,
                                            backgroundColor: Get.isDarkMode ? colors.Colors().deepGrey(1) : colors.Colors().lightCardBG,
                                            child: CircleAvatar(
                                              radius: 8,
                                              backgroundColor: doctors[index]['doctor']['online'] ? Colors.green : Get.isDarkMode ? Colors.grey[600] : Colors.grey[400],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ),
                                  Flexible(
                                    flex: 4,
                                    child: Container(),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: SizedBox(),
                                  ),
                                  Flexible(
                                    flex: 10,
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 8),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text("${doctors[index]['doctor']['speciality'].toString().capitalizeFirst}",
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Get.isDarkMode ? colors.Colors().deepYellow(1) : Colors.black,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text("Dr. ${doctors[index]['name'].toString().capitalize}", style: TypographyStyles.title(20)),
                                          SizedBox(height: 15),
                                          doctors[index]['qualifications'].length != 0 ? Text("${doctors[index]['qualifications'][0]['title'].toString().capitalize} - ${doctors[index]['qualifications'][0]['description'].toString().capitalize}",
                                            style: TextStyle(
                                                color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[700],
                                            ),
                                          ) : Text("No Qualifications",
                                            style: TextStyle(
                                                color: colors.Colors().darkGrey(1)
                                            ),
                                          ),
                                        ],
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
                  );


                },
              ): LoadingAndEmptyWidgets.emptyWidget(): LoadingAndEmptyWidgets.loadingWidget(),
              ),
            )
          ],
        ),
      ),
    );
  }
}
