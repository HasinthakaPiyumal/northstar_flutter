import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:north_star/Utils/PopUps.dart';

class AddNewClientToChat extends StatelessWidget {
  const AddNewClientToChat({Key? key, required this.chatID}) : super(key: key);
  final String chatID;
  @override
  Widget build(BuildContext context) {
    RxBool ready = false.obs;
    RxMap chatData = {}.obs;
    List clientsIndex = [];

    void getChatData() async{
      ready.value = false;
      Map res = await httpClient.getChatData(chatID);
      if(res['code'] == 200){
        chatData.value = res['data'];
        clientsIndex = [];
        chatData['clients'].forEach((element) {
          clientsIndex.add(element['client_id'].toString());
        });
        ready.value = true;
      }
    }

    Future<List> searchMembers(pattern) async {
      Map res = await httpClient.searchMembers(pattern);
      if (res['code'] == 200) {
        print(res['data']);
        return res['data'];
      } else {
        return [];
      }
    }

    void showAddNewClient() async{
      Get.defaultDialog(
        radius: 4,
        title: 'Add New Member to Chat',
        content: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            children: [
              TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                    autofocus: true,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search Member...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    )
                ),
                suggestionsCallback: (pattern) async {
                  print(pattern);
                  return await searchMembers(pattern);
                },
                itemBuilder: (context, suggestion) {
                  var jsonObj = jsonDecode(jsonEncode(suggestion));

                  return ListTile(
                    title: Text(jsonObj['user']['name']),
                    subtitle: Text(jsonObj['user']['email']),
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(HttpClient.s3BaseUrl + jsonObj['user']['avatar_url']),
                    ),
                  );
                },
                onSuggestionSelected: (suggestion) {
                  var jsonObj = jsonDecode(jsonEncode(suggestion));
                  print(jsonObj['user_id'].toString());
                  if(!clientsIndex.contains(jsonObj['user_id'].toString())){
                    Get.back();
                    CommonConfirmDialog.confirm('Add ${jsonObj['user']['name']}').then((value) async{
                      if (value) {
                        if (value) {
                          Map res = await httpClient.addOrRemoveClientFromChat({
                            'chat_id': chatData['chat_id'],
                            'client_id': jsonObj['user_id'],
                            'action': 'ADD',
                            'title': chatData['title'],
                          });
                          print(res);
                          getChatData();
                        }
                      }
                    });
                  } else {
                    showSnack('Already Added!', 'The Client you are trying to add is already in this chat.');
                  }
                },
              ),
            ],
          ),
        )
      );
    }

    getChatData();


    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Members'),
      ),
      body: Obx(()=> ready.value ? SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text('Members', style: TypographyStyles.title(18)),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      showAddNewClient();
                    },
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: chatData['clients'].length,
                itemBuilder: (context, index) {

                  if(chatData['clients'][index]['client_id'].toString() == authUser.id.toString()) {
                    return Container();
                  }

                  return ListTile(
                    title: Text(chatData['clients'][index]['user']['name']),
                    subtitle: Text(chatData['clients'][index]['user']['email']),
                    leading: CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(HttpClient.s3BaseUrl + chatData['clients'][index]['user']['avatar_url']),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.group_remove, color: Colors.red),
                      onPressed: () {
                        CommonConfirmDialog.confirm('Remove').then((value) async{
                          if (value) {
                            Map res = await httpClient.addOrRemoveClientFromChat({
                              'chat_id': chatData['chat_id'],
                              'client_id': chatData['clients'][index]['client_id'],
                              'action': 'REMOVE',
                              'title': chatData['title'],
                            });

                            print(res);
                            getChatData();

                          }
                        });
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ): Center(child: LoadingAndEmptyWidgets.loadingWidget())),
    );
  }
}
