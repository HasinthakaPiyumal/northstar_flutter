import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/UI/Chats/AddNewClientToChat.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:north_star/Utils/PopUps.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../Styles/AppColors.dart';

class ChatThread extends StatelessWidget {
  const ChatThread(
      {Key? key,
      required this.name,
      required this.chatID,
      required this.chatData})
      : super(key: key);

  final String name;
  final String chatID;
  final Map chatData;

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    RxBool sending = false.obs;
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    TextEditingController message = new TextEditingController();

    TextEditingController title =
        new TextEditingController(text: chatData['title']);
    TextEditingController description =
        new TextEditingController(text: chatData['description']);

    void saveChat() async {
      Map res = await httpClient.editChat({
        'title': title.text,
        'description': description.text,
        'chat_id': chatID,
      });

      if (res['code'] == 200) {
        await firestore.collection('chats').doc(chatID).update({
          'title': title.text,
          'description': description.text,
        });

        Get.back();
        Get.back();
        showSnack('Success!', 'Chat updated successfully');
      } else {
        showSnack('Error!', 'Something went wrong');
      }
    }

    void sendMessage() async {
      sending.value = true;
      firestore.collection('chats').doc(chatID).collection('messages').add({
        'message': message.text,
        'sender_id': authUser.id,
        'sender_name': authUser.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'has_read': false,
        'is_file': false,
      }).then((value) async {
        String tempMSG = message.text.toString();
        message.clear();
        sending.value = false;
        List users = [];
        chatData['clients'].forEach((client) {
          if (client['client_id'].toString() != authUser.id.toString()) {
            users.add(client['client_id'].toString());
          }
        });
        if (authUser.role == 'client') {
          users.add(chatData['owner_id'].toString());
        }

        await httpClient.newChatNotification({
          'clients': users,
          'title': authUser.name + ': ' + tempMSG.toString(),
        });
      });
    }

    void sendAttachment(String url) async {
      firestore.collection('chats').doc(chatID).collection('messages').add({
        'message': url,
        'sender_id': authUser.id,
        'sender_name': authUser.name,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'has_read': false,
        'is_file': true,
      }).then((value) async {
        String tempMSG = message.text.toString();
        message.clear();
        List users = [];
        if(chatData['clients']!=null) {
          chatData['clients'].forEach((client) {
            if (client['client_id'].toString() != authUser.id.toString()) {
              users.add(client['client_id'].toString());
            }
          });
          if (authUser.role == 'client') {
            users.add(chatData['owner_id'].toString());
          }

          await httpClient.newChatNotification({
            'clients': users,
            'title': authUser.name + ': ' + tempMSG.toString(),
          });
        }

        Get.back();
      });
    }

    void uploadFile(File file) async {
      FirebaseStorage storage = FirebaseStorage.instance;
      String fileExtention = '.' + file.path.split('/').last.split('.').last;
      String filePath =
          'attachments/' + chatID + '/' + Uuid().v4() + fileExtention;
      print(filePath);
      Reference ref = storage.ref(filePath);
      await ref.putFile(file);
      String url = await ref.getDownloadURL();
      sendAttachment(url);
    }

    void deleteMessage(doc) async {
      CommonConfirmDialog.confirm('Delete').then((value) async {
        if (value) {
          if (doc['is_file']) {
            await FirebaseStorage.instance.refFromURL(doc['message']).delete();
          }
          await firestore
              .collection('chats')
              .doc(chatID)
              .collection('messages')
              .doc(doc.id)
              .delete();
        }
      });
    }

