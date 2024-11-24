import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
class NewSingleChat extends StatelessWidget {
  const NewSingleChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    RxMap selectedClient = {}.obs;

    Future<List> searchMembers(pattern) async {
      Map res = await httpClient.searchMembers(pattern);
      if (res['code'] == 200) {
        return res['data'];
      } else {
        return [];
      }
    }


    void createChat() async{
      ready.value = false;
      var chat =  await firestore.collection('chats').add({
        'title': selectedClient['user']['name'],
        'description': 'Chat with' + selectedClient['user']['name'],
        'owner_id': authUser.id,
      });

      List idList = [];
      idList.add(selectedClient['user_id'].toString());
      idList.add(authUser.id.toString());

      Map res = await httpClient.newChat({
        'owner_id': authUser.id,
        'chat_id': chat.id,
        'title': selectedClient['user']['name'].split(' ')[0] + ' And ' + authUser.name.split(' ')[0],
        'description': 'Chat With' + selectedClient['user']['name'],
        'clients': jsonEncode(idList),
        'type':'SINGLE'
      });
      if (res['code'] == 200) {
        Get.back();
        showSnack('Success!', 'Chat created successfully!');
      } else {
        print(res);
        showSnack('Error!', res.toString());
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('New Single Chat'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Text('Select Member', style: TypographyStyles.title(18)),
                ],
              ),
              SizedBox(height: 16),
              TypeAheadField(
    builder: (context, controller, focusNode){
    return TextField(
    controller: controller,
    focusNode: focusNode,
    autofocus: true,

                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search Member...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
                    )
                );},
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
                onSelected: (suggestion) {
                  var jsonObj = jsonDecode(jsonEncode(suggestion));
                  selectedClient.value = jsonObj;
                },
              ),
              SizedBox(height: 16),

              Obx(()=> selectedClient.isNotEmpty ? Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider('https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/avatars/' + selectedClient.value['user']['avatar_url']),
                  ),
                  title: Text(selectedClient.value['user']['name']),
                  subtitle: Text(selectedClient.value['user']['email']),
                ),
              ): SizedBox()),

              SizedBox(height: 16),

              Container(
                height: 56,
                  width: Get.width,
                child: ElevatedButton(
                  onPressed: () {
                    if(selectedClient.isEmpty){
                      showSnack('Error!', 'Please Select a Member!');
                    } else {
                      createChat();
                    }
                  },
                  style: ButtonStyles.primaryButton(),
                  child: Obx(()=> ready.value ? Text('Create Chat') : CircularProgressIndicator()),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
