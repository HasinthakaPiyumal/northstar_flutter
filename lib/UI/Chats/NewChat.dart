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
class NewChat extends StatelessWidget {
  const NewChat({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    TextEditingController title = TextEditingController();
    TextEditingController description = TextEditingController();
    RxList selectedClients = [].obs;

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
        'title': title.text,
        'description': description.text,
        'owner_id': authUser.id,
      });

      List idList = [];
      selectedClients.forEach((element) {
        idList.add(element['user_id'].toString());
      });
      idList.add(authUser.id.toString());

      Map res = await httpClient.newChat({
        'owner_id': authUser.id,
        'chat_id': chat.id,
        'title': title.text,
        'description': description.text,
        'clients': jsonEncode(idList),
        'type':'GROUP'
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
        title: Text('New Chat'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: title,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: description,
                decoration: InputDecoration(
                  labelText: 'Description',
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Text('Add Members to Group', style: TypographyStyles.title(18)),
                ],
              ),
              SizedBox(height: 16),
              TypeAheadField(
                textFieldConfiguration: TextFieldConfiguration(
                    autofocus: true,

                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      labelText: 'Search Members...',
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
                  var already = selectedClients.firstWhereOrNull((element) => element['user_id'] == jsonObj['user_id']);
                  if (already == null){
                    selectedClients.add(jsonObj);
                    print(jsonObj);
                  } else {
                    print('already added');
                  }
                },
              ),
              SizedBox(height: 16),

              Obx(()=> ListView.builder(
                shrinkWrap: true,
                itemCount: selectedClients.length,
                itemBuilder: (context, index) {
                  var jsonObj = jsonDecode(jsonEncode(selectedClients[index]));
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: CachedNetworkImageProvider('https://north-star-storage-new.s3.ap-southeast-1.amazonaws.com/avatars/' + jsonObj['user']['avatar_url']),
                      ),
                      title: Text(jsonObj['user']['name']),
                      subtitle: Text(jsonObj['user']['email']),
                    ),
                  );
                },
              )),

              SizedBox(height: 16),

              Container(
                height: 56,
                  width: Get.width,
                child: ElevatedButton(
                  onPressed: () {
                    if(title.text.isEmpty || description.text.isEmpty || selectedClients.length == 0){
                      showSnack('Error!', 'Please fill all the fields!');
                    } else {
                      createChat();
                    }
                  },
                  style: ButtonStyles.bigBlackButton(),
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
