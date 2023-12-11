import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Controllers/ClientNotesController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/ClientNote.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

import '../../SharedWidgets/LoadingAndEmptyWidgets.dart';

class SelectedClientNote extends StatefulWidget {
  final int clientId;

  const SelectedClientNote({Key? key, required this.clientId})
      : super(key: key);

  @override
  State<SelectedClientNote> createState() => _SelectedClientNoteState();
}

class _SelectedClientNoteState extends State<SelectedClientNote> {
  @override
  Widget build(BuildContext context) {
    RxList<ClientNote> activeNotes = <ClientNote>[].obs;
    RxList<ClientNote> completedNotes = <ClientNote>[].obs;
    RxBool ready = false.obs;

    Future<void> sortClientNotes() async {
      ready.value = false;
      RxList<ClientNote> allNotes = <ClientNote>[].obs;
      activeNotes.value = <ClientNote>[].obs;
      completedNotes.value = <ClientNote>[].obs;
      await ClientNotesController.getClientNotes();
      allNotes.value =
          ClientNotesController.getClientNotesByClientId(widget.clientId);
      allNotes.forEach((element) {
        print(element);
        if (element.active) {
          activeNotes.add(element);
        } else {
          completedNotes.add(element);
        }
      });
      activeNotes.sort((a, b) {
        return Comparable.compare(a.startDate, b.startDate);
      });
      completedNotes.sort((a, b) {
        return Comparable.compare(b.startDate, a.startDate);
      });
      ready.value = true;
    }

    sortClientNotes();

    return Scaffold(
        appBar: AppBar(
          title: Text(
              ClientNotesController.getClientNotesByClientId(widget.clientId)
                  .first
                  .client['name']),
        ),
        body: Obx(()=>ready.value?ListView(
          children: [
            SizedBox(
              height: 16,
            ),
            Obx(() => activeNotes.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: activeNotes.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 20,
                        );
                      },
                      itemBuilder: (context, index) {
                        ClientNote clientNote = activeNotes[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? colors.Colors().deepGrey(1)
                                : colors.Colors().lightCardBG,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        clientNote.service,
                                        style: TypographyStyles.boldText(
                                          16,
                                          Get.isDarkMode
                                              ? Themes
                                                  .mainThemeColorAccent.shade100
                                              : colors.Colors().lightBlack(1),
                                        ),
                                      ),
                                      Visibility(
                                        visible: authUser.role == 'trainer',
                                        child: IconButton(
                                          onPressed: () {
                                            CommonConfirmDialog.confirm(
                                                    'Delete')
                                                .then((value) async {
                                              if (value) {
                                                await clientNote.deleteClientNote();
                                                sortClientNotes();
                                              }
                                            });
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Get.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    clientNote.note,
                                    style: TypographyStyles.normalText(
                                      13,
                                      Get.isDarkMode
                                          ? Themes.mainThemeColorAccent.shade300
                                          : colors.Colors().lightBlack(1),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: clientNote.active
                                            ? Colors.green
                                            : Get.isDarkMode
                                                ? colors.Colors().darkGrey(1)
                                                : colors.Colors()
                                                    .selectedCardBG,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Amount:"),
                                          Text(
                                            authUser.user['currency'] +
                                                "  " +
                                                clientNote.amount
                                                    .toStringAsFixed(2),
                                            style: TypographyStyles.title(16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Date - ",
                                            style: TypographyStyles.normalText(
                                              12,
                                              Get.isDarkMode
                                                  ? Themes.mainThemeColorAccent
                                                      .shade300
                                                  : colors.Colors()
                                                      .lightBlack(0.7),
                                            ),
                                          ),
                                          Text(
                                            "${DateFormat("yyyy-MM-dd").format(clientNote.startDate)}",
                                            style: TypographyStyles.boldText(
                                              12,
                                              Get.isDarkMode
                                                  ? Themes.mainThemeColorAccent
                                                      .shade100
                                                  : colors.Colors()
                                                      .lightBlack(1),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: authUser.role == 'trainer' &&
                                            clientNote.active,
                                        child: MaterialButton(
                                          onPressed: () {
                                            CommonConfirmDialog.confirm(
                                                    'Mark as Done')
                                                .then((value) async {
                                              if (value) {
                                                await clientNote
                                                    .deactivateClientNote();
                                                sortClientNotes();
                                              }
                                            });
                                          },
                                          color: Colors.green,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          padding: EdgeInsets.zero,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Done",
                                                style:
                                                    TypographyStyles.boldText(
                                                        14, Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // child: CupertinoSwitch(
                                        //   activeColor: Colors.green,
                                        //   value: clientNote.active,
                                        //   onChanged: (value) {
                                        //     clientNote.deactivateClientNote();
                                        //   },
                                        // ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        );
                      },
                    ),
                  )
                : SizedBox()),
           Obx(()=> Visibility(
              visible: activeNotes.length>0,
              child: SizedBox(
                height: 28,
              ),
            )),
            Obx(()=>Visibility(
              visible: completedNotes.length>0,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Completed Client Notes",
                  style: TypographyStyles.boldText(
                      16, Get.isDarkMode ? Colors.white : Colors.black),
                ),
              ),
            )),
            SizedBox(
              height: 16,
            ),
            Obx(() => completedNotes.isNotEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: completedNotes.length,
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          height: 20,
                        );
                      },
                      itemBuilder: (context, index) {
                        ClientNote clientNote = completedNotes[index];

                        return Container(
                          decoration: BoxDecoration(
                            color: Get.isDarkMode
                                ? colors.Colors().deepGrey(1)
                                : colors.Colors().lightCardBG,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        clientNote.service,
                                        style: TypographyStyles.boldText(
                                          16,
                                          Get.isDarkMode
                                              ? Themes
                                                  .mainThemeColorAccent.shade100
                                              : colors.Colors().lightBlack(1),
                                        ),
                                      ),
                                      Visibility(
                                        visible: authUser.role == 'trainer',
                                        child: IconButton(
                                          onPressed: () {
                                            CommonConfirmDialog.confirm(
                                                    'Delete')
                                                .then((value) async {
                                              if (value) {
                                                await clientNote.deleteClientNote();
                                                sortClientNotes();
                                              }
                                            });
                                          },
                                          icon: Icon(
                                            Icons.delete,
                                            color: Get.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 6,
                                  ),
                                  Text(
                                    clientNote.note,
                                    style: TypographyStyles.normalText(
                                      13,
                                      Get.isDarkMode
                                          ? Themes.mainThemeColorAccent.shade300
                                          : colors.Colors().lightBlack(1),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  ),
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: clientNote.active
                                            ? Colors.green
                                            : Get.isDarkMode
                                                ? colors.Colors().darkGrey(1)
                                                : colors.Colors()
                                                    .selectedCardBG,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 15),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("Amount:"),
                                          Text(
                                            authUser.user['currency'] +
                                                "  " +
                                                clientNote.amount
                                                    .toStringAsFixed(2),
                                            style: TypographyStyles.title(16),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "Date - ",
                                            style: TypographyStyles.normalText(
                                              12,
                                              Get.isDarkMode
                                                  ? Themes.mainThemeColorAccent
                                                      .shade300
                                                  : colors.Colors()
                                                      .lightBlack(0.7),
                                            ),
                                          ),
                                          Text(
                                            "${DateFormat("yyyy-MM-dd").format(clientNote.startDate)}",
                                            style: TypographyStyles.boldText(
                                              12,
                                              Get.isDarkMode
                                                  ? Themes.mainThemeColorAccent
                                                      .shade100
                                                  : colors.Colors()
                                                      .lightBlack(1),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Visibility(
                                        visible: authUser.role == 'trainer' &&
                                            clientNote.active,
                                        child: MaterialButton(
                                          onPressed: () {
                                            CommonConfirmDialog.confirm(
                                                    'Mark as Done')
                                                .then((value) async {
                                              if (value) {
                                                await clientNote
                                                    .deactivateClientNote();
                                                sortClientNotes();
                                              }
                                            });
                                          },
                                          color: Colors.green,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                          padding: EdgeInsets.zero,
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 25,
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                "Done",
                                                style:
                                                    TypographyStyles.boldText(
                                                        14, Colors.white),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // child: CupertinoSwitch(
                                        //   activeColor: Colors.green,
                                        //   value: clientNote.active,
                                        //   onChanged: (value) {
                                        //     clientNote.deactivateClientNote();
                                        //   },
                                        // ),
                                      ),
                                    ],
                                  ),
                                ],
                              )),
                        );
                      },
                    ),
                  )
                : SizedBox()),
            SizedBox(
              height: 16,
            ),
          ],
        ):LoadingAndEmptyWidgets.loadingWidget()));
  }
}
