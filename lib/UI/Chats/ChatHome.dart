import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/IcoMoon.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/UI/Chats/ChatThread.dart';
import 'package:north_star/UI/Chats/NewChat.dart';
import 'package:north_star/UI/Chats/NewSingleChat.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/UI/SharedWidgets/LoadingAndEmptyWidgets.dart';
import 'package:simple_speed_dial/simple_speed_dial.dart';

class ChatHome extends StatelessWidget {
  const ChatHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    RxBool ready = false.obs;
    RxList tempChats = [].obs;
    RxList chats = [].obs;



    void getFirebaseChats() async{
      ready.value = false;
      if(tempChats.length > 0){
        tempChats.forEach((element) async{
        element['unread_count'] = 0;
        QuerySnapshot firebaseChats = await firestore.collection('chats').doc(element['chat_id']).collection('messages').get();
        int chatUnreadCount = 0;
        firebaseChats.docs.forEach((QueryDocumentSnapshot doc) async{
          if(doc.get('has_read') == false && doc.get('sender_id') != authUser.id) {
            chatUnreadCount++;
          }
        });
        element['unread_count'] = chatUnreadCount;
        chats.add(element);
        ready.value = tempChats.length == chats.length;
      });
      
      } else {
        ready.value = true;
      }
      
    }



    void getChats() async {
      ready.value = false;
      Map res = await httpClient.getMyChats();
      if (res['code'] == 200) {
        chats.clear();
        tempChats.value = res['data'];
        print(tempChats.length);
        getFirebaseChats();
      } else {
        ready.value = true;
      }
    }

    getChats();

    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
      ),
      floatingActionButton: authUser.role == 'trainer' ? SpeedDial(
        child: Icon(IcoMoon.messages, color: Themes.mainThemeColorAccent.shade100),
        closedBackgroundColor: Themes.mainThemeColorAccent,
        openBackgroundColor: Themes.mainThemeColor.shade600,
        labelsBackgroundColor: Themes.mainThemeColorAccent,
        labelsStyle: TextStyle(
          color: Get.isDarkMode ? Colors.white : Colors.white,
        ),
        speedDialChildren: <SpeedDialChild>[
          SpeedDialChild(
            child: Icon(Icons.people, size: 22, color: Themes.mainThemeColorAccent.shade100,),
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Themes.mainThemeColorAccent,
            label: 'Direct Chat',
            closeSpeedDialOnPressed: true,
            onPressed: () {
              Get.to(()=>NewSingleChat())?.then((value){
                getChats();
              });
            },
          ),
          SpeedDialChild(
            child: Icon(Icons.person,size: 22, color: Themes.mainThemeColorAccent.shade100,),
            foregroundColor: Theme.of(context).primaryColor,
            backgroundColor: Themes.mainThemeColorAccent,
            label: 'Group Chat',
            closeSpeedDialOnPressed: true,
            onPressed: () {
              Get.to(()=>NewChat())?.then((value){
                getChats();
              });
            },
          ),

        ],
      ) : null,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Obx(() => ready.value & (tempChats.length == chats.length)
            ? ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            return Container(
              padding: EdgeInsets.all(4),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  child: Obx(()=>ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onTap: () {
                      print(chats[index].toString());
                      Get.to(() => ChatThread(
                        name: chats[index]['title'],
                        chatID: chats[index]['chat_id'].toString(),
                        chatData: chats[index],
                      ))?.then((value) => getChats());
                    },
                    title: Text(chats[index]['title']),
                    subtitle: Text(chats[index]['updated_at'].split('T')[0]),
                    trailing: chats[index]['unread_count'] > 0 ? Card(
                      color: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(64),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(4),
                        child: Text(chats[index]['unread_count'].toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ): Text(''),
                  )),
                  onLongPress: authUser.id == chats[index]['owner_id'] ?  (){
                    CommonConfirmDialog.confirm('Delete').then((value){
                      if (value) {
                        httpClient.deleteChat(chats[index]['chat_id']).then((value){
                          firestore.collection('chats').doc(chats[index]['chat_id']).delete();
                          getChats();
                        });
                      }
                    });
                  }: null,
                ),
              ),
            );
          },
        ): Center(
          child: LoadingAndEmptyWidgets.loadingWidget(),
        )),
      ),
    );
  }
}
