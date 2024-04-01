import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/UI/SharedWidgets/CommonConfirmDialog.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'package:north_star/components/CheckButton.dart';
import 'package:north_star/components/Radios.dart';

import '../../../Styles/ThemeBdayaStyles.dart';
import '../../../components/Buttons.dart';

class CreateClass extends StatelessWidget {
  CreateClass();

  RxBool ready = true.obs;
  TextEditingController name = new TextEditingController();
  TextEditingController description = new TextEditingController();
  TextEditingController datetime = new TextEditingController();
  TextEditingController locationOrLink = new TextEditingController();
  RxInt type = 1.obs;
  DateTime? dateTimeObj = null;

  FocusNode nameNode = new FocusNode();
  FocusNode descriptionNode = new FocusNode();
  FocusNode datetimeNode = new FocusNode();
  FocusNode locationOrLinkNode = new FocusNode();

  @override
  Widget build(BuildContext context) {

    void saveClass()async{
      ready.value = false;
      if(dateTimeObj==null){
        showSnack("Failed","Date Time Required");
        ready.value = true;
        return;
      }
      Map data = {
        'class_name':name.text,
        'description':description.text,
        'shedule_time':dateTimeObj.toString(),
        'class_type':type.value,
        'location':locationOrLink.text
      };
      Map res = await httpClient.createClass(data);
      if(res['code']==200){
        ready.value = true;
        Get.back();
        print(res);
        showSnack("Success","Class Creation Success");
      }else{
        ready.value = true;
        showSnack("Class Creation Failed", res['data']['info']['message']);
      }
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Class'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                autofocus: true,
                controller: name,
                focusNode: nameNode,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(), label: Text('Name Of Class')),
                onSubmitted: (value) {
                  descriptionNode.requestFocus();
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextField(
                controller: description,
                focusNode: descriptionNode,
                maxLength: 250,
                maxLines: 2,
                decoration: InputDecoration(label:Text('Description')),
                onSubmitted: (value) {
                  datetimeNode.requestFocus();
                },
              ),
              SizedBox(
                height: 40,
              ),
              TextField(
                controller: datetime,
                focusNode: datetimeNode,
                readOnly: true,
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today_outlined),
                    label: Text('Select Date And Time')),
                onTap: () {
                  DatePickerBdaya.showDateTimePicker(
                    context,
                    theme: ThemeBdayaStyles.main(),
                    showTitleActions: true,
                    minTime: DateTime.now(),
                    // currentTime: dateTimeObj!=null?dateTimeObj:DateTime.now().add(Duration(minutes: 10)),
                    onChanged: (date) {
                      print('change $date');
                    },
                    onConfirm: (date) {
                      print('confirm ${date.toLocal()}');
                      datetime.text = DateFormat('yyyy-MM-dd HH:mm a').format(date).toString();
                      dateTimeObj = date;
                    },
                  );
                },
                onSubmitted: (value) {
                  locationOrLinkNode.nextFocus();
                },
              ),
              SizedBox(
                height: 10,
              ),
              Row(children: [
                Obx(()=> InkWell(
                    onTap: (){
                      type.value = 1;
                    },
                    radius: 0,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                      children: [
                        type.value==1?Radios.radioChecked2():Radios.radio(),
                        SizedBox(width: 10,),
                        Text('Physical')
                      ],
                                        ),
                    )),
                ),
                SizedBox(width: 40,),
                Obx(()=>InkWell(
                    onTap: (){
                      type.value = 2;
                    },
                    radius: 0,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                      children: [
                        type.value==2?Radios.radioChecked2():Radios.radio(),
                        SizedBox(width: 10,),
                        Text('Virtual')
                      ],
                                        ),
                    )),
                )
              ],)
              ,SizedBox(
                height: 10,
              ),
              Obx(()=> TextField(
                  controller: locationOrLink,
                  focusNode: locationOrLinkNode,
                  decoration: InputDecoration(
                      prefixIcon: Icon(type.value==1?Icons.location_on_outlined:Icons.http_sharp),
                      border: UnderlineInputBorder(), label: Text(type.value==1?'Location':'Link')),

                  onSubmitted: (value) {
                    // datetimeNode.requestFocus();
                  },
                ),
              ),
              SizedBox(
                height: 40,
              ),
              Buttons.outlineButton(
                  onPressed: () {
                    CommonConfirmDialog.confirm("Go Back").then((value) {
                      if (value){
                        Get.back();
                      }
                    });
                  }, label: 'Cancel', width: Get.width),
              SizedBox(
                height: 10,
              ),
              Obx(()=>Buttons.yellowFlatButton(
                    onPressed: saveClass, label: 'Save', width: Get.width,isLoading: !ready.value),
              ),
              SizedBox(height: 40,)
            ],
          ),
        ),
      ),
    );
  }
}
