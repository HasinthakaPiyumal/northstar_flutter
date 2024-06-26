import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/BoxStyles.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetToDo/AddToDos.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetToDo/SelectedDayTodos.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetToDo/VIewAndEditToDo.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../Controllers/LocalNotificationsController.dart';

class HomeWidgetToDos extends StatelessWidget {
  const HomeWidgetToDos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxList todos = [].obs;

    Rx<DateTime> selectedDay = DateTime.now().obs;
    Rx<DateTime> focusedDay = DateTime.now().obs;

    RxList toHighlight = [].obs;

    final MyTabController tabController = Get.put(MyTabController());

    RxList upcomingTasksHaveDates = [].obs;
    RxList completedTasksHaveDates = [].obs;

    Future<void> getDatesWithTasks() async {
      upcomingTasksHaveDates.value = [].obs;
      completedTasksHaveDates.value = [].obs;

      todos.forEach((element) {
        if (element["completed"] == false) {
          upcomingTasksHaveDates.add(element["endDate"]);
          upcomingTasksHaveDates.refresh();
        } else {
          completedTasksHaveDates.add(element["endDate"]);
          upcomingTasksHaveDates.refresh();
        }
      });

      upcomingTasksHaveDates.value = upcomingTasksHaveDates.toSet().toList();
      completedTasksHaveDates.value = completedTasksHaveDates.toSet().toList();

      upcomingTasksHaveDates.sort((a, b) {
        return Comparable.compare(DateTime.parse(a), DateTime.parse(b));
      });

      completedTasksHaveDates.sort((b, a) {
        return Comparable.compare(DateTime.parse(b), DateTime.parse(a));
      });
      //
      // print("upcoming todos have dates list : $upcomingTasksHaveDates");
      // print("completed todos have dates list : $completedTasksHaveDates");
    }

    RxList categorizedUpcomingTodosMapsList = [].obs;
    RxList categorizedCompletedTodosMapsList = [].obs;

    Future<bool> categorizeTodos() async {
      categorizedUpcomingTodosMapsList.value = [];
      categorizedCompletedTodosMapsList.value = [];

      upcomingTasksHaveDates.forEach((element) {
        List tmpToDos = [];
        todos.forEach((todo) {
          if (todo["endDate"] == element && todo["completed"] == false) {
            tmpToDos.add(todo);
          }
        });
        categorizedUpcomingTodosMapsList
            .add({'date': element, 'todos': tmpToDos});
      });

      completedTasksHaveDates.forEach((element) {
        List tmpToDos = [];
        todos.forEach((todo) {
          if (todo["endDate"] == element && todo["completed"] == true) {
            tmpToDos.add(todo);
          }
        });
        categorizedCompletedTodosMapsList
            .add({'date': element, 'todos': tmpToDos});
      });

      return true;
    }

    Future<void> getTODOs() async {
      ready.value = false;
      Map res = await httpClient.getTodo();
      if (res['code'] == 200) {
        todos.value = res['data'];
        print('Printing todos---');
        print(res['data']);
        res['data'].forEach((element) {
          try{
            toHighlight.add(DateTime.parse(element['endDate']));
          }catch(e){
            toHighlight.add(DateFormat('dd-MM-yyyy').parse(element['endDate']).toLocal());
          }
        });
        print(toHighlight);
        await getDatesWithTasks();
        await categorizeTodos();
        ready.value = true;
      } else {
        ready.value = true;
        showSnack('Error', 'Something went wrong');
      }
    }

    bool hasPassed(Map todoElement) {
      if (DateTime.parse(todoElement["endDate"]).isAfter(DateTime.now())) {
        return true;
      } else {
        return false;
      }
    }

