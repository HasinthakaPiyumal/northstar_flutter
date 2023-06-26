import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Utils/PopUps.dart';

class AddMember extends StatelessWidget {
  const AddMember({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;


    TextEditingController email = TextEditingController();

    void sendInvite() async {
        ready.value = false;

        Map res = await httpClient.inviteMember({
          'email': email.text,
          'trainer_id': authUser.id.toString(),
          'trainer_type': authUser.user['trainer']['type'],
        });

        if (res['code'] == 200) {
          Get.back();
          showSnack('Info', res['data']['message']);
          print(res);
          ready.value = true;
        } else {
          showSnack('Error!', 'Client does not exist or something went wrong!');
          ready.value = true;
        }
    }



    return Scaffold(
      appBar: AppBar(
        title: Text('Add Member'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextFormField(
                controller: email,
                decoration: InputDecoration(
                    hintText: 'Email',
                    label: Text('Email'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(
                        color: Color(0xFFD2D2D2),
                      ),
                    ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(
                      color: Color(0xFFD2D2D2),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Container(
                width: Get.width,
                height: 58,
                child: Obx(()=> ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      shape: Themes().roundedBorder(12),
                      backgroundColor: Color(0xFF1C1C1C)),
                  child: ready.value ? Text(
                    'Send Request',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ) : Center(child: CircularProgressIndicator()),
                  onPressed: () {
                    if(email.text.isEmail){
                      sendInvite();
                    } else {
                      showSnack('Error!', 'Please enter a valid email');
                    }
                  },
                )),
              )
            ],
          ),
        ),
      ),

    );
  }
}
