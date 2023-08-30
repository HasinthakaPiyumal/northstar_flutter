import 'package:flutter/material.dart' hide DatePickerTheme;
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:get/get.dart';
import 'package:north_star/Controllers/LocalNotificationsController.dart';
import 'package:intl/intl.dart';
import 'package:north_star/Models/AuthUser.dart';
import 'package:north_star/Models/HttpClient.dart';
import 'package:north_star/Styles/ButtonStyles.dart';
import 'package:north_star/Styles/ThemeBdayaStyles.dart';
import 'package:north_star/Styles/Themes.dart';
import 'package:north_star/Styles/TypographyStyles.dart';
import 'package:north_star/Utils/PopUps.dart';
import 'dart:math';
import 'package:north_star/Utils/CustomColors.dart' as colors;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AddToDos extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    RxBool ready = true.obs;
    RxInt noteCounter = 0.obs;
    TextEditingController todo = TextEditingController();
    TextEditingController notes = TextEditingController();
    TextEditingController endDate = TextEditingController();

    late DateTime selectedDate;

    void addTodo() async{
      ready.value = false;
      print(authUser.id);
      Map res = await httpClient.saveTodo({
        'user_id': authUser.id.toString(),
        'todo': todo.text,
        'notes': notes.text,
        'endDate': endDate.text
      });

      if (res['code'] == 200) {
        Get.back();
        Random random = Random();
        await LocalNotificationsController.showLocalNotification(
            id: random.nextInt(1000000),
            title: todo.text,
            body: notes.text,
            scheduledDate: DateTime.parse(endDate.text)
        );

        showSnack('TODO Saved!', 'Your Todo has been saved!');
      } else {
        print(res);
        showSnack('Something went wrong!', 'Please try again.');
        ready.value = true;
      }
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: Text('Add a ToDo',style: TypographyStyles.title(20)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: todo,

                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.content_paste),
                  labelText: 'ToDo',
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  )
                ),
              ),
              SizedBox(height: 36),
              Obx(()=>TextField(
                controller: notes,

                onChanged: (val){
                  noteCounter.value = val.length;
                },

                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 40,horizontal: 20),
                  labelText: 'Notes',
                  counter: Text(noteCounter.toString() + '/512'),
                ),
              )),
              SizedBox(height: 16),
              TextField(
                controller: endDate,
                onTap: () {

                  DatePickerBdaya.showDateTimePicker(
                    context,
                    theme: ThemeBdayaStyles.main(),
                    showTitleActions: true,
                    minTime: DateTime.now().add(Duration(hours: 1)),
                    onChanged: (date) {
                      print('change $date');
                    },
                    onConfirm: (date) {
                      print('confirm $date');
                      endDate.text = date.toString();
                    },
                  );
                },
                readOnly: true,
                decoration: InputDecoration(
                  labelText: "End Date",
                  prefixIcon: Icon(Icons.calendar_today_rounded),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 16),
              Container(
                height: 44,
                width: Get.width,
                child: ElevatedButton(
                  style: ButtonStyles.bigFlatYellowButton(),
                  onPressed: () {
                    addTodo();
                  },
                  child: Obx(() => ready.value ? Text('SAVE',
                    style: TextStyle(
                      color: Color(0xFF1B1F24),
                      fontSize: 20,
                      fontFamily: 'Bebas Neue',
                      fontWeight: FontWeight.w400,
                    ),
                  ) : Center(
                    child: CircularProgressIndicator(),
                  )),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