    getTODOs();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        centerTitle: true,
        title: Text(
          'TO-DO List',
          style: TypographyStyles.title(20),
        ),
      ),
      floatingActionButton: Container(
        height: 44,
        width: 131,
        child: FloatingActionButton.extended(
          onPressed: () {
            Get.to(() => AddToDos())?.then((value) {
              getTODOs().then((value) async {
                await getDatesWithTasks();
              }).then((value) async {
                await categorizeTodos();
              });
            });
          },
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          backgroundColor: AppColors.accentColor,
          label: Text('Add Item',
              style: TextStyle(
                color: AppColors.textOnAccentColor,
                fontSize: 20,
                fontFamily: 'Bebas Neue',
                fontWeight: FontWeight.w400,
              )),
          icon: Icon(Icons.add, color: AppColors.textOnAccentColor),
        ),
      ),
      body: Obx(() => ready.value
          ? Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Card(
                    margin: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    color: Get.isDarkMode
                        ? AppColors.primary2Color
                        : AppColors.baseColor,
                    elevation: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Obx(
                        () => TableCalendar(
                          firstDay: DateTime.utc(2010, 10, 16),
                          lastDay: DateTime.utc(2030, 3, 14),
                          focusedDay: focusedDay.value,
                          calendarStyle: CalendarStyle(
                            isTodayHighlighted: true,
                            defaultDecoration:
                                BoxDecorations().commonCalendarDec,
                            disabledDecoration:
                                BoxDecorations().commonCalendarDec,
                            outsideDecoration:
                                BoxDecorations().commonCalendarDec,
                            todayDecoration: BoxDecoration(
                                // color: colors.Colors().deepYellow(1),
                                // borderRadius: BorderRadius.all(Radius.circular(2)),
                                ),
                            weekendDecoration:
                                BoxDecorations().commonCalendarDec,
                            selectedDecoration: BoxDecoration(
                              color: colors.Colors().deepYellow(1),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            cellMargin: const EdgeInsets.all(0),
                            selectedTextStyle:
                                TypographyStyles.title(12).copyWith(
                              color:
                                  Get.isDarkMode ? Colors.white : Colors.black,
                            ),
                            weekendTextStyle:
                                TypographyStyles.title(12).copyWith(
                              color:
                                  Get.isDarkMode ? Colors.white : Colors.black,
                            ),
                            defaultTextStyle:
                                TypographyStyles.title(12).copyWith(
                              color:
                                  Get.isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          daysOfWeekHeight: 30,
                          rowHeight: 25,
                          calendarFormat: CalendarFormat.month,
                          headerStyle: HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Get.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                ),
                            headerMargin: EdgeInsets.zero,
                            headerPadding: EdgeInsets.only(bottom: 10),
                            leftChevronPadding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            rightChevronPadding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                          ),
                          daysOfWeekStyle: DaysOfWeekStyle(
                            weekdayStyle: TypographyStyles.title(12)
                                .copyWith(color: AppColors.accentColor),
                            weekendStyle: TypographyStyles.title(12).copyWith(
                                color: AppColors.accentColor.withOpacity(0.8)),
                          ),
                          startingDayOfWeek: StartingDayOfWeek.monday,
                          onDaySelected: (selected, focused) {
                            // selectedDay.value = selected;
                            focusedDay.value = focused;
                            Get.to(() => SelectedDayTodos(
                                  selectedDate: selected,
                                  allTodos: todos,
                                ));
                          },
                          selectedDayPredicate: (day) {
                            return isSameDay(selectedDay.value, day);
                          },
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, day, focusedDay) {
                              for (DateTime d in toHighlight) {
                                print(d);
                                if (day.day == d.day &&
                                    day.month == d.month &&
                                    day.year == d.year) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      // color: Colors.blue,
                                      border: Border.fromBorderSide(
                                          BorderSide(color: Colors.blue)),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${day.day}',
                                        style: TypographyStyles.text(16),
                                      ),
                                    ),
                                  );
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: TabBar(
                    controller: tabController.controller,
                    tabs: tabController.myTabs,
                    isScrollable: false,
                    labelStyle: TypographyStyles.title(16),
                    labelColor: Get.isDarkMode ? Colors.white : Colors.black,
                    unselectedLabelStyle: TypographyStyles.title(16).copyWith(
                        color: Get.isDarkMode
                            ? colors.Colors().darkGrey(1)
                            : Colors.black38),
                    // unselectedLabelColor:
                    //     colors.Colors().lightCardBG.withOpacity(0.6),
                    indicatorColor: AppColors.accentColor,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Expanded(
                  child: TabBarView(
                    controller: tabController.controller,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      Obx(() => categorizedUpcomingTodosMapsList.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  categorizedUpcomingTodosMapsList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        "${DateFormat("MMMM dd").format(DateTime.parse(categorizedUpcomingTodosMapsList[index]['date']))}",
                                        style: TypographyStyles.title(16)
                                            .copyWith(
                                                color: Get.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            categorizedUpcomingTodosMapsList[
                                                    index]['todos']
                                                .length,
                                        itemBuilder: (context, subIndex) {
                                          var thisTodo =
                                              categorizedUpcomingTodosMapsList[
                                                  index]['todos'][subIndex];

                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Get.to(() => ViewAndEditToDo(
                                                        selectedToDo: thisTodo,
                                                      ));
                                                },
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Card(
                                                  elevation: 0,
                                                  margin: EdgeInsets.zero,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  color: Get.isDarkMode
                                                      ? AppColors.primary2Color
                                                      : Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            16, 16, 16, 4),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(thisTodo["todo"],
                                                            style: TypographyStyles
                                                                .textWithWeight(
                                                                    14,
                                                                    FontWeight
                                                                        .w300)),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(thisTodo["notes"],
                                                            style: TypographyStyles
                                                                .textWithWeight(
                                                                    14,
                                                                    FontWeight
                                                                        .w300)),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text(
                                                          "Due Date " +
                                                              DateFormat(
                                                                      "MMM dd, yyyy hh:mm a")
                                                                  .format(DateTime
                                                                      .parse(thisTodo[
                                                                          "endDate"])),
                                                          style:
                                                              TypographyStyles
                                                                  .normalText(
                                                            16,
                                                            hasPassed(thisTodo)
                                                                ? Get.isDarkMode
                                                                    ? AppColors
                                                                        .textColorDark
                                                                    : AppColors
                                                                        .textColorLight
                                                                : Colors.red,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Visibility(
                                                              child: Container(
                                                                height: 28,
                                                                width: 73.85,
                                                                child:
                                                                    ElevatedButton(
                                                                  style: ButtonStyles
                                                                      .bigFlatYellowButton(),
                                                                  child: Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: AppColors
                                                                          .textOnAccentColor,
                                                                      size: 24),
                                                                  onPressed:
                                                                      () async {
                                                                    CommonConfirmDialog.confirm(
                                                                            'Complete')
                                                                        .then(
                                                                            (value) async {
                                                                      if (value) {
                                                                        httpClient
                                                                            .completeTodo(thisTodo['id'])
                                                                            .then((value) {
                                                                          getTODOs().then(
                                                                              (value) async {
                                                                            await getDatesWithTasks();
                                                                          }).then(
                                                                              (value) async {
                                                                            await categorizeTodos();
                                                                          });
                                                                        });
                                                                        await LocalNotificationsController.cancelNotification(thisTodo['id']);
                                                                      }
                                                                    });
                                                                  },
                                                                ),
                                                              ),
                                                              visible: !thisTodo[
                                                                  'completed'],
                                                            ),
                                                            SizedBox(
                                                              width: 10,
                                                            ),
                                                            Container(
                                                              height: 28,
                                                              width: 73.85,
                                                              child:
                                                                  ElevatedButton(
                                                                style: ElevatedButton
                                                                    .styleFrom(
                                                                  foregroundColor:
                                                                      Colors
                                                                          .black,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .transparent,
                                                                  elevation: 0,
                                                                  shape:
                                                                      RoundedRectangleBorder(
                                                                    side: BorderSide(
                                                                        color: AppColors
                                                                            .accentColor),
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                  ),
                                                                ),
                                                                child: Icon(
                                                                    Icons
                                                                        .close_rounded,
                                                                    color: AppColors
                                                                        .accentColor,
                                                                    size: 24),
                                                                onPressed:
                                                                    () async {
                                                                  CommonConfirmDialog
                                                                          .confirm(
                                                                              'Delete')
                                                                      .then(
                                                                          (value) async {
                                                                    if (value) {
                                                                      httpClient
                                                                          .deleteTodo(thisTodo[
                                                                              'id'])
                                                                          .then(
                                                                              (value) {
                                                                        getTODOs().then(
                                                                            (value) async {
                                                                          await getDatesWithTasks();
                                                                        }).then(
                                                                            (value) async {
                                                                          await categorizeTodos();
                                                                        });
                                                                      });
                                                                      await LocalNotificationsController.cancelNotification(thisTodo['id']);
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: index + 1 ==
                                              categorizedUpcomingTodosMapsList
                                                  .length
                                          ? 70
                                          : 10,
                                    )
                                  ],
                                );
                              },
                            )
                          : LoadingAndEmptyWidgets.emptyWidget()),
                      Obx(() => categorizedCompletedTodosMapsList.isNotEmpty
                          ? ListView.builder(
                              shrinkWrap: true,
                              itemCount:
                                  categorizedCompletedTodosMapsList.length,
                              itemBuilder: (context, index) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        "${DateFormat("MMMM dd").format(DateTime.parse(categorizedCompletedTodosMapsList[index]['date']))}",
                                        style: TypographyStyles.title(16)
                                            .copyWith(
                                                color: Get.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8,
                                    ),
                                    Padding(
                                      padding:
                                          EdgeInsets.symmetric(horizontal: 16),
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        itemCount:
                                            categorizedCompletedTodosMapsList[
                                                    index]['todos']
                                                .length,
                                        itemBuilder: (context, subIndex) {
                                          var thisTodo =
                                              categorizedCompletedTodosMapsList[
                                                  index]['todos'][subIndex];

                                          return Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Get.to(() => ViewAndEditToDo(
                                                        selectedToDo: thisTodo,
                                                      ));
                                                },
                                                child: Card(
                                                  elevation: 0,
                                                  margin: EdgeInsets.zero,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  color: Get.isDarkMode
                                                      ? AppColors.primary2Color
                                                      : Colors.white,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.fromLTRB(
                                                            16, 16, 16, 4),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          thisTodo["todo"],
                                                          style: TypographyStyles
                                                                  .normalText(
                                                                      16,
                                                                      Themes
                                                                          .mainThemeColorAccent
                                                                          .shade100)
                                                              .copyWith(
                                                                  height: 1.4),
                                                        ),
                                                        SizedBox(
                                                          height: 8,
                                                        ),
                                                        Column(
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Text(
                                                                  "Due Date",
                                                                  style: TypographyStyles
                                                                      .normalText(
                                                                    13,
                                                                    Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Text(
                                                                  DateFormat(
                                                                          "MMM dd, yyyy hh:mm a")
                                                                      .format(DateTime
                                                                          .parse(
                                                                              thisTodo["endDate"])),
                                                                  style: TypographyStyles
                                                                      .boldText(
                                                                    15,
                                                                    Colors
                                                                        .green,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Container(
                                                                    height: 28,
                                                                    width:
                                                                        73.85,
                                                                    margin: EdgeInsets.only(
                                                                        bottom:
                                                                            10),
                                                                    child:
                                                                        ElevatedButton(
                                                                      style: ElevatedButton
                                                                          .styleFrom(
                                                                        foregroundColor:
                                                                            Colors.black,
                                                                        backgroundColor:
                                                                            Colors.transparent,
                                                                        elevation:
                                                                            0,
                                                                        shape:
                                                                            RoundedRectangleBorder(
                                                                          side:
                                                                              BorderSide(color: AppColors.accentColor),
                                                                          borderRadius:
                                                                              BorderRadius.circular(5),
                                                                        ),
                                                                      ),
                                                                      child: Icon(
                                                                          Icons
                                                                              .close_rounded,
                                                                          color: AppColors
                                                                              .accentColor,
                                                                          size:
                                                                              24),
                                                                      onPressed:
                                                                          () async {
                                                                        CommonConfirmDialog.confirm('Delete')
                                                                            .then((value) async {
                                                                          if (value) {
                                                                            httpClient.deleteTodo(thisTodo['id']).then((value) {
                                                                              getTODOs().then((value) async {
                                                                                await getDatesWithTasks();
                                                                              }).then((value) async {
                                                                                await categorizeTodos();
                                                                              });
                                                                            });
                                                                          }
                                                                        });
                                                                      },
                                                                    )),
                                                                Visibility(
                                                                  visible:
                                                                      !thisTodo[
                                                                          'completed'],
                                                                  child:
                                                                      SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                ),
                                                                Visibility(
                                                                  child:
                                                                      IconButton(
                                                                    icon: Icon(
                                                                        Icons
                                                                            .check,
                                                                        color: Colors
                                                                            .white,
                                                                        size:
                                                                            30),
                                                                    padding:
                                                                        EdgeInsets
                                                                            .zero,
                                                                    onPressed:
                                                                        () async {
                                                                      CommonConfirmDialog.confirm(
                                                                              'Complete')
                                                                          .then(
                                                                              (value) {
                                                                        if (value) {
                                                                          httpClient
                                                                              .completeTodo(thisTodo['id'])
                                                                              .then((value) {
                                                                            getTODOs().then((value) async {
                                                                              await getDatesWithTasks();
                                                                            }).then((value) async {
                                                                              await categorizeTodos();
                                                                            });
                                                                          });
                                                                        }
                                                                      });
                                                                    },
                                                                  ),
                                                                  visible:
                                                                      !thisTodo[
                                                                          'completed'],
                                                                ),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: index + 1 ==
                                              categorizedCompletedTodosMapsList
                                                  .length
                                          ? 70
                                          : 10,
                                    )
                                  ],
                                );
                              },
                            )
                          : LoadingAndEmptyWidgets.emptyWidget()),
                    ],
                  ),
                ),
              ],
            )
          : LoadingAndEmptyWidgets.loadingWidget()),
    );
  }
}

class MyTabController extends GetxController
    with GetSingleTickerProviderStateMixin {
  final List<Tab> myTabs = <Tab>[
    const Tab(text: 'Pending'),
    const Tab(text: 'Completed'),
  ];

  late TabController controller;

  @override
  void onInit() {
    super.onInit();
    controller = TabController(vsync: this, length: myTabs.length);
  }

  @override
  void onClose() {
    controller.dispose();
    super.onClose();
  }
}

// Container(
// decoration: BoxDecoration(
// borderRadius: BorderRadius.circular(15),
// gradient: LinearGradient(
// begin: Alignment.topLeft,
// end: Alignment.bottomRight,
// colors: !thisTodo["completed"] ? [
// Color(0xFFFF412B),
// Color(0xFFFF0046),
// ] : [
// Color(0xFF40C286),
// Color(0xFF0594AB),
// ],
// ),
// ),
// child: Padding(
// padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
// child: Column(
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text(thisTodo["todo"], style: TypographyStyles.boldText(18, Themes.mainThemeColorAccent.shade100)),
// SizedBox(height: 10,),
// Text(thisTodo["notes"], style: TypographyStyles.normalText(16, Themes.mainThemeColorAccent.shade100),),
// SizedBox(height: 20,),
// Row(
// children: [
// Expanded(
// child: Column(
// mainAxisSize: MainAxisSize.min,
// crossAxisAlignment: CrossAxisAlignment.start,
// children: [
// Text("End Date", style: TypographyStyles.normalText(13, Themes.mainThemeColorAccent.shade100),),
// SizedBox(height: 5,),
// Text(thisTodo["endDate"], style: TypographyStyles.boldText(15, Themes.mainThemeColorAccent.shade100)),
// ],
// ),
// ),
// Row(
// children: [
// Visibility(
// child: IconButton(
// icon: Icon(Icons.check, color: Get.isDarkMode?Colors.white:Colors.black, size: 40),
// onPressed: () async {
// CommonConfirmDialog.confirm('Complete').then((value) {
// if(value){
// httpClient.completeTodo(thisTodo['id']).then((value){
// getTODOs().then((value) async {
// await getDatesWithTasks();
// }).then((value) async {
// await categorizeTodos();
// });
// });
// }
// });
// },
// ),
// visible: !thisTodo['completed'],
// ),
// SizedBox(width: 10,),
// IconButton(
// icon: Icon(Icons.close_rounded, color: Get.isDarkMode?Colors.white:Colors.black, size: 40),
// onPressed: () async {
// CommonConfirmDialog.confirm('Delete').then((value) async {
// if(value){
// httpClient.deleteTodo(thisTodo['id']).then((value){
// getTODOs().then((value) async {
// await getDatesWithTasks();
// }).then((value) async {
// await categorizeTodos();
// });
// });
// }
// });
// },
// ),
// ],
// )
// ],
// ),
// ],
// ),
// ),
// )
