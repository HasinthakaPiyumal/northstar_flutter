import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class SelectedDayTodos extends StatelessWidget {

  final DateTime selectedDate;
  final RxList allTodos;

  const SelectedDayTodos({Key? key, required this.selectedDate, required this.allTodos}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    RxBool ready = false.obs;

    RxList selectedDayPendingToDos = [].obs;
    RxList selectedDayCompletedToDos = [].obs;
    RxList upcomingToDos = [].obs;

    Future<void> getSelectedDayTodos() async{

      ready.value = false;

      selectedDayPendingToDos.value = [];
      selectedDayCompletedToDos.value = [];
      upcomingToDos.value = [];

      allTodos.forEach((element) {
        if(element['endDate'] == DateFormat("yyyy-MM-dd").format(selectedDate) && element['completed'] == false) {
          selectedDayPendingToDos.add(element);
        } else if (element['endDate'] == DateFormat("yyyy-MM-dd").format(selectedDate) && element['completed'] == true) {
          selectedDayCompletedToDos.add(element);
        } else if (DateTime.parse(element['endDate']).difference(selectedDate).inMinutes > 0 && element['completed'] == false) {
          upcomingToDos.add(element);
        }
      });

      selectedDayPendingToDos.sort((a, b){
        return Comparable.compare(DateTime.parse(a["endDate"]) , DateTime.parse(b["endDate"]));
      });
      selectedDayCompletedToDos.sort((a, b){
        return Comparable.compare(DateTime.parse(a["endDate"]) , DateTime.parse(b["endDate"]));
      });
      upcomingToDos.sort((a, b){
        return Comparable.compare(DateTime.parse(a["endDate"]) , DateTime.parse(b["endDate"]));
      });

      // for debug purpose

      // print("selected day pending");
      // selectedDayPendingToDos.forEach((element) => print(element["endDate"]));
      // print("selected day completed");
      // selectedDayCompletedToDos.forEach((element) => print(element["endDate"]));
      // print("selected day upcoming");
      // upcomingToDos.forEach((element) => print(element["endDate"]));

      ready.value = true;
    }

    getSelectedDayTodos();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text(DateFormat("EEEE, MMMM dd, yyyy").format(selectedDate),
          style: TypographyStyles.title(20)
        ),
      ),
      body: Obx(() => ready.value ? Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          // crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 12,),
            // Text(DateFormat("EEEE, MMMM dd, yyyy").format(selectedDate),
            //   style: TypographyStyles.boldText(25, Get.isDarkMode ? Colors.white : Colors.black ),
            // ),
            SizedBox(height: 24,),
            Visibility(
              visible: selectedDayPendingToDos.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Pending",
                    style: TypographyStyles.boldText(18, Get.isDarkMode ? Colors.white : Colors.black ),
                  ),
                  SizedBox(height: 10,),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: selectedDayPendingToDos.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 8,);
                    },
                    itemBuilder: (context, index) {

                      var thisTodo = selectedDayPendingToDos[index];

                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: colors.Colors().lightBlack(1),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(thisTodo["todo"], style: TypographyStyles.normalText(16, Themes.mainThemeColorAccent.shade100).copyWith(height: 1.4),
                              ),
                              SizedBox(height: 8,),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("Due Date", style: TypographyStyles.normalText(13,colors.Colors().lightCardBG.withOpacity(0.6),),),
                                        SizedBox(width: 5,),
                                        Text(thisTodo["endDate"], style: TypographyStyles.boldText(15, colors.Colors().lightCardBG.withOpacity(0.6),),),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.close_rounded, color: Colors.white, size: 30),
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          CommonConfirmDialog.confirm('Delete').then((value) async {
                                            if(value){
                                              httpClient.deleteTodo(thisTodo['id']).then((value){
                                                getSelectedDayTodos();
                                              });
                                            }
                                          });
                                        },
                                      ),
                                      SizedBox(width: 10,),
                                      Visibility(
                                        child: IconButton(
                                          icon: Icon(Icons.check, color: Colors.white, size: 30),
                                          padding: EdgeInsets.zero,
                                          onPressed: () async {
                                            CommonConfirmDialog.confirm('Complete').then((value) {
                                              if(value){
                                                httpClient.completeTodo(thisTodo['id']).then((value){
                                                  getSelectedDayTodos();
                                                });
                                              }
                                            });
                                          },
                                        ),
                                        visible: !thisTodo['completed'],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 12,),
            Visibility(
              visible: upcomingToDos.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Upcoming",
                    style: TypographyStyles.boldText(18, Get.isDarkMode ? colors.Colors().lightCardBG.withOpacity(0.8) : Colors.black ),
                  ),
                  SizedBox(height: 10,),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: upcomingToDos.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 10,);
                    },
                    itemBuilder: (context, index) {

                      var thisTodo = upcomingToDos[index];

                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: colors.Colors().lightBlack(1),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(thisTodo["todo"], style: TypographyStyles.normalText(16, Themes.mainThemeColorAccent.shade100).copyWith(height: 1.4),
                              ),
                              SizedBox(height: 8,),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("Due Date", style: TypographyStyles.normalText(13,colors.Colors().lightCardBG.withOpacity(0.6)),),
                                        SizedBox(width: 5,),
                                        Text(thisTodo["endDate"], style: TypographyStyles.boldText(15,colors.Colors().lightCardBG.withOpacity(0.6)),),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.close_rounded, color: Colors.white, size: 30),
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          CommonConfirmDialog.confirm('Delete').then((value) async {
                                            if(value){
                                              httpClient.deleteTodo(thisTodo['id']).then((value){
                                                getSelectedDayTodos();
                                              });
                                            }
                                          });
                                        },
                                      ),
                                      SizedBox(width: 10,),
                                      Visibility(
                                        child: IconButton(
                                          icon: Icon(Icons.check, color: Colors.white, size: 30),
                                          padding: EdgeInsets.zero,
                                          onPressed: () async {
                                            CommonConfirmDialog.confirm('Complete').then((value) {
                                              if(value){
                                                httpClient.completeTodo(thisTodo['id']).then((value){
                                                  getSelectedDayTodos();
                                                });
                                              }
                                            });
                                          },
                                        ),
                                        visible: !thisTodo['completed'],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 24,),
            Visibility(
              visible: selectedDayCompletedToDos.isNotEmpty,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Completed",
                    style: TypographyStyles.boldText(18, Get.isDarkMode ? Colors.white : Colors.black ),
                  ),
                  SizedBox(height: 10,),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: selectedDayCompletedToDos.length,
                    separatorBuilder: (context, index) {
                      return SizedBox(height: 10,);
                    },
                    itemBuilder: (context, index) {

                      var thisTodo = selectedDayCompletedToDos[index];

                      return Card(
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        color: colors.Colors().lightBlack(1),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(thisTodo["todo"], style: TypographyStyles.normalText(16, Themes.mainThemeColorAccent.shade100).copyWith(height: 1.4),
                              ),
                              SizedBox(height: 8,),
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text("Due Date", style: TypographyStyles.normalText(13,Colors.green,),),
                                        SizedBox(width: 5,),
                                        Text(
                                          thisTodo["endDate"],
                                          style: TypographyStyles.boldText(15,Colors.green),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.close_rounded, color: Colors.white, size: 30),
                                        padding: EdgeInsets.zero,
                                        onPressed: () async {
                                          CommonConfirmDialog.confirm('Delete').then((value) async {
                                            if(value){
                                              httpClient.deleteTodo(thisTodo['id']).then((value){
                                                getSelectedDayTodos();
                                              });
                                            }
                                          });
                                        },
                                      ),
                                      SizedBox(width: 10,),
                                      Visibility(
                                        child: IconButton(
                                          icon: Icon(Icons.check, color: Colors.white, size: 30),
                                          padding: EdgeInsets.zero,
                                          onPressed: () async {
                                            CommonConfirmDialog.confirm('Complete').then((value) {
                                              if(value){
                                                httpClient.completeTodo(thisTodo['id']).then((value){
                                                  getSelectedDayTodos();
                                                });
                                              }
                                            });
                                          },
                                        ),
                                        visible: !thisTodo['completed'],
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 30,)
          ],
        ),
      ) : LoadingAndEmptyWidgets.loadingWidget())
    );
  }
}
