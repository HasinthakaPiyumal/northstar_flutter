import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/Buttons.dart';

import '../../components/ImageUploader.dart';

class HelpAndSupportView extends StatefulWidget {
  final subFaq;
  HelpAndSupportView(this.subFaq, {Key? key}) : super(key: key);

  @override
  State<HelpAndSupportView> createState() => _HelpAndSupportViewState();
}

class _HelpAndSupportViewState extends State<HelpAndSupportView> {
  late dynamic _imageFile = false;
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    void addComplain() async{
      ready.value = false;
      dynamic data = {
      'description': descriptionController.value,
      'main_faqId': widget.subFaq['mainfaq_id'],
      'sub_faqId': widget.subFaq['id'],
      };
      if(descriptionController.value ==""){
        ready.value = true;
        showSnack("Failed","Description can not be empty" );
        return;
      }

      dynamic res = await httpClient.addHelpContact(data, _imageFile!=false?_imageFile:null);
      print(res);
      if(res['code']==200){
        ready.value = true;
        Get.back();
        showSnack("Success", "Your submission recorded successfully");
      }else{
        ready.value = true;
        showSnack("Failed","Something went wrong");
      }

    }
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.subFaq["title"]}'.capitalizeFirst.toString()),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[ Text(
              widget.subFaq["description"],
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                height: 0,
              ),
            ),
              SizedBox(height: 60,),
              TextField(
                maxLines: 6,
                controller: descriptionController,
              ),
              SizedBox(height: 20,),
              ImageUploader(handler: (img) {
                setState(() {
                  _imageFile = img;
                });
              }),
              SizedBox(height: 20,),
              Obx(()=> Center(child: Buttons.yellowFlatButton(onPressed: addComplain,label: "Submit",isLoading: !ready.value)))
            ],
          ),
        ),
      ),
    );
  }
}
