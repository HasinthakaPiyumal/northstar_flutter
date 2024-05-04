import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:north_star/Styles/AppColors.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/TypographyStyles.dart';

import '../../components/Buttons.dart';

class DoctorSettings extends StatelessWidget {
  const DoctorSettings({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Rx<DateTime> date = new DateTime.now().add(Duration(days: 5)).obs;
    Rx<TimeOfDay> time = new TimeOfDay.now().obs;
    RxList list = [].obs;
    TextEditingController dateController = new TextEditingController(text: DateTime.now().toString().split(' ')[0]);
    TextEditingController timeController = new TextEditingController(
        text: TimeOfDay.now().hour.toString() + ':' + TimeOfDay.now().minute.toString()
    );

    void pickDateDialog() {
      showDatePicker(
          context: context,
          initialDate: date.value,
          firstDate: DateTime.now().add(Duration(days: 2)),
          lastDate: DateTime(2100),
          builder: (BuildContext context, Widget? child) {
            return child!;
          }).then((pickedDate) {
        if (pickedDate == null) {
          return;
        }
        date.value = pickedDate;
        dateController.text = pickedDate.toString().split(' ')[0];
      });
    }
    void pickTimeDialog() {
      showTimePicker(
          context: context,
          initialTime: time.value,
          builder: (BuildContext context, Widget? child) {
            return child!;
          }).then((pickedTime) {
        if (pickedTime == null) {
          return;
        }
        time.value = pickedTime;
        timeController.text = pickedTime.hour.toString() + ':' + pickedTime.minute.toString();
      });
    }

    void addDays(){
      Get.defaultDialog(
          radius: 10,
          title: 'Add Availability',
          titlePadding: const EdgeInsets.only(top: 16, bottom: 0),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onTap: pickTimeDialog,
                controller: timeController,
                decoration: InputDecoration(
                  hintText: 'Time',
                  border: UnderlineInputBorder(
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: SvgPicture.asset("assets/svgs/birthday.svg",width: 14,height: 14,color: AppColors().getPrimaryColor(reverse: true),),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                onTap: pickDateDialog,
                controller: dateController,
                decoration: InputDecoration(
                  hintText: 'Date',
                  border: UnderlineInputBorder(
                  ),
                  prefixIcon: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: SvgPicture.asset("assets/svgs/birthday.svg",width: 14,height: 14,color: AppColors().getPrimaryColor(reverse: true),),
                  ),
                ),
              ),
              SizedBox(height: 16,),
              Row(
                children: [
                  Expanded(child: Buttons.outlineButton(onPressed: (){

                    Get.back();
                  },label: "Cancel")),
                  SizedBox(width: 10,),
                  Expanded(child: Buttons.yellowFlatButton(onPressed: (){
                    list.add({
                      'date': date.value,
                      'time': time.value,
                    });
                    Get.back();
                  },label: "Save"),),
                ],
              )
            ],
          ),
          // actions: [
          //   Container(
          //     height: 52,
          //     width: Get.width,
          //     child: ElevatedButton(
          //         style: ButtonStyles.primaryButton(),
          //         onPressed: (){
          //           list.add({
          //             'date': date.value,
          //             'time': time.value,
          //           });
          //           Get.back();
          //         }, child: Text('Save'.toUpperCase())),
          //   ),
          //   Container(
          //     width: Get.width,
          //     height: 52,
          //     child: ElevatedButton(
          //         style: ButtonStyles.bigGreyButton(),
          //         onPressed: (){
          //           Get.back();
          //         }, child: Text('Cancel'.toUpperCase(),)),
          //   ),
          // ]
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available days', style: TypographyStyles.title(18)),
                IconButton(onPressed: (){addDays();}, icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentColor,
                    borderRadius: BorderRadius.circular(5)
                  ),
                  child: Center(
                    child: Icon(Icons.add,color: AppColors.textOnAccentColor,),
                  ),
                ))
              ],
            ),
            Expanded(
              child: Obx(()=>ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(list[index]['date'].toString().substring(0,10)),
                      subtitle: Text(list[index]['time'].format(context)),
                      trailing: IconButton(
                        icon: Icon(Icons.close),
                        onPressed: (){
                          list.removeAt(index);
                        },
                      ),
                    ),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}
