import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Controllers/ClientNotesController.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClientNotes/CreateClientNotes.dart';
import 'package:north_star/UI/HomeWidgets/HomeWidgetClientNotes/SelectedClientNotes.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;

class HomeWidgetClientNotes extends StatelessWidget {

  const HomeWidgetClientNotes({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    ClientNotesController.getClientNotes();

    return Scaffold(
      appBar: AppBar(
        title: Text('Income & Expenses'),
      ),
      floatingActionButton: authUser.role == 'trainer' ? FloatingActionButton(
        onPressed: (){
          Get.to(() => CreateClientNotes())?.then((value) {
            ClientNotesController.getClientNotes();
          });
        },
        backgroundColor: colors.Colors().lightBlack(1),
        child: Icon(Icons.add, size: 30, color: Themes.mainThemeColorAccent.shade100),
      ): null,
      body: Obx(() => ClientNotesController.clientNotes.length > 0 ? Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView.separated(
          itemCount: ClientNotesController.getUniqueClientsCount(),
          separatorBuilder: (context, index) {
            return SizedBox(height: 4);
          },
          itemBuilder: (context, index){

            NumberFormat valueFmt = NumberFormat("###,###,###.##");
            Map<String,dynamic> client = ClientNotesController.getUniqueClientsWithIncome()[index];

            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5)
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)
                ),
                onTap: (){
                  Get.to(() => SelectedClientNote(clientId: client['client']['id']));
                },
                leading: CircleAvatar(
                  radius: 25,
                  backgroundImage: CachedNetworkImageProvider(HttpClient.s3BaseUrl + client['client']['avatar_url']),
                ),
                title: Text("${client['client']['name']}"),
                subtitle: Text("MVR ${valueFmt.format(client['income'])}"),
                trailing: Chip(
                  label: Text("${ClientNotesController.getClientNotesByClientId(client['client']['id']).length}"),
                  backgroundColor: AppColors.accentColor,
                  labelStyle: TypographyStyles.boldText(14, AppColors.textOnAccentColor),
                )
              ),
            );

          },
        ),
      ): LoadingAndEmptyWidgets.emptyWidget()),
    );
  }
}