    void askToAttach(File file) async {
      Get.defaultDialog(
        radius: 8,
        title: 'Attach File',
        barrierDismissible: false,
        content: Text('Are you sure you want to attach this file?'),
        textConfirm: 'Yes',
        textCancel: 'No',
        onConfirm: () {
          Get.back();
          uploadFile(file);
          Get.defaultDialog(
            barrierDismissible: false,
            radius: 8,
            title: 'Uploading File',
            content: Container(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      );
    }

    void selectFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        File file = File(result.files.single.path.toString());
        askToAttach(file);
      }
    }

    void showAndEditChatDetails() async {
      Get.bottomSheet(Container(
        width: Get.width,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                Text('Chat Details', style: TypographyStyles.title(18)),
                SizedBox(height: 16),
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
                Container(
                  height: 56,
                  width: Get.width,
                  child: ElevatedButton(
                    onPressed: () {
                      if (title.text.isEmpty || description.text.isEmpty) {
                        showSnack('Error!', 'Please fill all the fields!');
                      } else {
                        saveChat();
                      }
                    },
                    style: ButtonStyles.primaryButton(),
                    child: Obx(() => ready.value
                        ? Text('Save Chat')
                        : CircularProgressIndicator()),
                  ),
                )
              ],
            ),
          ),
        ),
      ));
    }

    return Scaffold(
      // backgroundColor: Get.isDarkMode ? Color(0xFF232323) : Colors.white,
      appBar: AppBar(
        toolbarHeight: 64,
        // backgroundColor: Get.isDarkMode ? Color(0xFF232323) : Colors.white,
        actions: [
          Visibility(
            visible: authUser.role == 'trainer' && chatData['type'] == 'GROUP',
            child: IconButton(
                onPressed: () {
                  showAndEditChatDetails();
                },
                icon: Icon(Icons.info_outline_rounded)),
          ),
          Visibility(
            visible: authUser.role == 'trainer' && chatData['type'] == 'GROUP',
            child: IconButton(
                onPressed: () {
                  Get.to(() => AddNewClientToChat(chatID: chatID));
                },
                icon: Icon(Icons.person_add)),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text('Attach File'),
                value: 1,
                onTap: () {
                  selectFile();
                },
              ),
            ],
          )
        ],
        title: Text('$name'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('chats')
                  .doc(chatID)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data?.docs.length,
                  itemBuilder: (context, index) {
                    var dt = DateTime.fromMillisecondsSinceEpoch(
                        snapshot.data?.docs[index]['timestamp']);

                    if (snapshot.data?.docs[index]['has_read'] == false) {
                      if (snapshot.data?.docs[index]['sender_id'].toString() !=
                          authUser.id.toString()) {
                        firestore
                            .collection('chats')
                            .doc(chatID)
                            .collection('messages')
                            .doc(snapshot.data?.docs[index].id)
                            .update({
                          'has_read': true,
                        });
                      }
                    }

                    return Row(
                      mainAxisAlignment:
                          snapshot.data?.docs[index]['sender_id'] == authUser.id
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                      children: [
                        Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                          width: Get.width * 0.8,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.only(
                                  topLeft: snapshot.data?.docs[index]
                                              ['sender_id'] ==
                                          authUser.id
                                      ? Radius.circular(12)
                                      : Radius.circular(0),
                                  bottomRight: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                  topRight: snapshot.data?.docs[index]
                                              ['sender_id'] ==
                                          authUser.id
                                      ? Radius.circular(0)
                                      : Radius.circular(12),
                                ),
                              ),
                              elevation: 0,
                              color: snapshot.data?.docs[index]['sender_id'] ==
                                      authUser.id
                                  ? Get.isDarkMode
                                      ? Color(0xFF887157)
                                      : Color(0xFFFCE6CA)
                                  : Get.isDarkMode
                                      ? colors.Colors().deepGrey(1)
                                      : colors.Colors().lightWhite(1),
                              child: InkWell(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 15, horizontal: 15),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        snapshot.data?.docs[index]
                                            ['sender_name'],
                                        style: TypographyStyles.boldText(
                                            14,
                                            snapshot.data?.docs[index]
                                                        ['sender_id'] ==
                                                    authUser.id
                                                ? Get.isDarkMode
                                                    ? Colors.white
                                                    : Colors.black54
                                                : Get.isDarkMode
                                                    ? Color(0xFFF6B669)
                                                    : Colors.black54),
                                      ),
                                      SizedBox(height: 4),
                                      snapshot.data?.docs[index]['is_file']
                                          ? ElevatedButton(
                                              onPressed: () {
                                                launchUrl(
                                                    Uri.parse(snapshot
                                                            .data?.docs[index]
                                                        ['message']),
                                                    mode: LaunchMode
                                                        .externalApplication);
                                              },
                                              child: Text('View Attachment'),
                                            )
                                          : Text(snapshot.data?.docs[index]
                                                  ['message'] ??
                                              ''),
                                      SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${DateFormat("dd-MMM-yyyy").format(dt)} | ${DateFormat("HH:mm").format(dt)}",
                                            style: TypographyStyles.boldText(
                                                12,
                                                Get.isDarkMode
                                                    ? Colors.white38
                                                    : Colors.black38),
                                          ),
                                          SizedBox(width: 4),
                                          snapshot.data?.docs[index]
                                                      ['has_read'] ==
                                                  false
                                              ? Icon(
                                                  Icons
                                                      .check_circle_outline_rounded,
                                                  size: 14,
                                                  color: Get.isDarkMode
                                                      ? Colors.white38
                                                      : Colors.black54)
                                              : Icon(Icons.check_circle_rounded,
                                                  size: 14,
                                                  color: Get.isDarkMode
                                                      ? Colors.white
                                                      : Colors.black54),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: snapshot.data?.docs[index]
                                              ['sender_id'] ==
                                          authUser.id
                                      ? Radius.circular(12)
                                      : Radius.circular(0),
                                  bottomRight: Radius.circular(12),
                                  bottomLeft: Radius.circular(12),
                                  topRight: snapshot.data?.docs[index]
                                              ['sender_id'] ==
                                          authUser.id
                                      ? Radius.circular(0)
                                      : Radius.circular(12),
                                ),
                                onLongPress: snapshot.data?.docs[index]
                                            ['sender_id'] ==
                                        authUser.id
                                    ? () {
                                        deleteMessage(
                                            snapshot.data?.docs[index]);
                                      }
                                    : null,
                              )),
                        )
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Container(
            // height: 96,
            width: Get.width,
            child: Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    // height: 56,
                    width: Get.width - 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          20.0), // Adjust the radius as needed
                    ),
                    child: TextField(
                      controller: message,
                      maxLines: null,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor:
                            Get.isDarkMode ? Color(0xFF272D38) : Colors.white,
                        focusColor: Color(0xFF333333),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black, // Set the border color
                            width: 0.0, // Set the border width
                          ),
                          borderRadius: BorderRadius.circular(
                              5.0), // Adjust the radius as needed
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Colors.black, // Set the border color
                            width: 0.0, // Set the border width
                          ),
                          borderRadius: BorderRadius.circular(
                              5.0), // Adjust the radius as needed
                        ),
                        hintText: 'Type your message...',
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Obx(() => Container(
                      height: 48,
                      width: 48,
                      child: sending.value
                          ? Center(
                            child: Container(
                                height: 30,
                                width: 30,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4.0,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.accentColor),
                                ),
                              ),
                          )
                          : Material(
                              borderRadius: BorderRadius.circular(100),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(100),
                                onTap: () {
                                  if (message.text.isNotEmpty) {
                                    sendMessage();
                                  }
                                },
                                child: Ink(
                                  padding: EdgeInsets.all(10),
                                  decoration: ShapeDecoration(
                                    shape: CircleBorder(),
                                    color: AppColors.accentColor,
                                  ),
                                  child: Icon(
                                    Icons.send,
                                    color: AppColors.primary2Color,
                                  ),
                                ),
                              ),
                            )))
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}
